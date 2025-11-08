import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/components/transfer_stepper.dart';
import 'package:bit_money/models/transfer_data.dart';
import 'package:bit_money/services/transfer_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:bit_money/l10n/app_localizations.dart';


class SendConfirmationScreen extends StatefulWidget {
  final TransferData transferData;

  const SendConfirmationScreen({
    super.key,
    required this.transferData
  });

  @override
  State<SendConfirmationScreen> createState() => SendConfirmationScreenState();
}

class SendConfirmationScreenState extends State<SendConfirmationScreen> {
  bool _isSubmitting = false;
  final TransferService _transferService = TransferService();
  late String _today;

  @override
  void initState() {
    super.initState();
    _today = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  Map<String, String> get _idTypeLabels {
    final tr = AppLocalizations.of(context)!;
    return {
      'PASSPORT': tr.passport,
      'CARTE_IDENTITE': tr.identityCard,
      'PERMIS': tr.drivingLicense,
      'AUTRE': tr.other
    };
  }

  Future<void> _submitTransfer() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _transferService.confirmTransaction();
      if (!mounted) return;
      final tr = AppLocalizations.of(context)!;

      if (response.containsKey('success') && !response['success']) {
        _showErrorMessage(response['message'] ?? tr.confirmationError);
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      if (mounted) {
        _showSuccessDialog(response);
      }
    } catch (e) {
      if (mounted) {
        final tr = AppLocalizations.of(context)!;
        _showErrorMessage(tr.errorOccurredWithDetails(e.toString()));
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessDialog([dynamic transactionData]) {
    final tr = AppLocalizations.of(context)!;
    String transactionId = '';
    if (transactionData is Map<String, dynamic> && transactionData.containsKey('id')) {
      transactionId = transactionData['id'];
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            tr.transferConfirmation,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                tr.transferProcessingMessage,
                textAlign: TextAlign.center,
              ),
              if (transactionId.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  tr.referenceLabel(transactionId),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                tr.receiptAvailabilityMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.darkGrey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(
                  tr.backToHome,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  )
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.secondary,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Text(
          tr.transferConfirmation,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            TransferStepper(
              currentStep: 4,
              totalSteps: 4,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildConfirmationCard(),
                ),
              ),
            ),
            _buildButtonBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationCard() {
    final tr = AppLocalizations.of(context)!;
    final formatter = NumberFormat('#,###', 'fr');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              tr.confirmationTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
          ),
          Center(
            child: Text(
              tr.verifyInformationSubtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.darkGrey,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildDetailRow(tr.transactionDate, _today),
          const SizedBox(height: 8),
          _buildDetailRow(tr.amount, '${formatter.format(widget.transferData.amount)} ${widget.transferData.currency}'),
          const SizedBox(height: 8),
          _buildDetailRow(tr.operator, widget.transferData.operator?.name ?? ''),
          const SizedBox(height: 8),
          _buildDetailRow(tr.transferReason, widget.transferData.reason ?? ''),
          const SizedBox(height: 24),
          _buildRecipientInfos(),
          const SizedBox(height: 24),
          _buildSenderInfos(),
        ],
      ),
    );
  }

  Widget _buildSenderInfos() {
    final tr = AppLocalizations.of(context)!;

    if (widget.transferData.senderBirthDate == null ||
        widget.transferData.senderLastName == null ||
        widget.transferData.senderFirstName == null) {
      return Center(
        child: Text(
          tr.incompleteSenderInfo,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final birthdayFormatter = DateFormat('dd/MM/yyyy');
    final birthDate = widget.transferData.senderBirthDate!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr.senderInformation,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailRow(tr.lastName, widget.transferData.senderLastName!),
        const SizedBox(height: 8),
        _buildDetailRow(tr.firstName, widget.transferData.senderFirstName!),
        const SizedBox(height: 8),
        _buildDetailRow(tr.phone, widget.transferData.senderPhone ?? ''),
        const SizedBox(height: 8),
        _buildDetailRow(tr.address, widget.transferData.senderAddress ?? ''),
        const SizedBox(height: 8),
        _buildDetailRow(tr.idType, _idTypeLabels[widget.transferData.senderIdType!] ?? widget.transferData.senderIdType ?? ''),
        const SizedBox(height: 8),
        _buildDetailRow(tr.idNumber, widget.transferData.senderIdNumber ?? ''),
        const SizedBox(height: 8),
        _buildDetailRow(tr.nationality, widget.transferData.senderNationality ?? ''),
        const SizedBox(height: 8),
        _buildDetailRow(tr.birthDate, birthdayFormatter.format(birthDate)),
        const SizedBox(height: 8),
        _buildDetailRow(tr.birthPlace, widget.transferData.senderBirthPlace ?? ''),
        const SizedBox(height: 8),
        _buildDetailRow(tr.country, widget.transferData.senderCountry ?? ''),
      ],
    );
  }

  Widget _buildRecipientInfos() {
    final tr = AppLocalizations.of(context)!;

    if (widget.transferData.recipientCountry == null ||
        widget.transferData.recipientLastName == null ||
        widget.transferData.recipientFirstName == null) {
      return Center(
        child: Text(
          tr.incompleteRecipientInfo,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr.recipientInformation,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailRow(tr.lastName, widget.transferData.recipientLastName!),
        const SizedBox(height: 8),
        _buildDetailRow(tr.firstName, widget.transferData.recipientFirstName!),
        const SizedBox(height: 8),
        _buildDetailRow(tr.country, widget.transferData.recipientCountry ?? ''),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.darkGrey,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 6,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.text,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildButtonBar() {
    final tr = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSubmitting ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.darkGrey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                tr.back,
                style: const TextStyle(
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitTransfer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                disabledBackgroundColor: Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    tr.confirm,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}