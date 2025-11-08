import 'package:bit_money/components/transfer_stepper.dart';
import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/models/transfer_data.dart';
import 'package:bit_money/screens/send/send_confirmation_screen.dart';
import 'package:bit_money/services/transfer_service.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/services.dart';
import 'package:bit_money/l10n/app_localizations.dart';

class RecipientInformationForm extends StatefulWidget {
  final TransferData transferData;
  const RecipientInformationForm({super.key, required this.transferData});

  @override
  State<RecipientInformationForm> createState() => _RecipientInformationFormState();
}

class _RecipientInformationFormState extends State<RecipientInformationForm> {
  final _formKey = GlobalKey<FormState>();
  final TransferService _transferService = TransferService();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _selectedCountryController = TextEditingController();

  Country? _selectedCountry;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _selectedCountryController.dispose();
    super.dispose();
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
      final tr = AppLocalizations.of(context)!;
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

  Future<void> _continueToConfirmation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;

      widget.transferData.recipientFirstName = _firstNameController.text;
      widget.transferData.recipientLastName = _lastNameController.text;
      widget.transferData.recipientCountry = _selectedCountryController.text;
    });

    try {
      final response = await _transferService.submitRecipientInfo(widget.transferData.toRecipientJson());

      if (!mounted) return;

      if (response is Map<String, dynamic> && response.containsKey('success') && !response['success']) {
        _showErrorSnackBar(response['message'] ?? AppLocalizations.of(context)!.errorOccured);
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
            builder: (context) => SendConfirmationScreen(
              transferData: widget.transferData,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog('${AppLocalizations.of(context)!.senderInfoError}: ${e.toString()}');
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
              currentStep: 3,
              totalSteps: 4,
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

  Widget _buildRecipientForm() {
    final tr = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(tr.lastName, _lastNameController, validator: _requiredValidator),
        const SizedBox(height: 16),
        _buildTextField(tr.firstName, _firstNameController, validator: _requiredValidator),
        const SizedBox(height: 16),
        _buildCountrySelector(),
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
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.fieldRequired;
    }
    return null;
  }
}