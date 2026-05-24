import '../models/models.dart';
import 'base_service.dart';

class DiagnosticService extends BaseService {
  static final DiagnosticService _instance = DiagnosticService._internal();
  factory DiagnosticService() => _instance;
  DiagnosticService._internal();

  Future<PageResponse<QuizResponse>> listerQuizzes({int page = 0, int size = 10}) async {
    final res = await dio.get('/api/v1/quiz', queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(res.data, (json) => QuizResponse.fromJson(json));
  }

  Future<List<QuestionResponse>> getQuestionsQuiz(String quizId) async {
    final res = await dio.get('/api/v1/quiz/$quizId/questions');
    return (res.data as List).map((e) => QuestionResponse.fromJson(e)).toList();
  }

  Future<List<ReponseResponse>> getReponsesQuestion(String questionId) async {
    final res = await dio.get('/api/v1/questions/$questionId/reponses');
    return (res.data as List).map((e) => ReponseResponse.fromJson(e)).toList();
  }

  Future<ResultatDiagnosticResponse> soumettreResultat(ResultatDiagnosticRequest request) async {
    final res = await dio.post('/api/v1/resultats-diagnostic', data: request.toJson());
    return ResultatDiagnosticResponse.fromJson(res.data);
  }

  Future<List<ResultatDiagnosticResponse>> getHistoriqueResultats(String eleveId) async {
    final res = await dio.get('/api/v1/eleves/$eleveId/resultats-diagnostic');
    return (res.data as List).map((e) => ResultatDiagnosticResponse.fromJson(e)).toList();
  }

  Future<ResultatDiagnosticResponse?> getDernierResultat(String eleveId, String quizId) async {
    try {
      final res = await dio.get('/api/v1/eleves/$eleveId/resultats-diagnostic/dernier', queryParameters: {'quizTrackingId': quizId});
      if (res.statusCode == 204) return null;
      return ResultatDiagnosticResponse.fromJson(res.data);
    } catch (_) {
      return null;
    }
  }

  Future<PageResponse<ResultatDiagnosticResponse>> getResultatsEleve(String eleveId, {int page = 0, int size = 10}) async {
    final res = await dio.get('/api/v1/eleves/$eleveId/resultats-diagnostic', queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(res.data, (json) => ResultatDiagnosticResponse.fromJson(json));
  }

}
