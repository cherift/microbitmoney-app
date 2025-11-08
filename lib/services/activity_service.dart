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

  List<ActivityItem> _recentActivities = [];
  List<ActivityItem> get recentActivities => _recentActivities;

  Future<List<ActivityItem>> fetchRecentActivities(BuildContext context) async {
    if (_isLoading) return _recentActivities;

    try {
      _isLoading = true;

      final response = await _apiClient.get('/notifications');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> notificationsJson = data['notifications'] as List;

        _recentActivities = await Future.wait(
          notificationsJson.map((json) => ActivityItem.fromNotificationAsync(json, context))
        );
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