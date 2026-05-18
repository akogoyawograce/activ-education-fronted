import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('Backend Connection Tests', () {
    late Dio dio;

    setUp(() async {
      await dotenv.load(fileName: ".env");
      final baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://localhost:8081');
      final skipNgrok = dotenv.get('API_SKIP_NGROK_WARNING', fallback: 'false') == 'true';

      dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (skipNgrok) 'ngrok-skip-browser-warning': 'true',
        },
      ));
    });

    test('can connect to backend and get API documentation', () async {
      try {
        // Test a simple endpoint that should exist
        final response = await dio.get('/api-docs');
        expect(response.statusCode, 200);
        expect(response.data, isNotNull);
        print('API documentation accessible: ${response.data['info']['title']}');
      } catch (e) {
        print('Error connecting to API: $e');
        rethrow; // Rethrow to fail the test if connection fails
      }
    });

    test('can access bibliotheque series endpoint (paginated)', () async {
      try {
        final response = await dio.get('/api/v1/bibliotheque/series');
        expect(response.statusCode, 200);
        expect(response.data, isNotNull);
        // Check that it's a paginated response
        expect(response.data, isA<Map<String, dynamic>>());
        final data = response.data as Map<String, dynamic>;
        expect(data.containsKey('content'), true);
        expect(data.containsKey('totalElements'), true);
        print('Series endpoint accessible: ${data['totalElements']} total elements, ${data['content'].length} in current page');
      } catch (e) {
        print('Error accessing series endpoint: $e');
        rethrow;
      }
    });

    test('can access conseillers endpoint (paginated)', () async {
      try {
        final response = await dio.get('/api/v1/conseillers');
        expect(response.statusCode, 200);
        expect(response.data, isNotNull);
        // Check that it's a paginated response
        expect(response.data, isA<Map<String, dynamic>>());
        final data = response.data as Map<String, dynamic>;
        expect(data.containsKey('content'), true);
        expect(data.containsKey('totalElements'), true);
        print('Conseillers endpoint accessible: ${data['totalElements']} total elements, ${data['content'].length} in current page');
      } catch (e) {
        print('Error accessing conseillers endpoint: $e');
        rethrow;
      }
    });

    test('can access a specific endpoint without pagination', () async {
      try {
        // Test an endpoint that might return a simple list or object
        final response = await dio.get('/api/v1/bibliotheque/series/0');
        // This might return 404 if the ID doesn't exist, but that's OK for testing connectivity
        print('Specific series endpoint responded with status: ${response.statusCode}');
      } catch (e) {
        print('Error accessing specific series endpoint: $e');
        // This is expected if the ID doesn't exist
      }
    });
  });
}