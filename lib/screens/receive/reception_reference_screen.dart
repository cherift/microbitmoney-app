import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/models/operator_model.dart';
import 'package:bit_money/screens/receive/reception_confirmation_screen.dart';
import 'package:bit_money/components/transfer_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:country_picker/country_picker.dart';
import 'package:bit_money/l10n/app_localizations.dart';

class ReceptionReferenceScreen extends StatefulWidget {
  final Operator operator;
  final String referenceId;
  final dynamic transferDetails;

  const ReceptionReferenceScreen({
    super.key,
    required this.operator,
    required this.referenceId,
    this.transferDetails,
  });

  @override
  State<ReceptionReferenceScreen> createState() => _ReceptionReferenceScreenState();
}

class _ReceptionReferenceScreenState extends State<ReceptionReferenceScreen> {
  final _formKey = GlobalKey<FormState>();

  final String _currency = 'GNF';

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _idTypeController = TextEditingController(text: 'PASSPORT');
  final _idNumberController = TextEditingController();
  final _idIssueDateController = TextEditingController();
  final _idExpirationDateController = TextEditingController();
  final _idIssuingCountryNameController = TextEditingController();
  final _nationalityController = TextEditingController(text: 'GN');
  final _nationalityNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  final _selectedCountryController = TextEditingController();
  final _reasonController = TextEditingController(text: 'FAMILY');

  Country? _selectedCountry;
  Country? _selectedNationality;
  DateTime? _selectedBirthDate;
  DateTime? _selectedIdIssueDate;
  DateTime? _selectedIdExpirationDate;
  Country? _selectedIdIssuingCountry;

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

  Map<String, String> get _idTypeLabels {
    final tr = AppLocalizations.of(context)!;
    return {
      'PASSPORT': tr.passport,
      'CARTE_IDENTITE': tr.identityCard,
      'PERMIS': tr.drivingLicense,
      'AUTRE': tr.other
    };
  }

  Map<String, String> get _reasonLabels {
    final tr = AppLocalizations.of(context)!;
    return {
      'FAMILY': tr.familyAssistance,
      'BILL': tr.billPayment,
      'PURCHASE': tr.purchase,
      'OTHER': tr.other
    };
  }

  @override
  void initState() {
    super.initState();
    _initializeFromTransferDetails();
  }

  void _initializeFromTransferDetails() {
    final details = widget.transferDetails;
    if (details == null) return;

    _firstNameController.text = details['recipientFirstName'] ?? '';
    _lastNameController.text = details['recipientLastName'] ?? '';
    Country? country = CountryParser.tryParseCountryCode(details['recipientCountry']);
    _selectedCountryController.text = country?.name ?? '';
    _selectedCountry = country;

    final reason = details['reason'];
    if (reason != null && reason.toString().isNotEmpty) {
      if (!_reasons.contains(reason)) {
        _reasons.insert(_reasons.length - 1, reason);
      }
      _reasonController.text = reason;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _idTypeController.dispose();
    _idNumberController.dispose();
    _idIssueDateController.dispose();
    _idExpirationDateController.dispose();
    _idIssuingCountryNameController.dispose();
    _nationalityController.dispose();
    _nationalityNameController.dispose();
    _selectedCountryController.dispose();
    _reasonController.dispose();
    _birthDateController.dispose();
    _birthPlaceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
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

  Future<void> _selectIssueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedIdIssueDate ?? DateTime.now(),
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

    if (picked != null && picked != _selectedIdIssueDate) {
      setState(() {
        _selectedIdIssueDate = picked;
        _idIssueDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
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

  void _continueToConfirmation() {
    if (_formKey.currentState!.validate()) {
      final recipientData = {
        "recipientFirstName": _firstNameController.text,
        "recipientLastName": _lastNameController.text,
        "recipientPhone": _phoneController.text,
        "recipientAddress": _addressController.text,
        "recipientIdType": _idTypeController.text,
        "recipientIdNumber": _idNumberController.text,
        "recipientIdIssueDate": _selectedIdIssueDate?.toUtc().toIso8601String(),
        "recipientNationality": _nationalityController.text,
        "recipientBirthDate": _selectedBirthDate?.toUtc().toIso8601String(),
        "recipientIdExpiryDate": _selectedIdExpirationDate?.toUtc().toIso8601String(),
        "recipientBirthPlace": _birthPlaceController.text,
        "recipientCountry": _selectedCountryController.text,
        "recipientCountryCode": _selectedCountry?.countryCode ?? '',
        "recipientIdIssuingCountry": _idIssuingCountryNameController.text,
        "recipientIdIssuingCountryCode": _selectedIdIssuingCountry?.countryCode ?? '',
        "operatorId": widget.operator.id,
        "referenceId": widget.referenceId,
        "reason": _reasonLabels[_reasonController.text] ?? _reasonController.text,
        "amount": widget.transferDetails?["amount"],
        "currency": widget.transferDetails?["currency"],
        "senderLastName": widget.transferDetails?["senderLastName"],
        "senderFirstName": widget.transferDetails?["senderFirstName"],
        "senderCountry": widget.transferDetails?["senderCountry"],
        "transactionToken": widget.transferDetails?["transactionToken"],
        "orderNo": widget.transferDetails?["orderNo"],
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceptionConfirmationScreen(
            operator: widget.operator,
            recipientData: recipientData,
            currency: _currency,
          ),
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
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        title: Text(
          tr.recipientInformation,
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
              totalSteps: 3,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: _buildRecipientForm(),
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

  Widget _buildRecipientForm() {
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
        _buildTextField(tr.issueDate, _idIssueDateController,
          readOnly: true,
          onTap: () => _selectIssueDate(context),
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
          validator: _requiredValidator
        ),

        const SizedBox(height: 16),
        _buildTextField(tr.expiryDate, _idExpirationDateController,
          readOnly: true,
          onTap: () => _selectExpirationDate(context),
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
          validator: _expirationValidator
        ),

        const SizedBox(height: 16),
        _buildIssuingCountrySelector(),

        const SizedBox(height: 16),
        _buildTextField(tr.birthDate, _birthDateController,
          readOnly: true,
          onTap: () => _selectDate(context),
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

  Widget _buildIssuingCountrySelector() {
    final tr = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr.issuingCountry,
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
              favorite: ['GN'],
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
                  _selectedIdIssuingCountry = country;
                  _idIssuingCountryNameController.text = country.name;
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
                if (_selectedIdIssuingCountry != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    _selectedIdIssuingCountry!.flagEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    _idIssuingCountryNameController.text,
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
              favorite: ['GN'],
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
          tr.residenceCountry,
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
              favorite: ['GN'],
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
              borderSide: BorderSide(color: AppColors.secondary),
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
              onPressed: () => Navigator.pop(context),
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
              onPressed: _continueToConfirmation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: Text(
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

  // Validateurs
  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.fieldRequired;
    }
    return null;
  }

  String? _expirationValidator(String? value) {
    final tr = AppLocalizations.of(context)!;

    if (value == null || value.isEmpty) {
      return tr.fieldRequired;
    }
    final expirationDate = DateFormat('dd/MM/yyyy').parse(value, true);
    if (expirationDate.isBefore(DateTime.now())) {
      return tr.futureExpiryDate;
    }
    return null;
  }
}
