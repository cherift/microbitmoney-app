import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/l10n/app_localizations.dart';
import 'package:bit_money/models/operator_model.dart';
import 'package:bit_money/components/transfer_stepper.dart';
import 'package:bit_money/services/reception_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ReceptionConfirmationScreen extends StatefulWidget {
  final Operator operator;
  final Map<String, dynamic> recipientData;
  final String currency;

  const ReceptionConfirmationScreen({
    super.key,
    required this.operator,
    required this.recipientData,
    required this.currency,
  });

  @override
  State<ReceptionConfirmationScreen> createState() => _ReceptionConfirmationScreenState();
}

class _ReceptionConfirmationScreenState extends State<ReceptionConfirmationScreen> {
  final ReceptionService _receptionService = ReceptionService();
  bool _isSubmitting = false;

  late String _transactionNumber;
  late String _today;

  @override
  void initState() {
    super.initState();
    _transactionNumber = widget.recipientData['referenceId'];
    _today = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  Future<void> _submitReception() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _receptionService.createReception(widget.recipientData);

      if (!mounted) return;
      final tr = AppLocalizations.of(context)!;

      if (response != null) {
        if (response['error'] != null) {
          _showErrorMessage(response['error']);
          return;
        }
        _showSuccessDialog(widget.recipientData['referenceId']);
      } else {
        _showErrorMessage(tr.receptionCreationError);
      }
    } catch (e) {
      final tr = AppLocalizations.of(context)!;
      _showErrorMessage(tr.errorOccurredWithDetails(e.toString()));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessDialog(String transactionId) {
    final tr = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            tr.receptionConfirmation,
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
                tr.receptionProcessingMessage,
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
                tr.receiptInReceptionHistory,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
      ),
    );
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
          tr.receiveTransfer,
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
              currentStep: 3,
              totalSteps: 3,
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

    final birthdayFormatter = DateFormat('dd/MM/yyyy');
    DateTime birthDate = DateTime.parse(widget.recipientData['recipientBirthDate']);

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
          const SizedBox(height: 12),
          _buildDetailRow(tr.referenceNumber, _transactionNumber),
          const SizedBox(height: 12),
          _buildDetailRow(tr.transferReason, widget.recipientData['reason'],),
          const SizedBox(height: 24),
          Text(
            tr.recipientInformation,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(tr.lastName, widget.recipientData['recipientLastName']),
          const SizedBox(height: 8),
          _buildDetailRow(tr.firstName, widget.recipientData['recipientFirstName']),
          const SizedBox(height: 8),
          _buildDetailRow(tr.phone, widget.recipientData['recipientPhone']),
          const SizedBox(height: 8),
          _buildDetailRow(tr.address, widget.recipientData['recipientAddress']),
          const SizedBox(height: 8),
          _buildDetailRow(tr.idType, widget.recipientData['recipientIdType']),
          const SizedBox(height: 8),
          _buildDetailRow(tr.idNumber, widget.recipientData['recipientIdNumber']),
          const SizedBox(height: 8),
          _buildDetailRow(tr.nationality, widget.recipientData['recipientNationality']),
          const SizedBox(height: 8),
          _buildDetailRow(tr.birthDate, birthdayFormatter.format(birthDate)),
          const SizedBox(height: 8),
          _buildDetailRow(tr.birthPlace, widget.recipientData['recipientBirthPlace']),
          const SizedBox(height: 8),
          _buildDetailRow(tr.country, widget.recipientData['recipientCountry']),
          const SizedBox(height: 16),
          _buildDetailRow(tr.operator, widget.operator.name),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.darkGrey,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
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
              onPressed: () => Navigator.pop(context),
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
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReception,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
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