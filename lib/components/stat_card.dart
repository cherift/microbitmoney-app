import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/l10n/app_localizations.dart';
import 'package:bit_money/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatCardsWidget extends StatefulWidget {
  const StatCardsWidget({
    super.key,
  });

  @override
  State<StatCardsWidget> createState() => _StatCardsWidgetState();
}

class _StatCardsWidgetState extends State<StatCardsWidget> {
  String transactionCount = '0';
  String commissionAmount = '0';
  bool isLoading = true;
  String currencySymbol = 'GNF';

  late TransactionService _transactionService;

  @override
  void initState() {
    super.initState();
    _transactionService = TransactionService();
    _loadTransactionStats();
  }

  Future<void> _loadTransactionStats() async {
    try {
      final stats = await _transactionService.getTransactionStats();

      final locale = Localizations.localeOf(context).languageCode;
      final formatter = NumberFormat('#,###', locale);

      setState(() {
        transactionCount = formatter.format(stats.weeklyTransactionCount);
        commissionAmount = formatter.format(stats.monthlyCommissionTotal);
        currencySymbol = stats.currencySymbol;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> refresh() async {
    setState(() {
      isLoading = true;
    });
    await _loadTransactionStats();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return isLoading
      ? const Center(child: CircularProgressIndicator())
      : Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildGradientStatCard(
                title: tr.transactions,
                value: transactionCount,
                growth: tr.thisWeek,
                gradientStart: AppColors.secondary,
                gradientEnd: AppColors.lightSecondary,
                icon: Icons.trending_up,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: _buildGradientStatCard(
                title: tr.total,
                value: commissionAmount,
                growth: tr.thisMonth,
                gradientStart: AppColors.primary,
                gradientEnd: AppColors.darkPrimary,
                currencySymbol: currencySymbol,
              ),
            ),
          ],
        );
  }

  Widget _buildGradientStatCard({
    required String title,
    required String value,
    required String growth,
    required Color gradientStart,
    required Color gradientEnd,
    IconData? icon,
    String? currencySymbol,
  }) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            title == AppLocalizations.of(context)!.transactions ? AppColors.secondary : AppColors.primary,
            title == AppLocalizations.of(context)!.transactions ? AppColors.lightSecondary : AppColors.darkPrimary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: (title == AppLocalizations.of(context)!.transactions ? AppColors.secondary : AppColors.primary).withValues(alpha: .3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                icon != null
                  ? Icon(
                    icon,
                    color: Colors.white.withValues(alpha: .9),
                    size: 16,
                  )
                  : Text(
                    currencySymbol ?? AppLocalizations.of(context)!.currency,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w100,
                    ),
                  )
                ,
                const SizedBox(width: 4),
                Text(
                  growth,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}