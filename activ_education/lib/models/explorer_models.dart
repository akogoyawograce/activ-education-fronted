class FicheLien {
  final String trackingId;
  final String titre;
  final String resume;
  final String? typeFiche;

  FicheLien({
    required this.trackingId,
    required this.titre,
    required this.resume,
    this.typeFiche,
  });

  factory FicheLien.fromJson(Map<String, dynamic> json) => FicheLien(
        trackingId: json['trackingId'] ?? '',
        titre: json['titre'] ?? '',
        resume: json['resume'] ?? '',
        typeFiche: json['typeFiche'],
      );
}

abstract class FicheBase {
  final String trackingId;
  final String titre;
  final String resume;
  final List<String> imageUrls;
  final List<String> videoUrls;
  final List<String> documentUrls;
  final bool estPublie;
  final int nbConsultations;
  final String? typeFiche;

  FicheBase({
    required this.trackingId,
    required this.titre,
    required this.resume,
    this.imageUrls = const [],
    this.videoUrls = const [],
    this.documentUrls = const [],
    required this.estPublie,
    required this.nbConsultations,
    this.typeFiche,
  });

  String? get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;
  String? get videoUrl => videoUrls.isNotEmpty ? videoUrls.first : null;
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
    super.imageUrls,
    super.videoUrls,
    super.documentUrls,
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
        imageUrls: (json['imageUrls'] as List?)?.cast<String>() ?? [],
        videoUrls: (json['videoUrls'] as List?)?.cast<String>() ?? [],
        documentUrls: (json['documentUrls'] as List?)?.cast<String>() ?? [],
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
    super.imageUrls,
    super.videoUrls,
    super.documentUrls,
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
        imageUrls: (json['imageUrls'] as List?)?.cast<String>() ?? [],
        videoUrls: (json['videoUrls'] as List?)?.cast<String>() ?? [],
        documentUrls: (json['documentUrls'] as List?)?.cast<String>() ?? [],
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
    super.imageUrls,
    super.videoUrls,
    super.documentUrls,
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
        imageUrls: (json['imageUrls'] as List?)?.cast<String>() ?? [],
        videoUrls: (json['videoUrls'] as List?)?.cast<String>() ?? [],
        documentUrls: (json['documentUrls'] as List?)?.cast<String>() ?? [],
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
  final String? typeEtablissement;
  final String? niveau;
  final String? contacts;
  final String? siteWeb;
  final String? offreFormation;
  final bool estPublic;
  final List<FicheLien> filieresProposees;

  FicheEtablissementResponse({
    required super.trackingId,
    required super.titre,
    required super.resume,
    super.imageUrls,
    super.videoUrls,
    super.documentUrls,
    required super.estPublie,
    required super.nbConsultations,
    super.typeFiche,
    this.adresse,
    this.ville,
    this.typeEtablissement,
    this.niveau,
    this.contacts,
    this.siteWeb,
    this.offreFormation,
    required this.estPublic,
    this.filieresProposees = const [],
  });

  factory FicheEtablissementResponse.fromJson(Map<String, dynamic> json) =>
      FicheEtablissementResponse(
        trackingId: json['trackingId'] ?? '',
        titre: json['titre'] ?? '',
        resume: json['resume'] ?? '',
        imageUrls: (json['imageUrls'] as List?)?.cast<String>() ?? [],
        videoUrls: (json['videoUrls'] as List?)?.cast<String>() ?? [],
        documentUrls: (json['documentUrls'] as List?)?.cast<String>() ?? [],
        estPublie: json['estPublie'] ?? false,
        nbConsultations: json['nbConsultations'] ?? 0,
        typeFiche: json['typeFiche'],
        adresse: json['adresse'],
        ville: json['ville'],
        typeEtablissement: json['typeEtablissement'],
        niveau: json['niveau'],
        contacts: json['contacts'],
        siteWeb: json['siteWeb'],
        offreFormation: json['offreFormation'],
        estPublic: json['estPublic'] ?? true,
        filieresProposees: (json['filieresProposees'] as List?)
                ?.map((e) => FicheLien.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class RechercheGlobaleResponse {
  final String trackingId;
  final String typeResultat;
  final String titre;
  final String resume;
  final String? imageCouverture;

  RechercheGlobaleResponse({
    required this.trackingId,
    required this.typeResultat,
    required this.titre,
    required this.resume,
    this.imageCouverture,
  });

  factory RechercheGlobaleResponse.fromJson(Map<String, dynamic> json) =>
      RechercheGlobaleResponse(
        trackingId: json['trackingId']?.toString() ?? '',
        typeResultat: json['typeResultat'] ?? '',
        titre: json['titre'] ?? '',
        resume: json['resume'] ?? '',
        imageCouverture: json['imageCouverture'],
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
