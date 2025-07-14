import 'package:bit_money/models/operator_model.dart';
import 'package:bit_money/services/client/api_client.dart';
import 'package:flutter/material.dart';

class OperatorService {
  final ApiClient _apiClient;

  OperatorService() : _apiClient = ApiClient();

  Future<List<Operator>> getOperators() async {
    try {
      return await _fetchOperators(useCache: true);
    } catch (e) {
      debugPrint('Échec avec cache: $e');
    }

    try {
      return await _fetchOperators(useCache: false);
    } catch (e) {
      debugPrint('Échec sans cache: $e');
    }

    try {
      await _apiClient.clearCache();
      await Future.delayed(const Duration(seconds: 1));
      return await _fetchOperators(useCache: false);
    } catch (e) {
      debugPrint('Échec final: $e');
      rethrow;
    }
  }

  Future<List<Operator>> _fetchOperators({required bool useCache}) async {
    final response = await _apiClient.get(
      '/operators',
      useCache: useCache,
      cacheDuration: const Duration(hours: 1),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data == null) {
        throw Exception('Données nulles reçues du serveur');
      }

      final List<dynamic>? operatorsList = data['operators'];
      if (operatorsList == null) {
        throw Exception('Liste des opérateurs manquante dans la réponse');
      }

      return operatorsList.map((json) => Operator.fromJson(json)).toList();
    } else {
      throw Exception('Erreur serveur: ${response.statusCode}');
    }
  }
}