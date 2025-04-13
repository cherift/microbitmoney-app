import 'package:bit_money/components/operator_grid.dart';
import 'package:bit_money/constants/app_colors.dart';
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
  final _selectedCountryController = TextEditingController(text: 'Guinée');

  final List<String> _currencies = ['GNF', 'USD'];
  String _selectedCurrency = 'GNF';
  String _recipientCurrency = 'GNF';
  Country? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _loadOperators();
    _initDefaultCountry();
    _sendAmountController.addListener(_onSendAmountChanged);
    _receiveAmountController.addListener(_onReceiveAmountChanged);
  }

  void _initDefaultCountry() {
    try {
      final List<Country> countries = CountryService().getAll();
      final Country guinea = countries.firstWhere(
        (country) => country.countryCode == 'GN',
        orElse: () => countries.first,
      );

      setState(() {
        _selectedCountry = guinea;
        _selectedCountryController.text = guinea.name;
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
      setState(() {
        _operators = operators;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog("Impossible de charger les opérateurs");
    }
  }

  Future<void> _submitDevis() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedOperator == null) {
      _showErrorSnackBar("Veuillez sélectionner un opérateur");
      return;
    }

    bool isSendAmountFilled = _sendAmountController.text.isNotEmpty;
    bool isReceiveAmountFilled = _receiveAmountController.text.isNotEmpty;

    if (!isSendAmountFilled && !isReceiveAmountFilled) {
      _showErrorSnackBar("Veuillez renseigner un des montants");
      return;
    }

    if (isSendAmountFilled && isReceiveAmountFilled) {
      _showErrorSnackBar("Veuillez renseigner un seul montant (à envoyer OU à recevoir)");
      return;
    }

    final sendAmount = _sendAmountController.text.isNotEmpty
        ? double.tryParse(_sendAmountController.text)
        : null;

    if (sendAmount != null && _selectedOperator != null) {
      double checkAmount = sendAmount;
      if (_selectedCurrency == 'USD') {
        checkAmount = sendAmount * 9000;
      }

      if (checkAmount < _selectedOperator!.minAmount) {
        _showErrorSnackBar('Le montant minimum est de ${_selectedOperator!.minAmount} GNF');
        return;
      }
      if (checkAmount > _selectedOperator!.maxAmount) {
        _showErrorSnackBar('Le montant maximum est de ${_selectedOperator!.maxAmount} GNF');
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
          const SnackBar(
            content: Text('Demande de devis envoyée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog('Erreur lors de la création du devis: ${e.toString()}');
    }
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
          'Nouveau devis',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SafeArea(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pays de réception',
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
                  hintText: 'Rechercher un pays',
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
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Montant à envoyer',
            style: TextStyle(
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
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      hintText: 'Entrez le montant à envoyer',
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

                      final amount = int.tryParse(value);
                      if (amount == null) {
                        return 'Veuillez entrer un montant valide';
                      }

                      if (amount <= 0) {
                        return 'Le montant doit être supérieur à 0';
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
              child: const Text(
                'OU',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
          ),

          const Text(
            'Montant à recevoir',
            style: TextStyle(
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
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      hintText: 'Entrez le montant à recevoir',
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

                      final amount = int.tryParse(value);
                      if (amount == null) {
                        return 'Veuillez entrer un montant valide';
                      }

                      if (amount <= 0) {
                        return 'Le montant doit être supérieur à 0';
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
                  : const Text(
                      'Demander un devis',
                      style: TextStyle(
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