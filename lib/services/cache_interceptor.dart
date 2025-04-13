import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheInterceptor extends Interceptor {
  final Map<String, CacheEntry> _memoryCache = {};
  final Duration defaultCacheDuration;
  final bool useMemoryCache;
  final bool useSharedPreferences;

  CacheInterceptor({
    this.defaultCacheDuration = const Duration(hours: 1),
    this.useMemoryCache = true,
    this.useSharedPreferences = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.method != 'GET') {
      return handler.next(options);
    }

    if (options.extra['noCache'] == true) {
      return handler.next(options);
    }

    final bool useCache = options.extra['useCache'] ?? false;
    if (!useCache) {
      return handler.next(options);
    }

    final String cacheKey = _generateCacheKey(options);

    if (useMemoryCache) {
      final cacheEntry = _memoryCache[cacheKey];
      if (cacheEntry != null && !cacheEntry.isExpired()) {

        final headers = Headers();
        cacheEntry.headers.forEach((key, value) {
          headers.set(key, value);
        });

        return handler.resolve(
          Response(
            requestOptions: options,
            data: cacheEntry.data,
            statusCode: 200,
            headers: headers,
            isRedirect: false,
            extra: {'fromCache': true},
          ),
        );
      }
    }

    if (useSharedPreferences) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final String? cachedData = prefs.getString(cacheKey);

        if (cachedData != null) {
          final Map<String, dynamic> cacheMap = jsonDecode(cachedData);
          final CacheEntry cacheEntry = CacheEntry.fromJson(cacheMap);

          if (!cacheEntry.isExpired()) {
            if (useMemoryCache) {
              _memoryCache[cacheKey] = cacheEntry;
            }

            final headers = Headers();
            cacheEntry.headers.forEach((key, value) {
              headers.set(key, value);
            });

            return handler.resolve(
              Response(
                requestOptions: options,
                data: cacheEntry.data,
                statusCode: 200,
                headers: headers,
                isRedirect: false,
                extra: {'fromCache': true},
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Erreur lors de la récupération du cache: $e');
      }
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response.requestOptions.method != 'GET') {
      return handler.next(response);
    }

    final RequestOptions options = response.requestOptions;
    final bool useCache = options.extra['useCache'] ?? false;

    if (useCache && response.statusCode == 200) {
      final String cacheKey = _generateCacheKey(options);
      final Duration cacheDuration = options.extra['cacheDuration'] ?? defaultCacheDuration;

      final Map<String, List<String>> headerMap = {};
      response.headers.forEach((name, values) {
        headerMap[name] = values;
      });

      final CacheEntry cacheEntry = CacheEntry(
        data: response.data,
        headers: headerMap,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        duration: cacheDuration.inMilliseconds,
      );

      if (useMemoryCache) {
        _memoryCache[cacheKey] = cacheEntry;
      }

      if (useSharedPreferences) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(cacheKey, jsonEncode(cacheEntry.toJson()));
        } catch (e) {
          debugPrint('Erreur lors de la sauvegarde du cache: $e');
        }
      }
    }

    handler.next(response);
  }

  String _generateCacheKey(RequestOptions options) {
    final StringBuffer buffer = StringBuffer();
    buffer.write(options.method);
    buffer.write(options.path);

    if (options.queryParameters.isNotEmpty) {
      final String queryParams = Uri(queryParameters: options.queryParameters).query;
      buffer.write('?$queryParams');
    }

    return buffer.toString();
  }

  Future<void> clearCache() async {
    _memoryCache.clear();

    if (useSharedPreferences) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final keys = prefs.getKeys();
        for (final key in keys) {
          if (key.startsWith('dio_cache_')) {
            await prefs.remove(key);
          }
        }
      } catch (e) {
        debugPrint('Erreur lors de la suppression du cache: $e');
      }
    }
  }
}

class CacheEntry {
  final dynamic data;
  final Map<String, List<String>> headers;
  final int timestamp;
  final int duration;

  CacheEntry({
    required this.data,
    required this.headers,
    required this.timestamp,
    required this.duration,
  });

  bool isExpired() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return now > timestamp + duration;
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'headers': headers,
      'timestamp': timestamp,
      'duration': duration,
    };
  }

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      data: json['data'],
      headers: (json['headers'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, List<String>.from(v as List)),
      ),
      timestamp: json['timestamp'],
      duration: json['duration'],
    );
  }
}