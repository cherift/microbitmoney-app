import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/l10n/app_localizations.dart';
import 'package:bit_money/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TransactionReceiptScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionReceiptScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(tr.transactionDetails),
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.secondary,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
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
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          tr.close,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  if (transaction.status == "COMPLETED") ... [
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () => _printReceipt(context),
                          label: Text(tr.print),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptCard(BuildContext context, double screenWidth) {
    final tr = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final amountFormatter = NumberFormat('#,###', locale);
    final double amountSent = transaction.amount;
    final double totalAmount = transaction.totalAmount;

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
            Center(
              child: Text(
                tr.transactionReceipt,
                style: const TextStyle(
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

            _buildDetailRow(tr.receivedDate, _formatDate(transaction.completedAt ?? DateTime.now())),

            const Divider(height: 32),

            _buildDetailRow(tr.transactionDate, _formatDate(transaction.createdAt)),
            const SizedBox(height: 12),
            _buildDetailRowWithWrap(tr.transactionNumber, _truncateWithEllipsis(transaction.referenceId, 18), screenWidth),

            if (transaction.finalTransactionNumber != null && transaction.finalTransactionNumber!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailRowWithWrap(
                '${tr.referenceNumber} ${transaction.operator!.code}',
                _truncateWithEllipsis(transaction.finalTransactionNumber!, 18),
                screenWidth,
                isBold: true
              ),
            ],
            const SizedBox(height: 24),
            Text(
              tr.transferReason,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              transaction.reason ?? tr.familyAssistance,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Text(
              tr.beneficiary,
              style: const TextStyle(
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
              transaction.recipientCountry!,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Text(
              tr.sender,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              transaction.senderFullName,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              transaction.senderCountry!,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Text(
              tr.transferDetails,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(tr.amountSent, '${amountFormatter.format(amountSent)} ${transaction.currency}'),
            const SizedBox(height: 8),
            _buildDetailRow(tr.operator, transaction.operator!.name),
            const SizedBox(height: 8),
            _buildDetailRow(tr.totalAmountIncludesTax, '${amountFormatter.format(totalAmount)} ${transaction.currency}',
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

  Future<void> _printReceipt(BuildContext context) async {
    final tr = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final amountFormatter = NumberFormat('#,###', locale);

    final pdf = pw.Document();

    // Ajoutez une police qui prend en charge l'unicode (pour les caractères spéciaux)
    final font = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  tr.transactionReceipt,
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 18,
                  ),
                ),
              ),

              pw.SizedBox(height: 16),

              pw.Center(
                child: pw.Text(
                  '${amountFormatter.format(transaction.totalAmount)} ${transaction.currency}',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 24,
                  ),
                ),
              ),

              pw.SizedBox(height: 16),

              _buildPdfRow(
                tr.receivedDate,
                _formatDate(transaction.completedAt ?? DateTime.now()),
                font,
              ),

              pw.Divider(height: 16),

              _buildPdfRow(tr.transactionDate, _formatDate(transaction.createdAt), font),
              pw.SizedBox(height: 8),
              _buildPdfRow(tr.transactionNumber, transaction.referenceId, font),

              if (transaction.finalTransactionNumber != null && transaction.finalTransactionNumber!.isNotEmpty) ...[
                pw.SizedBox(height: 8),
                _buildPdfRow(
                  '${tr.referenceNumber} ${transaction.operator!.code}',
                  transaction.finalTransactionNumber!,
                  font,
                  isBold: true,
                  boldFont: boldFont,
                ),
              ],

              pw.SizedBox(height: 16),
              pw.Text(
                tr.transferReason,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 14,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                transaction.reason ?? tr.familyAssistance,
                style: pw.TextStyle(font: font, fontSize: 12),
              ),

              pw.SizedBox(height: 16),
              pw.Text(
                tr.beneficiary,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 14,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                transaction.recipientFullName,
                style: pw.TextStyle(font: font, fontSize: 12),
              ),
              if (transaction.recipientCountry != null)
                pw.Text(
                  transaction.recipientCountry!,
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),

              pw.SizedBox(height: 16),
              pw.Text(
                tr.sender,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 14,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                transaction.senderFullName,
                style: pw.TextStyle(font: font, fontSize: 12),
              ),
              if (transaction.senderCountry != null)
                pw.Text(
                  transaction.senderCountry!,
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),

              pw.SizedBox(height: 16),
              pw.Text(
                tr.transferDetails,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 14,
                ),
              ),
              pw.SizedBox(height: 8),

              _buildPdfRow(
                tr.amountSent,
                '${amountFormatter.format(transaction.amount)} ${transaction.currency}',
                font,
              ),
              pw.SizedBox(height: 4),
              _buildPdfRow(tr.operator, transaction.operator!.name, font),
              pw.SizedBox(height: 4),
              _buildPdfRow(
                tr.totalAmountIncludesTax,
                '${amountFormatter.format(transaction.totalAmount)} ${transaction.currency}',
                font,
                isBold: true,
                boldFont: boldFont,
              ),

              pw.SizedBox(height: 24),
              pw.Center(
                child: pw.Text(
                  'Bit Money - ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                  style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'reception_${transaction.referenceId}.pdf',
      format: PdfPageFormat.a4,
    );
  }

  pw.Row _buildPdfRow(String label, String value, pw.Font font, {bool isBold = false, pw.Font? boldFont}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          child: pw.Text(
            label,
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
            ),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              font: isBold ? boldFont : font,
              fontSize: 12,
            ),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }
}