import 'package:bit_money/config/env_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UsersService {
  final String baseUrl = EnvConfig.baseUrl;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Dio _dio;

  UsersService(): _dio = Dio();

  Future<Map<String, dynamic> > createNewUser(Map<String, dynamic> userData) async {
    try {
      String? headerCookies = await _secureStorage.read(key: 'Cookies');

      final response = await _dio.post(
        '$baseUrl/api/users',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Cookie': headerCookies
          },
          validateStatus: (status) => true,
        ),
        data: userData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true
        };
      }
      return {
        'success': false,
        'message': response.data['error']
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}