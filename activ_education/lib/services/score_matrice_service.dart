import '../models/models.dart';
import 'base_service.dart';

class ScoreMatriceService extends BaseService {
  static final ScoreMatriceService _instance = ScoreMatriceService._internal();
  factory ScoreMatriceService() => _instance;
  ScoreMatriceService._internal();

  Future<ScoreMatriceResponse> creerMatrice(ScoreMatriceRequest request) async {
    final res = await dio.post('/api/v1/score-matrices', data: request.toJson());
    return ScoreMatriceResponse.fromJson(res.data);
  }

  Future<ScoreMatriceResponse> getMatrice(String trackingId) async {
    final res = await dio.get('/api/v1/score-matrices/$trackingId');
    return ScoreMatriceResponse.fromJson(res.data);
  }

  Future<List<ScoreMatriceResponse>> listerMatrices({
    int page = 0,
    int size = 10,
  }) async {
    final res = await dio.get('/api/v1/score-matrices', queryParameters: {
      'page': page,
      'size': size,
    });
    return (res.data['content'] as List)
        .map((e) => ScoreMatriceResponse.fromJson(e))
        .toList();
  }

  Future<ScoreMatriceResponse> modifierMatrice(
    String trackingId,
    ScoreMatriceRequest request,
  ) async {
    final res =
        await dio.put('/api/v1/score-matrices/$trackingId', data: request.toJson());
    return ScoreMatriceResponse.fromJson(res.data);
  }

  Future<void> supprimerMatrice(String trackingId) async {
    await dio.delete('/api/v1/score-matrices/$trackingId');
  }
}
