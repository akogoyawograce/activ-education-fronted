import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('Backend Connection Tests', () {
    late Dio dio;

    setUp(() async {
      await dotenv.load(fileName: ".env");
      final baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://localhost:8081');

      dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));
    });

    test('can connect to backend and get API documentation', () async {
      try {
        final response = await dio.get('/api-docs');
        expect(response.statusCode, 200);
        expect(response.data, isNotNull);
      } catch (e) {
        print('Error connecting to API: $e');
        rethrow;
      }
    });

    test('can access bibliotheque series endpoint (paginated)', () async {
      try {
        final response = await dio.get('/api/v1/bibliotheque/series');
        expect(response.statusCode, 200);
        expect(response.data, isNotNull);
        expect(response.data, isA<Map<String, dynamic>>());
        final data = response.data as Map<String, dynamic>;
        expect(data.containsKey('content'), true);
        expect(data.containsKey('totalElements'), true);
      } catch (e) {
        print('Error accessing series endpoint: $e');
        rethrow;
      }
    });

    test('can access bibliotheque filieres endpoint', () async {
      try {
        final response = await dio.get('/api/v1/bibliotheque/filieres');
        expect(response.statusCode, 200);
        expect(response.data, isNotNull);
      } catch (e) {
        print('Error accessing filieres endpoint: $e');
        rethrow;
      }
    });
  });
}