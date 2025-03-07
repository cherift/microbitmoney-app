import 'package:bit_money/screens/general_screen.dart';
import 'package:flutter/material.dart';
import 'package:bit_money/services/auth_service.dart';
import 'package:bit_money/constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isPasswordVisible = false;
  Future<Map<String, dynamic>>? _loginFuture;
  String? _errorMessage;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _fetchCsrfToken();
  }

  Future<void> _fetchCsrfToken() async {
    setState(() => _isInitializing = true);

    try {
      final csrfToken = await _authService.getCsrfToken();
      if (csrfToken == null) {
        setState(() {
          _errorMessage = 'Impossible de se connecter au serveur. Veuillez réessayer.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion. Veuillez vérifier votre connexion internet.';
      });
    } finally {
      setState(() => _isInitializing = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
        _loginFuture = _authService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final availableHeight = size.height - padding.top - padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: _isInitializing
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: availableHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: availableHeight * 0.2,
                            child: Image.asset(
                              'assets/images/bit-mo_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: availableHeight * 0.04),
                          Text(
                            'Connectez-vous pour accéder à votre compte',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: size.width * 0.035,
                              color: AppColors.darkGrey,
                            ),
                          ),

                          SizedBox(height: availableHeight * 0.06),

                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_errorMessage != null) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.red.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: const TextStyle(color: Colors.red, fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                const Text(
                                  'Email',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.text,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    hintText: 'Entrez votre adresse email',
                                    hintStyle: TextStyle(
                                      color: AppColors.mediumGrey,
                                      fontSize: size.width * 0.035,
                                    ),
                                    filled: true,
                                    fillColor: AppColors.background,
                                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.darkGrey),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer votre adresse email';
                                    }
                                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                    if (!emailRegex.hasMatch(value)) {
                                      return 'Veuillez entrer une adresse email valide';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: availableHeight * 0.025),
                                const Text(
                                  'Mot de passe',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.text,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  decoration: InputDecoration(
                                    hintText: 'Entrez votre mot de passe',
                                    hintStyle: TextStyle(
                                      color: AppColors.mediumGrey,
                                      fontSize: size.width * 0.035,
                                    ),
                                    filled: true,
                                    fillColor: AppColors.background,
                                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.darkGrey),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                        color: AppColors.darkGrey,
                                        size: 22,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible = !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer votre mot de passe';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: availableHeight * 0.04),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: _loginFuture == null
                                      ? ElevatedButton(
                                          onPressed: _login,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.secondary,
                                            foregroundColor: AppColors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                          ),
                                          child: const Text(
                                            'Se connecter',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        )
                                      : FutureBuilder<Map<String, dynamic>>(
                                          future: _loginFuture,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return ElevatedButton(
                                                onPressed: null,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppColors.secondary,
                                                  foregroundColor: AppColors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  elevation: 0,
                                                ),
                                                child: const SizedBox(
                                                  height: 22,
                                                  width: 22,
                                                  child: CircularProgressIndicator(
                                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                              );
                                            } else if (snapshot.hasError) {
                                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                                setState(() {
                                                  _errorMessage = 'Une erreur s\'est produite. Veuillez réessayer.';
                                                  _loginFuture = null;
                                                });
                                              });
                                              return ElevatedButton(
                                                onPressed: _login,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppColors.secondary,
                                                  foregroundColor: AppColors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  elevation: 0,
                                                ),
                                                child: const Text(
                                                  'Réessayer',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              );
                                            } else if (snapshot.hasData) {
                                              final response = snapshot.data!;
                                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                                if (response['success'] == true) {
                                                  Navigator.of(context).pushReplacement(
                                                    MaterialPageRoute(builder: (_) => const GeneralScreen()),
                                                  );
                                                } else {
                                                  setState(() {
                                                    _errorMessage = response['message'] ?? 'Identifiants invalides';
                                                    _loginFuture = null;
                                                  });
                                                }
                                              });

                                              return ElevatedButton(
                                                onPressed: _login,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppColors.secondary,
                                                  foregroundColor: AppColors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  elevation: 0,
                                                ),
                                                child: const Text(
                                                  'Se connecter',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return ElevatedButton(
                                                onPressed: _login,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppColors.secondary,
                                                  foregroundColor: AppColors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  elevation: 0,
                                                ),
                                                child: const Text(
                                                  'Se connecter',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: availableHeight * 0.06),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}