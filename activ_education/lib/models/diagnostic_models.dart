class QuizResponse {
  final String trackingId;
  final String titre;
  final String? description;
  final bool estActif;
  final int nombreQuestions;

  QuizResponse({
    required this.trackingId,
    required this.titre,
    this.description,
    required this.estActif,
    required this.nombreQuestions,
  });

  factory QuizResponse.fromJson(Map<String, dynamic> json) => QuizResponse(
        trackingId: json['trackingId'] ?? '',
        titre: json['titre'] ?? '',
        description: json['description'],
        estActif: json['estActif'] ?? true,
        nombreQuestions: json['nombreQuestions'] ?? 0,
      );
}

class QuestionResponse {
  final String trackingId;
  final String texteQuestion;
  final int ordre;
  final String quizTrackingId;
  final int nombreReponses;

  QuestionResponse({
    required this.trackingId,
    required this.texteQuestion,
    required this.ordre,
    required this.quizTrackingId,
    required this.nombreReponses,
  });

  factory QuestionResponse.fromJson(Map<String, dynamic> json) =>
      QuestionResponse(
        trackingId: json['trackingId'] ?? '',
        texteQuestion: json['texteQuestion'] ?? '',
        ordre: json['ordre'] ?? 0,
        quizTrackingId: json['quizTrackingId'] ?? '',
        nombreReponses: json['nombreReponses'] ?? 0,
      );
}

class ScoreMatriceRequest {
  final String titreMatrice;
  final double? scoreGoutsPersonnel;
  final double? scoreAcademique;
  final double? scoreMarcheTravail;
  final double? scoreTotalEstime;

  ScoreMatriceRequest({
    required this.titreMatrice,
    this.scoreGoutsPersonnel,
    this.scoreAcademique,
    this.scoreMarcheTravail,
    this.scoreTotalEstime,
  });

  Map<String, dynamic> toJson() => {
        'titreMatrice': titreMatrice,
        if (scoreGoutsPersonnel != null)
          'scoreGoutsPersonnel': scoreGoutsPersonnel,
        if (scoreAcademique != null) 'scoreAcademique': scoreAcademique,
        if (scoreMarcheTravail != null)
          'scoreMarcheTravail': scoreMarcheTravail,
        if (scoreTotalEstime != null) 'scoreTotalEstime': scoreTotalEstime,
      };
}

class ScoreMatriceResponse {
  final String trackingId;
  final String titreMatrice;
  final double? scoreGoutsPersonnel;
  final double? scoreAcademique;
  final double? scoreMarcheTravail;
  final double? scoreTotalEstime;
  final DateTime createdAt;

  ScoreMatriceResponse({
    required this.trackingId,
    required this.titreMatrice,
    this.scoreGoutsPersonnel,
    this.scoreAcademique,
    this.scoreMarcheTravail,
    this.scoreTotalEstime,
    required this.createdAt,
  });

  factory ScoreMatriceResponse.fromJson(Map<String, dynamic> json) =>
      ScoreMatriceResponse(
        trackingId: json['trackingId'] ?? '',
        titreMatrice: json['titreMatrice'] ?? '',
        scoreGoutsPersonnel:
            (json['scoreGoutsPersonnel'] as num?)?.toDouble(),
        scoreAcademique: (json['scoreAcademique'] as num?)?.toDouble(),
        scoreMarcheTravail:
            (json['scoreMarcheTravail'] as num?)?.toDouble(),
        scoreTotalEstime: (json['scoreTotalEstime'] as num?)?.toDouble(),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );
}

class ReponseResponse {
  final String trackingId;
  final String texteReponse;
  final String? categoriePoint;
  final int points;
  final String questionTrackingId;

  ReponseResponse({
    required this.trackingId,
    required this.texteReponse,
    this.categoriePoint,
    required this.points,
    required this.questionTrackingId,
  });

  factory ReponseResponse.fromJson(Map<String, dynamic> json) =>
      ReponseResponse(
        trackingId: json['trackingId'] ?? '',
        texteReponse: json['texteReponse'] ?? '',
        categoriePoint: json['categoriePoint'],
        points: json['points'] ?? 0,
        questionTrackingId: json['questionTrackingId'] ?? '',
      );
}

class ResultatDiagnosticRequest {
  final String eleveTrackingId;
  final String quizTrackingId;
  final double? scoreFinal;
  final String? profilDecouvert;
  final String? recommandation;

  ResultatDiagnosticRequest({
    required this.eleveTrackingId,
    required this.quizTrackingId,
    this.scoreFinal,
    this.profilDecouvert,
    this.recommandation,
  });

  Map<String, dynamic> toJson() => {
        'eleveTrackingId': eleveTrackingId,
        'quizTrackingId': quizTrackingId,
        if (scoreFinal != null) 'scoreFinal': scoreFinal,
        if (profilDecouvert != null) 'profilDecouvert': profilDecouvert,
        if (recommandation != null) 'recommandation': recommandation,
      };
}


class ResultatDiagnosticResponse {
  final String trackingId;
  final DateTime? datePassage;
  final double? scoreFinal;
  final String? profilDecouvert;
  final String? recommandation;
  final String eleveTrackingId;
  final String quizTrackingId;

  ResultatDiagnosticResponse({
    required this.trackingId,
    this.datePassage,
    this.scoreFinal,
    this.profilDecouvert,
    this.recommandation,
    required this.eleveTrackingId,
    required this.quizTrackingId,
  });

  factory ResultatDiagnosticResponse.fromJson(Map<String, dynamic> json) =>
      ResultatDiagnosticResponse(
        trackingId: json['trackingId'] ?? '',
        datePassage: json['datePassage'] != null
            ? DateTime.tryParse(json['datePassage'])
            : null,
        scoreFinal: (json['scoreFinal'] as num?)?.toDouble(),
        profilDecouvert: json['profilDecouvert'],
        recommandation: json['recommandation'],
        eleveTrackingId: json['eleveTrackingId'] ?? '',
        quizTrackingId: json['quizTrackingId'] ?? '',
      );
}
