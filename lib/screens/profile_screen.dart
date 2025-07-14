import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/models/user_model.dart';
import 'package:bit_money/screens/login_screen.dart';
import 'package:bit_money/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService authService = AuthService();
  UserModel? userModel;

  @override
  void initState() {
    super.initState();
    authService.getStoredSession().then((value) {
      setState(() {
        userModel = value?.user!;
      });
    }).catchError((error) {
      debugPrint('Error: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userModel == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.secondary,
          statusBarIconBrightness: Brightness.light,
        ),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildLogoutButton(),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;
              final maxContentWidth = isTablet ? 600.0 : constraints.maxWidth;
              return SingleChildScrollView(
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.lightGrey,
                          child: Text(
                            _getInitials(userModel!.name),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16,),
                        _buildInfoSection(context, 'Informations Personnelles', [
                          _buildInfoTile(context, 'Adresse e-mail', userModel!.email, Icons.email),
                          _buildInfoTile(context, 'Type de compte', userModel!.role == 'ADMIN' ? 'Administrateur' : userModel!.accountType, Icons.badge),
                          if (userModel!.phone != null && userModel!.phone != "")
                            ...[
                              _buildInfoTile(context, 'Téléphone', userModel!.phone!, Icons.phone),
                            ]
                        ]),
                        const SizedBox(height: 16),
                        if (userModel!.pdv != null) ...[
                          _buildInfoSection(context, 'Point de Vente', [
                            _buildInfoTile(context, 'Nom PDV', userModel!.pdv!.name, Icons.store),
                            _buildInfoTile(context, 'Commission', userModel!.commission.toString(), Icons.percent_outlined),
                            _buildInfoTile(context, 'Adresse', userModel!.pdv!.address, Icons.location_on),
                            _buildInfoTile(context, 'Horaires',
                              '${userModel!.pdv!.openingTime} - ${userModel!.pdv!.closingTime}',
                              Icons.access_time
                            ),
                            _buildInfoTile(
                              context,
                              'Ouvert le weekend',
                              userModel!.pdv!.openWeekend ? 'Oui' : 'Non',
                              Icons.calendar_today
                            ),
                          ]),
                        ],
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Bouton de déconnexion
  Widget _buildLogoutButton() {
    return InkWell(
      onTap: () => _showLogoutDialog(context),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accent,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: .1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(
            Icons.settings_power,
            color: AppColors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  // Section d'informations avec titre et liste
  Widget _buildInfoSection(BuildContext context, String title, List<Widget> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  // Tuile d'information individuelle
  Widget _buildInfoTile(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
            color: const Color.fromARGB(255, 94, 98, 168),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.text,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dialogue de confirmation de déconnexion
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Déconnexion',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: TextStyle(
            color: AppColors.text,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Annuler',
              style: TextStyle(
                color: AppColors.darkGrey,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: () async {
              await authService.logout();
              // Utiliser dialogContext.mounted pour vérifier si le widget est encore monté
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop(); // Fermer d'abord la boîte de dialogue
              }
              // Utiliser context.mounted pour vérifier si le widget principal est encore monté
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            child: const Text(
              'Déconnexion',
              style: TextStyle(
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Obtenir les initiales du nom pour l'avatar
  String _getInitials(String name) {
    if (name.isEmpty) return '';

    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    } else if (name.length > 1) {
      return name.substring(0, 2);
    } else {
      return name;
    }
  }
}