import 'package:bit_money/components/operator_grid.dart';
import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/models/operator_model.dart';
import 'package:bit_money/components/transfer_stepper.dart';
import 'package:bit_money/services/operator_service.dart';
import 'package:bit_money/screens/receive/reception_reference_screen.dart';
import 'package:bit_money/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bit_money/l10n/app_localizations.dart';

class ReceiveTransferOperatorScreen extends StatefulWidget {
  const ReceiveTransferOperatorScreen({super.key});

  @override
  State<ReceiveTransferOperatorScreen> createState() => _ReceiveTransferOperatorScreenState();
}

class _ReceiveTransferOperatorScreenState extends State<ReceiveTransferOperatorScreen> {
  final OperatorService _operatorService = OperatorService();
  final TransactionService _transactionService = TransactionService();
  Map<String, dynamic>? _transferDetails;

  List<Operator> _operators = [];
  bool _isLoading = true;
  bool _isVerifying = false;
  Operator? _selectedOperator;
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOperators();
  }

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _loadOperators() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final operators = await _operatorService.getOperators();
      if (mounted) {
        setState(() {
          _operators = operators;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar(AppLocalizations.of(context)!.operatorsLoadError);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _verifyReference() async {
    if (_formKey.currentState!.validate() && _selectedOperator != null) {
      setState(() {
        _isVerifying = true;
      });

      try {
        final response = await _transactionService.verifyTransaction(
          _selectedOperator!.code,
          _referenceController.text,
        );

        if (!mounted) return;

        if (response['success'] == false) {
          _showErrorSnackBar(response['error'] ?? AppLocalizations.of(context)!.errorOccured);
          return;
        }

        _transferDetails = response['data']?['transferDetails'];

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReceptionReferenceScreen(
                operator: _selectedOperator!,
                referenceId: _referenceController.text,
                transferDetails: _transferDetails,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar(AppLocalizations.of(context)!.errorOccured);
        }
      } finally {
        if (mounted) {
          setState(() {
            _isVerifying = false;
          });
        }
      }
    } else if (_selectedOperator == null) {
      _showErrorSnackBar(AppLocalizations.of(context)!.selectOperator);
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
          tr.receiveTransfer,
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
                    totalSteps: 3,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          OperatorGrid(
                            operators: _operators.where((operator) => operator.isActive).toList(),
                            onOperatorSelected: (operator) {
                              setState(() {
                                _selectedOperator = operator;
                              });
                            },
                            selectedOperator: _selectedOperator,
                          ),
                          const SizedBox(height: 24),
                          _buildReferenceForm(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildReferenceForm() {
    final tr = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr.referenceNumber,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _referenceController,
            decoration: InputDecoration(
              hintText: tr.enterTransferCode,
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
                return tr.enterReferenceNumber;
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
              });
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _verifyReference,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: _isVerifying
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    tr.verify,
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