import 'package:bit_money/models/operator_model.dart';
import 'package:bit_money/services/api_client.dart';
import 'package:flutter/material.dart';

class OperatorService {
  final ApiClient _apiClient;

  OperatorService() : _apiClient = ApiClient();

  Future<List<Operator>> getOperators() async {
    try {
      final response = await _apiClient.get(
        '/operators',
        useCache: true,
        cacheDuration: const Duration(hours: 1),
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