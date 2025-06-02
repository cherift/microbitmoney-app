import 'package:dio/dio.dart';

abstract class ApiClientInterface {
  Future<Response> get(String path, {
    Map<String, dynamic>? queryParams,
    bool useCache = false,
    Duration? cacheDuration,
  });

  Future<Response> post(String path, {dynamic data});

  Future<Response> postWithOptions(String path, {
    dynamic data,
    Map<String, String>? headers,
    Options? options,
  });

  Future<Response> put(String path, {dynamic data});
  Future<Response> delete(String path);
  Future<void> clearCache();
}