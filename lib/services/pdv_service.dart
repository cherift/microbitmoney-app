import 'package:bit_money/config/env_config.dart';
import 'package:bit_money/models/pdv_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PdvService {
  final String baseUrl = EnvConfig.baseUrl;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Dio _dio;

  PdvService() : _dio = Dio();

  Future<List<PDV>> getPdvs() async {
    try {
      String? headerCookies = await _secureStorage.read(key: 'Cookies');
      final response = await _dio.get('$baseUrl/api/pdvs',
        options: Options(
          headers: {'Cookie': headerCookies}
        ),
      );

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