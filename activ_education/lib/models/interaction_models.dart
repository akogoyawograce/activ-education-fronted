class MessageRequest {
  final String contenu;
  final String destinataireTrackingId;

  MessageRequest({
    required this.contenu,
    required this.destinataireTrackingId,
  });

  Map<String, dynamic> toJson() => {
        'contenu': contenu,
        'destinataireTrackingId': destinataireTrackingId,
      };
}

class MessageResponse {
  final String trackingId;
  final String contenu;
  final DateTime? dateEnvoi;
  final bool lu;
  final String expediteurTrackingId;
  final String destinataireTrackingId;

  MessageResponse({
    required this.trackingId,
    required this.contenu,
    this.dateEnvoi,
    required this.lu,
    required this.expediteurTrackingId,
    required this.destinataireTrackingId,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      MessageResponse(
        trackingId: json['trackingId'] ?? '',
        contenu: json['contenu'] ?? '',
        dateEnvoi: json['dateEnvoi'] != null
            ? DateTime.tryParse(json['dateEnvoi'])
            : null,
        lu: json['lu'] ?? false,
        expediteurTrackingId: json['expediteurTrackingId'] ?? '',
        destinataireTrackingId: json['destinataireTrackingId'] ?? '',
      );
}

class RendezVousRequest {
  final String eleveTrackingId;
  final String conseillerTrackingId;
  final DateTime dateHeurePrevue;
  final String? lienVisio;
  final String? notes;

  RendezVousRequest({
    required this.eleveTrackingId,
    required this.conseillerTrackingId,
    required this.dateHeurePrevue,
    this.lienVisio,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'eleveTrackingId': eleveTrackingId,
        'conseillerTrackingId': conseillerTrackingId,
        'dateHeurePrevue': dateHeurePrevue.toIso8601String(),
        if (lienVisio != null) 'lienVisio': lienVisio,
        if (notes != null) 'notes': notes,
      };
}

class RendezVousResponse {
  final String trackingId;
  final DateTime? dateHeurePrevue;
  final String statut;
  final String? lienVisio;
  final String? notes;
  final String eleveTrackingId;
  final String conseillerTrackingId;

  RendezVousResponse({
    required this.trackingId,
    this.dateHeurePrevue,
    required this.statut,
    this.lienVisio,
    this.notes,
    required this.eleveTrackingId,
    required this.conseillerTrackingId,
  });

  factory RendezVousResponse.fromJson(Map<String, dynamic> json) =>
      RendezVousResponse(
        trackingId: json['trackingId'] ?? '',
        dateHeurePrevue: json['dateHeurePrevue'] != null
            ? DateTime.tryParse(json['dateHeurePrevue'])
            : null,
        statut: json['statut'] ?? 'PLANIFIE',
        lienVisio: json['lienVisio'],
        notes: json['notes'],
        eleveTrackingId: json['eleveTrackingId'] ?? '',
        conseillerTrackingId: json['conseillerTrackingId'] ?? '',
      );
}

class DisponibiliteResponse {
  final String trackingId;
  final int jourSemaine;
  final String? jourLabel;
  final Map<String, int>? heureDebut;
  final Map<String, int>? heureFin;
  final String conseillerTrackingId;

  DisponibiliteResponse({
    required this.trackingId,
    required this.jourSemaine,
    this.jourLabel,
    this.heureDebut,
    this.heureFin,
    required this.conseillerTrackingId,
  });

  factory DisponibiliteResponse.fromJson(Map<String, dynamic> json) =>
      DisponibiliteResponse(
        trackingId: json['trackingId'] ?? '',
        jourSemaine: json['jourSemaine'] ?? 1,
        jourLabel: json['jourLabel'],
        heureDebut: json['heureDebut'] != null
            ? Map<String, int>.from(json['heureDebut'])
            : null,
        heureFin: json['heureFin'] != null
            ? Map<String, int>.from(json['heureFin'])
            : null,
        conseillerTrackingId: json['conseillerTrackingId'] ?? '',
      );

  String get heureDebutLabel {
    if (heureDebut == null) return '--:--';
    final h = heureDebut!['hour'] ?? 0;
    final m = heureDebut!['minute'] ?? 0;
    return '${h.toString().padLeft(2, '0')}h${m.toString().padLeft(2, '0')}';
  }

  String get heureFinLabel {
    if (heureFin == null) return '--:--';
    final h = heureFin!['hour'] ?? 0;
    final m = heureFin!['minute'] ?? 0;
    return '${h.toString().padLeft(2, '0')}h${m.toString().padLeft(2, '0')}';
  }
}

class NotificationResponse {
  final String trackingId;
  final String titre;
  final String message;
  final bool lue;
  final String utilisateurTrackingId;
  final DateTime? createdAt;

  NotificationResponse({
    required this.trackingId,
    required this.titre,
    required this.message,
    required this.lue,
    required this.utilisateurTrackingId,
    this.createdAt,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      NotificationResponse(
        trackingId: json['trackingId'] ?? '',
        titre: json['titre'] ?? '',
        message: json['message'] ?? '',
        lue: json['lue'] ?? false,
        utilisateurTrackingId: json['utilisateurTrackingId'] ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : null,
      );
}
