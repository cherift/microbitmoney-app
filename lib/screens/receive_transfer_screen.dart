import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/models/operator_model.dart';
import 'package:bit_money/services/operator_service.dart';
import 'package:bit_money/screens/reception_reference_screen.dart';
import 'package:flutter/material.dart';

class ReceiveTransferOperatorScreen extends StatefulWidget {
  const ReceiveTransferOperatorScreen({super.key});

  @override
  State<ReceiveTransferOperatorScreen> createState() => _ReceiveTransferOperatorScreenState();
}

class _ReceiveTransferOperatorScreenState extends State<ReceiveTransferOperatorScreen> {
  final OperatorService _operatorService = OperatorService();
  List<Operator> _operators = [];
  bool _isLoading = true;
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
      setState(() {
        _operators = operators;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar("Impossible de charger les opérateurs");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _verifyReference() {
    if (_formKey.currentState!.validate() && _selectedOperator != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceptionReferenceScreen(
            operator: _selectedOperator!,
            referenceId: _referenceController.text,
          ),
        ),
      );
    } else if (_selectedOperator == null) {
      _showErrorSnackBar("Veuillez sélectionner un opérateur");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Recevoir un transfert',
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
                  _buildStepper(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildOperatorGrid(),
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

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepCircle('1', true, AppColors.secondary, Colors.white),
          _buildStepLine(Colors.grey.shade300),
          _buildStepCircle('2', false, Colors.grey.shade300, Colors.grey),
          _buildStepLine(Colors.grey.shade300),
          _buildStepCircle('3', false, Colors.grey.shade300, Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStepCircle(String text, bool isActive, Color bgColor, Color textColor) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: isActive ? null : Border.all(color: Colors.grey),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStepLine(Color color) {
    return Container(
      width: 70,
      height: 1,
      color: color,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildOperatorGrid() {
    List<Operator> activeOperators = _operators.where((operator) => operator.isActive).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: activeOperators.length,
          itemBuilder: (context, index) {
            final operator = activeOperators[index];
            final isSelected = _selectedOperator?.id == operator.id;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedOperator = operator;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.secondary : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: operator.logo.isNotEmpty
                            ? Image.network(
                                operator.logo,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                      strokeWidth: 2,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: Icon(Icons.business, color: Colors.grey.shade400),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey.shade200,
                                child: Icon(Icons.business, color: Colors.grey.shade400),
                              ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        operator.name.length > 9
                            ? operator.name.substring(0, 9)
                            : operator.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        textWidthBasis: TextWidthBasis.parent,
                        strutStyle: StrutStyle.disabled,
                        semanticsLabel: operator.name.substring(0, 9),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReferenceForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Numéro de référence',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _referenceController,
            decoration: InputDecoration(
              hintText: 'Entrez un code de transfert',
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
                return 'Veuillez entrer un numéro de référence';
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
              child: const Text(
                'Vérifier',
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