import '../models/models.dart';
import 'base_service.dart';

class ParentService extends BaseService {
  static final ParentService _instance = ParentService._internal();
  factory ParentService() => _instance;
  ParentService._internal();

  Future<ParentResponse> getParent(String trackingId) async {
    final r = await dio.get('/api/v1/parents/$trackingId');
    return ParentResponse.fromJson(r.data);
  }

  Future<List<ParentResponse>> getParentsByEleve(String eleveTrackingId) async {
    final r = await dio.get('/api/v1/parents/par-eleve/$eleveTrackingId');
    return (r.data as List).map((e) => ParentResponse.fromJson(e)).toList();
  }

  Future<ParentResponse> ajouterEnfant(String parentId, String eleveId) async {
    final r = await dio.post('/api/v1/parents/$parentId/enfants/$eleveId');
    return ParentResponse.fromJson(r.data);
  }

  Future<ParentResponse> retirerEnfant(String parentId, String eleveId) async {
    final r = await dio.delete('/api/v1/parents/$parentId/enfants/$eleveId');
    return ParentResponse.fromJson(r.data);
  }
}
