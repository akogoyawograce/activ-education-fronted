import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class BaseService {
  static final Dio _dio = _initDio();
  static const _storage = FlutterSecureStorage();

  static Dio _initDio() {
    final baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://localhost:8080');
    final skipNgrok = dotenv.get('API_SKIP_NGROK_WARNING', fallback: 'false') == 'true';
    print('BaseService: baseUrl = $baseUrl, skipNgrok = $skipNgrok');

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (skipNgrok) 'ngrok-skip-browser-warning': 'true',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));

    return dio;
  }

  Dio get dio => _dio;
  FlutterSecureStorage get storage => _storage;

  // Error handling common to all services
  String handleError(dynamic e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return "Le serveur met trop de temps à répondre.";
      }
      if (e.type == DioExceptionType.connectionError) {
        return "Impossible de se connecter au serveur. Vérifiez votre connexion.";
      }
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'];
        }
        return "Erreur serveur : ${e.response?.statusCode}";
      }
    }
    return e.toString();
  }

  Future<String?> getTrackingId() => _storage.read(key: 'user_tracking_id');
  Future<String?> getUserRole() => _storage.read(key: 'user_role');
}
