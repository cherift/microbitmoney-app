import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/models/transaction_model.dart';
import 'package:bit_money/screens/transaction_receipt_screen.dart';
import 'package:bit_money/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({
    super.key,
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TransactionService _transactionService = TransactionService();
  final NumberFormat _amountFormatter = NumberFormat('#,###', 'fr');
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy', 'fr');
  final ScrollController _scrollController = ScrollController();

  List<Transaction> _transactions = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  double _totalAmount = 0;
  String _currency = 'GNF';

  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _hasMoreData = true;

  final Map<String, _StatusInfo> _statusCache = {
    'PENDING': _StatusInfo(Colors.orange, 'En attente'),
    'COMPLETED': _StatusInfo(Colors.green, 'Terminé'),
    'CANCELLED': _StatusInfo(Colors.red, 'Annulé'),
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll * 0.8 && !_isLoadingMore && _hasMoreData) {
      _loadMoreTransactions();
    }
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    try {
      final paginatedResponse = await _transactionService.getTransactionsPaginated(
        page: _currentPage,
        limit: _itemsPerPage,
      );

      if (!mounted) return;

      setState(() {
        _transactions = paginatedResponse.items;
        _hasMoreData = paginatedResponse.pagination.hasNext;
        _currency = _transactions.isNotEmpty ? _transactions.first.currency : 'GNF';
        _isLoading = false;
      });

      _loadStats();
    } catch (e) {
      debugPrint('Erreur lors du chargement des transactions: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadStats() async {
    try {
      final statsResponse = await _transactionService.getTransactionStats(forceRefresh: false);

      if (mounted) {
        setState(() {
          _totalAmount = statsResponse.totalAmount;
        });
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des statistiques: $e');
    }
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
    });

    try {
      final paginatedResponse = await _transactionService.getTransactionsPaginated(
        page: _currentPage,
        limit: _itemsPerPage,
      );

      if (!mounted) return;

      setState(() {
        _transactions = paginatedResponse.items;
        _hasMoreData = paginatedResponse.pagination.hasNext;
        _currency = _transactions.isNotEmpty ? _transactions.first.currency : 'GNF';
        _isLoading = false;
      });

      _loadStats();
    } catch (e) {
      debugPrint('Erreur lors du chargement des transactions: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreTransactions() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final paginatedResponse = await _transactionService.getTransactionsPaginated(
        page: nextPage,
        limit: _itemsPerPage,
      );

      if (!mounted) return;

      setState(() {
        _transactions.addAll(paginatedResponse.items);
        _currentPage = nextPage;
        _hasMoreData = paginatedResponse.pagination.hasNext;
        _isLoadingMore = false;
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement de plus de transactions: $e');
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTransactions,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTotalAmountCard(),
                            const SizedBox(height: 24),
                            const Text(
                              'Liste des envois',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _buildTransactionsList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTotalAmountCard() {
    final formattedAmount = _amountFormatter.format(_totalAmount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary,
            AppColors.secondary.withValues(alpha: .8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Montant total des envois',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                _currency,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formattedAmount,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun envoi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _transactions.length + (_hasMoreData ? 1 : 0),
      cacheExtent: 200,
      itemBuilder: (context, index) {
        if (index == _transactions.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final transaction = _transactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final formattedAmount = _amountFormatter.format(transaction.amount);
    final formattedDate = _dateFormatter.format(transaction.createdAt);

    final statusInfo = _statusCache[transaction.status] ??
        _StatusInfo(Colors.grey, transaction.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.referenceId,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${transaction.operator?.name ?? 'Opérateur'} - $formattedAmount $_currency',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${transaction.pdv?.name ?? 'PDV'} - $formattedDate',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusInfo.color.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    statusInfo.text,
                    style: TextStyle(
                      color: statusInfo.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionReceiptScreen(transaction: transaction),
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt_outlined, size: 18),
                  label: const Text('Voir le reçu'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    side: BorderSide(color: AppColors.secondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusInfo {
  final Color color;
  final String text;

  _StatusInfo(this.color, this.text);
}