import '../models/models.dart';
import 'base_service.dart';

class AuthService extends BaseService {
  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Inscription élève
  Future<EleveResponse> inscrireEleve(EleveRequest request) async {
    final res = await dio.post('/api/v1/eleves', data: request.toJson());
    return EleveResponse.fromJson(res.data);
  }

  /// Login simulé ou réel (selon l'API actuelle)
  /// Note: Dans api_service.dart actuel, le login semble être géré par saveToken
  /// après un appel spécifique. Je garde la structure actuelle.

  Future<void> saveToken(String token) async {
    await storage.write(key: 'auth_token', value: token);
  }

  Future<void> saveUserData({
    required String trackingId,
    required String role,
  }) async {
    await storage.write(key: 'user_tracking_id', value: trackingId);
    await storage.write(key: 'user_role', value: role);
  }

  Future<void> logout() async {
    await storage.deleteAll();
  }

  // User management
  Future<EleveResponse> getEleve(String trackingId) async {
    final res = await dio.get('/api/v1/eleves/$trackingId');
    return EleveResponse.fromJson(res.data);
  }

  Future<ConseillerResponse> getConseiller(String trackingId) async {
    final res = await dio.get('/api/v1/conseillers/$trackingId');
    return ConseillerResponse.fromJson(res.data);
  }

  Future<ParentResponse> getParent(String trackingId) async {
    final res = await dio.get('/api/v1/parents/$trackingId');
    return ParentResponse.fromJson(res.data);
  }

  Future<AdministrateurResponse> creerAdministrateur(AdministrateurRequest request) async {
    final res = await dio.post('/api/v1/administrateurs', data: request.toJson());
    return AdministrateurResponse.fromJson(res.data);
  }

  Future<PageResponse<AdministrateurResponse>> listerAdmins({int page = 0, int size = 10}) async {
    final res = await dio.get('/api/v1/administrateurs', queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(res.data, (json) => AdministrateurResponse.fromJson(json));
  }

  Future<Map<String, String>> getUtilisateurNom(String trackingId) async {
    try {
      final conseiller = await getConseiller(trackingId);
      return {'nom': conseiller.nom, 'prenom': conseiller.prenom, 'type': 'conseiller'};
    } catch (_) {
      try {
        final eleve = await getEleve(trackingId);
        return {'nom': eleve.nom, 'prenom': eleve.prenom, 'type': 'eleve'};
      } catch (_) {
        return {'nom': 'Inconnu', 'prenom': 'Utilisateur', 'type': 'inconnu'};
      }
    }
  }
  Future<List<ConseillerResponse>> getConseillers({int page = 0, int size = 100}) async {
    final res = await dio.get('/api/v1/conseillers', queryParameters: {'page': page, 'size': size});
    return (res.data as List).map((e) => ConseillerResponse.fromJson(e)).toList();
  }
}
