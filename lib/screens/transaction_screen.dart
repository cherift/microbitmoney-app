import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/models/transaction_model.dart';
import 'package:bit_money/screens/transaction_receipt_screen.dart';
import 'package:bit_money/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatefulWidget {

  const TransactionsScreen({
    super.key,
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late TransactionService _transactionService;
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  double _totalAmount = 0;
  String _currency = 'GNF';

  @override
  void initState() {
    super.initState();
    _transactionService = TransactionService();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transactions = await _transactionService.getTransactions();
      transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final total = transactions.fold<double>(
        0, (sum, transaction) => sum + transaction.amount
      );
      final currency = transactions.isNotEmpty ? transactions.first.currency : 'GNF';

      setState(() {
        _transactions = transactions;
        _totalAmount = total;
        _currency = currency;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement des transactions: $e');
      setState(() {
        _isLoading = false;
      });
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
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTotalAmountCard(),
                          const SizedBox(height: 24),
                          const Text(
                            'Transactions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTransactionsList(),
                        ],
                      ),
                    ),
                  ),
                ),
            ),
          ),
    );
  }

  Widget _buildTotalAmountCard() {
    final formatter = NumberFormat('#,###', 'fr');
    final formattedAmount = formatter.format(_totalAmount);

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
            'Montant total des transferts',
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
          children: [
            const SizedBox(height: 40),
            Icon(
              Icons.hourglass_empty,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune transaction',
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
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final formatter = NumberFormat('#,###', 'fr');
    final formattedAmount = formatter.format(transaction.amount);

    final dateFormatter = DateFormat('dd/MM/yyyy', 'fr');
    final formattedDate = dateFormatter.format(transaction.createdAt);

    Color statusColor;
    String statusText;

    switch (transaction.status) {
      case 'PENDING':
        statusColor = Colors.amber;
        statusText = 'En attente';
        break;
      case 'COMPLETED':
        statusColor = Colors.green;
        statusText = 'Terminé';
        break;
      case 'REJECTED':
        statusColor = Colors.red;
        statusText = 'Refusé';
        break;
      default:
        statusColor = Colors.grey;
        statusText = transaction.status;
    }

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
                    color: statusColor.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
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