import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class _CacheEntry {
  final dynamic data;
  final DateTime expiresAt;
  _CacheEntry(this.data, this.expiresAt);
}

abstract class BaseService {
  static final Dio _dio = _initDio();
  static const _storage = FlutterSecureStorage();
  static Completer<bool>? _refreshCompleter;
  static String? cachedRefreshToken;
  static final Map<String, _CacheEntry> _cache = {};
  static const Duration _cacheTtl = Duration(minutes: 5);

  static dynamic _cachedGet(String url, {Map<String, dynamic>? params}) {
    final key = _cacheKey(url, params);
    final entry = _cache[key];
    if (entry != null && entry.expiresAt.isAfter(DateTime.now())) {
      return entry.data;
    }
    return null;
  }

  static void _setCache(String url, dynamic data,
      {Map<String, dynamic>? params}) {
    final key = _cacheKey(url, params);
    _cache[key] = _CacheEntry(data, DateTime.now().add(_cacheTtl));
    if (_cache.length > 100) {
      _cache.remove(_cache.keys.first);
    }
  }

  static void clearCache() => _cache.clear();

  static String _cacheKey(String url, Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) return url;
    final sorted = params.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return '$url?${sorted.map((e) => '${e.key}=${e.value}').join('&')}';
  }

  static Future<String?> getRefreshToken() async {
    if (cachedRefreshToken != null) return cachedRefreshToken;
    cachedRefreshToken = await _storage.read(key: 'refresh_token');
    return cachedRefreshToken;
  }

  Future<Response> dioGet(String url,
      {Map<String, dynamic>? queryParameters, bool useCache = true}) async {
    if (useCache) {
      final cached = _cachedGet(url, params: queryParameters);
      if (cached != null) return cached;
    }
    final response = await dio.get(url, queryParameters: queryParameters);
    if (useCache) _setCache(url, response, params: queryParameters);
    return response;
  }

  static Dio _initDio() {
    final baseUrl =
        dotenv.get('API_BASE_URL', fallback: 'http://localhost:8080');

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final token = BaseService.cachedAccessToken ??
              await _storage.read(key: 'auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (_) {
          // ignore storage read errors and continue without auth header
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final requestUrl = error.requestOptions.path;
          debugPrint('401 received for $requestUrl');
          if (requestUrl.endsWith('/api/v1/auth/login') ||
              requestUrl.endsWith('/api/v1/auth/refresh')) {
            await _storage.deleteAll();
            return handler.next(error);
          }

          final refreshed = await _refreshWithLock();
          if (!refreshed) {
            debugPrint('Refresh failed — deleting tokens');
            await _storage.deleteAll();
            BaseService.clearUserCache();
            return handler.next(error);
          }

          final token = BaseService.cachedAccessToken ??
              await _storage.read(key: 'auth_token');
          if (token == null || token.isEmpty) {
            debugPrint('Token null after refresh — deleting tokens');
            await _storage.deleteAll();
            BaseService.clearUserCache();
            return handler.next(error);
          }

          final baseUrl =
              dotenv.get('API_BASE_URL', fallback: 'http://localhost:8080');
          final method = error.requestOptions.method;
          final path = error.requestOptions.path;
          final data = error.requestOptions.data;
          final queryParams = error.requestOptions.queryParameters;

          debugPrint('Retrying $method $path with new token');

          try {
            final retryResponse = await Dio().request(
              '$baseUrl$path',
              data: data,
              queryParameters: queryParams.isNotEmpty ? queryParams : null,
              options: Options(
                method: method,
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token',
                },
                validateStatus: (_) => true,
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 5),
              ),
            );
            debugPrint(
                'Retry response: ${retryResponse.statusCode} for $method $path');
            return handler.resolve(retryResponse);
          } catch (retryError) {
            debugPrint('Retry after refresh failed: $retryError');
            return handler.next(error);
          }
        }
        handler.next(error);
      },
    ));

    return dio;
  }

  static Future<bool> _refreshWithLock() async {
    if (_refreshCompleter != null) return _refreshCompleter!.future;
    _refreshCompleter = Completer<bool>();
    try {
      final result = await _tryRefreshToken();
      _refreshCompleter!.complete(result);
      return result;
    } catch (_) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  static Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint('Refresh token missing');
        return false;
      }
      final baseUrl =
          dotenv.get('API_BASE_URL', fallback: 'http://localhost:8080');
      final response = await Dio().post(
        '$baseUrl/api/v1/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(validateStatus: (_) => true),
      );
      debugPrint('Refresh response status: ${response.statusCode}');
      debugPrint('Refresh response data: ${response.data}');
      if (response.statusCode != 200) {
        return false;
      }
      final data = response.data as Map<String, dynamic>;
      final newAccess = data['accessToken'] as String?;
      final newRefresh = data['refreshToken'] as String?;
      if (newAccess != null && newAccess.isNotEmpty) {
        await _storage.write(key: 'auth_token', value: newAccess);
        cachedAccessToken = newAccess;
        if (newRefresh != null && newRefresh.isNotEmpty) {
          await _storage.write(key: 'refresh_token', value: newRefresh);
          cachedRefreshToken = newRefresh;
        }
        return true;
      }
      debugPrint('Refresh response missing accessToken');
      return false;
    } catch (e) {
      debugPrint('Refresh token exception: $e');
      return false;
    }
  }

  Dio get dio => _dio;
  FlutterSecureStorage get storage => _storage;

  String handleError(dynamic e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return "Le serveur met trop de temps à répondre.";
      }
      if (e.type == DioExceptionType.connectionError) {
        return "Impossible de se connecter au serveur. Vérifiez votre connexion.";
      }
      if (e.response?.statusCode == 401) {
        return "Votre session a expiré. Veuillez vous reconnecter.";
      }
      if (e.response?.statusCode == 403) {
        return "Vous n'avez pas accès à cette ressource.";
      }
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'];
        }
        return "Erreur serveur : ${e.response?.statusCode}";
      }
    }
    return "Une erreur inattendue est survenue.";
  }

  static String? cachedTrackingId;
  static String? cachedUserRole;
  static String? cachedAccessToken;

  Future<String?> getTrackingId() async {
    if (cachedTrackingId != null) return cachedTrackingId;
    cachedTrackingId = await _storage.read(key: 'user_tracking_id');
    return cachedTrackingId;
  }

  Future<String?> getUserRole() async {
    if (cachedUserRole != null) return cachedUserRole;
    cachedUserRole = await _storage.read(key: 'user_role');
    return cachedUserRole;
  }

  Future<String?> getAccessToken() async {
    if (cachedAccessToken != null) return cachedAccessToken;
    cachedAccessToken = await _storage.read(key: 'auth_token');
    return cachedAccessToken;
  }

  static void clearUserCache() {
    cachedTrackingId = null;
    cachedUserRole = null;
    cachedAccessToken = null;
    cachedRefreshToken = null;
  }
}
