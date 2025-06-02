import 'package:bit_money/services/client/api_client_interface.dart';
import 'package:bit_money/services/client/api_client_web.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

class ApiClient implements ApiClientInterface {
  static ApiClientInterface? _instance;
  late final ApiClientInterface _delegate;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  factory ApiClient() {
    return ApiClient._internal();
  }

  ApiClient._internal() {
    _delegate = _createApiClient();
  }

  ApiClientInterface _createApiClient() => ApiClientWeb(navigatorKey);

  static ApiClientInterface get instance {
    _instance ??= ApiClient();
    return _instance!;
  }

  static void reset() {
    _instance = null;
  }

  @override
  Future<Response> get(String path, {
    Map<String, dynamic>? queryParams,
    bool useCache = false,
    Duration? cacheDuration,
  }) => _delegate.get(
    path,
    queryParams: queryParams,
    useCache: useCache,
    cacheDuration: cacheDuration,
  );

  @override
  Future<Response> post(String path, {dynamic data}) =>
      _delegate.post(path, data: data);

  @override
  Future<Response> postWithOptions(String path, {
    dynamic data,
    Map<String, String>? headers,
    Options? options,
  }) => _delegate.postWithOptions(
    path,
    data: data,
    headers: headers,
    options: options,
  );

  @override
  Future<Response> put(String path, {dynamic data}) =>
      _delegate.put(path, data: data);

  @override
  Future<Response> delete(String path) =>
      _delegate.delete(path);

  @override
  Future<void> clearCache() => _delegate.clearCache();
}