import '../models/models.dart';
import '../widgets/common_widgets.dart';
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
    final res = await dioGet('/api/v1/auth/me');
    return res.data as Map<String, dynamic>;
  }

  /// Save JWT access token
  Future<void> saveToken(String token) async {
    await storage.write(key: 'auth_token', value: token);
    BaseService.cachedAccessToken = token;
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await storage.write(key: 'refresh_token', value: token);
    BaseService.cachedRefreshToken = token;
  }

  Future<void> saveUserData({
    required String trackingId,
    required String role,
  }) async {
    await storage.write(key: 'user_tracking_id', value: trackingId);
    await storage.write(key: 'user_role', value: role);
    BaseService.cachedTrackingId = trackingId;
    BaseService.cachedUserRole = role;
  }

  Future<void> logout() async {
    try {
      await dio.post('/api/v1/auth/logout');
    } catch (_) {}
    BaseService.clearCache();
    BaseService.clearUserCache();
    await storage.deleteAll();
    _nomCache.clear();
    AuthImage.clearTokenCache();
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

  Future<ConseillerResponse> inscrireConseiller(
      ConseillerRequest request) async {
    final res = await dio.post('/api/v1/conseillers', data: request.toJson());
    return ConseillerResponse.fromJson(res.data);
  }

  Future<AdministrateurResponse> creerAdministrateur(
      AdministrateurRequest request) async {
    final res =
        await dio.post('/api/v1/administrateurs', data: request.toJson());
    return AdministrateurResponse.fromJson(res.data);
  }

  // User lookup
  Future<EleveResponse> getEleve(String trackingId) async {
    final res = await dioGet('/api/v1/eleves/$trackingId');
    return EleveResponse.fromJson(res.data);
  }

  Future<ConseillerResponse> getConseiller(String trackingId) async {
    final res = await dioGet('/api/v1/conseillers/$trackingId');
    return ConseillerResponse.fromJson(res.data);
  }

  Future<ParentResponse> getParent(String trackingId) async {
    final res = await dioGet('/api/v1/parents/$trackingId');
    return ParentResponse.fromJson(res.data);
  }

  Future<AdministrateurResponse> getAdministrateur(String trackingId) async {
    final res = await dioGet('/api/v1/administrateurs/$trackingId');
    return AdministrateurResponse.fromJson(res.data);
  }

  Future<PageResponse<AdministrateurResponse>> listerAdmins(
      {int page = 0, int size = 10}) async {
    final res = await dioGet('/api/v1/administrateurs',
        queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(
        res.data, (json) => AdministrateurResponse.fromJson(json));
  }

  static final Map<String, Map<String, String>> _nomCache = {};
  static const int _nomCacheMax = 50;

  Future<Map<String, String>> getUtilisateurNom(String trackingId) async {
    if (_nomCache.containsKey(trackingId)) return _nomCache[trackingId]!;
    try {
      final conseiller = await getConseiller(trackingId);
      final result = {
        'nom': conseiller.nom,
        'prenom': conseiller.prenom,
        'type': 'conseiller'
      };
      _setCache(trackingId, result);
      return result;
    } catch (_) {
      try {
        final eleve = await getEleve(trackingId);
        final result = {
          'nom': eleve.nom,
          'prenom': eleve.prenom,
          'type': 'eleve'
        };
        _setCache(trackingId, result);
        return result;
      } catch (_) {
        final short =
            trackingId.length >= 8 ? trackingId.substring(0, 8) : trackingId;
        final result = {'nom': short, 'prenom': 'Élève', 'type': 'inconnu'};
        _setCache(trackingId, result);
        return result;
      }
    }
  }

  void _setCache(String key, Map<String, String> value) {
    if (_nomCache.length >= _nomCacheMax) {
      _nomCache.remove(_nomCache.keys.first);
    }
    _nomCache[key] = value;
  }

  Future<List<ConseillerResponse>> getConseillers(
      {int page = 0, int size = 100}) async {
    final res = await dioGet('/api/v1/conseillers',
        queryParameters: {'page': page, 'size': size});
    final pageResponse = PageResponse.fromJson(
        res.data, (json) => ConseillerResponse.fromJson(json));
    return pageResponse.content;
  }
}
