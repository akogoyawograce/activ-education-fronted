import 'package:flutter_dotenv/flutter_dotenv.dart';

String? resolveImageUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.contains('minio:')) {
    final fileName = url.split('/').last;
    final baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://localhost:8081');
    return '$baseUrl/files/download/IMAGE/$fileName';
  }
  return url;
}
