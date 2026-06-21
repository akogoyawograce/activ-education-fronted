import 'package:flutter_dotenv/flutter_dotenv.dart';

String? resolveImageUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  final fileName = url.split('/').last;
  if (url.contains(':9000/') || url.contains('minio:')) {
    final baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://localhost:8080');
    return '$baseUrl/files/download/IMAGE/$fileName';
  }
  return url;
}
