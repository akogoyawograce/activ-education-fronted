import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
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

  // Upload single file
  Future<String> uploadFile(File file, String fileType) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path,
        filename: path.basename(file.path)),
    });
    final response = await dio.post('/files/upload/$fileType', data: formData);
    return response.data['fileName'] as String;
  }

  // Get public URL
  Future<String> getPublicUrl(String fileType, String fileName) async {
    final response = await dio.get('/files/url/$fileType/$fileName');
    return response.data as String;
  }

  // Get PDF thumbnail
  Future<Uint8List> getPdfThumbnail(String fileName, {int width = 200, int height = 280}) async {
    final response = await dio.get(
      '/files/pdf/thumbnail/$fileName',
      queryParameters: {'width': width, 'height': height},
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data);
  }

  // List files by type
  Future<List<dynamic>> listFiles(String fileType) async {
    final response = await dio.get('/files/list/$fileType');
    return response.data as List;
  }

  // Delete file
  Future<void> deleteFile(String fileType, String fileName) async {
    await dio.delete('/files/$fileType/$fileName');
  }

  // Upload multiple files
  Future<List<String>> uploadMultiple(List<File> files, String fileType) async {
    final formData = FormData();
    for (final file in files) {
      formData.files.add(MapEntry('files',
        await MultipartFile.fromFile(file.path, filename: path.basename(file.path))));
    }
    final response = await dio.post('/files/upload/multiple/$fileType', data: formData);
    return (response.data as List).map((e) => e['fileName'] as String).toList();
  }
}
