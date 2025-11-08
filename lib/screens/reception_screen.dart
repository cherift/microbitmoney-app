import 'package:bit_money/l10n/app_localizations.dart';
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
  final ReceptionService _receptionService = ReceptionService();
  late NumberFormat _amountFormatter;
  late DateFormat _dateFormatter;
  final ScrollController _scrollController = ScrollController();

  List<Reception> _receptions = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  Map<String, double> _currencyTotals = {};

  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final locale = Localizations.localeOf(context).languageCode;
    _amountFormatter = NumberFormat('#,###', locale);
    _dateFormatter = DateFormat('dd/MM/yyyy', locale);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  _StatusInfo _getStatusInfo(String status) {
    final tr = AppLocalizations.of(context)!;

    switch (status) {
      case 'PENDING':
        return _StatusInfo(Colors.orange, tr.statusPending);
      case 'COMPLETED':
        return _StatusInfo(Colors.green, tr.statusCompleted);
      case 'CANCELLED':
        return _StatusInfo(Colors.red, tr.statusCancelled);
      default:
        return _StatusInfo(Colors.grey, status);
    }
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll * 0.8 && !_isLoadingMore && _hasMoreData) {
      _loadMoreReceptions();
    }
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    try {
      final receptions = await _receptionService.getReceptionsPaginated(
        page: _currentPage,
        limit: _itemsPerPage,
      );

      if (!mounted) return;

      setState(() {
        _receptions = receptions.items;
        _hasMoreData = receptions.pagination.hasNext;
        _isLoading = false;
      });

      _loadStats();
    } catch (e) {
      debugPrint('Erreur lors du chargement des réceptions: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _receptionService.getReceptionStats(forceRefresh: false);

      if (mounted) {
        setState(() {
          _currencyTotals = stats.currencyTotals;

          if (_currencyTotals.isEmpty) {
            _calculateCurrencyTotals();
          }
        });
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des statistiques: $e');
      if (mounted) {
        setState(() {
          _calculateCurrencyTotals();
        });
      }
    }
  }

  void _calculateCurrencyTotals() {
    Map<String, double> totals = {};

    for (var reception in _receptions) {
      if (reception.status == 'COMPLETED' && reception.amount != null) {
        String currency = reception.currency ?? 'GNF';
        totals[currency] = (totals[currency] ?? 0) + reception.amount!;
      }
    }

    if (totals.isEmpty) {
      totals['GNF'] = 0;
    }

    _currencyTotals = totals;
  }

  Future<void> _loadReceptions() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
    });

    try {
      final receptions = await _receptionService.getReceptionsPaginated(
        page: _currentPage,
        limit: _itemsPerPage,
      );

      if (!mounted) return;

      setState(() {
        _receptions = receptions.items;
        _hasMoreData = receptions.pagination.hasNext;
        _isLoading = false;
      });

      _loadStats();
    } catch (e) {
      debugPrint('Erreur lors du chargement des réceptions: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreReceptions() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final receptions = await _receptionService.getReceptionsPaginated(
        page: nextPage,
        limit: _itemsPerPage,
      );

      if (!mounted) return;

      setState(() {
        _receptions.addAll(receptions.items);
        _currentPage = nextPage;
        _hasMoreData = receptions.pagination.hasNext;
        _isLoadingMore = false;
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement de plus de réceptions: $e');
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

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
                  bottom: true,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTotalAmountCard(),
                            const SizedBox(height: 24),
                            Text(
                              tr.receptionList,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _buildReceptionsList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTotalAmountCard() {
    final tr = AppLocalizations.of(context)!;

    String formatCurrencyAmount(String currency, double amount) {
      if (currency == 'GNF' && amount >= 1000000 && _currencyTotals.length > 1) {
        final inMillions = amount / 1000000;
        return '${_amountFormatter.format(inMillions)} M';
      }
      return _amountFormatter.format(amount);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr.totalReceptionAmount,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: _currencyTotals.entries.map((entry) {
              final currency = entry.key;
              final amount = entry.value;
              final formattedAmount = formatCurrencyAmount(currency, amount);

              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currency,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedAmount,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReceptionsList() {
    final tr = AppLocalizations.of(context)!;

    if (_receptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              tr.noReceptions,
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
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _receptions.length + (_hasMoreData ? 1 : 0),
      cacheExtent: 200,
      itemBuilder: (context, index) {
        if (index == _receptions.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final reception = _receptions[index];
        return _buildReceptionCard(reception);
      },
    );
  }

  Widget _buildReceptionCard(Reception reception) {
    final tr = AppLocalizations.of(context)!;

    final formattedAmount = reception.amount != null
        ? _amountFormatter.format(reception.amount)
        : 'N/A';

    final formattedDate = _dateFormatter.format(reception.createdAt);

    final statusInfo = _getStatusInfo(reception.status);

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
                        '${reception.pdv?.name ?? tr.pdv} - $formattedDate',
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
                    color: statusInfo.color.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    statusInfo.text,
                    style: TextStyle(
                      color: statusInfo.color,
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
                  label: Text(tr.viewReceipt),
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

class _StatusInfo {
  final Color color;
  final String text;

  _StatusInfo(this.color, this.text);
}