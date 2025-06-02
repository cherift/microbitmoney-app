import 'dart:async';
import 'package:bit_money/services/auth/auth_service_interface.dart';
import 'package:bit_money/services/auth/auth_service_web.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:bit_money/screens/login_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final AuthServiceInterface authService;
  final GlobalKey<NavigatorState> navigatorKey;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _accessTokenKey = 'flutter_access_token';

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

      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
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
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      final authServiceWeb = authService as AuthServiceWeb;
      final refreshSuccess = await authServiceWeb.refreshToken();

      if (refreshSuccess) {
        final newAccessToken = await _secureStorage.read(key: _accessTokenKey);
        if (newAccessToken != null) {
          err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          try {
            final retryDio = Dio(dio.options);
            final response = await retryDio.fetch(err.requestOptions);
            return handler.resolve(response);
          } catch (e) {
            debugPrint('Échec de la retry après refresh: $e');
          }
        }
      } else {
        _handleSessionExpired();
      }
    }

    return handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) => handler.next(response);

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