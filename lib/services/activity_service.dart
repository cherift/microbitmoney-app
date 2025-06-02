import 'package:bit_money/models/activity_model.dart';
import 'package:bit_money/services/client/api_client.dart';
import 'package:flutter/material.dart';

class ActivityService {
  static final ActivityService _instance = ActivityService._internal();
  factory ActivityService() => _instance;
  ActivityService._internal();

  final ApiClient _apiClient = ApiClient();


  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Activités en cache
  List<ActivityItem> _recentActivities = [];
  List<ActivityItem> get recentActivities => _recentActivities;


  // Récupérer les activités récentes (les 10 dernières notifications)
  Future<List<ActivityItem>> fetchRecentActivities() async {
    if (_isLoading) return _recentActivities;

    try {
      _isLoading = true;

      final response = await _apiClient.get('/notifications');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> notificationsJson = data['notifications'] as List;

        _recentActivities = notificationsJson
            .map((json) => ActivityItem.fromNotification(json))
            .toList();
      }

      return _recentActivities;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des activités récentes: $e');
      return _recentActivities;
    } finally {
      _isLoading = false;
    }
  }
}