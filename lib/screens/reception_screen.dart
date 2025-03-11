import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/models/reception_model.dart';
import 'package:bit_money/screens/reception_receipt_sreen.dart';
import 'package:bit_money/services/reception_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceptionsScreen extends StatefulWidget {
  const ReceptionsScreen({super.key});

  @override
  State<ReceptionsScreen> createState() => _ReceptionsScreenState();
}

class _ReceptionsScreenState extends State<ReceptionsScreen> {
  late ReceptionService _receptionService;
  List<Reception> _receptions = [];
  bool _isLoading = true;
  double _totalAmount = 0;
  String _currency = 'GNF';

  @override
  void initState() {
    super.initState();
    _receptionService = ReceptionService();
    _loadReceptions();
  }

  Future<void> _loadReceptions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final receptions = await _receptionService.getReceptions();
      receptions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      double total = 0;
      for (var reception in receptions) {
        if (reception.amount != null) {
          total += reception.amount!;
        }
      }

      final currency = (receptions.isNotEmpty && receptions.first.currency != null)
        ? receptions.first.currency! : 'GNF';

      setState(() {
        _receptions = receptions;
        _totalAmount = total;
        _currency = currency;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement des réceptions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
            onRefresh: _loadReceptions,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTotalAmountCard(),
                        const SizedBox(height: 24),
                        const Text(
                          'Liste des réceptions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildReceptionsList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildTotalAmountCard() {
    final formatter = NumberFormat('#,###', 'fr');
    final formattedAmount = formatter.format(_totalAmount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent,
            AppColors.accent.withValues(alpha: .8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Montant total des réceptions',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                _currency,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formattedAmount,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceptionsList() {
    if (_receptions.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(
              Icons.hourglass_empty,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune réception',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _receptions.length,
      itemBuilder: (context, index) {
        final reception = _receptions[index];
        return _buildReceptionCard(reception);
      },
    );
  }

  Widget _buildReceptionCard(Reception reception) {
    final formatter = NumberFormat('#,###', 'fr');
    final formattedAmount = reception.amount != null
        ? formatter.format(reception.amount)
        : 'N/A';

    final dateFormatter = DateFormat('dd/MM/yyyy', 'fr');
    final formattedDate = dateFormatter.format(reception.createdAt);

    Color statusColor;
    String statusText;

    switch (reception.status) {
      case 'PENDING':
        statusColor = Colors.orange;
        statusText = 'En attente';
        break;
      case 'COMPLETED':
        statusColor = Colors.green;
        statusText = 'Terminé';
        break;
      case 'CANCELLED':
        statusColor = Colors.red;
        statusText = 'Annulé';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Inconnu';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reception.referenceId,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${reception.operator.name} - $formattedAmount ${reception.currency ?? "GNF"}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${reception.pdv?.name ?? 'PDV'} - $formattedDate',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReceptionReceiptScreen(reception: reception),
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt_outlined, size: 18),
                  label: const Text('Voir les détails'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: BorderSide(color: AppColors.accent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}