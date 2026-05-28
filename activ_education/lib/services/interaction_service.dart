import '../models/models.dart';
import 'base_service.dart';

class InteractionService extends BaseService {
  static final InteractionService _instance = InteractionService._internal();
  factory InteractionService() => _instance;
  InteractionService._internal();

  // Messages
  Future<MessageResponse> envoyerMessage(String expediteurId, MessageRequest request) async {
    final res = await dio.post('/api/v1/utilisateurs/$expediteurId/messages', data: request.toJson());
    return MessageResponse.fromJson(res.data);
  }

  Future<List<MessageResponse>> getConversation(String user1, String user2) async {
    final res = await dio.get('/api/v1/messages/conversation', queryParameters: {'user1': user1, 'user2': user2});
    return (res.data as List).map((e) => MessageResponse.fromJson(e)).toList();
  }

  Future<int> getMessagesNonLus(String destinataireId) async {
    final res = await dio.get('/api/v1/utilisateurs/$destinataireId/messages/non-lus/compteur');
    return (res.data['nonLus'] as int?) ?? 0;
  }

  Future<void> marquerConversationLue(String expediteur, String destinataire) async {
    await dio.patch('/api/v1/messages/conversation/lire', queryParameters: {'expediteur': expediteur, 'destinataire': destinataire});
  }

  // Rendez-vous
  Future<RendezVousResponse> planifierRDV(RendezVousRequest request) async {
    final res = await dio.post('/api/v1/rendez-vous', data: request.toJson());
    return RendezVousResponse.fromJson(res.data);
  }

  Future<List<RendezVousResponse>> getRDVEleve(String eleveId) async {
    final res = await dio.get('/api/v1/rendez-vous/eleve/$eleveId');
    return (res.data as List).map((e) => RendezVousResponse.fromJson(e)).toList();
  }

  Future<List<RendezVousResponse>> getRDVConseiller(String conseillerId) async {
    final res = await dio.get('/api/v1/rendez-vous/conseiller/$conseillerId');
    return (res.data as List).map((e) => RendezVousResponse.fromJson(e)).toList();
  }

  Future<void> annulerRDV(String rdvId) async {
    await dio.patch('/api/v1/rendez-vous/$rdvId/annuler');
  }

  Future<RendezVousResponse> terminerRDV(String rdvId) async {
    final res = await dio.patch('/api/v1/rendez-vous/$rdvId/terminer');
    return RendezVousResponse.fromJson(res.data);
  }

  // Disponibilités
  Future<List<DisponibiliteResponse>> getDisponibilitesConseiller(String conseillerId) async {
    final res = await dio.get('/api/v1/conseillers/$conseillerId/disponibilites');
    return (res.data as List).map((e) => DisponibiliteResponse.fromJson(e)).toList();
  }

  Future<List<ConseillerResponse>> getConseillersDisponibles({int seuil = 5}) async {
    final res = await dio.get('/api/v1/conseillers/disponibles', queryParameters: {'seuil': seuil});
    return (res.data as List).map((e) => ConseillerResponse.fromJson(e)).toList();
  }

  Future<RendezVousResponse> modifierRDV(String rdvId, RendezVousRequest request) async {
    final res = await dio.put('/api/v1/rendez-vous/$rdvId', data: request.toJson());
    return RendezVousResponse.fromJson(res.data);
  }

  Future<RendezVousResponse> getRDV(String trackingId) async {
    final res = await dio.get('/api/v1/rendez-vous/$trackingId');
    return RendezVousResponse.fromJson(res.data);
  }

  Future<PageResponse<RendezVousResponse>> getRDVElevePagine(String eleveId, {int page = 0, int size = 10}) async {
    final res = await dio.get('/api/v1/rendez-vous/eleve/$eleveId/pagine', queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(res.data, (json) => RendezVousResponse.fromJson(json));
  }

  Future<PageResponse<RendezVousResponse>> getRDVConseillerPagine(String conseillerId, {int page = 0, int size = 10}) async {
    final res = await dio.get('/api/v1/rendez-vous/conseiller/$conseillerId/pagine', queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(res.data, (json) => RendezVousResponse.fromJson(json));
  }

  Future<List<RendezVousResponse>> getRDVEleveParStatut(String eleveId, String statut) async {
    final res = await dio.get('/api/v1/rendez-vous/eleve/$eleveId/statut/$statut');
    return (res.data as List).map((e) => RendezVousResponse.fromJson(e)).toList();
  }

  Future<List<RendezVousResponse>> getRDVConseillerParStatut(String conseillerId, String statut) async {
    final res = await dio.get('/api/v1/rendez-vous/conseiller/$conseillerId/statut/$statut');
    return (res.data as List).map((e) => RendezVousResponse.fromJson(e)).toList();
  }

  // Notifications
  Future<List<NotificationResponse>> getNotificationsUtilisateur(String utilisateurId) async {
    final res = await dio.get('/api/v1/utilisateurs/$utilisateurId/notifications');
    return (res.data as List).map((e) => NotificationResponse.fromJson(e)).toList();
  }

  Future<NotificationResponse> getNotification(String trackingId) async {
    final res = await dio.get('/api/v1/notifications/$trackingId');
    return NotificationResponse.fromJson(res.data);
  }

  Future<PageResponse<NotificationResponse>> getNotificationsPagine(String utilisateurId, {int page = 0, int size = 10}) async {
    final res = await dio.get('/api/v1/utilisateurs/$utilisateurId/notifications/pagine', queryParameters: {'page': page, 'size': size});
    return PageResponse.fromJson(res.data, (json) => NotificationResponse.fromJson(json));
  }

  Future<void> envoyerNotification(String utilisateurId, {required String titre, required String message}) async {
    await dio.post('/api/v1/utilisateurs/$utilisateurId/notifications', data: {'titre': titre, 'message': message});
  }

  Future<void> marquerLue(String notificationId) async {
    await dio.patch('/api/v1/notifications/$notificationId/lire');
  }

  Future<int> getNotificationsNonLusCount(String utilisateurId) async {
    final res = await dio.get('/api/v1/utilisateurs/$utilisateurId/notifications/compteur');
    return (res.data['nonLus'] as int?) ?? 0;
  }

  Future<void> marquerToutesLues(String utilisateurId) async {
    await dio.patch('/api/v1/utilisateurs/$utilisateurId/notifications/tout-lire');
  }

  // Historique
  Future<List<HistoriqueResponse>> getHistorique(String utilisateurId) async {
    final res = await dio.get('/api/v1/utilisateurs/$utilisateurId/historique');
    return (res.data as List).map((e) => HistoriqueResponse.fromJson(e)).toList();
  }

  Future<void> enregistrerAction(String utilisateurId, String action, {String? details}) async {
    await dio.post('/api/v1/utilisateurs/$utilisateurId/historique', data: {'action': action, if (details != null) 'details': details});
  }
}
