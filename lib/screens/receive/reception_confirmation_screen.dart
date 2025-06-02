import 'package:bit_money/constants/app_colors.dart';
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

      if (response != null) {
        if (!mounted) return;
        _showSuccessDialog(widget.recipientData['referenceId']);
      } else {
        _showErrorMessage('Erreur lors de la création de la réception');
      }
    } catch (e) {
      _showErrorMessage('Une erreur est survenue: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessDialog(String transactionId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirmation de réception',
            style: TextStyle(fontWeight: FontWeight.bold),
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
              const Text(
                'La demande de réception est en cours de traitement.',
                textAlign: TextAlign.center,
              ),
              if (transactionId.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Référence: $transactionId',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 8),
              const Text(
                'Vous pouvez à tout moment retrouver le reçu dans l\'historique des réceptions.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
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
                child: const Text(
                  'Retour à l\'accueil',
                  style: TextStyle(
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.secondary,
          statusBarIconBrightness: Brightness.light,
        ),
        title: const Text(
          'Recevoir un transfert',
          style: TextStyle(fontWeight: FontWeight.bold),
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
    // Formatter pour la date
    final birthdayFormatter = DateFormat('dd/MM/yyyy');
    DateTime birthDate = DateTime.parse(widget.recipientData['recipientBirthDate']);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Confirmation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
          ),
          const Center(
            child: Text(
              '(Vérifier vos informations)',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.darkGrey,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildDetailRow('Date de la transaction', _today),
          const SizedBox(height: 12),
          _buildDetailRow('Numéro de référence', _transactionNumber),
          const SizedBox(height: 12),
          _buildDetailRow('Motif', widget.recipientData['reason'],),
          const SizedBox(height: 24),
          const Text(
            'Informations du bénéficiaire',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Nom', widget.recipientData['recipientLastName']),
          const SizedBox(height: 8),
          _buildDetailRow('Prénom', widget.recipientData['recipientFirstName']),
          const SizedBox(height: 8),
          _buildDetailRow('Téléphone', widget.recipientData['recipientPhone']),
          const SizedBox(height: 8),
          _buildDetailRow('Adresse', widget.recipientData['recipientAddress']),
          const SizedBox(height: 8),
          _buildDetailRow('Type de pièce', widget.recipientData['recipientIdType']),
          const SizedBox(height: 8),
          _buildDetailRow('Numéro ID', widget.recipientData['recipientIdNumber']),
          const SizedBox(height: 8),
          _buildDetailRow('Nationalité', widget.recipientData['recipientNationality']),
          const SizedBox(height: 8),
          _buildDetailRow('Date de naissance', birthdayFormatter.format(birthDate)),
          const SizedBox(height: 8),
          _buildDetailRow('Lieu de naissance', widget.recipientData['recipientBirthPlace']),
          const SizedBox(height: 8),
          _buildDetailRow('Pays', widget.recipientData['recipientCountry']),
          const SizedBox(height: 16),
          _buildDetailRow('Opérateur', widget.operator.name),
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
                padding: const EdgeInsets.symmetric(vertical: 23),
              ),
              child: const Text(
                'Retour',
                style: TextStyle(
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
                padding: const EdgeInsets.symmetric(vertical: 23),
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
                : const Text(
                    'Confirmer',
                    style: TextStyle(
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