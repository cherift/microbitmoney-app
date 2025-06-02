import 'package:bit_money/config/env_config.dart';
import 'package:bit_money/services/auth/auth_interceptor.dart';
import 'package:bit_money/services/auth/auth_service.dart';
import 'package:bit_money/services/auth/auth_service_web.dart';
import 'package:bit_money/services/client/cache_interceptor.dart';
import 'package:bit_money/services/client/api_client_interface.dart';
import 'package:dio/dio.dart';
import 'package:dio/browser.dart';
import 'package:flutter/material.dart';

class ApiClientWeb implements ApiClientInterface {
  final String baseUrl = EnvConfig.baseUrl;
  final Map<String, dynamic> _cache = {};
  late final Dio _dio;
  late CacheInterceptor _cacheInterceptor;
  final GlobalKey<NavigatorState> navigatorKey;

  ApiClientWeb(
    this.navigatorKey,
  ) {
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

    final adapter = BrowserHttpClientAdapter();
    _dio.httpClientAdapter = adapter;

    _cacheInterceptor = CacheInterceptor(
      defaultCacheDuration: const Duration(hours: 1),
      useMemoryCache: true,
      useSharedPreferences: true,
    );

    _dio.interceptors.add(_cacheInterceptor);

    _dio.interceptors.add(AuthInterceptor(
      dio: _dio,
      authService: AuthService.instance as AuthServiceWeb,
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

  @override
  Future<Response> get(String path, {
    Map<String, dynamic>? queryParams,
    bool useCache = false,
    Duration? cacheDuration,
  }) async {
    if (!await _checkAuth()) {
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

  @override
  Future<Response> post(String path, {dynamic data}) async {
    if (!await _checkAuth()) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.cancel,
        error: 'Session expirée',
      );
    }

    final response = await _dio.post(path, data: data);

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.connectionError,
        error: 'Session expirée',
        response: response,
      );
    }

    return response;
  }

  @override
  Future<Response> postWithOptions(String path, {
    dynamic data,
    Map<String, String>? headers,
    Options? options,
  }) async {
    if (!await _checkAuth()) {
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
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.connectionError,
        error: 'Session expirée',
        response: response,
      );
    }

    return response;
  }

  @override
  Future<Response> put(String path, {dynamic data}) async {
    if (!await _checkAuth()) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.cancel,
        error: 'Session expirée',
      );
    }

    final response = await _dio.put(path, data: data);

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.connectionError,
        error: 'Session expirée',
        response: response,
      );
    }

    return response;
  }

  @override
  Future<Response> delete(String path) async {
    if (!await _checkAuth()) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.cancel,
        error: 'Session expirée',
      );
    }

    final response = await _dio.delete(path);

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw DioException(
        requestOptions: response.requestOptions,
        type: DioExceptionType.connectionError,
        error: 'Session expirée',
        response: response,
      );
    }

    return response;
  }

  @override
  Future<void> clearCache() async {
    _cache.clear();
  }
}