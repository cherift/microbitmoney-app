
import 'package:bit_money/models/transaction_model.dart';
import 'package:bit_money/services/api_client.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class TransactionStats {
  final int weeklyTransactionCount;
  final double monthlyCommissionTotal;
  final String currencySymbol;

  TransactionStats({
    required this.weeklyTransactionCount,
    required this.monthlyCommissionTotal,
    required this.currencySymbol,
  });
}

class TransactionService {
  final ApiClient _apiClient;

  TransactionService() : _apiClient = ApiClient();

  String formatAmount(double amount) {
    final formatter = NumberFormat('#,###', 'fr');
    return formatter.format(amount);
  }

  // Obtenir la liste des transactions
  Future<List<Transaction>> getTransactions() async {
    try {
      final response = await _apiClient.get('/transactions',);

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> transactionsList = data['transactions'];
        return transactionsList.map((json) => Transaction.fromJson(json)).toList();
      } else {
        debugPrint('Impossible d\'accéder au transactions');
      }
    } catch (e) {
      debugPrint('Erreur d\'accès aux transactions: $e');
    }
    return [];
  }

  // Obtenir les statistiques des transactions
  Future<TransactionStats> getTransactionStats() async {
    final transactions = await getTransactions();

    final completedTransactions = transactions.where((t) => t.status == 'COMPLETED').toList();

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDay = DateTime(weekStart.year, weekStart.month, weekStart.day);

    final monthStart = DateTime(now.year, now.month, 1);

    final weeklyTransactions = completedTransactions.where((t) =>
      t.createdAt.isAfter(weekStartDay) ||
      (t.createdAt.year == weekStartDay.year &&
       t.createdAt.month == weekStartDay.month &&
       t.createdAt.day == weekStartDay.day)
    ).toList();

    final monthlyTransactions = completedTransactions.where((t) =>
      t.createdAt.isAfter(monthStart) ||
      (t.createdAt.year == monthStart.year &&
       t.createdAt.month == monthStart.month &&
       t.createdAt.day == monthStart.day)
    ).toList();

    final weeklyTransactionCount = weeklyTransactions.length;

    final monthlyCommissionTotal = monthlyTransactions.fold<double>(
      0, (sum, transaction) => sum + transaction.amount
    );

    final currencySymbol = completedTransactions.isNotEmpty ? completedTransactions.first.currency : 'GNF';

    return TransactionStats(
      weeklyTransactionCount: weeklyTransactionCount,
      monthlyCommissionTotal: monthlyCommissionTotal,
      currencySymbol: currencySymbol,
    );
  }

  // Obtenir le total des transactions par opérateur
  Future<Map<String, double>> getTransactionAmountsByOperator() async {
    final transactions = await getTransactions();
    final completedTransactions = transactions.where((t) => t.status == 'COMPLETED').toList();

    final Map<String, double> amountsByOperator = {};

    for (var transaction in completedTransactions) {
      if (transaction.operator != null) {
        final operatorName = transaction.operator!.name;
        if (amountsByOperator.containsKey(operatorName)) {
          amountsByOperator[operatorName] = amountsByOperator[operatorName]! + transaction.amount;
        } else {
          amountsByOperator[operatorName] = transaction.amount;
        }
      }
    }

    return amountsByOperator;
  }

  // Obtenir le nombre de transactions par point de vente
  Future<Map<String, int>> getTransactionCountByPDV() async {
    final transactions = await getTransactions();
    final completedTransactions = transactions.where((t) => t.status == 'COMPLETED').toList();

    final Map<String, int> countByPDV = {};

    for (var transaction in completedTransactions) {
      if (transaction.pdv != null) {
        final pdvName = transaction.pdv!.name;
        if (countByPDV.containsKey(pdvName)) {
          countByPDV[pdvName] = countByPDV[pdvName]! + 1;
        } else {
          countByPDV[pdvName] = 1;
        }
      }
    }

    return countByPDV;
  }

  // Obtenir les transactions pour une période donnée
  Future<List<Transaction>> getTransactionsForPeriod({
    required DateTime startDate,
    required DateTime endDate
  }) async {
    final transactions = await getTransactions();

    return transactions.where((t) =>
      (t.createdAt.isAfter(startDate) ||
       (t.createdAt.year == startDate.year &&
        t.createdAt.month == startDate.month &&
        t.createdAt.day == startDate.day)) &&
      (t.createdAt.isBefore(endDate) ||
       (t.createdAt.year == endDate.year &&
        t.createdAt.month == endDate.month &&
        t.createdAt.day == endDate.day))
    ).toList();
  }

  Future<dynamic> getTransactionStatus(referenceId) async {
    final response = await _apiClient.get('/transactions/$referenceId/status',);

    if (response.statusCode! > 201) {
      final data = response.data;
      return data;
    }
    return {'error': false};
  }
}