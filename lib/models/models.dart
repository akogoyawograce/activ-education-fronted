// ─────────────────────────────────────────────────────────────────────────────
// MODELS — ActivEducation API
// Générés depuis le Swagger OpenAPI 3.0
// ─────────────────────────────────────────────────────────────────────────────

// ─── Page Response générique ─────────────────────────────────────────────────
class PageResponse<T> {
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;
  final bool first;
  final bool last;
  final List<T> content;

  PageResponse({
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
    required this.first,
    required this.last,
    required this.content,
  });

  factory PageResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return PageResponse(
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      size: json['size'] ?? 0,
      number: json['number'] ?? 0,
      first: json['first'] ?? true,
      last: json['last'] ?? true,
      content: (json['content'] as List? ?? [])
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ─── ÉLÈVE ───────────────────────────────────────────────────────────────────
enum TypeApprenant { ECOLIER, COLLEGIEN, LYCEEN, ETUDIANT, PROFESSIONNEL, AUTRE }

class EleveRequest {
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;
  final String motDePasse;
  final String? niveauEtude;
  final String? etablissementActuel;
  final String? filiere;
  final TypeApprenant typeApprenant;

  EleveRequest({
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone,
    required this.motDePasse,
    this.niveauEtude,
    this.etablissementActuel,
    this.filiere,
    required this.typeApprenant,
  });

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'prenom': prenom,
        'email': email,
        if (telephone != null) 'telephone': telephone,
        'motDePasse': motDePasse,
        if (niveauEtude != null) 'niveauEtude': niveauEtude,
        if (etablissementActuel != null) 'etablissementActuel': etablissementActuel,
        if (filiere != null) 'filiere': filiere,
        'typeApprenant': typeApprenant.name,
      };
}

class EleveResponse {
  final String trackingId;
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;
  final String? niveauEtude;
  final String? etablissementActuel;
  final String? filiere;
  final String typeApprenant;
  final bool actif;
  final DateTime? createdAt;

  EleveResponse({
    required this.trackingId,
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone,
    this.niveauEtude,
    this.etablissementActuel,
    this.filiere,
    required this.typeApprenant,
    required this.actif,
    this.createdAt,
  });

  factory EleveResponse.fromJson(Map<String, dynamic> json) => EleveResponse(
        trackingId: json['trackingId'] ?? '',
        nom: json['nom'] ?? '',
        prenom: json['prenom'] ?? '',
        email: json['email'] ?? '',
        telephone: json['telephone'],
        niveauEtude: json['niveauEtude'],
        etablissementActuel: json['etablissementActuel'],
        filiere: json['filiere'],
        typeApprenant: json['typeApprenant'] ?? 'AUTRE',
        actif: json['actif'] ?? true,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : null,
      );

  String get nomComplet => '$prenom $nom';
}

// ─── CONSEILLER ───────────────────────────────────────────────────────────────
class ConseillerRequest {
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;
  final String motDePasse;
  final String? specialites;
  final String? biographie;
  final String? qualifications;
  final int? anneesExperience;

  ConseillerRequest({
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone,
    required this.motDePasse,
    this.specialites,
    this.biographie,
    this.qualifications,
    this.anneesExperience,
  });

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'prenom': prenom,
        'email': email,
        if (telephone != null) 'telephone': telephone,
        'motDePasse': motDePasse,
        if (specialites != null) 'specialites': specialites,
        if (biographie != null) 'biographie': biographie,
        if (qualifications != null) 'qualifications': qualifications,
        if (anneesExperience != null) 'anneesExperience': anneesExperience,
      };
}

class ConseillerResponse {
  final String trackingId;
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;
  final String? specialites;
  final String? biographie;
  final String? qualifications;
  final int? anneesExperience;
  final int? chargeTravail;
  final bool actif;
  final DateTime? createdAt;

  ConseillerResponse({
    required this.trackingId,
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone,
    this.specialites,
    this.biographie,
    this.qualifications,
    this.anneesExperience,
    this.chargeTravail,
    required this.actif,
    this.createdAt,
  });

  factory ConseillerResponse.fromJson(Map<String, dynamic> json) =>
      ConseillerResponse(
        trackingId: json['trackingId'] ?? '',
        nom: json['nom'] ?? '',
        prenom: json['prenom'] ?? '',
        email: json['email'] ?? '',
        telephone: json['telephone'],
        specialites: json['specialites'],
        biographie: json['biographie'],
        qualifications: json['qualifications'],
        anneesExperience: json['anneesExperience'],
        chargeTravail: json['chargeTravail'],
        actif: json['actif'] ?? true,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : null,
      );

  String get nomComplet => '$prenom $nom';
}

// ─── PARENT ───────────────────────────────────────────────────────────────────
class ParentRequest {
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;
  final String motDePasse;
  final List<String>? enfantsTrackingIds;

  ParentRequest({
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone,
    required this.motDePasse,
    this.enfantsTrackingIds,
  });

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'prenom': prenom,
        'email': email,
        if (telephone != null) 'telephone': telephone,
        'motDePasse': motDePasse,
        if (enfantsTrackingIds != null)
          'enfantsTrackingIds': enfantsTrackingIds,
      };
}

class ParentResponse {
  final String trackingId;
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;
  final List<String> enfantsTrackingIds;
  final bool actif;

  ParentResponse({
    required this.trackingId,
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone,
    required this.enfantsTrackingIds,
    required this.actif,
  });

  factory ParentResponse.fromJson(Map<String, dynamic> json) => ParentResponse(
        trackingId: json['trackingId'] ?? '',
        nom: json['nom'] ?? '',
        prenom: json['prenom'] ?? '',
        email: json['email'] ?? '',
        telephone: json['telephone'],
        enfantsTrackingIds:
            List<String>.from(json['enfantsTrackingIds'] ?? []),
        actif: json['actif'] ?? true,
      );
}

// ─── NOTES ────────────────────────────────────────────────────────────────────
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

// ─── BIBLIOTHÈQUE : BASE ──────────────────────────────────────────────────────
class FicheBase {
  final String trackingId;
  final String titre;
  final String resume;
  final String? imageUrl;
  final String? videoUrl;
  final bool estPublie;
  final int nbConsultations;
  final String? typeFiche;

  FicheBase({
    required this.trackingId,
    required this.titre,
    required this.resume,
    this.imageUrl,
    this.videoUrl,
    required this.estPublie,
    required this.nbConsultations,
    this.typeFiche,
  });
}

// ─── SÉRIE ────────────────────────────────────────────────────────────────────
class FicheSerieResponse extends FicheBase {
  final String? niveau;
  final String? matieresPrincipales;
  final String? debouches;
  final String? coefficients;

  FicheSerieResponse({
    required super.trackingId,
    required super.titre,
    required super.resume,
    super.imageUrl,
    super.videoUrl,
    required super.estPublie,
    required super.nbConsultations,
    super.typeFiche,
    this.niveau,
    this.matieresPrincipales,
    this.debouches,
    this.coefficients,
  });

  factory FicheSerieResponse.fromJson(Map<String, dynamic> json) =>
      FicheSerieResponse(
        trackingId: json['trackingId'] ?? '',
        titre: json['titre'] ?? '',
        resume: json['resume'] ?? '',
        imageUrl: json['imageUrl'],
        videoUrl: json['videoUrl'],
        estPublie: json['estPublie'] ?? false,
        nbConsultations: json['nbConsultations'] ?? 0,
        typeFiche: json['typeFiche'],
        niveau: json['niveau'],
        matieresPrincipales: json['matieresPrincipales'],
        debouches: json['debouches'],
        coefficients: json['coefficients'],
      );
}

// ─── FILIÈRE ──────────────────────────────────────────────────────────────────
class FicheFiliereResponse extends FicheBase {
  final String? duree;
  final String? niveauRequis;
  final String? conditionsAdmission;
  final String? programme;
  final String? debouchesMetiers;
  final String? domaine;

  FicheFiliereResponse({
    required super.trackingId,
    required super.titre,
    required super.resume,
    super.imageUrl,
    super.videoUrl,
    required super.estPublie,
    required super.nbConsultations,
    super.typeFiche,
    this.duree,
    this.niveauRequis,
    this.conditionsAdmission,
    this.programme,
    this.debouchesMetiers,
    this.domaine,
  });

  factory FicheFiliereResponse.fromJson(Map<String, dynamic> json) =>
      FicheFiliereResponse(
        trackingId: json['trackingId'] ?? '',
        titre: json['titre'] ?? '',
        resume: json['resume'] ?? '',
        imageUrl: json['imageUrl'],
        videoUrl: json['videoUrl'],
        estPublie: json['estPublie'] ?? false,
        nbConsultations: json['nbConsultations'] ?? 0,
        typeFiche: json['typeFiche'],
        duree: json['duree'],
        niveauRequis: json['niveauRequis'],
        conditionsAdmission: json['conditionsAdmission'],
        programme: json['programme'],
        debouchesMetiers: json['debouchesMetiers'],
        domaine: json['domaine'],
      );
}

// ─── MÉTIER ───────────────────────────────────────────────────────────────────
class FicheMetierResponse extends FicheBase {
  final String? secteur;
  final String? missions;
  final String? competences;
  final String? debouchesTogo;
  final String? fourchetteSalaire;

  FicheMetierResponse({
    required super.trackingId,
    required super.titre,
    required super.resume,
    super.imageUrl,
    super.videoUrl,
    required super.estPublie,
    required super.nbConsultations,
    super.typeFiche,
    this.secteur,
    this.missions,
    this.competences,
    this.debouchesTogo,
    this.fourchetteSalaire,
  });

  factory FicheMetierResponse.fromJson(Map<String, dynamic> json) =>
      FicheMetierResponse(
        trackingId: json['trackingId'] ?? '',
        titre: json['titre'] ?? '',
        resume: json['resume'] ?? '',
        imageUrl: json['imageUrl'],
        videoUrl: json['videoUrl'],
        estPublie: json['estPublie'] ?? false,
        nbConsultations: json['nbConsultations'] ?? 0,
        typeFiche: json['typeFiche'],
        secteur: json['secteur'],
        missions: json['missions'],
        competences: json['competences'],
        debouchesTogo: json['debouchesTogo'],
        fourchetteSalaire: json['fourchetteSalaire'],
      );
}

// ─── ÉTABLISSEMENT ────────────────────────────────────────────────────────────
class FicheEtablissementResponse extends FicheBase {
  final String? adresse;
  final String? ville;
  final String? region;
  final String? typeEtablissement;
  final String? contacts;
  final String? siteWeb;
  final bool estPublic;

  FicheEtablissementResponse({
    required super.trackingId,
    required super.titre,
    required super.resume,
    super.imageUrl,
    super.videoUrl,
    required super.estPublie,
    required super.nbConsultations,
    super.typeFiche,
    this.adresse,
    this.ville,
    this.region,
    this.typeEtablissement,
    this.contacts,
    this.siteWeb,
    required this.estPublic,
  });

  factory FicheEtablissementResponse.fromJson(Map<String, dynamic> json) =>
      FicheEtablissementResponse(
        trackingId: json['trackingId'] ?? '',
        titre: json['titre'] ?? '',
        resume: json['resume'] ?? '',
        imageUrl: json['imageUrl'],
        videoUrl: json['videoUrl'],
        estPublie: json['estPublie'] ?? false,
        nbConsultations: json['nbConsultations'] ?? 0,
        typeFiche: json['typeFiche'],
        adresse: json['adresse'],
        ville: json['ville'],
        region: json['region'],
        typeEtablissement: json['typeEtablissement'],
        contacts: json['contacts'],
        siteWeb: json['siteWeb'],
        estPublic: json['estPublic'] ?? true,
      );
}

// ─── FAQ ──────────────────────────────────────────────────────────────────────
class EntreeFAQResponse {
  final String trackingId;
  final String question;
  final String reponse;
  final String? categorie;
  final bool estPublie;
  final int nbVues;

  EntreeFAQResponse({
    required this.trackingId,
    required this.question,
    required this.reponse,
    this.categorie,
    required this.estPublie,
    required this.nbVues,
  });

  factory EntreeFAQResponse.fromJson(Map<String, dynamic> json) =>
      EntreeFAQResponse(
        trackingId: json['trackingId'] ?? '',
        question: json['question'] ?? '',
        reponse: json['reponse'] ?? '',
        categorie: json['categorie'],
        estPublie: json['estPublie'] ?? false,
        nbVues: json['nbVues'] ?? 0,
      );
}

// ─── FAVORIS ─────────────────────────────────────────────────────────────────
class FavoriRequest {
  final String utilisateurTrackingId;
  final String ficheTrackingId;
  final String? notePersonnelle;

  FavoriRequest({
    required this.utilisateurTrackingId,
    required this.ficheTrackingId,
    this.notePersonnelle,
  });

  Map<String, dynamic> toJson() => {
        'utilisateurTrackingId': utilisateurTrackingId,
        'ficheTrackingId': ficheTrackingId,
        if (notePersonnelle != null) 'notePersonnelle': notePersonnelle,
      };
}

class FavoriResponse {
  final String trackingId;
  final String utilisateurTrackingId;
  final String ficheTrackingId;
  final String? ficheTitre;
  final String? notePersonnelle;

  FavoriResponse({
    required this.trackingId,
    required this.utilisateurTrackingId,
    required this.ficheTrackingId,
    this.ficheTitre,
    this.notePersonnelle,
  });

  factory FavoriResponse.fromJson(Map<String, dynamic> json) => FavoriResponse(
        trackingId: json['trackingId'] ?? '',
        utilisateurTrackingId: json['utilisateurTrackingId'] ?? '',
        ficheTrackingId: json['ficheTrackingId'] ?? '',
        ficheTitre: json['ficheTitre'],
        notePersonnelle: json['notePersonnelle'],
      );
}

// ─── QUIZ ─────────────────────────────────────────────────────────────────────
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

// ─── RÉSULTATS DIAGNOSTIC ────────────────────────────────────────────────────
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

// ─── MESSAGES ─────────────────────────────────────────────────────────────────
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

// ─── RENDEZ-VOUS ──────────────────────────────────────────────────────────────
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

// ─── DISPONIBILITÉ ───────────────────────────────────────────────────────────
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

// ─── NOTIFICATIONS ────────────────────────────────────────────────────────────
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

// ─── HISTORIQUE ───────────────────────────────────────────────────────────────
class HistoriqueResponse {
  final String trackingId;
  final String action;
  final String? details;
  final String utilisateurTrackingId;
  final DateTime? createdAt;

  HistoriqueResponse({
    required this.trackingId,
    required this.action,
    this.details,
    required this.utilisateurTrackingId,
    this.createdAt,
  });

  factory HistoriqueResponse.fromJson(Map<String, dynamic> json) =>
      HistoriqueResponse(
        trackingId: json['trackingId'] ?? '',
        action: json['action'] ?? '',
        details: json['details'],
        utilisateurTrackingId: json['utilisateurTrackingId'] ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : null,
      );
}

// ─── ADMINISTRATEUR ───────────────────────────────────────────────────────────
class AdministrateurRequest {
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;
  final String motDePasse;
  final String? niveauAcces;

  AdministrateurRequest({
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone,
    required this.motDePasse,
    this.niveauAcces,
  });

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'prenom': prenom,
        'email': email,
        if (telephone != null) 'telephone': telephone,
        'motDePasse': motDePasse,
        if (niveauAcces != null) 'niveauAcces': niveauAcces,
      };
}

class AdministrateurResponse {
  final String trackingId;
  final String nom;
  final String prenom;
  final String email;
  final String? niveauAcces;
  final bool actif;

  AdministrateurResponse({
    required this.trackingId,
    required this.nom,
    required this.prenom,
    required this.email,
    this.niveauAcces,
    required this.actif,
  });

  factory AdministrateurResponse.fromJson(Map<String, dynamic> json) =>
      AdministrateurResponse(
        trackingId: json['trackingId'] ?? '',
        nom: json['nom'] ?? '',
        prenom: json['prenom'] ?? '',
        email: json['email'] ?? '',
        niveauAcces: json['niveauAcces'],
        actif: json['actif'] ?? true,
      );
}

// ─── FILE UPLOAD ──────────────────────────────────────────────────────────────
class FileUploadResponse {
  final String fileName;
  final String? fileUrl;
  final String? contentType;
  final int? fileSize;

  FileUploadResponse({
    required this.fileName,
    this.fileUrl,
    this.contentType,
    this.fileSize,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) =>
      FileUploadResponse(
        fileName: json['fileName'] ?? '',
        fileUrl: json['fileUrl'],
        contentType: json['contentType'],
        fileSize: json['fileSize'],
      );
}
