import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class BaseService {
  static final Dio _dio = _initDio();
  static const _storage = FlutterSecureStorage();
  static Completer<bool>? _refreshCompleter;

  static Dio _initDio() {
    final baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://localhost:8081');

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        _storage.read(key: 'auth_token').then((token) {
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        }).catchError((_) {
          handler.next(options);
        });
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshWithLock();
          if (refreshed) {
            final token = await _storage.read(key: 'auth_token');
            if (token != null) {
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              try {
                final retryResponse = await Dio(_dio.options).fetch(error.requestOptions);
                return handler.resolve(retryResponse);
              } catch (_) {
                return handler.next(error);
              }
            }
          }
          await _storage.deleteAll();
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
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null || refreshToken.isEmpty) return false;
      final baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://localhost:8081');
      final response = await Dio().post(
        '$baseUrl/api/v1/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = response.data as Map<String, dynamic>;
      final newAccess = data['accessToken'] as String?;
      final newRefresh = data['refreshToken'] as String?;
      if (newAccess != null && newAccess.isNotEmpty) {
        await _storage.write(key: 'auth_token', value: newAccess);
        if (newRefresh != null && newRefresh.isNotEmpty) {
          await _storage.write(key: 'refresh_token', value: newRefresh);
        }
        return true;
      }
      return false;
    } catch (_) {
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

  Future<String?> getTrackingId() => _storage.read(key: 'user_tracking_id').catchError((_) => null);
  Future<String?> getUserRole() => _storage.read(key: 'user_role').catchError((_) => null);
  Future<String?> getAccessToken() => _storage.read(key: 'auth_token').catchError((_) => null);
}
