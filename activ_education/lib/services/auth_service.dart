import '../models/models.dart';
import 'base_service.dart';

class AuthService extends BaseService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// JWT Login
  Future<TokenResponse> login(String email, String password) async {
    final body = LoginRequest(email: email, motDePasse: password);
    final res = await dio.post('/api/v1/auth/login', data: body.toJson());
    return TokenResponse.fromJson(res.data);
  }

  /// Get current user profile (JWT required)
  Future<Map<String, dynamic>> getMe() async {
    final res = await dio.get('/api/v1/auth/me');
    return res.data as Map<String, dynamic>;
  }

  /// Save JWT token + user data
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
    try {
      await dio.post('/api/v1/auth/logout');
    } catch (_) {}
    await storage.deleteAll();
  }

  // Registration (public endpoints)
  Future<EleveResponse> inscrireEleve(EleveRequest request) async {
    final res = await dio.post('/api/v1/eleves', data: request.toJson());
    return EleveResponse.fromJson(res.data);
  }

  Future<ParentResponse> inscrireParent(ParentRequest request) async {
    final res = await dio.post('/api/v1/parents', data: request.toJson());
    return ParentResponse.fromJson(res.data);
  }

  Future<ConseillerResponse> inscrireConseiller(ConseillerRequest request) async {
    final res = await dio.post('/api/v1/conseillers', data: request.toJson());
    return ConseillerResponse.fromJson(res.data);
  }

  Future<AdministrateurResponse> creerAdministrateur(AdministrateurRequest request) async {
    final res = await dio.post('/api/v1/administrateurs', data: request.toJson());
    return AdministrateurResponse.fromJson(res.data);
  }

  // User lookup
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

  Future<AdministrateurResponse> getAdministrateur(String trackingId) async {
    final res = await dio.get('/api/v1/administrateurs/$trackingId');
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
