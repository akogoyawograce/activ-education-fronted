class NoteRequest {
  final String matiere;
  final double note;
  final int? coefficient;
  final String? anneeScolaire;
  final String? semestreOuTrimestre;

  NoteRequest({
    required this.matiere,
    required this.note,
    this.coefficient,
    this.anneeScolaire,
    this.semestreOuTrimestre,
  });

  Map<String, dynamic> toJson() => {
        'matiere': matiere,
        'note': note,
        if (coefficient != null) 'coefficient': coefficient,
        if (anneeScolaire != null) 'anneeScolaire': anneeScolaire,
        if (semestreOuTrimestre != null)
          'semestreOuTrimestre': semestreOuTrimestre,
      };
}

class NoteResponse {
  final String trackingId;
  final String matiere;
  final double note;
  final int? coefficient;
  final String? anneeScolaire;
  final String? semestreOuTrimestre;
  final String eleveTrackingId;

  NoteResponse({
    required this.trackingId,
    required this.matiere,
    required this.note,
    this.coefficient,
    this.anneeScolaire,
    this.semestreOuTrimestre,
    required this.eleveTrackingId,
  });

  factory NoteResponse.fromJson(Map<String, dynamic> json) => NoteResponse(
        trackingId: json['trackingId'] ?? '',
        matiere: json['matiere'] ?? '',
        note: (json['note'] as num?)?.toDouble() ?? 0.0,
        coefficient: json['coefficient'],
        anneeScolaire: json['anneeScolaire'],
        semestreOuTrimestre: json['semestreOuTrimestre'],
        eleveTrackingId: json['eleveTrackingId'] ?? '',
      );
}
