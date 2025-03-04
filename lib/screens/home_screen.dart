import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/screens/login_screen.dart';
import 'package:bit_money/services/auth_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BIT-MO'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService().logout().then((_) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              });
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Bienvenue sur la page d\'accueil !'),
      ),
    );
  }
}