import 'package:bit_money/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class BottomNavBarWidget extends StatefulWidget {
  const BottomNavBarWidget({super.key});

  @override
  State<BottomNavBarWidget> createState() => _BottomNavBarWidgetState();
}

class _BottomNavBarWidgetState extends State<BottomNavBarWidget> {
  int _selectedIndex = 0; // Index de l'onglet actif

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home, 'label': 'Accueil'},
    {'icon': Icons.send, 'label': 'Transferts'},
    {'icon': Icons.insert_chart, 'label': 'Rapports'},
    {'icon': Icons.settings, 'label': 'Paramètres'},
  ];

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
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
        // Logique pour naviguer vers la page correspondante
      },
    );
  }
}