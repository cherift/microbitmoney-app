import 'package:bit_money/components/home_header.dart';
import 'package:bit_money/components/notifications.dart';
import 'package:bit_money/components/quick_actions.dart';
import 'package:bit_money/components/stat_card.dart';
import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/screens/bottom_navigation.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 12),
                  HeaderWidget(),
                  SizedBox(height: 24),
                  StatCardsWidget(),
                  SizedBox(height: 24),
                  QuickActionsWidget(),
                  SizedBox(height: 24),
                  RecentNotificationsWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBarWidget(),
    );
  }
}