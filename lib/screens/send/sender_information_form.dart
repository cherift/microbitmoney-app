import 'package:bit_money/components/transfer_stepper.dart';
import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/l10n/app_localizations.dart';
import 'package:bit_money/models/transfer_data.dart';
import 'package:bit_money/screens/send/recipient_information_form.dart';
import 'package:bit_money/services/transfer_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:country_picker/country_picker.dart';

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
  final _nationalityNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _idExpirationDateController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  final _selectedCountryController = TextEditingController();
  final _reasonController = TextEditingController(text: 'FAMILY');

  DateTime? _selectedBirthDate;
  DateTime? _selectedIdExpirationDate;
  bool _isProcessing = false;

  Country? _selectedCountry;
  Country? _selectedNationality;

  final List<String> _idTypes = [
    'PASSPORT',
    'CARTE_IDENTITE',
    'PERMIS',
    'AUTRE'
  ];

  final List<String> _reasons = [
    'FAMILY',
    'BILL',
    'PURCHASE',
    'OTHER'
  ];

  Map<String, String> _idTypeLabels = {};
  Map<String, String> _reasonLabels = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _idTypeLabels = {
      'PASSPORT': AppLocalizations.of(context)!.passport,
      'CARTE_IDENTITE': AppLocalizations.of(context)!.identityCard,
      'PERMIS': AppLocalizations.of(context)!.drivingLicense,
      'AUTRE': AppLocalizations.of(context)!.other
    };

    _reasonLabels = {
      'FAMILY': AppLocalizations.of(context)!.familyAssistance,
      'BILL': AppLocalizations.of(context)!.billPayment,
      'PURCHASE': AppLocalizations.of(context)!.purchase,
      'OTHER': AppLocalizations.of(context)!.other
    };
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _idTypeController.dispose();
    _idNumberController.dispose();
    _nationalityController.dispose();
    _nationalityNameController.dispose();
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
    final tr = AppLocalizations.of(context)!;

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(tr.error),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(tr.ok),
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
    final tr = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBirthDate == null) {
      _showErrorSnackBar(tr.selectBirthDate);
      return;
    }

    if (_selectedIdExpirationDate == null) {
      _showErrorSnackBar(tr.selectExpiryDate);
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
      widget.transferData.reason = _reasonLabels[_reasonController.text];
    });

    try {
      final response = await _transferService.submitSenderInfo(widget.transferData.toSenderJson());

      if (response is Map<String, dynamic> && response.containsKey('success') && !response['success']) {
        _showErrorSnackBar(response['message'] ?? tr.errorOccured);
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
      _showErrorDialog('${tr.senderInfoError}: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        title: Text(
          tr.senderInformation,
          style: const TextStyle(fontWeight: FontWeight.bold),
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
        bottom: true,
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
    final tr = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(tr.lastName, _lastNameController, validator: _requiredValidator),
        const SizedBox(height: 16),
        _buildTextField(tr.firstName, _firstNameController, validator: _requiredValidator),
        const SizedBox(height: 16),
        _buildTextField(tr.address, _addressController, validator: _requiredValidator),
        const SizedBox(height: 16),
        _buildTextField(tr.phone, _phoneController,
          keyboardType: TextInputType.phone,
          validator: _requiredValidator
        ),
        const SizedBox(height: 16),
        _buildCountrySelector(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildIdTypeDropdown(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(tr.idNumber, _idNumberController,
                validator: _requiredValidator
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(tr.expiryDate, _idExpirationDateController,
          readOnly: true,
          onTap: () => _selectExpirationDate(context),
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
          validator: _requiredValidator
        ),
        const SizedBox(height: 16),
        _buildTextField(tr.birthDate, _birthDateController,
          readOnly: true,
          onTap: () => _selectBirthDate(context),
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
          validator: _requiredValidator
        ),
        const SizedBox(height: 16),
        _buildTextField(tr.birthPlace, _birthPlaceController,
          validator: _requiredValidator
        ),
        const SizedBox(height: 16),
        _buildNationalitySelector(),
        const SizedBox(height: 16),
        _reasonDropdown(),
      ],
    );
  }

  Widget _buildNationalitySelector() {
    final tr = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr.nationality,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            showCountryPicker(
              context: context,
              showPhoneCode: false,
              countryListTheme: CountryListThemeData(
                borderRadius: BorderRadius.circular(8),
                inputDecoration: InputDecoration(
                  hintText: tr.searchNationality,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
                searchTextStyle: const TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                ),
              ),
              onSelect: (Country country) {
                setState(() {
                  _selectedNationality = country;
                  _nationalityNameController.text = country.name;
                  _nationalityController.text = country.countryCode;
                });
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                if (_selectedNationality != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    _selectedNationality!.flagEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    _nationalityNameController.text,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.darkGrey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountrySelector() {
    final tr = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr.country,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            showCountryPicker(
              context: context,
              showPhoneCode: false,
              countryListTheme: CountryListThemeData(
                borderRadius: BorderRadius.circular(8),
                inputDecoration: InputDecoration(
                  hintText: tr.searchCountry,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
                searchTextStyle: const TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                ),
              ),
              onSelect: (Country country) {
                setState(() {
                  _selectedCountry = country;
                  _selectedCountryController.text = country.name;
                });
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                if (_selectedCountry != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    _selectedCountry!.flagEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    _selectedCountryController.text,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.darkGrey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIdTypeDropdown() {
    final tr = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr.idType,
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
            initialValue: _idTypeController.text.isEmpty ? _idTypes[0] : _idTypeController.text,
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
    final tr = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr.transferReason,
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
            initialValue: _reasonController.text.isEmpty ? _reasons[0] : _reasonController.text,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            items: _reasons.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(_reasonLabels[value] ?? value),
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
    final tr = AppLocalizations.of(context)!;

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
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                tr.cancel,
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
              onPressed: _isProcessing ? null : _continueToConfirmation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                disabledBackgroundColor: Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
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
                  : Text(
                      tr.nextStep,
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

  String? _requiredValidator(String? value) {
    final tr = AppLocalizations.of(context)!;

    if (value == null || value.isEmpty) {
      return tr.fieldRequired;
    }
    return null;
  }
}
