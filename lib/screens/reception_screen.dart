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
  // Initialisation optimisée des services et formateurs
  final ReceptionService _receptionService = ReceptionService();
  final NumberFormat _amountFormatter = NumberFormat('#,###', 'fr');
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy', 'fr');
  final ScrollController _scrollController = ScrollController();

  // États de données
  List<Reception> _receptions = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  double _totalAmount = 0;
  String _currency = 'GNF';

  // États de pagination
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _hasMoreData = true;

  // Cache pour les états de réception
  final Map<String, _StatusInfo> _statusCache = {
    'PENDING': _StatusInfo(Colors.orange, 'En attente'),
    'COMPLETED': _StatusInfo(Colors.green, 'Terminé'),
    'CANCELLED': _StatusInfo(Colors.red, 'Annulé'),
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // Écoute de défilement pour le chargement paresseux
  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll * 0.8 && !_isLoadingMore && _hasMoreData) {
      _loadMoreReceptions();
    }
  }

  // Chargement initial séparé
  Future<void> _loadInitialData() async {
    if (!mounted) return;

    try {
      // Simuler la pagination pour les réceptions (à implémenter côté API)
      final receptions = await _receptionService.getReceptionsPaginated(
        page: _currentPage,
        limit: _itemsPerPage,
      );

      if (!mounted) return;

      setState(() {
        _receptions = receptions.items;
        _hasMoreData = receptions.pagination.hasNext;
        _currency = (_receptions.isNotEmpty && _receptions.first.currency != null)
          ? _receptions.first.currency! : 'GNF';
        _isLoading = false;
      });

      // Charger les statistiques séparément
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

  // Chargement des statistiques
  Future<void> _loadStats() async {
    try {
      // Calculer le montant total (à remplacer par un appel d'API dédié)
      double total = 0;
      for (var reception in _receptions) {
        if (reception.amount != null) {
          total += reception.amount!;
        }
      }

      if (mounted) {
        setState(() {
          _totalAmount = total;
        });
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des statistiques: $e');
    }
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
        _currency = (_receptions.isNotEmpty && _receptions.first.currency != null)
          ? _receptions.first.currency! : 'GNF';
        _isLoading = false;
      });

      // Charger les statistiques séparément
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
                  child: Column(
                    children: [
                      Padding(
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
    final formattedAmount = _amountFormatter.format(_totalAmount);

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _receptions.length + (_hasMoreData ? 1 : 0),
      cacheExtent: 200, // Préchargement des éléments
      itemBuilder: (context, index) {
        // Si on est au dernier élément et qu'il y a plus de données, afficher un loader
        if (index == _receptions.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
    final formattedAmount = reception.amount != null
        ? _amountFormatter.format(reception.amount)
        : 'N/A';

    final formattedDate = _dateFormatter.format(reception.createdAt);

    // Utilisation du cache de statut
    final statusInfo = _statusCache[reception.status] ??
        _StatusInfo(Colors.grey, 'Inconnu');

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

// Classe utilitaire pour stocker les infos de statut
class _StatusInfo {
  final Color color;
  final String text;

  _StatusInfo(this.color, this.text);
}