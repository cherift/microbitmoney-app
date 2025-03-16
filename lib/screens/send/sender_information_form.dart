import 'package:bit_money/components/transfer_stepper.dart';
import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/models/transfer_data.dart';
import 'package:bit_money/screens/send/recipient_information_form.dart';
import 'package:bit_money/services/transfer_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SenderInformationForm extends StatefulWidget {
  final TransferData transferData;
  const SenderInformationForm({super.key, required this.transferData});

  @override
  State<SenderInformationForm> createState() => _SenderInformationFormState();
}

class _SenderInformationFormState extends State<SenderInformationForm> {
  final _formKey = GlobalKey<FormState>();
  final TransferService _transferService = TransferService();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _idTypeController = TextEditingController(text: 'PASSPORT');
  final _idNumberController = TextEditingController();
  final _nationalityController = TextEditingController(text: 'GN');
  final _birthDateController = TextEditingController();
  final _idExpirationDateController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  final _selectedCountryController = TextEditingController(text: 'Guinée');
  final _reasonController = TextEditingController(text: 'Assistance famille');

  DateTime? _selectedBirthDate;
  DateTime? _selectedIdExpirationDate;
  bool _isProcessing = false;

  final List<String> _idTypes = [
    'PASSPORT',
    'CARTE_IDENTITE',
    'PERMIS',
    'AUTRE'
  ];

  final Map<String, String> _idTypeLabels = {
    'PASSPORT': 'Passeport',
    'CARTE_IDENTITE': 'Carte d\'identité',
    'PERMIS': 'Permis de conduire',
    'AUTRE': 'Autre'
  };

  final List<String> _reasons = [
    'Assistance famille',
    'Paiement factures',
    'Achat',
    'Autre'
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _idTypeController.dispose();
    _idNumberController.dispose();
    _nationalityController.dispose();
    _selectedCountryController.dispose();
    _idExpirationDateController.dispose();
    _birthDateController.dispose();
    _birthPlaceController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.secondary,
              onPrimary: Colors.white,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showErrorDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _selectExpirationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.secondary,
              onPrimary: Colors.white,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedIdExpirationDate) {
      setState(() {
        _selectedIdExpirationDate = picked;
        _idExpirationDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _continueToConfirmation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBirthDate == null) {
      _showErrorSnackBar('Veuillez sélectionner une date de naissance');
      return;
    }

    if (_selectedIdExpirationDate == null) {
      _showErrorSnackBar('Veuillez sélectionner une date d\'expiration');
      return;
    }

    setState(() {
      _isProcessing = true;

      widget.transferData.senderFirstName = _firstNameController.text;
      widget.transferData.senderLastName = _lastNameController.text;
      widget.transferData.senderPhone = _phoneController.text;
      widget.transferData.senderAddress = _addressController.text;
      widget.transferData.senderIdType = _idTypeController.text;
      widget.transferData.senderIdExpiryDate = _selectedIdExpirationDate;
      widget.transferData.senderIdNumber = _idNumberController.text;
      widget.transferData.senderNationality = _nationalityController.text;
      widget.transferData.senderBirthDate = _selectedBirthDate;
      widget.transferData.senderBirthPlace = _birthPlaceController.text;
      widget.transferData.senderCountry = _selectedCountryController.text;
      widget.transferData.reason = _reasonController.text;
    });

    try {
      final response = await _transferService.submitSenderInfo(widget.transferData.toSenderJson());

      if (response is Map<String, dynamic> && response.containsKey('success') && !response['success']) {
        _showErrorSnackBar(response['message'] ?? 'Une erreur est survenue');
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipientInformationForm(
              transferData: widget.transferData
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog('Erreur lors de l\'envoi des informations: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Infos de l\'expéditeur',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
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
              currentStep: 2,
              totalSteps: 4,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: _buildSenderForm(),
                  ),
                ),
              ),
            ),
            _buildButtonBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSenderForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Nom', _lastNameController, validator: _requiredValidator),
        const SizedBox(height: 16),
        _buildTextField('Prénom', _firstNameController, validator: _requiredValidator),
        const SizedBox(height: 16),
        _buildTextField('Adresse', _addressController, validator: _requiredValidator),
        const SizedBox(height: 16),
        _buildTextField('Téléphone', _phoneController,
          keyboardType: TextInputType.phone,
          validator: _requiredValidator
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildIdTypeDropdown(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField('Numéro ID', _idNumberController,
                validator: _requiredValidator
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField('Date d\'expiration', _idExpirationDateController,
          readOnly: true,
          onTap: () => _selectExpirationDate(context),
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
          validator: _requiredValidator
        ),
        const SizedBox(height: 16),
        _buildTextField('Date de naissance', _birthDateController,
          readOnly: true,
          onTap: () => _selectBirthDate(context),
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
          validator: _requiredValidator
        ),
        const SizedBox(height: 16),
        _buildTextField('Lieu de naissance', _birthPlaceController,
          validator: _requiredValidator
        ),
        const SizedBox(height: 16),
        _buildTextField('Pays', _selectedCountryController,
          validator: _requiredValidator
        ),
        const SizedBox(height: 16),
        _buildTextField('Nationalité', _nationalityController,
          validator: _requiredValidator
        ),
        const SizedBox(height: 16),
        _reasonDropdown(),
      ],
    );
  }

  Widget _buildIdTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type de pièce',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonFormField<String>(
            value: _idTypeController.text.isEmpty ? _idTypes[0] : _idTypeController.text,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            items: _idTypes.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(_idTypeLabels[value] ?? value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _idTypeController.text = newValue;
                });
              }
            },
            validator: _requiredValidator,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.darkGrey),
            dropdownColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _reasonDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Motif du transfert',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonFormField<String>(
            value: _reasonController.text.isEmpty ? _idTypes[0] : _reasonController.text,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            items: _reasons.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _reasonController.text = newValue;
                });
              }
            },
            validator: _requiredValidator,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.darkGrey),
            dropdownColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.secondary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            suffixIcon: suffixIcon,
          ),
          validator: validator,
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
              onPressed: _isProcessing ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.darkGrey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Annuler',
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
              onPressed: _isProcessing ? null : _continueToConfirmation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                disabledBackgroundColor: Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Continuer',
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

  // Validateurs
  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est obligatoire';
    }
    return null;
  }
}