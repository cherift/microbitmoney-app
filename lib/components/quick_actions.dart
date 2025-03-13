import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/screens/receive_transfer_screen.dart';
import 'package:flutter/material.dart';

class QuickActionsWidget extends StatefulWidget {
  const QuickActionsWidget({super.key});

  @override
  State<QuickActionsWidget> createState() => _QuickActionsWidgetState();
}

class _QuickActionsWidgetState extends State<QuickActionsWidget> {
  final List<Map<String, dynamic>> _actions = [
    {'icon': Icons.send, 'title': 'Envoyer', 'color': AppColors.primary},
    {'icon': Icons.download, 'title': 'Recevoir', 'color': AppColors.secondary},
    {'icon': Icons.add_circle_outline, 'title': 'Enrôler', 'color': AppColors.secondary},
    {'icon': Icons.insert_chart_outlined, 'title': 'Rapports', 'color': AppColors.lightSecondary},
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double buttonWidth = (constraints.maxWidth - 16) / 2;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(_actions[0]['icon'], _actions[0]['title'], _actions[0]['color'], buttonWidth),
                _buildActionButton(_actions[1]['icon'], _actions[1]['title'], _actions[1]['color'], buttonWidth)
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(_actions[2]['icon'], _actions[2]['title'], _actions[2]['color'], buttonWidth),
                _buildActionButton(_actions[3]['icon'], _actions[3]['title'], _actions[3]['color'], buttonWidth)
              ],
            ),
          ],
        );
      }
    );
  }

  Widget _buildActionButton(IconData icon, String title, Color color, double width) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: width,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              switch (title) {
                case 'Envoyer':
                  // Logique pour l'envoi
                  break;
                case 'Recevoir':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReceiveTransferOperatorScreen(),
                    ),
                  );
                  break;
                case 'Enrôler':
                  // Logique pour l'enrôlement
                  break;
                case 'Rapports':
                  // Logique pour les rapports
                  break;
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    size: 24,
                    color: color,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.almostBlack,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

