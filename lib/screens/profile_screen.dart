import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/controllers/app_language_controller.dart';
import 'package:bit_money/l10n/app_localizations.dart';
import 'package:bit_money/models/user_model.dart';
import 'package:bit_money/screens/login_screen.dart';
import 'package:bit_money/services/auth/auth_service.dart';
import 'package:bit_money/services/localization_service.dart';
import 'package:bit_money/services/users_service.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService authService = AuthService();
  final UsersService usersService = UsersService();
  UserModel? userModel;
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String _defaultLanguageCode = 'fr';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final session = await authService.getStoredSession();
      final defaultLanguageCode = await LocalizationService.getCurrentLanguageCode();

      if (session != null && session.user != null) {
        setState(() {
          userModel = session.user;
          _firstNameController.text = userModel?.firstName ?? '';
          _lastNameController.text = userModel?.lastName ?? '';
          _defaultLanguageCode = defaultLanguageCode;
        });
      }
    } catch (error) {
      debugPrint('Error loading user data: $error');
    }
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
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        elevation: 0,
        actions: [
          _buildLanguageButton(context),
          Spacer(),
          if (!isEditing) ...[
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: _buildEditButton(),
            ),
          ],
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildLogoutButton(),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
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
                    child: isEditing
                      ? _buildEditForm(context)
                      : _buildProfileView(context),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileView(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Column(
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
        const SizedBox(height: 16),
        _buildInfoSection(context, tr.personalInfo, [
          _buildInfoTile(context, tr.firstName, userModel!.firstName, Icons.person_outline),
          _buildInfoTile(context, tr.lastName, userModel!.lastName, Icons.person),
          _buildInfoTile(context, tr.email, userModel!.email, Icons.email),
          _buildInfoTile(context, tr.accountType, userModel!.role == 'ADMIN' ? tr.administrator : userModel!.accountType, Icons.badge),
          if (userModel!.phone != null && userModel!.phone!.isNotEmpty)
            _buildInfoTile(context, tr.phone, userModel!.phone!, Icons.phone),
        ]),
        const SizedBox(height: 16),
        if (userModel!.pdv != null) ...[
          _buildInfoSection(context, tr.pointOfSale, [
            _buildInfoTile(context, tr.pdvName, userModel!.pdv!.name, Icons.store),
            _buildInfoTile(context, tr.commission, '${userModel!.commission}%', Icons.percent_outlined),
            _buildInfoTile(context, tr.address, userModel!.pdv!.address, Icons.location_on),
            _buildInfoTile(context, tr.times,
              '${userModel!.pdv!.openingTime} - ${userModel!.pdv!.closingTime}',
              Icons.access_time
            ),
            _buildInfoTile(
              context,
              tr.openOnWeekends,
              userModel!.pdv!.openWeekend ? tr.yes : tr.no,
              Icons.calendar_today
            ),
          ]),
        ],
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildEditForm(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr.updateProfile,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 24),

          _buildFormField(
            label: tr.firstName,
            controller: _firstNameController,
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return tr.enterAFirstName;
              }
              return null;
            },
          ),

          const SizedBox(height: 16),
          _buildFormField(
            label: tr.lastName,
            controller: _lastNameController,
            icon: Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return tr.enterALastName;
              }
              return null;
            },
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            "${tr.updatePassword} (${tr.optional})",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 16),

          _buildFormField(
            label: tr.newPassword,
            controller: _passwordController,
            icon: Icons.lock_outline,
            obscureText: true,
            validator: (value) {
              if (value != null && value.isNotEmpty && value.length < 6) {
                return tr.passwordRegex;
              }
              return null;
            },
          ),

          const SizedBox(height: 16),
          _buildFormField(
            label: tr.confirmPassword,
            controller: _confirmPasswordController,
            icon: Icons.lock,
            obscureText: true,
            validator: (value) {
              if (_passwordController.text.isNotEmpty &&
                  value != _passwordController.text) {
                return tr.passwordNotConfirmed;
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      isEditing = false;
                      _firstNameController.text = userModel?.firstName ?? '';
                      _lastNameController.text = userModel?.lastName ?? '';
                      _passwordController.clear();
                      _confirmPasswordController.clear();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.darkGrey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    tr.cancel,
                    style: TextStyle(
                      color: AppColors.darkGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _updateProfile(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        tr.save,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Future<void> _updateProfile(BuildContext content) async {
    final tr = AppLocalizations.of(content)!;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final updateData = {
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
        };

        if (_passwordController.text.isNotEmpty) {
          updateData['password'] = _passwordController.text;
        }

        final result = await usersService.updateProfile(updateData);

        if (result['success'] == true) {
          if (result['user'] != null) {
            final updatedUserData = result['user'];
            updatedUserData['name'] = '${updatedUserData['firstName']} ${updatedUserData['lastName']}';

            await authService.updateStoredUserData(updatedUserData);

            setState(() {
              userModel = UserModel.fromJson(updatedUserData);

              isEditing = false;
              _passwordController.clear();
              _confirmPasswordController.clear();
            });
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(tr.profileUpdated),
                backgroundColor: AppColors.lightSecondary,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(tr.updateFailed),
                backgroundColor: AppColors.darkPrimary,
              ),
            );
          }
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${error.toString()}'),
              backgroundColor: AppColors.darkPrimary,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // Champ de formulaire réutilisable
  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.darkGrey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildLanguageButton(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 40),
        onSelected: (String languageCode) async {
          await AppLanguageController().changeLanguage(languageCode);

          if (mounted) {
            setState(() {
              _defaultLanguageCode = languageCode;
            });
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.language,
              color: AppColors.secondary,
              size: 40,
            ),
            const SizedBox(width: 10),
            Text(
              tr.language,
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'fr',
            child: Row(
              children: [
                CountryFlag.fromLanguageCode(
                  'fr',
                  theme: const ImageTheme(
                    width: 24,
                    height: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(LocalizationService.getLanguageName('fr')),
                const SizedBox(width: 8),
                if (_defaultLanguageCode == 'fr')
                  const Icon(Icons.check, color: AppColors.primary),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'en',
            child: Row(
              children: [
                CountryFlag.fromLanguageCode(
                  'en',
                  theme: const ImageTheme(
                    width: 24,
                    height: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(LocalizationService.getLanguageName('en')),
                const SizedBox(width: 8),
                if (_defaultLanguageCode == 'en')
                  const Icon(Icons.check, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Bouton d'édition du profil
  Widget _buildEditButton() {
    return InkWell(
      onTap: () {
        setState(() {
          isEditing = true;
        });
      },
      borderRadius: BorderRadius.circular(50),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.secondary,
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
            Icons.edit,
            color: AppColors.white,
            size: 24,
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
    final tr = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          tr.logout,
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          tr.logoutConfirmation,
          style: TextStyle(
            color: AppColors.text,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              tr.cancel,
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
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            child: Text(
              tr.logout,
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
    }
    if (name.length > 1) {
      return name.substring(0, 2);
    }
    return name;
  }
}
