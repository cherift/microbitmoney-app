import 'package:bit_money/constants/app_colors.dart';
import 'package:bit_money/controllers/app_language_controller.dart';
import 'package:bit_money/l10n/app_localizations.dart';
import 'package:bit_money/screens/general_screen.dart';
import 'package:bit_money/screens/login_screen.dart';
import 'package:bit_money/services/auth/auth_service.dart';
import 'package:bit_money/services/client/api_client.dart';
import 'package:bit_money/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: AppColors.secondary,
    statusBarIconBrightness: Brightness.light,
  ));

  final initialLocale = await LocalizationService.getStoredOrSystemLocale();

  await initializeDateFormatting(initialLocale.languageCode, null);

  // Forcer l'orientation en portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(MyApp(initialLocale: initialLocale));
  });
}

class MyApp extends StatefulWidget {
  final Locale initialLocale;

  const MyApp({super.key, required this.initialLocale});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _currentLocale;

  @override
  void initState() {
    super.initState();
    _currentLocale = widget.initialLocale;

    AppLanguageController().setUpdateCallback((locale) {
      setState(() {
        _currentLocale = locale;
      });
    });
  }

  void setLocale(Locale locale) {
    setState(() {
      _currentLocale = locale;
    });

    initializeDateFormatting(locale.languageCode, null);
  }

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();

    return MaterialApp(
      navigatorKey: apiClient.navigatorKey,
      debugShowCheckedModeBanner: false,
      locale: _currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocalizationService.supportedLocales.values.toList(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const AuthCheckScreen(),
    );
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (mounted) {
        setState(() {
          _isAuthenticated = isLoggedIn;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.secondary,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppColors.secondary,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/bit-mo_logo.png',
                height: 100,
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 20),
              const Text(
                'Chargement...',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      if (_isAuthenticated) {
        return const GeneralScreen();
      }
      return const LoginScreen();
    }
  }
}