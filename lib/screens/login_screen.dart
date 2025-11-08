import 'package:bit_money/l10n/app_localizations.dart';
import 'package:bit_money/screens/general_screen.dart';
import 'package:flutter/material.dart';
import 'package:bit_money/services/auth/auth_service.dart';
import 'package:bit_money/constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isPasswordVisible = false;
  Future<Map<String, dynamic>>? _loginFuture;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateIdentifier(String? value, AppLocalizations tr) {
    if (value == null || value.trim().isEmpty) {
      return tr.enterEmailOrPhoneError;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final phoneRegex = RegExp(r'^(\+|00)?[0-9]\d{0,14}$');
    final normalizedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (!emailRegex.hasMatch(value) && !phoneRegex.hasMatch(normalizedValue)) {
      return tr.emailOrPhoneInvalid;
    }

    return null;
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
        _loginFuture = _authService.login(
          _identifierController.text.trim(),
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
    final tr =  AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: true,
        child: LayoutBuilder(
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
                        tr.pleaseLogin,
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

                            Text(
                              tr.emailOrPhone,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.text,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _identifierController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: tr.emailOrPhone,
                                hintStyle: TextStyle(
                                  color: AppColors.mediumGrey,
                                  fontSize: size.width * 0.035,
                                ),
                                filled: true,
                                fillColor: AppColors.background,
                                prefixIcon: const Icon(
                                  Icons.alternate_email,
                                  color: AppColors.darkGrey,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              validator: (value) => _validateIdentifier(value, tr),
                            ),

                            SizedBox(height: availableHeight * 0.025),

                            Text(
                              tr.password,
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
                                hintText: tr.enterYourPassword,
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
                                  return tr.enterYourPasswordError;
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
                                      child: Text(
                                        tr.login,
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
                                              _errorMessage = tr.errorOccured;
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
                                            child: Text(
                                              tr.retry,
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
                                                _errorMessage = tr.invalidCredentials;
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
                                            child: Text(
                                              tr.login,
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
                                            child: Text(
                                              tr.login,
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