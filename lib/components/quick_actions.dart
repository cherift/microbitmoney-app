import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/l10n/app_localizations.dart';
import 'package:bit_money/screens/devis_list_screen.dart';
import 'package:bit_money/screens/enrollment_screen.dart';
import 'package:bit_money/screens/pdv_list_screen.dart';
import 'package:bit_money/screens/receive/receive_transfer_screen.dart';
import 'package:bit_money/screens/send/send_transfer_operator_screen.dart';
import 'package:bit_money/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class QuickActionsWidget extends StatefulWidget {
  const QuickActionsWidget({super.key});

  @override
  State<QuickActionsWidget> createState() => _QuickActionsWidgetState();
}

class _QuickActionsWidgetState extends State<QuickActionsWidget> {
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

  List<Map<String, dynamic>> _getActions(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    return [
      {'icon': Icons.send, 'title': tr.send, 'color': AppColors.primary},
      {'icon': Icons.download, 'title': tr.receive, 'color': AppColors.secondary},
      {'icon': Icons.add_circle_outline, 'title': tr.enroll, 'color': AppColors.secondary},
      {'icon': Icons.store_mall_directory, 'title': tr.ourPdv, 'color': AppColors.lightSecondary},
      {'icon': Icons.currency_exchange_rounded, 'title': tr.quote, 'color': Colors.green},
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final actions = _getActions(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        double buttonWidth = (constraints.maxWidth - 16) / 2;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(actions[0]['icon'], actions[0]['title'], actions[0]['color'], buttonWidth, true),
                _buildActionButton(actions[1]['icon'], actions[1]['title'], actions[1]['color'], buttonWidth, true)
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_isAdmin)
                  _buildActionButton(actions[2]['icon'], actions[2]['title'], actions[2]['color'], buttonWidth, _isAdmin),
                if (!_isAdmin)
                  _buildActionButton(actions[4]['icon'], actions[4]['title'], actions[4]['color'], buttonWidth, true),
                _buildActionButton(actions[3]['icon'], actions[3]['title'], actions[3]['color'], buttonWidth, true)
              ],
            ),
            if (_isAdmin) ... [
              const SizedBox(height: 16),
              _buildActionButton(actions[4]['icon'], actions[4]['title'], actions[4]['color'], buttonWidth, true),
            ],
          ],
        );
      }
    );
  }

  Widget _buildActionButton(IconData icon, String title, Color color, double width, bool isEnabled) {
    // Récupérer les traductions pour le switch case
    final tr = AppLocalizations.of(context)!;
    final sendText = tr.send;
    final receiveText = tr.receive;
    final enrollText = tr.enroll;
    final ourPdvText = tr.ourPdv;
    final quoteText = tr.quote;

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
              if (title == sendText) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SendTransferOperatorScreen(),
                  ),
                );
              } else if (title == receiveText) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReceiveTransferOperatorScreen(),
                  ),
                );
              } else if (title == enrollText) {
                if (_isAdmin) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EnrollmentScreen()
                    ),
                  );
                }
              } else if (title == ourPdvText) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdvListScreen(),
                  ),
                );
              } else if (title == quoteText) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DevisListScreen(),
                  ),
                );
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