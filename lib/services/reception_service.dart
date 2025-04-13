import 'package:bit_money/models/reception_model.dart';
import 'package:bit_money/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceptionStats {
  final int weeklyReceptionCount;
  final double monthlyAmountTotal;
  final double totalAmount;
  final String currencySymbol;

  ReceptionStats({
    required this.weeklyReceptionCount,
    required this.monthlyAmountTotal,
    required this.totalAmount,
    required this.currencySymbol,
  });

  factory ReceptionStats.empty() {
    return ReceptionStats(
      weeklyReceptionCount: 0,
      monthlyAmountTotal: 0,
      totalAmount: 0,
      currencySymbol: 'GNF',
    );
  }
}

class PaginationInfo {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  PaginationInfo({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  }) :
    hasNext = page < totalPages,
    hasPrevious = page > 1;
}

class PaginatedResponse<T> {
  final List<T> items;
  final PaginationInfo pagination;

  PaginatedResponse({
    required this.items,
    required this.pagination,
  });
}

class ReceptionService {
  final ApiClient _apiClient;
  List<Reception>? _cachedReceptions;
  DateTime? _cacheTimestamp;
  final Duration _cacheDuration = const Duration(minutes: 30);

  ReceptionStats? _cachedStats;
  DateTime? _statsTimestamp;

  ReceptionService() : _apiClient = ApiClient();

  String formatAmount(double amount) {
    final formatter = NumberFormat('#,###', 'fr');
    return formatter.format(amount);
  }

  Future<List<Reception>> getReceptions({bool forceRefresh = false}) async {
    try {
      final now = DateTime.now();
      final isCacheValid = _cachedReceptions != null &&
                          _cacheTimestamp != null &&
                          now.difference(_cacheTimestamp!) < _cacheDuration;

      if (!forceRefresh && isCacheValid) {
        return _cachedReceptions!;
      }

      final response = await _apiClient.get(
        '/receptions',
        useCache: !forceRefresh,
        cacheDuration: _cacheDuration,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> receptionsList = data['receptions'];
        final receptions = receptionsList
            .map((json) => Reception.fromJson(json))
            .toList();

        receptions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        _cachedReceptions = receptions;
        _cacheTimestamp = now;

        return receptions;
      } else {
        debugPrint('Impossible d\'accéder aux réceptions (code: ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Erreur d\'accès aux réceptions: $e');
    }
    return [];
  }

  Future<PaginatedResponse<Reception>> getReceptionsPaginated({
    int page = 1,
    int limit = 10,
    String? date,
    String? status,
  }) async {
    try {
      try {
        final queryParams = {
          'page': page.toString(),
          'limit': limit.toString(),
          if (date != null) 'date': date,
          if (status != null) 'status': status,
        };

        final response = await _apiClient.get(
          '/receptions',
          queryParams: queryParams,
          useCache: false,
        );

        if (response.statusCode == 200 && response.data.containsKey('pagination')) {
          final data = response.data;
          final List<dynamic> receptionsList = data['receptions'];
          final receptions = receptionsList
              .map((json) => Reception.fromJson(json))
              .toList();

          final paginationData = data['pagination'];
          final pagination = PaginationInfo(
            total: paginationData['total'] ?? 0,
            page: paginationData['page'] ?? 1,
            limit: paginationData['limit'] ?? 10,
            totalPages: paginationData['totalPages'] ?? 1,
          );

          return PaginatedResponse(
            items: receptions,
            pagination: pagination,
          );
        }
      } catch (e) {
        debugPrint('Pagination côté serveur non disponible: $e');
      }

      final allReceptions = await getReceptions(forceRefresh: page == 1);

      List<Reception> filteredReceptions = allReceptions;
      if (status != null) {
        filteredReceptions = filteredReceptions.where((r) => r.status == status).toList();
      }

      final int total = filteredReceptions.length;
      final int totalPages = (total / limit).ceil();

      final int startIndex = (page - 1) * limit;
      final int endIndex = startIndex + limit > total ? total : startIndex + limit;

      List<Reception> pageItems = [];
      if (startIndex < total) {
        pageItems = filteredReceptions.sublist(startIndex, endIndex);
      }

      return PaginatedResponse(
        items: pageItems,
        pagination: PaginationInfo(
          total: total,
          page: page,
          limit: limit,
          totalPages: totalPages,
        ),
      );
    } catch (e) {
      debugPrint('Erreur lors de la récupération des réceptions paginées: $e');
      return PaginatedResponse(
        items: [],
        pagination: PaginationInfo(
          total: 0,
          page: page,
          limit: limit,
          totalPages: 0,
        ),
      );
    }
  }

  Future<ReceptionStats> getReceptionStats({bool forceRefresh = false}) async {
    final now = DateTime.now();
    final isCacheValid = _cachedStats != null &&
                        _statsTimestamp != null &&
                        now.difference(_statsTimestamp!) < _cacheDuration;

    if (!forceRefresh && isCacheValid) {
      return _cachedStats!;
    }

    try {
      try {
        final response = await _apiClient.get(
          '/receptions/stats',
          useCache: !forceRefresh,
        );

        if (response.statusCode == 200) {
          final data = response.data;
          final stats = ReceptionStats(
            weeklyReceptionCount: data['weeklyReceptionCount'] ?? 0,
            monthlyAmountTotal: (data['monthlyAmountTotal'] ?? 0).toDouble(),
            totalAmount: (data['totalAmount'] ?? 0).toDouble(),
            currencySymbol: data['currencySymbol'] ?? 'GNF',
          );

          _cachedStats = stats;
          _statsTimestamp = now;

          return stats;
        }
      } catch (e) {
        debugPrint('API de statistiques non disponible: $e');
      }

      final receptions = await getReceptions(forceRefresh: forceRefresh);
      final completedReceptions = receptions.where((r) => r.status == 'COMPLETED').toList();

      if (completedReceptions.isEmpty) {
        return ReceptionStats.empty();
      }

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
      double totalAmount = 0;

      for (var reception in monthlyReceptions) {
        if (reception.amount != null) {
          monthlyAmountTotal += reception.amount!;
        }
      }

      for (var reception in completedReceptions) {
        if (reception.amount != null) {
          totalAmount += reception.amount!;
        }
      }

      final currencySymbol = completedReceptions.isNotEmpty && completedReceptions.first.currency != null
          ? completedReceptions.first.currency!
          : 'GNF';

      final stats = ReceptionStats(
        weeklyReceptionCount: weeklyReceptionCount,
        monthlyAmountTotal: monthlyAmountTotal,
        totalAmount: totalAmount,
        currencySymbol: currencySymbol,
      );

      _cachedStats = stats;
      _statsTimestamp = now;

      return stats;
    } catch (e) {
      debugPrint('Erreur lors du calcul des statistiques: $e');
      return ReceptionStats.empty();
    }
  }

  Future<Map<String, double>> getReceptionAmountsByOperator() async {
    final receptions = await getReceptions();
    final completedReceptions = receptions.where((r) => r.status == 'COMPLETED').toList();

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
        _cachedReceptions = null;
        _cacheTimestamp = null;
        _cachedStats = null;
        _statsTimestamp = null;

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