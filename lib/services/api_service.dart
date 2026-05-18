import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/models.dart';

// ─── Base URL ─────────────────────────────────────────────────────────────────
// Remplacer par l'URL de production quand disponible
const String kBaseUrl = 'http://7e46-41-207-188-29.ngrok-free.app';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: kBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // ngrok header requis
        'ngrok-skip-browser-warning': 'true',
      },
    ));

    // Intercepteur : injection du token JWT
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
  }

  // ─── Auth helpers ────────────────────────────────────────────────────────
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> saveUserData({
    required String trackingId,
    required String role, // ELEVE | CONSEILLER | PARENT | ADMIN
  }) async {
    await _storage.write(key: 'user_tracking_id', value: trackingId);
    await _storage.write(key: 'user_role', value: role);
  }

  Future<String?> getTrackingId() => _storage.read(key: 'user_tracking_id');
  Future<String?> getUserRole() => _storage.read(key: 'user_role');

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 1. ÉLÈVES
  // ─────────────────────────────────────────────────────────────────────────

  /// Inscrire un nouvel élève → POST /api/v1/eleves
  Future<EleveResponse> inscrireEleve(EleveRequest request) async {
    final res = await _dio.post(
      '/api/v1/eleves',
      data: request.toJson(),
    );
    return EleveResponse.fromJson(res.data);
  }

  /// Récupérer un élève → GET /api/v1/eleves/{id}
  Future<EleveResponse> getEleve(String trackingId) async {
    final res = await _dio.get('/api/v1/eleves/$trackingId');
    return EleveResponse.fromJson(res.data);
  }

  /// Modifier un élève → PUT /api/v1/eleves/{id}
  Future<EleveResponse> modifierEleve(
      String trackingId, EleveRequest request) async {
    final res = await _dio.put(
      '/api/v1/eleves/$trackingId',
      data: request.toJson(),
    );
    return EleveResponse.fromJson(res.data);
  }

  /// Lister élèves (paginé) → GET /api/v1/eleves
  Future<PageResponse<EleveResponse>> listerEleves(
      {int page = 0, int size = 10}) async {
    final res = await _dio.get('/api/v1/eleves',
        queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(
        res.data, (json) => EleveResponse.fromJson(json));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 2. CONSEILLERS
  // ─────────────────────────────────────────────────────────────────────────

  /// Créer un conseiller → POST /api/v1/conseillers
  Future<ConseillerResponse> creerConseiller(
      ConseillerRequest request) async {
    final res = await _dio.post('/api/v1/conseillers', data: request.toJson());
    return ConseillerResponse.fromJson(res.data);
  }

  /// Récupérer un conseiller → GET /api/v1/conseillers/{id}
  Future<ConseillerResponse> getConseiller(String trackingId) async {
    final res = await _dio.get('/api/v1/conseillers/$trackingId');
    return ConseillerResponse.fromJson(res.data);
  }

  /// Modifier un conseiller → PUT /api/v1/conseillers/{id}
  Future<ConseillerResponse> modifierConseiller(
      String trackingId, ConseillerRequest request) async {
    final res = await _dio.put('/api/v1/conseillers/$trackingId',
        data: request.toJson());
    return ConseillerResponse.fromJson(res.data);
  }

  /// Lister conseillers disponibles → GET /api/v1/conseillers/disponibles
  Future<List<ConseillerResponse>> getConseillersDisponibles(
      {int seuil = 10}) async {
    final res = await _dio.get('/api/v1/conseillers/disponibles',
        queryParameters: {'seuil': seuil});
    return (res.data as List)
        .map((e) => ConseillerResponse.fromJson(e))
        .toList();
  }

  /// Lister tous les conseillers → GET /api/v1/conseillers
  Future<PageResponse<ConseillerResponse>> listerConseillers(
      {int page = 0, int size = 10}) async {
    final res = await _dio.get('/api/v1/conseillers',
        queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(
        res.data, (json) => ConseillerResponse.fromJson(json));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3. PARENTS
  // ─────────────────────────────────────────────────────────────────────────

  /// Créer un parent → POST /api/v1/parents
  Future<ParentResponse> creerParent(ParentRequest request) async {
    final res = await _dio.post('/api/v1/parents', data: request.toJson());
    return ParentResponse.fromJson(res.data);
  }

  /// Récupérer un parent → GET /api/v1/parents/{id}
  Future<ParentResponse> getParent(String trackingId) async {
    final res = await _dio.get('/api/v1/parents/$trackingId');
    return ParentResponse.fromJson(res.data);
  }

  /// Rattacher un enfant → POST /api/v1/parents/{id}/enfants/{eleveId}
  Future<ParentResponse> rattacherEnfant(
      String parentId, String eleveId) async {
    final res = await _dio
        .post('/api/v1/parents/$parentId/enfants/$eleveId');
    return ParentResponse.fromJson(res.data);
  }

  /// Parents d'un élève → GET /api/v1/parents/par-eleve/{eleveId}
  Future<List<ParentResponse>> getParentsParEleve(String eleveId) async {
    final res = await _dio.get('/api/v1/parents/par-eleve/$eleveId');
    return (res.data as List).map((e) => ParentResponse.fromJson(e)).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 4. NOTES MANUELLES
  // ─────────────────────────────────────────────────────────────────────────

  /// Ajouter une note → POST /api/v1/eleves/{id}/notes
  Future<NoteResponse> ajouterNote(
      String eleveId, NoteRequest request) async {
    final res = await _dio.post(
      '/api/v1/eleves/$eleveId/notes',
      data: request.toJson(),
    );
    return NoteResponse.fromJson(res.data);
  }

  /// Lister les notes d'un élève → GET /api/v1/eleves/{id}/notes
  Future<List<NoteResponse>> getNotesEleve(String eleveId) async {
    final res = await _dio.get('/api/v1/eleves/$eleveId/notes');
    return (res.data as List).map((e) => NoteResponse.fromJson(e)).toList();
  }

  /// Modifier une note → PUT /api/v1/notes/{id}
  Future<NoteResponse> modifierNote(
      String trackingId, NoteRequest request) async {
    final res =
        await _dio.put('/api/v1/notes/$trackingId', data: request.toJson());
    return NoteResponse.fromJson(res.data);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 5. BIBLIOTHÈQUE
  // ─────────────────────────────────────────────────────────────────────────

  /// Lister les séries → GET /api/v1/bibliotheque/series
  Future<PageResponse<FicheSerieResponse>> listerSeries(
      {int page = 0, int size = 10}) async {
    final res = await _dio.get('/api/v1/bibliotheque/series',
        queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(
        res.data, (json) => FicheSerieResponse.fromJson(json));
  }

  /// Récupérer une série → GET /api/v1/bibliotheque/series/{id}
  Future<FicheSerieResponse> getSerie(String trackingId) async {
    final res =
        await _dio.get('/api/v1/bibliotheque/series/$trackingId');
    return FicheSerieResponse.fromJson(res.data);
  }

  /// Lister les filières → GET /api/v1/bibliotheque/filieres
  Future<PageResponse<FicheFiliereResponse>> listerFilieres(
      {int page = 0, int size = 10}) async {
    final res = await _dio.get('/api/v1/bibliotheque/filieres',
        queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(
        res.data, (json) => FicheFiliereResponse.fromJson(json));
  }

  /// Récupérer une filière → GET /api/v1/bibliotheque/filieres/{id}
  Future<FicheFiliereResponse> getFiliere(String trackingId) async {
    final res =
        await _dio.get('/api/v1/bibliotheque/filieres/$trackingId');
    return FicheFiliereResponse.fromJson(res.data);
  }

  /// Lister les métiers → GET /api/v1/bibliotheque/metiers
  Future<PageResponse<FicheMetierResponse>> listerMetiers(
      {int page = 0, int size = 10}) async {
    final res = await _dio.get('/api/v1/bibliotheque/metiers',
        queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(
        res.data, (json) => FicheMetierResponse.fromJson(json));
  }

  /// Lister les établissements → GET /api/v1/bibliotheque/etablissements
  Future<PageResponse<FicheEtablissementResponse>> listerEtablissements(
      {int page = 0, int size = 10}) async {
    final res = await _dio.get('/api/v1/bibliotheque/etablissements',
        queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(
        res.data, (json) => FicheEtablissementResponse.fromJson(json));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 6. FAVORIS
  // ─────────────────────────────────────────────────────────────────────────

  /// Ajouter un favori → POST /api/v1/bibliotheque/favoris
  Future<FavoriResponse> ajouterFavori(FavoriRequest request) async {
    final res = await _dio.post('/api/v1/bibliotheque/favoris',
        data: request.toJson());
    return FavoriResponse.fromJson(res.data);
  }

  /// Favoris d'un utilisateur → GET /api/v1/bibliotheque/favoris/utilisateur/{id}
  Future<PageResponse<FavoriResponse>> getFavorisUtilisateur(
      String utilisateurId,
      {int page = 0,
      int size = 20}) async {
    final res = await _dio.get(
        '/api/v1/bibliotheque/favoris/utilisateur/$utilisateurId',
        queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(
        res.data, (json) => FavoriResponse.fromJson(json));
  }

  /// Supprimer un favori → DELETE /api/v1/bibliotheque/favoris/{id}
  Future<void> supprimerFavori(String trackingId) async {
    await _dio.delete('/api/v1/bibliotheque/favoris/$trackingId');
  }

  /// Supprimer une note → DELETE /api/v1/notes/{id}
  Future<void> supprimerNote(String trackingId) async {
    await _dio.delete('/api/v1/notes/$trackingId');
  }

  /// Lister établissements (pour dropdown) → GET /api/v1/bibliotheque/etablissements
  Future<List<String>> getEtablissementsList() async {
    try {
      final res = await listerEtablissements(page: 0, size: 100);
      return res.content.map((e) => e.titre).toList();
    } catch (_) {
      // Liste par défaut si l'API échoue
      return [
        'Lycée de Tokoin',
        'Lycée Béthel',
        'Lycée Notre-Dame des Apôtres',
        'Lycée du Sacrifié-Cœur',
        'Lycée Gbagba',
        'Lycée de Kégué',
        'Lycée de Bè',
        'Lycée de Lomé',
        'Lycée Technique de Lomé',
        'Lycée Scientifique de Lomé',
      ];
    }
  }

  /// Lister filières (pour dropdown) → GET /api/v1/bibliotheque/filieres
  Future<List<String>> getFilieresList() async {
    try {
      final res = await listerFilieres(page: 0, size: 100);
      return res.content.map((e) => e.titre).toList();
    } catch (_) {
      // Liste par défaut si l'API échoue
      return [
        'Informatique',
        'Mathématiques',
        'Sciences Physiques',
        'Sciences de la Vie et de la Terre',
        'Lettres Modernes',
        'Histoire-Géographie',
        'Économie-Gestion',
        'Droit',
        'Médecine',
        'Génie Civil',
        'Génie Électrique',
        'Comptabilité',
        'Commerce',
      ];
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 7. FAQ
  // ─────────────────────────────────────────────────────────────────────────

  /// Lister la FAQ → GET /api/v1/bibliotheque/faq
  Future<PageResponse<EntreeFAQResponse>> listerFAQ(
      {int page = 0, int size = 10}) async {
    final res = await _dio.get('/api/v1/bibliotheque/faq',
        queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(
        res.data, (json) => EntreeFAQResponse.fromJson(json));
  }

  /// FAQ par catégorie → GET /api/v1/bibliotheque/faq/categorie/{cat}
  Future<List<EntreeFAQResponse>> getFAQParCategorie(
      String categorie) async {
    final res = await _dio
        .get('/api/v1/bibliotheque/faq/categorie/$categorie');
    return (res.data as List)
        .map((e) => EntreeFAQResponse.fromJson(e))
        .toList();
  }

  /// Catégories FAQ → GET /api/v1/bibliotheque/faq/categories
  Future<List<String>> getCategoriesFAQ() async {
    final res =
        await _dio.get('/api/v1/bibliotheque/faq/categories');
    return List<String>.from(res.data);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 8. QUIZ & DIAGNOSTIC
  // ─────────────────────────────────────────────────────────────────────────

  /// Lister les quiz actifs → GET /api/v1/quiz
  Future<PageResponse<QuizResponse>> listerQuiz(
      {int page = 0, int size = 10}) async {
    final res = await _dio
        .get('/api/v1/quiz', queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(
        res.data, (json) => QuizResponse.fromJson(json));
  }

  /// Récupérer un quiz → GET /api/v1/quiz/{id}
  Future<QuizResponse> getQuiz(String trackingId) async {
    final res = await _dio.get('/api/v1/quiz/$trackingId');
    return QuizResponse.fromJson(res.data);
  }

  /// Questions d'un quiz → GET /api/v1/quiz/{id}/questions
  Future<List<QuestionResponse>> getQuestionsQuiz(
      String quizTrackingId) async {
    final res =
        await _dio.get('/api/v1/quiz/$quizTrackingId/questions');
    return (res.data as List)
        .map((e) => QuestionResponse.fromJson(e))
        .toList();
  }

  /// Réponses d'une question → GET /api/v1/questions/{id}/reponses
  Future<List<ReponseResponse>> getReponsesQuestion(
      String questionId) async {
    final res =
        await _dio.get('/api/v1/questions/$questionId/reponses');
    return (res.data as List)
        .map((e) => ReponseResponse.fromJson(e))
        .toList();
  }

  /// Enregistrer un résultat → POST /api/v1/resultats-diagnostic
  Future<ResultatDiagnosticResponse> enregistrerResultat(
      ResultatDiagnosticRequest request) async {
    final res = await _dio.post('/api/v1/resultats-diagnostic',
        data: request.toJson());
    return ResultatDiagnosticResponse.fromJson(res.data);
  }

  /// Résultats d'un élève → GET /api/v1/eleves/{id}/resultats-diagnostic
  Future<PageResponse<ResultatDiagnosticResponse>> getResultatsEleve(
      String eleveId,
      {int page = 0,
      int size = 10}) async {
    final res = await _dio.get(
        '/api/v1/eleves/$eleveId/resultats-diagnostic',
        queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(
        res.data, (json) => ResultatDiagnosticResponse.fromJson(json));
  }

  /// Dernier résultat d'un élève → GET /api/v1/eleves/{id}/resultats-diagnostic/dernier
  Future<ResultatDiagnosticResponse?> getDernierResultat(
      String eleveId, String quizId) async {
    try {
      final res = await _dio.get(
          '/api/v1/eleves/$eleveId/resultats-diagnostic/dernier',
          queryParameters: {'quizTrackingId': quizId});
      if (res.statusCode == 204) return null;
      return ResultatDiagnosticResponse.fromJson(res.data);
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 9. MESSAGES
  // ─────────────────────────────────────────────────────────────────────────

  /// Envoyer un message → POST /api/v1/utilisateurs/{id}/messages
  Future<MessageResponse> envoyerMessage(
      String expediteurId, MessageRequest request) async {
    final res = await _dio.post(
        '/api/v1/utilisateurs/$expediteurId/messages',
        data: request.toJson());
    return MessageResponse.fromJson(res.data);
  }

  /// Conversation entre 2 users → GET /api/v1/messages/conversation
  Future<List<MessageResponse>> getConversation(
      String user1, String user2) async {
    final res = await _dio.get('/api/v1/messages/conversation',
        queryParameters: {'user1': user1, 'user2': user2});
    return (res.data as List)
        .map((e) => MessageResponse.fromJson(e))
        .toList();
  }

  /// Messages reçus → GET /api/v1/utilisateurs/{id}/messages/recus
  Future<PageResponse<MessageResponse>> getMessagesRecus(
      String destinataireId,
      {int page = 0,
      int size = 20}) async {
    final res = await _dio.get(
        '/api/v1/utilisateurs/$destinataireId/messages/recus',
        queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(
        res.data, (json) => MessageResponse.fromJson(json));
  }

  /// Marquer conversation lue → PATCH /api/v1/messages/conversation/lire
  Future<void> marquerConversationLue(
      String expediteur, String destinataire) async {
    await _dio.patch('/api/v1/messages/conversation/lire',
        queryParameters: {
          'expediteur': expediteur,
          'destinataire': destinataire
        });
  }

  /// Compteur messages non lus
  Future<int> getMessagesNonLus(String destinataireId) async {
    final res = await _dio.get(
        '/api/v1/utilisateurs/$destinataireId/messages/non-lus/compteur');
    return (res.data['nonLus'] as int?) ?? 0;
  }

  /// Récupérer nom d'un utilisateur par trackingId
  Future<Map<String, String>> getUtilisateurNom(String trackingId) async {
    try {
      // Essayer conseiller d'abord
      final conseiller = await getConseiller(trackingId);
      return {'nom': conseiller.nom, 'prenom': conseiller.prenom, 'type': 'conseiller'};
    } catch (_) {
      try {
        // Essayer élève
        final eleve = await getEleve(trackingId);
        return {'nom': eleve.nom, 'prenom': eleve.prenom, 'type': 'eleve'};
      } catch (_) {
        return {'nom': 'Inconnu', 'prenom': 'Utilisateur', 'type': 'inconnu'};
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 10. RENDEZ-VOUS
  // ─────────────────────────────────────────────────────────────────────────

  /// Planifier un RDV → POST /api/v1/rendez-vous
  Future<RendezVousResponse> planifierRDV(RendezVousRequest request) async {
    final res =
        await _dio.post('/api/v1/rendez-vous', data: request.toJson());
    return RendezVousResponse.fromJson(res.data);
  }

  /// RDV d'un élève → GET /api/v1/rendez-vous/eleve/{id}
  Future<List<RendezVousResponse>> getRDVEleve(String eleveId) async {
    final res =
        await _dio.get('/api/v1/rendez-vous/eleve/$eleveId');
    return (res.data as List)
        .map((e) => RendezVousResponse.fromJson(e))
        .toList();
  }

  /// RDV d'un conseiller → GET /api/v1/rendez-vous/conseiller/{id}
  Future<List<RendezVousResponse>> getRDVConseiller(
      String conseillerId) async {
    final res = await _dio
        .get('/api/v1/rendez-vous/conseiller/$conseillerId');
    return (res.data as List)
        .map((e) => RendezVousResponse.fromJson(e))
        .toList();
  }

  /// Annuler un RDV → PATCH /api/v1/rendez-vous/{id}/annuler
  Future<RendezVousResponse> annulerRDV(String trackingId) async {
    final res =
        await _dio.patch('/api/v1/rendez-vous/$trackingId/annuler');
    return RendezVousResponse.fromJson(res.data);
  }

  /// Terminer un RDV → PATCH /api/v1/rendez-vous/{id}/terminer
  Future<RendezVousResponse> terminerRDV(String trackingId) async {
    final res =
        await _dio.patch('/api/v1/rendez-vous/$trackingId/terminer');
    return RendezVousResponse.fromJson(res.data);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 11. DISPONIBILITÉS
  // ─────────────────────────────────────────────────────────────────────────

  /// Disponibilités d'un conseiller → GET /api/v1/conseillers/{id}/disponibilites
  Future<List<DisponibiliteResponse>> getDisponibilitesConseiller(
      String conseillerId) async {
    final res = await _dio
        .get('/api/v1/conseillers/$conseillerId/disponibilites');
    return (res.data as List)
        .map((e) => DisponibiliteResponse.fromJson(e))
        .toList();
  }

  /// Disponibilités par jour → GET /api/v1/conseillers/{id}/disponibilites/jour/{jour}
  Future<List<DisponibiliteResponse>> getDisponibilitesParJour(
      String conseillerId, int jourSemaine) async {
    final res = await _dio.get(
        '/api/v1/conseillers/$conseillerId/disponibilites/jour/$jourSemaine');
    return (res.data as List)
        .map((e) => DisponibiliteResponse.fromJson(e))
        .toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 12. NOTIFICATIONS
  // ─────────────────────────────────────────────────────────────────────────

  /// Notifications d'un user → GET /api/v1/utilisateurs/{id}/notifications
  Future<List<NotificationResponse>> getNotifications(
      String utilisateurId) async {
    final res = await _dio
        .get('/api/v1/utilisateurs/$utilisateurId/notifications');
    return (res.data as List)
        .map((e) => NotificationResponse.fromJson(e))
        .toList();
  }

  /// Non lues → GET /api/v1/utilisateurs/{id}/notifications/non-lues
  Future<List<NotificationResponse>> getNotificationsNonLues(
      String utilisateurId) async {
    final res = await _dio.get(
        '/api/v1/utilisateurs/$utilisateurId/notifications/non-lues');
    return (res.data as List)
        .map((e) => NotificationResponse.fromJson(e))
        .toList();
  }

  /// Compteur non lues
  Future<int> getNotificationsNonLuesCount(String utilisateurId) async {
    final res = await _dio.get(
        '/api/v1/utilisateurs/$utilisateurId/notifications/compteur');
    return (res.data['nonLues'] as int?) ?? 0;
  }

  /// Marquer toutes lues → PATCH /api/v1/utilisateurs/{id}/notifications/tout-lire
  Future<void> marquerToutesLues(String utilisateurId) async {
    await _dio.patch(
        '/api/v1/utilisateurs/$utilisateurId/notifications/tout-lire');
  }

  /// Marquer une notification lue → PATCH /api/v1/notifications/{id}/lire
  Future<void> marquerNotificationLue(String notifId) async {
    await _dio.patch('/api/v1/notifications/$notifId/lire');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 13. HISTORIQUE
  // ─────────────────────────────────────────────────────────────────────────

  /// Historique d'un user → GET /api/v1/utilisateurs/{id}/historique
  Future<List<HistoriqueResponse>> getHistorique(
      String utilisateurId) async {
    final res = await _dio
        .get('/api/v1/utilisateurs/$utilisateurId/historique');
    return (res.data as List)
        .map((e) => HistoriqueResponse.fromJson(e))
        .toList();
  }

  /// Enregistrer une action → POST /api/v1/utilisateurs/{id}/historique
  Future<void> enregistrerAction(
      String utilisateurId, String action, {String? details}) async {
    await _dio.post('/api/v1/utilisateurs/$utilisateurId/historique',
        data: {'action': action, if (details != null) 'details': details});
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 14. FICHIERS (MinIO)
  // ─────────────────────────────────────────────────────────────────────────

  /// Upload un fichier → POST /files/upload/{fileType}
  Future<FileUploadResponse> uploadFichier(
      File file, String fileType) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
    });
    final res = await _dio.post(
      '/files/upload/$fileType',
      data: formData,
    );
    return FileUploadResponse.fromJson(res.data);
  }

  /// URL d'un fichier → GET /files/url/{fileType}/{fileName}
  Future<String> getFileUrl(String fileType, String fileName) async {
    final res = await _dio.get('/files/url/$fileType/$fileName');
    return res.data as String;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 15. ADMINISTRATEURS
  // ─────────────────────────────────────────────────────────────────────────

  /// Créer un admin → POST /api/v1/administrateurs
  Future<AdministrateurResponse> creerAdministrateur(
      AdministrateurRequest request) async {
    final res = await _dio.post('/api/v1/administrateurs',
        data: request.toJson());
    return AdministrateurResponse.fromJson(res.data);
  }

  /// Lister admins → GET /api/v1/administrateurs
  Future<PageResponse<AdministrateurResponse>> listerAdmins(
      {int page = 0, int size = 10}) async {
    final res = await _dio.get('/api/v1/administrateurs',
        queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(
        res.data, (json) => AdministrateurResponse.fromJson(json));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GESTION DES ERREURS
  // ─────────────────────────────────────────────────────────────────────────
  String handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Délai de connexion dépassé. Vérifiez votre connexion.';
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 400) return 'Données invalides. Vérifiez vos informations.';
        if (status == 401) return 'Non autorisé. Reconnectez-vous.';
        if (status == 404) return 'Ressource introuvable.';
        if (status == 409) return 'Conflit : cette ressource existe déjà.';
        if (status == 500) return 'Erreur serveur. Réessayez plus tard.';
        return 'Erreur ${status ?? "inconnue"}.';
      case DioExceptionType.connectionError:
        return 'Impossible de se connecter au serveur.';
      default:
        return 'Une erreur est survenue.';
    }
  }
}
