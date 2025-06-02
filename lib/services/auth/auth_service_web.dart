import 'dart:convert';
import 'package:bit_money/config/env_config.dart';
import 'package:bit_money/models/session_model.dart';
import 'package:bit_money/services/auth/auth_service_interface.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

class AuthServiceWeb implements AuthServiceInterface {
  final String baseUrl = EnvConfig.baseUrl;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late final http.Client _client;

  static const String _accessTokenKey = 'flutter_access_token';
  static const String _refreshTokenKey = 'flutter_refresh_token';
  static const String _userKey = 'flutter_user_data';
  static const String _sessionKey = 'user_session';

  AuthServiceWeb() {
    _client = BrowserClient();
  }

  @override
  Future<String?> getCsrfToken() async {
    return null;
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/flutter/auth'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email.toLowerCase(),
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          await _storeAuthData(
            data['accessToken'],
            data['refreshToken'],
            data['user']
          );
          await _createAndStoreSession(data['user']);

          return {
            'success': true,
            'message': 'Connexion réussie'
          };
        }
      }

      return _handleHttpError(response);

    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion. Vérifiez votre connexion internet.'
      };
    }
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);

      if (refreshToken == null) {
        return false;
      }

      final response = await _client.put(
        Uri.parse('$baseUrl/api/flutter/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'refreshToken': refreshToken,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          await _storeAuthData(
            data['accessToken'],
            data['refreshToken'],
            data['user']
          );
          await _createAndStoreSession(data['user']);
          return true;
        }
      }

      await _clearAllAuthData();
      return false;

    } catch (e) {
      await _clearAllAuthData();
      return false;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final localSession = await getStoredSession();
      if (localSession != null && localSession.isValid) {
        return await _verifyOrRefreshToken();
      }

      return false;

    } catch (e) {
      return false;
    }
  }

  Future<bool> _verifyOrRefreshToken() async {
    try {
      final accessToken = await _secureStorage.read(key: _accessTokenKey);

      if (accessToken == null) {
        return await refreshToken();
      }

      // Vérifier le token actuel
      final response = await _client.get(
        Uri.parse('$baseUrl/api/flutter/auth'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['authenticated'] == true) {
          return true;
        }
      }

      if (response.statusCode == 401) {
        final data = jsonDecode(response.body);
        if (data['needsRefresh'] == true) {
          return await refreshToken();
        }
      }

      await _clearAllAuthData();
      return false;

    } catch (e) {
      return await refreshToken();
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _clearAllAuthData();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<SessionModel?> fetchAndStoreSession(String? sessionCookie) async {
    return await getStoredSession();
  }

  @override
  Future<void> storeSession(SessionModel session) async {
    final sessionJson = jsonEncode(session.toJson());
    await _secureStorage.write(key: _sessionKey, value: sessionJson);
  }

  @override
  Future<SessionModel?> getStoredSession() async {
    try {
      final sessionJson = await _secureStorage.read(key: _sessionKey);
      if (sessionJson != null) {
        final sessionData = jsonDecode(sessionJson);
        return SessionModel.fromJson(sessionData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _storeAuthData(String accessToken, String refreshToken, Map<String, dynamic> user) async {
    await Future.wait([
      _secureStorage.write(key: _accessTokenKey, value: accessToken),
      _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
      _secureStorage.write(key: _userKey, value: jsonEncode(user)),
    ]);
  }

  Future<void> _createAndStoreSession(Map<String, dynamic> user) async {
    final sessionData = {
      'user': user,
      'expires': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
    };

    final session = SessionModel.fromJson(sessionData);
    await storeSession(session);
  }

  Future<void> _clearAllAuthData() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _secureStorage.delete(key: _userKey),
      _secureStorage.delete(key: _sessionKey),
    ]);
  }

  Map<String, dynamic> _handleHttpError(http.Response response) {
    try {
      if (response.statusCode == 401) {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['error'] ?? 'Identifiants invalides'
        };
      }

      return {
        'success': false,
        'message': 'Erreur serveur (${response.statusCode}). Veuillez réessayer.'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion. Veuillez réessayer.'
      };
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final userData = await _secureStorage.read(key: _userKey);
      if (userData != null) {
        return jsonDecode(userData);
      }

      final session = await getStoredSession();
      return session?.user?.toJson();

    } catch (e) {
      return null;
    }
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }
}