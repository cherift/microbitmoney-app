import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/screens/home_screen.dart';
import 'package:bit_money/screens/profile_screen.dart';
import 'package:bit_money/screens/reception_screen.dart';
import 'package:bit_money/screens/transaction_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class GeneralScreen extends StatefulWidget {
  const GeneralScreen({super.key});

  @override
  State<GeneralScreen> createState() => GeneralScreenState();
}

class GeneralScreenState extends State<GeneralScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home, 'page': HomePage()},
    {'icon': Icons.send, 'page': TransactionsScreen()},
    {'icon': Icons.download_for_offline, 'page': ReceptionsScreen()},
    {'icon': Icons.person_3, 'page': ProfileScreen()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: _navItems[_selectedIndex]['page'],
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: CurvedNavigationBar(
          backgroundColor: Colors.transparent,
          color: AppColors.secondary,
          buttonBackgroundColor: AppColors.primary,
          animationDuration: const Duration(milliseconds: 300),
          animationCurve: Curves.easeInOut,
          height: 60,
          index: _selectedIndex,
          items: _navItems.map((item) {
            return Icon(
              item['icon'],
              size: 30,
              color: AppColors.white
            );
          }).toList(),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}