import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:bit_money/config/env_config.dart';
import 'package:bit_money/services/auth_service.dart';
import 'auth_interceptor.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio dio;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final AuthService _authService = AuthService();
  final String baseUrl = EnvConfig.baseUrl;

  ApiClient._internal() {
    _initDio();
  }

  void _initDio() {
    dio = Dio(
      BaseOptions(
        baseUrl: '$baseUrl/api',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => true,
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        authService: _authService,
        navigatorKey: navigatorKey,
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: true,
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) {
    return dio.get(path, queryParameters: queryParams);
  }

  Future<Response> post(String path, {dynamic data}) {
    return dio.post(path, data: data);
  }
}