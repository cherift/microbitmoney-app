import 'package:bit_money/components/operator_grid.dart';
import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/l10n/app_localizations.dart';
import 'package:bit_money/models/operator_model.dart';
import 'package:bit_money/models/transfer_data.dart';
import 'package:bit_money/components/transfer_stepper.dart';
import 'package:bit_money/screens/send/sender_information_form.dart';
import 'package:bit_money/services/auth/auth_service.dart';
import 'package:bit_money/services/operator_service.dart';
import 'package:bit_money/services/transfer_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SendTransferOperatorScreen extends StatefulWidget {
  const SendTransferOperatorScreen({super.key});

  @override
  State<SendTransferOperatorScreen> createState() => _SendTransferOperatorScreenState();
}

class _SendTransferOperatorScreenState extends State<SendTransferOperatorScreen> {
  late final TransferService _apiService;
  final OperatorService _operatorService = OperatorService();
  List<Operator> _operators = [];
  bool _isLoading = true;
  bool _isProcessing = false;
  final TransferData _amountData = TransferData();
  Operator? _selectedOperator;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final AuthService authService = AuthService();

  final List<String> _currencies = ['GNF', 'USD', 'SLL'];

  String _selectedCurrency = 'GNF';

  @override
  void initState() {
    super.initState();
    _apiService = TransferService();
    _amountData.currency = _selectedCurrency;
    _amountData.fees = 0;

    _initializeTransfer();
    _loadOperators();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _initializeTransfer() async {
    try {
      await _apiService.requestAuthorization();
    } catch (e) {
      if (!mounted) return;
      final tr = AppLocalizations.of(context)!;
      _showErrorDialog('${tr.errorOccured}: $e');
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
      if (!mounted) return;
      final tr = AppLocalizations.of(context)!;
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(tr.operatorsLoadError);
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
          tr.sendTransfer,
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
                  TransferStepper(
                    currentStep: 1,
                    totalSteps: 4,
                  ),
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
                                _amountData.operatorId = operator.id;
                                _amountData.operator = operator;
                              });
                            },
                            activeColor: AppColors.secondary,
                          ),
                          const SizedBox(height: 24),
                          buildAmountForm(),
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

  Future<void> _verifyAmount() async {
    final tr = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedOperator == null) {
      _showErrorSnackBar(tr.selectOperator);
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (_selectedOperator != null) {
      double checkAmount = amount;
      if (_selectedCurrency == 'USD') {
        checkAmount = amount * 9000;
      }

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
      _amountData.amount = amount;
      _amountData.currency = _selectedCurrency;
    });

    try {
      final session = await authService.getStoredSession();
      _amountData.pdvId = session?.user?.pdv?.id;
      final response = await _apiService.submitAmount(_amountData.toAmountJson());

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
            builder: (context) => SenderInformationForm(
              transferData: _amountData,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog('${tr.errorOccured}: ${e.toString()}');
    }
  }

  Widget buildAmountForm() {
    final tr = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr.amount,
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
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      hintText: tr.amountHint,
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return tr.enterAmount;
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

                // Séparateur vertical
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.grey.shade300,
                ),

                // Sélecteur de devise
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
                            _amountData.currency = newValue;
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
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _verifyAmount,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
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
                      tr.nextStep,
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