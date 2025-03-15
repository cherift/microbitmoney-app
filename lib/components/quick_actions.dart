import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/screens/enrollment_screen.dart';
import 'package:bit_money/screens/pdv_list_screen.dart';
import 'package:bit_money/screens/receive/receive_transfer_screen.dart';
import 'package:bit_money/screens/send/send_transfer_operator_screen.dart';
import 'package:bit_money/services/auth_service.dart';
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
    {'icon': Icons.store_mall_directory, 'title': 'Nos PDVs', 'color': AppColors.lightSecondary},
  ];

  bool _isAdmin = false;
  bool _isLoading = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final session = await _authService.getStoredSession();
    setState(() {
      _isAdmin = session?.user?.role == 'ADMIN' || session?.user?.accountType == 'PROMOTEUR';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
      ? const Center(child: CircularProgressIndicator())
      : LayoutBuilder(
        builder: (context, constraints) {
          double buttonWidth = (constraints.maxWidth - 16) / 2;

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(_actions[0]['icon'], _actions[0]['title'], _actions[0]['color'], buttonWidth, true),
                  _buildActionButton(_actions[1]['icon'], _actions[1]['title'], _actions[1]['color'], buttonWidth, true)
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(_actions[2]['icon'], _actions[2]['title'], _actions[2]['color'], buttonWidth, _isAdmin),
                  _buildActionButton(_actions[3]['icon'], _actions[3]['title'], _actions[3]['color'], buttonWidth, true)
                ],
              ),
            ],
          );
        }
      );
  }

  Widget _buildActionButton(IconData icon, String title, Color color, double width, bool isEnabled) {
    return GestureDetector(
      onTap: isEnabled ? () {} : null,
      child: Container(
        width: width,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: .05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isEnabled ? () {
              switch (title) {
                case 'Envoyer':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SendTransferOperatorScreen(),
                    ),
                  );
                  break;
                case 'Recevoir':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReceiveTransferOperatorScreen(),
                    ),
                  );
                  break;
                case 'Enrôler':
                  if (_isAdmin) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EnrollmentScreen()
                      ),
                    );
                  }
                  break;
                case 'Nos PDVs':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PdvListScreen(),
                    ),
                  );
                  break;
              }
            } : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    size: 24,
                    color: isEnabled ? color : AppColors.darkGrey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isEnabled ? AppColors.almostBlack : AppColors.darkGrey,
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