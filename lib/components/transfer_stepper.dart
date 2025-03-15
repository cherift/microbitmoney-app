import 'package:bit_money/constants/app_colors.dart';
import 'package:flutter/material.dart';

class TransferStepper extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final double circleDiameter;
  final List<String>? stepLabels;

  const TransferStepper({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
    this.activeColor = AppColors.secondary,
    this.circleDiameter = 30,
    this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final totalCirclesWidth = circleDiameter * totalSteps;
    final availableWidthForLines = screenWidth - totalCirclesWidth - 60;
    final lineWidth = availableWidthForLines / (totalSteps - 1);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: AppColors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildStepperElements(context, lineWidth),
          ),
          if (stepLabels != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buildStepLabels(),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildStepperElements(BuildContext context, double lineWidth) {
    final List<Widget> elements = [];

    for (int i = 1; i <= totalSteps; i++) {
      // Ajouter le cercle d'étape
      final bool isActive = i <= currentStep;
      elements.add(
        _buildStepCircle(
          i.toString(),
          isActive,
          isActive ? activeColor : Colors.grey.shade300,
          isActive ? Colors.white : Colors.grey,
        ),
      );

      // Ajouter la ligne de connexion si ce n'est pas la dernière étape
      if (i < totalSteps) {
        elements.add(
          _buildStepLine(
            i < currentStep ? activeColor : Colors.grey.shade300,
            lineWidth,
          ),
        );
      }
    }

    return elements;
  }

  List<Widget> _buildStepLabels() {
    final List<Widget> labels = [];

    for (int i = 0; i < totalSteps; i++) {
      String label = '';
      if (stepLabels != null && i < stepLabels!.length) {
        label = stepLabels![i];
      } else {
        label = 'Étape ${i + 1}';
      }

      final bool isActive = i + 1 <= currentStep;

      labels.add(
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? activeColor : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ),
      );
    }

    return labels;
  }

  Widget _buildStepCircle(String text, bool isActive, Color bgColor, Color textColor) {
    return Container(
      width: circleDiameter,
      height: circleDiameter,
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
            fontSize: circleDiameter > 30 ? 16 : 12,
          ),
        ),
      ),
    );
  }

  Widget _buildStepLine(Color color, double width) {
    return Container(
      width: width,
      height: 1,
      color: color,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}