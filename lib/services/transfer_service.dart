import 'package:bit_money/config/env_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TransferService {
  final Dio _dio;
  final String baseUrl = EnvConfig.baseUrl;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  TransferService(): _dio = Dio();

  Future<dynamic> requestAuthorization() async {
    String? headerCookies = await _secureStorage.read(key: 'Cookies');
    final response = await _dio.post(
      '$baseUrl/api/transactions/auth',
      options: Options(
        headers: {
          'Cookie': headerCookies
        },
        validateStatus: (status) => true,
      ),
    );

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
    String? headerCookies = await _secureStorage.read(key: 'Cookies');
    String? sessionKey = await _secureStorage.read(key: 'SessionKey');

    final response = await _dio.post(
      '$baseUrl/api/transactions/sender',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'X-Session-Key': sessionKey,
          'Cookie': headerCookies
        },
        validateStatus: (status) => true,
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
    String? headerCookies = await _secureStorage.read(key: 'Cookies');
    String? sessionKey = await _secureStorage.read(key: 'SessionKey');

    final response = await _dio.post(
      '$baseUrl/api/transactions/recipient',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'X-Session-Key': sessionKey,
          'Cookie': headerCookies
        },
        validateStatus: (status) => true,
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
    String? headerCookies = await _secureStorage.read(key: 'Cookies');
    String? sessionKey = await _secureStorage.read(key: 'SessionKey');

    final response = await _dio.post(
      '$baseUrl/api/transactions/amount',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'X-Session-Key': sessionKey,
          'Cookie': headerCookies
        },
        validateStatus: (status) => true,
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
    String? headerCookies = await _secureStorage.read(key: 'Cookies');
    String? sessionKey = await _secureStorage.read(key: 'SessionKey');

    final response = await _dio.post(
      '$baseUrl/api/transactions',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'X-Session-Key': sessionKey,
          'Cookie': headerCookies
        },
        validateStatus: (status) => true,
      ),
    );

    if (response.statusCode == 200) {
      _secureStorage.delete(key: 'SessionKey');

      return {
        'sucess': true,
      };
    } else {
      return {
        'sucess': false,
        'message': 'Échec de la confirmation de la transaction'
      };
    }
  }
}