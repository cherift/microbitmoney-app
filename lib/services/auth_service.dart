import 'dart:async';
import 'dart:convert';
import 'package:bit_money/config/env_config.dart';
import 'package:bit_money/models/session_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl = EnvConfig.baseUrl;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  List<String> getNextAtuthHeaersCookies(List<String>? cookies) {
    if (cookies == null || cookies.isEmpty) {
      return <String>[];
    }

    final List<String> finalCookies = [];

    for (var cookieString in cookies) {
      final List<String> individualCookies = cookieString.split(';');
      for (var cookie in individualCookies) {
        if (cookie.contains('next-auth.csrf-token') ||
            cookie.contains('next-auth.callback-url') ||
            cookie.contains('next-auth.session-token')) {
          finalCookies.add(cookie);
        }
      }
    }

    return finalCookies;
  }

  Future<String?> getCsrfToken() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        '$baseUrl/api/auth/csrf',
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = response.data;
        final csrfToken = data['csrfToken'];
        final headerCookies = getNextAtuthHeaersCookies(response.headers['set-cookie']);
        await _secureStorage.write(key: 'Cookies', value: headerCookies.join(';'));

        if (csrfToken != null) {
          await _secureStorage.write(key: 'csrf_token', value: csrfToken);
          return csrfToken;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Connexion avec NextAuth credentials provider
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      String? csrfToken = await _secureStorage.read(key: 'csrf_token');
      String? headerCookies = await _secureStorage.read(key: 'Cookies');
      if (csrfToken == null) {
        csrfToken = await getCsrfToken();
        if (csrfToken == null) {
          return {
            'success': false,
            'message': 'Impossible de récupérer le jeton CSRF. Veuillez réessayer.'
          };
        }
      }

      final headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Cookie': headerCookies
      };

      final data = {
        'email': email.toLowerCase(),
        'password': password,
        'csrfToken': csrfToken,
        'callbackUrl': baseUrl,
        'json': 'true',
        'redirect': 'false'
      };

      final dio = Dio();
      final response = await dio.request(
        '$baseUrl/api/auth/callback/credentials',
          options: Options(
            method: 'POST',
            headers: headers,
            validateStatus: (_) => true,
          ),
          data: data,
        ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List<String> sessionCookies = getNextAtuthHeaersCookies(response.headers['set-cookie']);
        String cookieValue = sessionCookies.join(';');
        await _secureStorage.write(key: 'Cookies', value: cookieValue);
        await fetchAndStoreSession(cookieValue);

        return {
          'success': true,
          'message': 'Connexion réussie'
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Identifiants invalides.'
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur de connexion. Veuillez réessayer ultérieurement.'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Une erreur s\'est produite. Veuillez vérifier votre connexion internet.'
      };
    }
  }

  // Récupérer et stocker les informations de session
  Future<SessionModel?> fetchAndStoreSession(sessionCookie) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        '$baseUrl/api/auth/session',
        options: Options(
          headers: {
            'Cookie': sessionCookie
          },
        ),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['user'] != null) {
          final session = SessionModel.fromJson(data);
          await storeSession(session);
          return session;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Stocker les informations de session
  Future<void> storeSession(SessionModel session) async {
    final sessionJson = json.encode(session.toJson());
    await _secureStorage.write(key: 'user_session', value: sessionJson);
  }

  // Récupérer les informations de session stockées
  Future<SessionModel?> getStoredSession() async {
    try {
      final sessionJson = await _secureStorage.read(key: 'user_session');
      if (sessionJson != null) {
        final sessionData = json.decode(sessionJson);
        return SessionModel.fromJson(sessionData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Vérifier si l'utilisateur est connecté avec une session valide
  Future<bool> isLoggedIn() async {
    final session = await getStoredSession();
    return session?.isValid ?? false;
  }

  // Déconnexion
  Future<bool> logout() async {
    try {
      final dio = Dio();
      await dio.post('$baseUrl/api/auth/logout');

      await _secureStorage.delete(key: 'user_session');

      return true;
    } catch (e) {
      return false;
    }
  }
}