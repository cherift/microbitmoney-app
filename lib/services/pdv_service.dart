import 'package:bit_money/models/pdv_model.dart';
import 'package:bit_money/services/api_client.dart';

class PdvService {
  final ApiClient _apiClient;

  PdvService() : _apiClient = ApiClient();

  Future<List<PDV>> getPdvs() async {
    try {
      final response = await _apiClient.get('/pdvs');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> pdvsList = data['pdvs'];
        return pdvsList.map((pdvJson) => PDV.fromJson(pdvJson)).toList();
      } else {
        throw Exception('Échec du chargement des PDVs');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des PDVs: $e');
    }
  }
}