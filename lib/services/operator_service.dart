import 'package:bit_money/config/env_config.dart';
import 'package:bit_money/models/operator_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OperatorService {
  final Dio _dio;
  final String baseUrl = EnvConfig.baseUrl;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  OperatorService() : _dio = Dio();

  Future<List<Operator>> getOperators() async {
    try {
      String? headerCookies = await _secureStorage.read(key: 'Cookies');
      final response = await _dio.get(
        '$baseUrl/api/operators',
        options: Options(
          headers: {
            'Cookie': headerCookies
          },
          validateStatus: (status) => true,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> operatorsList = data['operators'];
        return operatorsList.map((json) => Operator.fromJson(json)).toList();
      } else {
        debugPrint('Impossible d\'accéder aux opérateurs');
      }
    } catch (e) {
      debugPrint('Erreur d\'accès aux opérateurs: $e');
    }
    return [];
  }
}