import 'package:bit_money/models/session_model.dart';

abstract class AuthServiceInterface {
  Future<String?> getCsrfToken();
  Future<Map<String, dynamic>> login(String email, String password);
  Future<SessionModel?> fetchAndStoreSession(String? sessionCookie);
  Future<void> storeSession(SessionModel session);
  Future<SessionModel?> getStoredSession();
  Future<bool> isLoggedIn();
  Future<bool> logout();
}