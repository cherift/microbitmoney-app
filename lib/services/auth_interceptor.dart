import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:bit_money/screens/login_screen.dart';
import 'package:bit_money/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final AuthService authService;
  final GlobalKey<NavigatorState> navigatorKey;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthInterceptor({
    required this.dio,
    required this.authService,
    required this.navigatorKey,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final isLoggedIn = await authService.isLoggedIn();

      if (!isLoggedIn) {
        _redirectToLogin();
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            error: 'Session expirée ou utilisateur non connecté',
          ),
        );
      }

      final cookies = await _secureStorage.read(key: 'Cookies');
      if (cookies != null && cookies.isNotEmpty) {
        options.headers['Cookie'] = cookies;
      }

      return handler.next(options);
    } catch (e) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: 'Erreur lors de la vérification de l\'authentification: $e',
        ),
      );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      _handleSessionExpired();
      return handler.reject(err);
    }

    return handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.headers.map.containsKey('set-cookie')) {
      _updateSessionCookies(response.headers.map['set-cookie'] ?? []);
    }

    return handler.next(response);
  }

  Future<void> _updateSessionCookies(List<String> cookies) async {
    if (cookies.isNotEmpty) {
      final nextAuthCookies = authService.getNextAtuthHeaersCookies(cookies);
      if (nextAuthCookies.isNotEmpty) {
        final cookieString = nextAuthCookies.join(';');
        await _secureStorage.write(key: 'Cookies', value: cookieString);

        await authService.fetchAndStoreSession(cookieString);
      }
    }
  }

  Future<void> _handleSessionExpired() async {
    await authService.logout();
    _redirectToLogin();
  }

  void _redirectToLogin() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
}