import '../models/models.dart';
import 'base_service.dart';

class AcademicService extends BaseService {
  static final AcademicService _instance = AcademicService._internal();
  factory AcademicService() => _instance;
  AcademicService._internal();

  Future<NoteResponse> ajouterNote(String eleveId, NoteRequest request) async {
    final res = await dio.post('/api/v1/eleves/$eleveId/notes', data: request.toJson());
    return NoteResponse.fromJson(res.data);
  }

  Future<List<NoteResponse>> getNotesEleve(String eleveId) async {
    final res = await dio.get('/api/v1/eleves/$eleveId/notes');
    return (res.data as List).map((e) => NoteResponse.fromJson(e)).toList();
  }

  Future<NoteResponse> modifierNote(String trackingId, NoteRequest request) async {
    final res = await dio.put('/api/v1/notes/$trackingId', data: request.toJson());
    return NoteResponse.fromJson(res.data);
  }

  Future<void> supprimerNote(String trackingId) async {
    await dio.delete('/api/v1/notes/$trackingId');
  }

  Future<NoteResponse> getNote(String trackingId) async {
    final res = await dio.get('/api/v1/notes/$trackingId');
    return NoteResponse.fromJson(res.data);
  }

  Future<PageResponse<NoteResponse>> getNotesElevePagine(String eleveId, {int page = 0, int size = 10}) async {
    final res = await dio.get('/api/v1/eleves/$eleveId/notes/pagine', queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(res.data, (json) => NoteResponse.fromJson(json));
  }
}
