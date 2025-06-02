import 'package:bit_money/services/client/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TransferService {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  TransferService(): _apiClient = ApiClient();

  Future<dynamic> requestAuthorization() async {
    final response = await _apiClient.post('/transactions/auth');

    if (response.statusCode == 200) {
      final data = response.data;
      _secureStorage.write(key: 'SessionKey', value: data['sessionKey']);

      return {
        'success': true,
      };
    } else {
      return {
        'success': false,
        'message': 'Échec de l\'autorisation'
      };
    }
  }

  Future<dynamic> submitSenderInfo(Map<String, dynamic> senderData) async {
    String? sessionKey = await _secureStorage.read(key: 'SessionKey');

    final response = await _apiClient.postWithOptions(
      '/transactions/sender',
      data: senderData,
      headers: {
        'X-Session-Key': sessionKey ?? '',
      },
    );

    if (response.statusCode != 200) {
      return {
        'success': false,
        'message': 'Échec de l\'envoi des infos de l\'expéditeur'
      };
    }

    return {'success': true};
  }

  Future<dynamic> submitRecipientInfo(Map<String, dynamic> recipientData) async {
    String? sessionKey = await _secureStorage.read(key: 'SessionKey');

    final response = await _apiClient.postWithOptions(
      '/transactions/recipient',
      data: recipientData,
      headers: {
        'X-Session-Key': sessionKey ?? '',
      },
    );

    if (response.statusCode != 200) {
      return {
        'success': false,
        'message': 'Échec de l\'envoi des infos du bénéficiaire'
      };
    }

    return {'success': true};
  }

  Future<dynamic> submitAmount(Map<String, dynamic> amountData) async {
    String? sessionKey = await _secureStorage.read(key: 'SessionKey');

    final response = await _apiClient.postWithOptions(
      '/transactions/amount',
      data: amountData,
      headers: {
        'X-Session-Key': sessionKey ?? '',
      },
    );

    if (response.statusCode != 200) {
      return {
        'success': false,
        'message': 'Échec de la submission du montant'
      };
    }

    return {'success': true};
  }

  Future<Map<String, dynamic>> confirmTransaction() async {
    String? sessionKey = await _secureStorage.read(key: 'SessionKey');

    final response = await _apiClient.postWithOptions(
      '/transactions',
      headers: {
        'X-Session-Key': sessionKey ?? '',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      _secureStorage.delete(key: 'SessionKey');

      return {
        'success': true,
      };
    } else {
      return {
        'success': false,
        'message': 'Échec de la confirmation de la transaction'
      };
    }
  }
}