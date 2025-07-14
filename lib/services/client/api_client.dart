import 'package:bit_money/config/env_config.dart';
import 'package:bit_money/screens/login_screen.dart';
import 'package:bit_money/services/auth/auth_interceptor.dart';
import 'package:bit_money/services/auth/auth_service.dart';
import 'package:bit_money/services/client/cache_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  final String baseUrl = EnvConfig.baseUrl;
  final Map<String, dynamic> _cache = {};
  late CacheInterceptor _cacheInterceptor;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  factory ApiClient() {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  ApiClient._internal() {
    _initDio();
  }

  static ApiClient get instance => ApiClient();

  static void reset() {
    _instance = null;
  }

  void _initDio() {
    _dio = Dio(BaseOptions(
      baseUrl: '$baseUrl/api',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) => true,
    ));

    _cacheInterceptor = CacheInterceptor(
      defaultCacheDuration: const Duration(hours: 1),
      useMemoryCache: true,
      useSharedPreferences: true,
    );

    _dio.interceptors.add(_cacheInterceptor);

    _dio.interceptors.add(AuthInterceptor(
      dio: _dio,
      authService: AuthService.instance,
      navigatorKey: navigatorKey,
    ));

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: true,
      ),
    );
  }

  Future<bool> _checkAuth() async {
    return await AuthService.instance.isLoggedIn();
  }

  void _handleSessionExpired() async {
    await AuthService.instance.logout();

    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<Response> get(String path, {
    Map<String, dynamic>? queryParams,
    bool useCache = false,
    Duration? cacheDuration,
  }) async {
    if (!await _checkAuth()) {
      _handleSessionExpired();
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.cancel,
        error: 'Session expirée',
      );
    }

    String cacheKey = path;
    if (queryParams != null && queryParams.isNotEmpty) {
      cacheKey += '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }

    if (useCache && _cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey];
      final cacheTime = cached['timestamp'] as DateTime;
      final duration = cacheDuration ?? const Duration(hours: 1);

      if (DateTime.now().difference(cacheTime) < duration) {
        return Response(
          requestOptions: RequestOptions(path: path),
          statusCode: 200,
          data: cached['data'],
        );
      }
    }

    final response = await _dio.get(
      path,
      queryParameters: queryParams,
      options: Options(
        extra: {
          'useCache': useCache,
          if (cacheDuration != null) 'cacheDuration': cacheDuration,
        },
      ),
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      _handleSessionExpired();
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.connectionError,
        error: 'Session expirée',
        response: response,
      );
    }

    if (useCache && response.statusCode == 200) {
      _cache[cacheKey] = {
        'data': response.data,
        'timestamp': DateTime.now(),
      };
    }

    return response;
  }

  Future<Response> post(String path, {dynamic data}) async {
    if (!await _checkAuth()) {
      _handleSessionExpired();
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.cancel,
        error: 'Session expirée',
      );
    }

    final response = await _dio.post(path, data: data);

    if (response.statusCode == 401 || response.statusCode == 403) {
      _handleSessionExpired();
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.connectionError,
        error: 'Session expirée',
        response: response,
      );
    }

    return response;
  }

  Future<Response> postWithOptions(String path, {
    dynamic data,
    Map<String, String>? headers,
    Options? options,
  }) async {
    if (!await _checkAuth()) {
      _handleSessionExpired();
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.cancel,
        error: 'Session expirée',
      );
    }

    final finalOptions = options ?? Options();

    if (headers != null) {
      finalOptions.headers = {
        ...?finalOptions.headers,
        ...headers,
      };
    }

    final response = await _dio.post(
      path,
      data: data,
      options: finalOptions,
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      _handleSessionExpired();
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.connectionError,
        error: 'Session expirée',
        response: response,
      );
    }

    return response;
  }

  Future<Response> put(String path, {dynamic data}) async {
    if (!await _checkAuth()) {
      _handleSessionExpired();
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.cancel,
        error: 'Session expirée',
      );
    }

    final response = await _dio.put(path, data: data);

    if (response.statusCode == 401 || response.statusCode == 403) {
      _handleSessionExpired();
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.connectionError,
        error: 'Session expirée',
        response: response,
      );
    }

    return response;
  }

  Future<Response> delete(String path) async {
    if (!await _checkAuth()) {
      _handleSessionExpired();
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.cancel,
        error: 'Session expirée',
      );
    }

    final response = await _dio.delete(path);

    if (response.statusCode == 401 || response.statusCode == 403) {
      _handleSessionExpired();
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.connectionError,
        error: 'Session expirée',
        response: response,
      );
    }

    return response;
  }

  Future<void> clearCache() async {
    _cache.clear();
    await _cacheInterceptor.clearCache();
  }

  Dio get dio => _dio;
}