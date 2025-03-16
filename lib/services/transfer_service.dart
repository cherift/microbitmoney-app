import 'package:bit_money/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TransferService {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  TransferService(): _apiClient = ApiClient();

  Future<dynamic> requestAuthorization() async {
    final response = await _apiClient.post('/transactions/auth');

    if (response.statusCode == 200) {
      final data = response.data;
      _secureStorage.write(key: 'SessionKey', value:data['sessionKey']);

      return {
        'sucess': true,
      };
    } else {
      return {
        'sucess': false,
        'message': 'Échec de l\'autorisation'
      };
    }
  }

  Future<dynamic> submitSenderInfo(Map<String, dynamic> senderData) async {
    String? sessionKey = await _secureStorage.read(key: 'SessionKey');

    final response = await _apiClient.dio.post(
      '/transactions/sender',
      options: Options(
        headers: {
          'X-Session-Key': sessionKey,
        },
      ),
      data: senderData,
    );

    if (response.statusCode != 200) {
      return {
        'sucess': false,
        'message': 'Échec de l\'envoi des infos de l\'expéditeur'
      };
    }
  }

  Future<dynamic> submitRecipientInfo(Map<String, dynamic> recipientData) async {
    String? sessionKey = await _secureStorage.read(key: 'SessionKey');

    final response = await _apiClient.dio.post(
      '/transactions/recipient',
      options: Options(
        headers: {
          'X-Session-Key': sessionKey,
        },
      ),
      data: recipientData,
    );

    if (response.statusCode != 200) {
      return {
        'sucess': false,
        'message': 'Échec de l\'envoi des infos du bénéficiaire'
      };
    }
  }

  Future<dynamic> submitAmount(Map<String, dynamic> amountData) async {
    String? sessionKey = await _secureStorage.read(key: 'SessionKey');

    final response = await _apiClient.dio.post(
      '/transactions/amount',
      options: Options(
        headers: {
          'X-Session-Key': sessionKey,
        },
      ),
      data: amountData,
    );

    if (response.statusCode != 200) {
      return {
        'sucess': false,
        'message': 'Échec de la submission du montant'
      };
    }
  }

  Future<Map<String, dynamic>> confirmTransaction() async {
    String? sessionKey = await _secureStorage.read(key: 'SessionKey');

    final response = await _apiClient.dio.post(
      '/transactions',
      options: Options(
        headers: {
          'X-Session-Key': sessionKey,
        },
      ),
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