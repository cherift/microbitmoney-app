

import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/models/operator_model.dart';
import 'package:flutter/material.dart';

class OperatorGrid extends StatelessWidget {
  final List<Operator> operators;
  final Operator? selectedOperator;
  final Function(Operator) onOperatorSelected;
  final Color activeColor;
  final String title;
  final bool showTitle;

  const OperatorGrid({
    super.key,
    required this.operators,
    required this.onOperatorSelected,
    this.selectedOperator,
    this.activeColor = AppColors.secondary,
    this.title = 'Sélectionnez un opérateur',
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    List<Operator> activeOperators = operators.where((operator) => operator.isActive).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
        ],
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
            final isSelected = selectedOperator?.id == operator.id;

            return _buildOperatorItem(
              context: context,
              operator: operator,
              isSelected: isSelected,
              onTap: () => onOperatorSelected(operator),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOperatorItem({
    required BuildContext context,
    required Operator operator,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade300,
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
                child: _buildOperatorLogo(operator),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                _formatOperatorName(operator.name),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
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
  }

  Widget _buildOperatorLogo(Operator operator) {
    if (operator.logo.isNotEmpty) {
      return Image.network(
        operator.logo,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              color: activeColor,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: Icon(Icons.business, color: Colors.grey.shade400),
          );
        },
      );
    } else {
      return Container(
        color: Colors.grey.shade200,
        child: Icon(Icons.business, color: Colors.grey.shade400),
      );
    }
  }

  String _formatOperatorName(String name) {
    return name.length > 9 ? name.substring(0, 9) : name;
  }
}