import 'package:bit_money/services/api_client.dart';

class UsersService {
  final ApiClient _apiClient;

  UsersService(): _apiClient = ApiClient();

  Future<Map<String, dynamic> > createNewUser(Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.post('/users', data: userData);

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