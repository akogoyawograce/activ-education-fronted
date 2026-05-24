import '../models/models.dart';

class RecommendationResult {
  final String titre;
  final String description;
  final String type;
  final double score;
  final FicheBase? fiche;

  const RecommendationResult({
    required this.titre,
    required this.description,
    required this.type,
    required this.score,
    this.fiche,
  });
}

class RecommendationService {
  static const _riasecFilieres = {
    'R': 'Génie Mécanique',
    'I': 'Médecine',
    'A': 'Arts Appliqués',
    'S': 'Droit',
    'E': 'Commerce',
    'C': 'Comptabilité',
  };

  static const _riasecMetiers = {
    'R': 'Ingénieur mécanique',
    'I': 'Chercheur',
    'A': 'Designer',
    'S': 'Conseiller',
    'E': 'Entrepreneur',
    'C': 'Comptable',
  };

  static const _matiereSeries = {
    'Mathématiques': ['Série C', 'Série E'],
    'Physique': ['Série C', 'Série E'],
    'Français': ['Série A', 'Série L'],
    'Histoire': ['Série A', 'Série L'],
    'Anglais': ['Série A', 'Série L'],
    'SVT': ['Série D', 'Série C'],
    'Philosophie': ['Série A', 'Série L'],
    'EPS': ['Série L'],
  };

  List<RecommendationResult> generate({
    String? profilDecouvert,
    String? recommandation,
    List<NoteResponse>? notes,
    List<FicheFiliereResponse>? filieres,
    List<FicheMetierResponse>? metiers,
  }) {
    final results = <RecommendationResult>[];

    // 1. Recommandations basées sur le profil RIASEC
    if (profilDecouvert != null && profilDecouvert.isNotEmpty) {
      for (final lettre in profilDecouvert.split('')) {
        final filiere = _riasecFilieres[lettre];
        final metier = _riasecMetiers[lettre];
        if (filiere != null) {
          final match = filieres?.firstWhere(
            (f) => f.titre.toLowerCase().contains(filiere.split(' ')[0].toLowerCase()),
            orElse: () => FicheFiliereResponse(
              trackingId: '', titre: filiere, resume: 'Recommandé pour votre profil $lettre',
              estPublie: true, nbConsultations: 0, typeFiche: 'filiere',
            ),
          );
          results.add(RecommendationResult(
            titre: filiere,
            description: 'Correspond à votre profil $lettre',
            type: 'Filière', score: 0.9,
            fiche: match?.trackingId.isNotEmpty == true ? match! : null,
          ));
        }
        if (metier != null) {
          results.add(RecommendationResult(
            titre: metier,
            description: 'Métier adapté à votre profil $lettre',
            type: 'Métier', score: 0.85,
          ));
        }
      }
    }

    // 2. Recommandations basées sur les notes
    if (notes != null && notes.isNotEmpty) {
      final bestSubjects = List<NoteResponse>.from(notes)
        ..sort((a, b) => (b.note * (b.coefficient ?? 1)).compareTo(a.note * (a.coefficient ?? 1)));
      for (final note in bestSubjects.take(3)) {
        if (note.note >= 12) {
          final series = _matiereSeries[note.matiere];
          if (series != null) {
            for (final serie in series) {
              results.add(RecommendationResult(
                titre: serie,
                description: 'Recommandé d\'après votre note en ${note.matiere} (${note.note}/20)',
                type: 'Série', score: note.note / 20,
              ));
            }
          }
        }
      }
    }

    // 3. Texte de recommandation du diagnostic
    if (recommandation != null && recommandation.isNotEmpty) {
      results.add(RecommendationResult(
        titre: 'Recommandation personnalisée',
        description: recommandation,
        type: 'Conseil', score: 1.0,
      ));
    }

    // Trier par score
    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }
}
