abstract class FicheBase {
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
