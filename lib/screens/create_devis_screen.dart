import 'package:bit_money/components/operator_grid.dart';
import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/l10n/app_localizations.dart';
import 'package:bit_money/models/operator_model.dart';
import 'package:bit_money/services/devis_service.dart';
import 'package:bit_money/services/operator_service.dart';
import 'package:country_currency_pickers/utils/utils.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateDevisScreen extends StatefulWidget {
  const CreateDevisScreen({super.key});

  @override
  State<CreateDevisScreen> createState() => _CreateDevisScreenState();
}

class _CreateDevisScreenState extends State<CreateDevisScreen> {
  final DevisService _devisService = DevisService();
  final OperatorService _operatorService = OperatorService();
  List<Operator> _operators = [];
  bool _isLoading = true;
  bool _isProcessing = false;
  Operator? _selectedOperator;
  final _formKey = GlobalKey<FormState>();
  final _sendAmountController = TextEditingController();
  final _receiveAmountController = TextEditingController();
  final _selectedCountryController = TextEditingController();
  bool _initialLoadDone = false;

  final List<String> _currencies = ['GNF', 'USD', 'SLL'];
  String _selectedCurrency = 'GNF';
  String _recipientCurrency = 'GNF';
  Country? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _initDefaultCountry();
    _sendAmountController.addListener(_onSendAmountChanged);
    _receiveAmountController.addListener(_onReceiveAmountChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialLoadDone) {
      _loadOperators();
      _initialLoadDone = true;
    }
  }

  void _initDefaultCountry() {
    try {
      final List<Country> countries = CountryService().getAll();
      final Country guinea = countries.firstWhere(
        (country) => country.countryCode == 'GN',
        orElse: () => countries.first,
      );

      final countryName = CountryLocalizations.of(context)!.countryName(countryCode: guinea.countryCode) ?? guinea.name;

      setState(() {
        _selectedCountry = guinea;
        _selectedCountryController.text = countryName;
        _recipientCurrency = CountryPickerUtils.getCountryByIsoCode(guinea.countryCode).currencyCode ?? 'GNF';
      });
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation du pays: $e');
    }
  }

  @override
  void dispose() {
    _sendAmountController.removeListener(_onSendAmountChanged);
    _receiveAmountController.removeListener(_onReceiveAmountChanged);

    _sendAmountController.dispose();
    _receiveAmountController.dispose();
    _selectedCountryController.dispose();
    super.dispose();
  }

  void _onSendAmountChanged() {
    if (_sendAmountController.text.isNotEmpty && _receiveAmountController.text.isNotEmpty) {
      setState(() {
        _receiveAmountController.text = '';
      });
    }
  }

  void _onReceiveAmountChanged() {
    if (_receiveAmountController.text.isNotEmpty && _sendAmountController.text.isNotEmpty) {
      setState(() {
        _sendAmountController.text = '';
      });
    }
  }

  Future<void> _loadOperators() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final operators = await _operatorService.getOperators();

      if (!mounted) return;

      setState(() {
        _operators = operators;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      final tr = AppLocalizations.of(context)!;
      _showErrorDialog(tr.operatorsLoadError);
    }
  }

  Future<void> _submitDevis() async {
    final tr = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedOperator == null) {
      _showErrorSnackBar(tr.selectOperator);
      return;
    }

    bool isSendAmountFilled = _sendAmountController.text.isNotEmpty;
    bool isReceiveAmountFilled = _receiveAmountController.text.isNotEmpty;
    bool isCountrySelected = _selectedCountryController.text.isNotEmpty;

    if (!isCountrySelected) {
      _showErrorSnackBar(tr.selectRecipientCountry);
      return;
    }

    if (!isSendAmountFilled && !isReceiveAmountFilled) {
      _showErrorSnackBar(tr.enterAmount);
      return;
    }

    if (isSendAmountFilled && isReceiveAmountFilled) {
      _showErrorSnackBar(tr.enterOnlyOneAmount);
      return;
    }

    final sendAmount = _sendAmountController.text.isNotEmpty
        ? double.tryParse(_sendAmountController.text)
        : null;

    if (sendAmount != null && _selectedOperator != null) {
      double checkAmount = sendAmount;

      if (checkAmount < _selectedOperator!.minAmount) {
        _showErrorSnackBar(tr.minimumAmount(_selectedOperator!.minAmount.toString()));
        return;
      }

      if (checkAmount > _selectedOperator!.maxAmount) {
        _showErrorSnackBar(tr.maximumAmount(_selectedOperator!.maxAmount.toString()));
        return;
      }
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      Map<String, dynamic> devisData = {
        "operatorId": _selectedOperator!.id,
        "currency": _selectedCurrency,
        "recipientCountry": _selectedCountryController.text,
        "recipientCurrency": _recipientCurrency,
      };

      if (_sendAmountController.text.isNotEmpty) {
        devisData["amountToSend"] = double.parse(_sendAmountController.text);
        devisData["amountToReceive"] = null;
      } else {
        devisData["amountToSend"] = null;
        devisData["amountToReceive"] = double.parse(_receiveAmountController.text);
      }

      await _devisService.createDevis(devisData);

      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr.quoteRequestSuccess),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog(tr.quoteCreationError(e.toString()));
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
          tr.newQuote,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SafeArea(
              bottom: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          OperatorGrid(
                            operators: _operators.where((operator) => operator.isActive).toList(),
                            selectedOperator: _selectedOperator,
                            onOperatorSelected: (operator) {
                              setState(() {
                                _selectedOperator = operator;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                          const SizedBox(height: 24),
                          buildDevisForm(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
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

  Widget _buildCountrySelector() {
    final tr = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr.recipientCountry,
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
                final countryName = CountryLocalizations.of(context)!.countryName(countryCode: country.countryCode) ?? country.name;

                setState(() {
                  _selectedCountry = country;
                  _selectedCountryController.text = countryName;
                  _recipientCurrency = CountryPickerUtils.getCountryByIsoCode(country.countryCode).currencyCode ?? 'GNF';
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

  Widget buildDevisForm() {
    final tr = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr.amountToSend,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _sendAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      hintText: tr.enterAmountToSend,
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null;
                      }

                      final amount = double.tryParse(value);
                      if (amount == null) {
                        return tr.enterValidAmount;
                      }

                      if (amount <= 0) {
                        return tr.amountGreaterThanZero;
                      }

                      return null;
                    },
                  ),
                ),

                Container(
                  height: 30,
                  width: 1,
                  color: Colors.grey.shade300,
                ),

                Container(
                  padding: const EdgeInsets.only(left: 8, right: 4),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCurrency,
                      isDense: true,
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.darkGrey),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCurrency = newValue;
                          });
                        }
                      },
                      items: _currencies.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                tr.or,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
          ),

          Text(
            tr.amountToReceive,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _receiveAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      hintText: tr.enterAmountToReceive,
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null;
                      }

                      final amount = double.tryParse(value);
                      if (amount == null) {
                        return tr.enterValidAmount;
                      }

                      if (amount <= 0) {
                        return tr.amountGreaterThanZero;
                      }

                      return null;
                    },
                  ),
                ),

                Container(
                  height: 30,
                  width: 1,
                  color: Colors.grey.shade300,
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    _recipientCurrency,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildCountrySelector(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _submitDevis,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
                      tr.requestQuote,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
