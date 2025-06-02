import 'package:bit_money/models/session_model.dart';
import 'package:bit_money/services/auth/auth_service_interface.dart';
import 'package:bit_money/services/auth/auth_service_web.dart';

class AuthService implements AuthServiceInterface {
  static AuthServiceInterface? _instance;
  late final AuthServiceInterface _delegate;

  factory AuthService() {
    return AuthService._internal();
  }

  AuthService._internal() {
    _delegate = _createAuthService();
  }

  static AuthServiceInterface _createAuthService() {
    return AuthServiceWeb();
  }

  static AuthServiceInterface get instance {
    _instance ??= AuthServiceWeb();
    return _instance!;
  }

  static void reset() {
    _instance = null;
  }

  @override
  Future<String?> getCsrfToken() => _delegate.getCsrfToken();

  @override
  Future<Map<String, dynamic>> login(String email, String password) =>
      _delegate.login(email, password);

  @override
  Future<SessionModel?> fetchAndStoreSession(String? sessionCookie) =>
      _delegate.fetchAndStoreSession(sessionCookie);

  @override
  Future<void> storeSession(SessionModel session) =>
      _delegate.storeSession(session);

  @override
  Future<SessionModel?> getStoredSession() =>
      _delegate.getStoredSession();

  @override
  Future<bool> isLoggedIn() => _delegate.isLoggedIn();

  @override
  Future<bool> logout() => _delegate.logout();
}