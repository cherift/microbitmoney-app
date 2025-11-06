import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/l10n/app_localizations.dart';
import 'package:bit_money/models/devis_model.dart';
import 'package:bit_money/models/session_model.dart';
import 'package:bit_money/screens/create_devis_screen.dart';
import 'package:bit_money/services/auth/auth_service.dart';
import 'package:bit_money/services/devis_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DevisListScreen extends StatefulWidget {
  const DevisListScreen({super.key});

  @override
  State<DevisListScreen> createState() => _DevisListScreenState();
}

class _DevisListScreenState extends State<DevisListScreen> with SingleTickerProviderStateMixin {
  final DevisService _devisService = DevisService();
  List<Devis> _devisList = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final AuthService authService = AuthService();
  bool _initialLoadDone = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialLoadDone) {
      _loadDevis();
      _initialLoadDone = true;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDevis() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final SessionModel? session = await authService.getStoredSession();

      final devis = await _devisService.getDevis(session?.user?.id ?? '');

      if (!mounted) return;

      setState(() {
        _devisList = devis;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      final errorMessage = AppLocalizations.of(context)!.loadQuotesError(e.toString());
      _showErrorMessage(errorMessage, context);
    }
  }

  void _showErrorMessage(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showDevisDetails(Devis devis) {
    final tr = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height / .5,
        maxWidth: isTablet ? screenWidth * 0.7 : double.infinity,
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Row(
                  children: [
                    const Icon(Icons.receipt, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tr.quoteNumber(devis.id.toString()),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 400) {
                      return Column(
                        children: [
                          _buildInfoCard(
                            icon: Icons.upload_outlined,
                            title: tr.amountToSend,
                            content: devis.amountToSend != null
                              ? '${devis.amountToSend} ${devis.currency}'
                              : devis.reponseDevis != null
                                ? '${devis.reponseDevis!.amountToSend} ${devis.reponseDevis!.currency}'
                                : tr.notDefined,
                            iconColor: AppColors.primary,
                            fullWidth: true,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: Icons.download_outlined,
                            title: tr.amountToReceive,
                            content: devis.amountToReceive != null
                              ? '${devis.amountToReceive} ${devis.recipientCurrency}'
                              : devis.reponseDevis != null
                                ? '${devis.reponseDevis!.amountToReceive} ${devis.reponseDevis!.receiveCurrency}'
                                : tr.notDefined,
                            iconColor: AppColors.primary,
                            fullWidth: true,
                          ),
                        ],
                      );
                    } else {
                      return IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                icon: Icons.upload_outlined,
                                title: tr.amountToSend,
                                content: devis.amountToSend != null
                                  ? '${devis.amountToSend} ${devis.currency}'
                                  : devis.reponseDevis != null
                                    ? '${devis.reponseDevis!.amountToSend} ${devis.reponseDevis!.currency}'
                                    : tr.notDefined,
                                iconColor: AppColors.primary,
                                fullWidth: false,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCard(
                                icon: Icons.download_outlined,
                                title: tr.amountToReceive,
                                content: devis.amountToReceive != null
                                  ? '${devis.amountToReceive} ${devis.recipientCurrency}'
                                  : devis.reponseDevis != null
                                    ? '${devis.reponseDevis!.amountToReceive} ${devis.reponseDevis!.receiveCurrency}'
                                    : tr.notDefined,
                                iconColor: AppColors.primary,
                                fullWidth: false,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),

                if (devis.reponseDevis != null)
                  _buildDetailSection(
                    icon: Icons.money,
                    title: tr.fees,
                    content: '${devis.reponseDevis!.fees} ${devis.reponseDevis!.currency}',
                  ),

                _buildDetailSection(
                  icon: Icons.location_on,
                  title: tr.recipientCountry,
                  content: devis.recipientCountry,
                ),

                _buildDetailSection(
                  icon: Icons.business,
                  title: tr.operator,
                  content: devis.operateur.name,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color iconColor,
    required bool fullWidth,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildDevisItem(Devis devis) {
    final tr = AppLocalizations.of(context)!;
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: devis.reponseDevis != null
                ? Colors.green.withValues(alpha: .1)
                : AppColors.primary.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              Icons.receipt_outlined,
              color: devis.reponseDevis != null
                ? Colors.green
                : AppColors.primary,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      devis.amountToSend != null
                          ? '${devis.amountToSend} ${devis.currency}'
                          : devis.reponseDevis != null
                              ? '${devis.reponseDevis!.amountToSend} ${devis.reponseDevis!.currency}'
                              : '-- ${devis.currency}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Text(
                    ' → ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      devis.amountToReceive != null
                          ? '${devis.amountToReceive} ${devis.recipientCurrency}'
                          : devis.reponseDevis != null
                              ? '${devis.reponseDevis!.amountToReceive} ${devis.reponseDevis!.receiveCurrency}'
                              : '-- ${devis.recipientCurrency}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      devis.recipientCountry,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.darkGrey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (devis.reponseDevis != null) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '• ${tr.fees}: ${devis.reponseDevis!.fees} ${devis.reponseDevis!.currency}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.darkGrey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.darkGrey,
        ),
      ],
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final currentTime = "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          tr.quotesList,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.secondary,
          statusBarIconBrightness: Brightness.light,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () => _loadDevis(),
          ),
        ],
      ),
      body: _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          )
        : FadeTransition(
            opacity: _fadeAnimation,
            child: RefreshIndicator(
              onRefresh: () => _loadDevis(),
              color: AppColors.primary,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tr.quotesCount(_devisList.length),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        Text(
                          tr.lastUpdate(currentTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.darkGrey.withValues(alpha: .7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: _devisList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 64,
                                  color: AppColors.darkGrey.withValues(alpha: .3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  tr.noQuoteAvailable,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkGrey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Text(
                                    tr.createNewQuote,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.darkGrey.withValues(alpha: .7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth > 600) {
                                return GridView.builder(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: constraints.maxWidth > 900 ? 3 : 2,
                                    childAspectRatio: 3,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                                  itemCount: _devisList.length,
                                  padding: const EdgeInsets.all(16),
                                  itemBuilder: (context, index) {
                                    final devis = _devisList[index];
                                    return Material(
                                      borderRadius: BorderRadius.circular(16),
                                      elevation: 1,
                                      color: Colors.white,
                                      child: InkWell(
                                        onTap: () => _showDevisDetails(devis),
                                        borderRadius: BorderRadius.circular(16),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: _buildDevisItem(devis),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return ListView.builder(
                                  itemCount: _devisList.length,
                                  padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16, top: 8),
                                  itemBuilder: (context, index) {
                                    final devis = _devisList[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: Material(
                                        borderRadius: BorderRadius.circular(16),
                                        elevation: 1,
                                        color: Colors.white,
                                        child: InkWell(
                                          onTap: () => _showDevisDetails(devis),
                                          borderRadius: BorderRadius.circular(16),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: _buildDevisItem(devis),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            }
                          ),
                  ),
                ],
              ),
            ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateDevisScreen()),
          ).then((result) {
            if (result == true) {
              _loadDevis();
            }
          });
        },
        backgroundColor: AppColors.primary,
        elevation: 2,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}