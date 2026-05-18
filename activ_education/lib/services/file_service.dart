import 'dart:io';
import 'package:dio/dio.dart';
import '../models/models.dart';
import 'base_service.dart';

class FileService extends BaseService {
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;
  FileService._internal();

  /// Upload un fichier → POST /files/upload/{fileType}
  Future<FileUploadResponse> uploadFichier(File file, String fileType) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
    });
    final res = await dio.post('/files/upload/$fileType', data: formData);
    return FileUploadResponse.fromJson(res.data);
  }

  /// URL d'un fichier → GET /files/url/{fileType}/{fileName}
  Future<String> getFileUrl(String fileType, String fileName) async {
    final res = await dio.get('/files/url/$fileType/$fileName');
    return res.data as String;
  }
}
