import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionReceiptScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionReceiptScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Détails de transaction',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    _buildReceiptCard(context, screenWidth),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Fermer',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptCard(BuildContext context, double screenWidth) {
    final amountFormatter = NumberFormat('#,###', 'fr_FR');
    final double amountSent = transaction.amount;
    final double fees = transaction.fees;
    final double totalAmount = transaction.totalAmount;
    final double receivedAmountForeign = amountSent / 1000;
    final String foreignCurrency = "USD";

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Reçu de transaction',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  '${amountFormatter.format(totalAmount)} ${transaction.currency}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            _buildDetailRow('Date de réception', _formatDate(transaction.completedAt ?? DateTime.now())),

            const Divider(height: 32),

            _buildDetailRow('Date de la transaction', _formatDate(transaction.createdAt)),
            const SizedBox(height: 12),
            _buildDetailRowWithWrap('Numéro de transaction', _truncateWithEllipsis(transaction.referenceId, 18), screenWidth),

            if (transaction.finalTransactionNumber != null && transaction.finalTransactionNumber!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailRowWithWrap('Numéro de référence ${transaction.operator!.code}', _truncateWithEllipsis(transaction.finalTransactionNumber!, 18), screenWidth),
            ],

            const SizedBox(height: 24),
            const Text(
              'Destination',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              transaction.recipientFullName,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              transaction.recipientNationality,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),
            const Text(
              'Motif de transfert',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              transaction.reason ?? 'Assistance famille',
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),
            const Text(
              'Détails du transfert',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildDetailRow('montant envoyé', '${amountFormatter.format(amountSent)} ${transaction.currency}'),
            const SizedBox(height: 8),
            _buildDetailRow('montant reçu', '${receivedAmountForeign.toStringAsFixed(0)} $foreignCurrency'),
            const SizedBox(height: 8),
            _buildDetailRow('Frais', '${amountFormatter.format(fees)} ${transaction.currency}'),
            const SizedBox(height: 8),
            _buildDetailRowWithWrap(
              'Total en ${transaction.currency}',
              '(1 $foreignCurrency = ${amountFormatter.format(1000)} ${transaction.currency})\n${amountFormatter.format(amountSent + fees)} ${transaction.currency}',
              screenWidth
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Opérateur', transaction.operator!.name),
            const SizedBox(height: 8),
            _buildDetailRow('Mntant total TTC', '${amountFormatter.format(totalAmount)} ${transaction.currency}',
              isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.black,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppColors.primary : AppColors.black,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRowWithWrap(String label, String value, double screenWidth, {bool isBold = false}) {
    final bool useColumnLayout = (label.length + value.length) * 7 > screenWidth - 64;

    if (useColumnLayout) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.black,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppColors.primary : Colors.black,
            ),
          ),
        ],
      );
    } else {
      return _buildDetailRow(label, value, isBold: isBold);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _truncateWithEllipsis(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }
}