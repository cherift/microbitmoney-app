import 'package:bit_money/models/reception_model.dart';
import 'package:bit_money/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceptionStats {
  final int weeklyReceptionCount;
  final double monthlyAmountTotal;
  final String currencySymbol;

  ReceptionStats({
    required this.weeklyReceptionCount,
    required this.monthlyAmountTotal,
    required this.currencySymbol,
  });
}

class ReceptionService {
  final ApiClient _apiClient ;

  ReceptionService() : _apiClient = ApiClient();

  String formatAmount(double amount) {
    final formatter = NumberFormat('#,###', 'fr');
    return formatter.format(amount);
  }

  Future<List<Reception>> getReceptions() async {
    try {
      final response = await _apiClient.get('/receptions');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> receptionsList = data['receptions'];
        return receptionsList.map((json) => Reception.fromJson(json)).toList();
      } else {
        debugPrint('Impossible d\'accéder aux réceptions');
      }
    } catch (e) {
      debugPrint('Erreur d\'accès aux réceptions: $e');
    }
    return [];
  }

  Future<ReceptionStats> getReceptionStats() async {
    final receptions = await getReceptions();
    final completedReceptions = receptions.where((r) => r.isCompleted()).toList();

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDay = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final monthStart = DateTime(now.year, now.month, 1);

    final weeklyReceptions = completedReceptions.where((r) =>
      r.createdAt.isAfter(weekStartDay) ||
      (r.createdAt.year == weekStartDay.year &&
       r.createdAt.month == weekStartDay.month &&
       r.createdAt.day == weekStartDay.day)
    ).toList();

    final monthlyReceptions = completedReceptions.where((r) =>
      r.createdAt.isAfter(monthStart) ||
      (r.createdAt.year == monthStart.year &&
       r.createdAt.month == monthStart.month &&
       r.createdAt.day == monthStart.day)
    ).toList();

    final weeklyReceptionCount = weeklyReceptions.length;

    double monthlyAmountTotal = 0;
    for (var reception in monthlyReceptions) {
      if (reception.amount != null) {
        monthlyAmountTotal += reception.amount!;
      }
    }

    final currencySymbol = completedReceptions.isNotEmpty && completedReceptions.first.currency != null
        ? completedReceptions.first.currency!
        : 'GNF';

    return ReceptionStats(
      weeklyReceptionCount: weeklyReceptionCount,
      monthlyAmountTotal: monthlyAmountTotal,
      currencySymbol: currencySymbol,
    );
  }

  Future<Map<String, double>> getReceptionAmountsByOperator() async {
    final receptions = await getReceptions();
    final completedReceptions = receptions.where((r) => r.isCompleted()).toList();

    final Map<String, double> amountsByOperator = {};

    for (var reception in completedReceptions) {
      if (reception.amount != null) {
        final operatorName = reception.operator.name;
        if (amountsByOperator.containsKey(operatorName)) {
          amountsByOperator[operatorName] = amountsByOperator[operatorName]! + reception.amount!;
        } else {
          amountsByOperator[operatorName] = reception.amount!;
        }
      }
    }

    return amountsByOperator;
  }

  Future<List<Reception>> getReceptionsForPeriod({
    required DateTime startDate,
    required DateTime endDate
  }) async {
    final receptions = await getReceptions();

    return receptions.where((r) =>
      (r.createdAt.isAfter(startDate) ||
       (r.createdAt.year == startDate.year &&
        r.createdAt.month == startDate.month &&
        r.createdAt.day == startDate.day)) &&
      (r.createdAt.isBefore(endDate) ||
       (r.createdAt.year == endDate.year &&
        r.createdAt.month == endDate.month &&
        r.createdAt.day == endDate.day))
    ).toList();
  }

  Future<Map<String, dynamic>?> createReception(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        '/receptions',
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        debugPrint('Erreur lors de la création de la réception: ${response.statusCode}');
        debugPrint('Message: ${response.data}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception lors de la création de la réception: $e');
      return null;
    }
  }
}