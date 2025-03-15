import 'package:bit_money/components/operator_grid.dart';
import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/models/operator_model.dart';
import 'package:bit_money/models/transfer_data.dart';
import 'package:bit_money/models/user_model.dart';
import 'package:bit_money/components/transfer_stepper.dart';
import 'package:bit_money/screens/send/sender_information_form.dart';
import 'package:bit_money/services/auth_service.dart';
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
  UserModel? user;

  @override
  void initState() {
    super.initState();
    _apiService = TransferService();

    authService.getStoredSession().then((value) {
      setState(() {
        user = value?.user!;
        _amountData.pdvId = user?.pdv?.id;
      });
    }).catchError((error) {
      debugPrint('Error: $error');
    });

    _amountData.currency = 'GNF';
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
      _showErrorDialog('Erreur d\'initialisation: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Envoyer un transfert',
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

  Future<void> _verifyAmount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedOperator == null) {
      _showErrorSnackBar("Veuillez sélectionner un opérateur");
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (_selectedOperator != null) {
      if (amount < _selectedOperator!.minAmount) {
        _showErrorSnackBar('Le montant minimum est de ${_selectedOperator!.minAmount} GNF');
        return;
      }
      if (amount > _selectedOperator!.maxAmount) {
        _showErrorSnackBar('Le montant maximum est de ${_selectedOperator!.maxAmount} GNF');
        return;
      }
    }

    setState(() {
      _isProcessing = true;
      _amountData.amount = amount;
    });

    try {
      final response = await _apiService.submitAmount(_amountData.toAmountJson());

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
      _showErrorDialog('Erreur lors de la vérification du montant: ${e.toString()}');
    }
  }

  Widget buildAmountForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Montant (en GNF)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              hintText: 'Entrez le montant en GNF',
              suffixText: 'GNF',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
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
                borderSide: BorderSide(color: AppColors.secondary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un montant';
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
                  : const Text(
                      'Continuer',
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