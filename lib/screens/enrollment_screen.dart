import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/services/users_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class EnrollmentScreen extends StatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _openWeekend = false;
  bool _isPasswordVisible = false;
  final List<String> _accountTypes = ['PROMOTEUR', 'PDV'];
  String _selectedAccountType = 'PDV';

  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _commissionController = TextEditingController(text: '0');

  final _pdvNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  TimeOfDay _openingTime = TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _closingTime = TimeOfDay(hour: 18, minute: 0);

  final UsersService _usersService = UsersService();

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _commissionController.dispose();
    _pdvNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectOpeningTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _openingTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: ThemeData.light().copyWith(
              primaryColor: AppColors.primary,
              colorScheme: ColorScheme.light(
                primary: AppColors.primary,
              ),
              buttonTheme: ButtonThemeData(
                colorScheme: ColorScheme.light(
                  primary: AppColors.primary,
                ),
              ),
            ),
            child: child!,
          ),
        );
      },
      initialEntryMode: TimePickerEntryMode.input,
    );

    if (pickedTime != null && pickedTime != _openingTime) {
      setState(() {
        _openingTime = pickedTime;
      });
    }
  }

  Future<void> _selectClosingTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _closingTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: ThemeData.light().copyWith(
              primaryColor: AppColors.primary,
              colorScheme: ColorScheme.light(
                primary: AppColors.primary,
              ),
              buttonTheme: ButtonThemeData(
                colorScheme: ColorScheme.light(
                  primary: AppColors.primary,
                ),
              ),
            ),
            child: child!,
          ),
        );
      },
      initialEntryMode: TimePickerEntryMode.input,
    );

    if (pickedTime != null && pickedTime != _closingTime) {
      setState(() {
        _closingTime = pickedTime;
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    // Utilisation de HH pour forcer le format 24h
    final now = DateTime.now();
    final datetime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(datetime);
  }

  String _formatTimeForApi(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showSuccessDialog(String nomPDV) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirmation d\'enrôllement',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'Le nouveau PDV \'$nomPDV\' a été créé avec succès.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text(
                  'Retour à l\'accueil',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  )
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userData = {
        'name': '${_firstNameController.text} ${_lastNameController.text}',
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text.toLowerCase(),
        'phone': _phoneController.text,
        'password': _passwordController.text,
        'accountType': _selectedAccountType,
        'commission': int.parse(_commissionController.text),
        'pdv': {
          'name': _pdvNameController.text,
          'address': _addressController.text,
          'phone': _phoneController.text,
          'openingTime': _formatTimeForApi(_openingTime),
          'closingTime': _formatTimeForApi(_closingTime),
          'openWeekend': _openWeekend,
        }
      };

      final response = await _usersService.createNewUser(userData);

      if (response['success']) {
        _showSuccessDialog(_pdvNameController.text);
      } else {
        _showErrorDialog(response['message'] ?? 'Une erreur est survenue');
        return;
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.secondary,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Text(
          'Nouveau Point de Vente',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.black),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      bool isWideScreen = constraints.maxWidth > 700;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isWideScreen)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildUserInfoSection()),
                                SizedBox(width: 16),
                                Expanded(child: _buildPdvInfoSection()),
                              ],
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildUserInfoSection(),
                                SizedBox(height: 24),
                                _buildPdvInfoSection(),
                              ],
                            ),
                          SizedBox(height: 32),
                          _buildActionButtons(),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildUserInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations utilisateur',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'email@example.com',
          icon: Icons.email_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Veuillez entrer un email valide';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Téléphone',
          hint: '+224 000000000',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un numéro de téléphone';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _firstNameController,
          label: 'Prénom',
          hint: 'Prénom',
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un prénom';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _lastNameController,
          label: 'Nom',
          hint: 'Nom',
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un nom';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          label: 'Mot de passe',
          hint: '••••••••',
          icon: Icons.lock_outline,
          isPassword: !_isPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un mot de passe';
            }
            if (value.length < 6) {
              return 'Le mot de passe doit contenir au moins 6 caractères';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        _buildDropdownField(
          label: 'Type de compte',
          value: _selectedAccountType,
          items: _accountTypes,
          icon: Icons.account_circle_outlined,
          onChanged: (value) {
            setState(() {
              _selectedAccountType = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPdvInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations du PDV',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _pdvNameController,
          label: 'Nom du PDV',
          hint: 'Nom du point de vente',
          icon: Icons.store_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un nom de PDV';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _commissionController,
          label: 'Commission (%)',
          hint: '0',
          icon: Icons.percent,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un pourcentage';
            }
            try {
              int commission = int.parse(value);
              if (commission < 0 || commission > 100) {
                return 'La commission doit être entre 0 et 100';
              }
            } catch (e) {
              return 'Veuillez entrer un nombre valide';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _addressController,
          label: 'Adresse',
          hint: 'Adresse complète',
          icon: Icons.location_on_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer une adresse';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTimePickerField(
                label: 'Heure d\'ouverture',
                value: _formatTimeOfDay(_openingTime),
                icon: Icons.access_time,
                onTap: _selectOpeningTime,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildTimePickerField(
                label: 'Heure de fermeture',
                value: _formatTimeOfDay(_closingTime),
                icon: Icons.access_time,
                onTap: _selectClosingTime,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildCheckboxField(
          label: 'Ouvert le weekend',
          value: _openWeekend,
          onChanged: (value) {
            setState(() {
              _openWeekend = value!;
            });
          },
        ),
      ],
    );
  }

  // Boutons d'action
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            'Annuler',
            style: TextStyle(
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: 16),
        ElevatedButton(
          onPressed: _createUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Créer le PDV',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.mediumGrey),
            prefixIcon: Icon(icon, color: AppColors.darkGrey),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.secondary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.lightGrey),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.darkGrey),
              isExpanded: true,
              hint: Row(
                children: [
                  Icon(icon, color: AppColors.darkGrey),
                  SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(color: AppColors.mediumGrey),
                  ),
                ],
              ),
              style: TextStyle(
                color: AppColors.text,
                fontSize: 14,
              ),
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Icon(icon, color: AppColors.darkGrey),
                      SizedBox(width: 12),
                      Text(value),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePickerField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.darkGrey),
                SizedBox(width: 12),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxField({
    required String label,
    required bool value,
    required void Function(bool?) onChanged,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.secondary,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}