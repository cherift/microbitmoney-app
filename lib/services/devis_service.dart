import 'package:bit_money/models/devis_model.dart';
import 'package:bit_money/services/api_client.dart';

class DevisService {
  final ApiClient _apiClient;

  DevisService(): _apiClient = ApiClient();

  Future<List<Devis>> getDevis(String userId) async {
    try {
      final String endpoint = userId.isNotEmpty ? '/devis?userId=$userId' : '/devis';
      final response = await _apiClient.get(endpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> devisData = data['demandes'];
        return devisData.map((json) => Devis.fromJson(json)).toList();
      } else {
        throw Exception('Échec du chargement des devis: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des devis: $e');
    }
  }

  Future<Map<String, dynamic>> createDevis(Map<String, dynamic> devisData) async {
    try {
      final response = await _apiClient.post(
        '/devis',
        data: devisData
      );

      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Échec de la création du devis: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création du devis: $e');
    }
  }
}