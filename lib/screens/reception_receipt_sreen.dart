import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/models/reception_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceptionReceiptScreen extends StatelessWidget {
  final Reception reception;

  const ReceptionReceiptScreen({
    super.key,
    required this.reception,
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
                      'Détails de réception',
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
                    backgroundColor: AppColors.accent,
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
    final double amountReceived = reception.amount ?? 0;
    final String currency = reception.currency ?? 'GNF';
    final double receivedAmountForeign = amountReceived / 1000;
    final String foreignCurrency = "USD";
    final String truncatedRef = _truncateWithEllipsis(reception.referenceId, 18);

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
                'Reçu de réception',
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
                  '${amountFormatter.format(amountReceived)} $currency',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            _buildDetailRow('Date de réception', _formatDate(reception.completedAt ?? DateTime.now())),

            const Divider(height: 32),

            _buildDetailRow('Date de la transaction', _formatDate(reception.createdAt)),
            const SizedBox(height: 12),
            _buildDetailRowWithWrap('Numéro de transaction', truncatedRef, screenWidth),

            const SizedBox(height: 24),
            const Text(
              'Bénéficiaire',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              reception.recipientFullName,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              reception.recipientNationality,
              style: const TextStyle(fontSize: 16),
            ),

            if (reception.senderFullName != 'N/A') ...[
              const SizedBox(height: 24),
              const Text(
                'Expéditeur',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                reception.senderFullName,
                style: const TextStyle(fontSize: 16),
              ),
              if (reception.senderCountry != null && reception.senderCountry != 'UNKNOWN') ...[
                const SizedBox(height: 8),
                Text(
                  reception.senderCountry!,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ],

            if (reception.reason != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Motif du transfert',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                reception.reason!,
                style: const TextStyle(fontSize: 16),
              ),
            ],

            const SizedBox(height: 24),
            const Text(
              'Détails du transfert',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildDetailRow('Montant reçu', '${amountFormatter.format(amountReceived)} $currency'),
            const SizedBox(height: 8),
            _buildDetailRow('Équivalent en devise', '${receivedAmountForeign.toStringAsFixed(0)} $foreignCurrency'),
            const SizedBox(height: 8),
            _buildDetailRowWithWrap(
              'Taux de change',
              '1 $foreignCurrency = ${amountFormatter.format(1000)} $currency',
              screenWidth
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Opérateur', reception.operator.name),
            const SizedBox(height: 8),
            _buildDetailRow('PDV', reception.pdv?.name ?? 'N/A'),
            const SizedBox(height: 8),
            _buildDetailRow('Montant total', '${amountFormatter.format(amountReceived)} $currency',
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