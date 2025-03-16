import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/components/transfer_stepper.dart';
import 'package:bit_money/models/transfer_data.dart';
import 'package:bit_money/services/transfer_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  final Map<String, String> _idTypeLabels = {
    'PASSPORT': 'Passeport',
    'CARTE_IDENTITE': 'Carte d\'identité',
    'PERMIS': 'Permis de conduire',
    'AUTRE': 'Autre'
  };

  @override
  void initState() {
    super.initState();
    _today = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  Future<void> _submitTransfer() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _transferService.confirmTransaction();

      if (response.containsKey('success') && !response['success']) {
        _showErrorMessage(response['message'] ?? 'Une erreur est survenue lors de la confirmation');
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
        _showErrorMessage('Une erreur est survenue: ${e.toString()}');
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessDialog([dynamic transactionData]) {
    String transactionId = '';
    if (transactionData is Map<String, dynamic> && transactionData.containsKey('id')) {
      transactionId = transactionData['id'];
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirmation de transfert',
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
                'La demande de transfert est en cours de traitement.',
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
                'Vous pouvez à tout moment retrouver le reçu dans l\'historique des transactions.',
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Confirmation de transfert',
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
    final formatter = NumberFormat('#,###', 'fr');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
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
          const SizedBox(height: 8),
          _buildDetailRow('Montant', '${formatter.format(widget.transferData.amount)} ${widget.transferData.currency}'),
          const SizedBox(height: 8),
          _buildDetailRow('Opérateur', widget.transferData.operator?.name ?? ''),
          const SizedBox(height: 8),
          _buildDetailRow('Motif', widget.transferData.reason ?? ''),
          const SizedBox(height: 24),
          _buildRecipientInfos(),
          const SizedBox(height: 24),
          _buildSenderInfos(),
        ],
      ),
    );
  }

  Widget _buildSenderInfos() {
    if (widget.transferData.senderBirthDate == null ||
        widget.transferData.senderLastName == null ||
        widget.transferData.senderFirstName == null) {
      return const Center(
        child: Text(
          'Informations de l\'expéditeur incomplètes',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    final birthdayFormatter = DateFormat('dd/MM/yyyy');
    final birthDate = widget.transferData.senderBirthDate!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
            'Informations de l\'expéditeur',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        const SizedBox(height: 12),
        _buildDetailRow('Nom', widget.transferData.senderLastName!),
        const SizedBox(height: 8),
        _buildDetailRow('Prénom', widget.transferData.senderFirstName!),
        const SizedBox(height: 8),
        _buildDetailRow('Téléphone', widget.transferData.senderPhone ?? ''),
        const SizedBox(height: 8),
        _buildDetailRow('Adresse', widget.transferData.senderAddress ?? ''),
        const SizedBox(height: 8),
        _buildDetailRow('Type de pièce', _idTypeLabels[widget.transferData.senderIdType!] ?? widget.transferData.senderIdType ?? ''),
        const SizedBox(height: 8),
        _buildDetailRow('Numéro ID', widget.transferData.senderIdNumber ?? ''),
        const SizedBox(height: 8),
        _buildDetailRow('Nationalité', widget.transferData.senderNationality ?? ''),
        const SizedBox(height: 8),
        _buildDetailRow('Date de naissance', birthdayFormatter.format(birthDate)),
        const SizedBox(height: 8),
        _buildDetailRow('Lieu de naissance', widget.transferData.senderBirthPlace ?? ''),
        const SizedBox(height: 8),
        _buildDetailRow('Pays', widget.transferData.senderCountry ?? ''),
      ],
    );
  }

  Widget _buildRecipientInfos() {
    if (widget.transferData.recipientCountry == null ||
        widget.transferData.recipientLastName == null ||
        widget.transferData.recipientFirstName == null) {
      return const Center(
        child: Text(
          'Informations du bénéficiaire incomplètes',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
            'Informations du bénéficiaire',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        const SizedBox(height: 12),
        _buildDetailRow('Nom', widget.transferData.recipientLastName!),
        const SizedBox(height: 8),
        _buildDetailRow('Prénom', widget.transferData.recipientFirstName!),
        const SizedBox(height: 8),
        _buildDetailRow('Pays', widget.transferData.recipientCountry ?? ''),
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
                padding: const EdgeInsets.symmetric(vertical: 12),
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
              onPressed: _isSubmitting ? null : _submitTransfer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                disabledBackgroundColor: Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
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