import '../models/models.dart';
import 'base_service.dart';

class AdminService extends BaseService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  Future<AdministrateurResponse> creerAdministrateur(
      AdministrateurRequest request) async {
    final res = await dio.post('/api/v1/administrateurs', data: request.toJson());
    return AdministrateurResponse.fromJson(res.data);
  }

  Future<AdministrateurResponse> getAdministrateur(String trackingId) async {
    final res = await dio.get('/api/v1/administrateurs/$trackingId');
    return AdministrateurResponse.fromJson(res.data);
  }

  Future<List<AdministrateurResponse>> listerAdministrateurs({
    int page = 0,
    int size = 10,
  }) async {
    final res = await dio.get('/api/v1/administrateurs', queryParameters: {
      'page': page,
      'size': size,
    });
    return (res.data['content'] as List)
        .map((e) => AdministrateurResponse.fromJson(e))
        .toList();
  }

  Future<AdministrateurResponse> modifierAdministrateur(
    String trackingId,
    AdministrateurRequest request,
  ) async {
    final res =
        await dio.put('/api/v1/administrateurs/$trackingId', data: request.toJson());
    return AdministrateurResponse.fromJson(res.data);
  }

  Future<void> desactiverAdministrateur(String trackingId) async {
    await dio.delete('/api/v1/administrateurs/$trackingId');
  }

  Future<Map<String, dynamic>> getRecherchesOrphelines({int limite = 15}) async {
    final res = await dio.get(
      '/api/v1/admin/bibliotheque/recherches-orphelines/frequentes',
      queryParameters: {'limite': limite},
    );
    return Map<String, dynamic>.from(res.data);
  }
}
