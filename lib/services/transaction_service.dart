import 'package:bit_money/models/transaction_model.dart';
import 'package:bit_money/services/api_client.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class TransactionStats {
  final int weeklyTransactionCount;
  final double monthlyCommissionTotal;
  final double totalAmount;
  final String currencySymbol;

  TransactionStats({
    required this.weeklyTransactionCount,
    required this.monthlyCommissionTotal,
    required this.currencySymbol,
    required this.totalAmount,
  });

  factory TransactionStats.empty() {
    return TransactionStats(
      weeklyTransactionCount: 0,
      monthlyCommissionTotal: 0,
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

class TransactionService {
  final ApiClient _apiClient;
  List<Transaction>? _cachedTransactions;
  DateTime? _cacheTimestamp;
  final Duration _cacheDuration = const Duration(minutes: 30);

  TransactionService() : _apiClient = ApiClient();

  String formatAmount(double amount) {
    final formatter = NumberFormat('#,###', 'fr');
    return formatter.format(amount);
  }

  Future<List<Transaction>> getTransactions({bool forceRefresh = false}) async {
    try {
      final now = DateTime.now();
      final isCacheValid = _cachedTransactions != null &&
                          _cacheTimestamp != null &&
                          now.difference(_cacheTimestamp!) < _cacheDuration;

      if (!forceRefresh && isCacheValid) {
        return _cachedTransactions!;
      }

      final response = await _apiClient.get(
        '/transactions',
        useCache: !forceRefresh,
        cacheDuration: _cacheDuration,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> transactionsList = data['transactions'];
        final transactions = transactionsList
            .map((json) => Transaction.fromJson(json))
            .toList();

        _cachedTransactions = transactions;
        _cacheTimestamp = now;

        return transactions;
      } else {
        debugPrint('Impossible d\'accéder aux transactions (code: ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Erreur d\'accès aux transactions: $e');
    }
    return [];
  }

  Future<PaginatedResponse<Transaction>> getTransactionsPaginated({
    int page = 1,
    int limit = 20,
    String? date,
    String? status,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (date != null) 'date': date,
        if (status != null) 'status': status,
      };

      final response = await _apiClient.get(
        '/transactions',
        queryParams: queryParams,
        useCache: false,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> transactionsList = data['transactions'];
        final transactions = transactionsList
            .map((json) => Transaction.fromJson(json))
            .toList();

        final paginationData = data['pagination'];
        final pagination = PaginationInfo(
          total: paginationData['total'] ?? 0,
          page: paginationData['page'] ?? 1,
          limit: paginationData['limit'] ?? 20,
          totalPages: paginationData['totalPages'] ?? 1,
        );

        return PaginatedResponse(
          items: transactions,
          pagination: pagination,
        );
      } else {
        debugPrint('Impossible d\'accéder aux transactions paginées (code: ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Erreur d\'accès aux transactions paginées: $e');
    }

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

  Future<List<Transaction>> refreshTransactions() async {
    _cachedTransactions = null;
    _cacheTimestamp = null;
    return await getTransactions(forceRefresh: true);
  }

  Future<TransactionStats> getTransactionStats({bool forceRefresh = false}) async {
    final transactions = await getTransactions(forceRefresh: forceRefresh);

    if (transactions.isEmpty) {
      return TransactionStats.empty();
    }

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

    final totalAmount = completedTransactions.fold<double>(
      0, (sum, transaction) => sum + transaction.amount
    );

    return TransactionStats(
      weeklyTransactionCount: weeklyTransactionCount,
      monthlyCommissionTotal: monthlyCommissionTotal,
      totalAmount: totalAmount,
      currencySymbol: 'GNF',
    );
  }

  Future<Map<String, double>> getTransactionAmountsByOperator({bool forceRefresh = false}) async {
    final transactions = await getTransactions(forceRefresh: forceRefresh);
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

  Future<Map<String, int>> getTransactionCountByPDV({bool forceRefresh = false}) async {
    final transactions = await getTransactions(forceRefresh: forceRefresh);
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

  Future<List<Transaction>> getTransactionsForPeriod({
    required DateTime startDate,
    required DateTime endDate,
    bool forceRefresh = false,
  }) async {
    final transactions = await getTransactions(forceRefresh: forceRefresh);

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

  Future<dynamic> getTransactionStatus(String referenceId) async {
    final response = await _apiClient.get(
      '/transactions/$referenceId/status',
      useCache: false,
    );

    if (response.statusCode! > 201) {
      final data = response.data;
      return data;
    }
    return {'error': false};
  }
}