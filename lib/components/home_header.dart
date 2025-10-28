import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/l10n/app_localizations.dart';
import 'package:bit_money/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({super.key});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  final session = AuthService().getStoredSession();
  String? _username = '';

  @override
  void initState() {
    AuthService().getStoredSession().then((value) {
      _username = value?.user?.firstName;
      setState(() {});
    }).catchError((error) {
      debugPrint('Error: $error');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${tr.hello} $_username,',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.almostBlack,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tr.welcome,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
