// ignore_for_file: constant_identifier_names

enum TypeApprenant { ECOLIER, COLLEGIEN, LYCEEN, ETUDIANT, PROFESSIONNEL, AUTRE }

class LoginRequest {
  final String email;
  final String motDePasse;

  LoginRequest({required this.email, required this.motDePasse});

  Map<String, dynamic> toJson() => {
        'email': email,
        'motDePasse': motDePasse,
      };
}

class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final String trackingId;
  final String typeUtilisateur;
  final List<String> roles;
  final int expiresInMs;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.trackingId,
    required this.typeUtilisateur,
    required this.roles,
    required this.expiresInMs,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) => TokenResponse(
        accessToken: json['accessToken'] ?? '',
        refreshToken: json['refreshToken'] ?? '',
        trackingId: json['trackingId'] ?? '',
        typeUtilisateur: json['typeUtilisateur'] ?? '',
        roles: List<String>.from(json['roles'] ?? []),
        expiresInMs: json['expiresInMs'] ?? 0,
      );
}

class EleveRequest {
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;
  final String? motDePasse;
  final String? niveauEtude;
  final String? etablissementActuel;
  final String? filiere;
  final TypeApprenant typeApprenant;
  final List<String>? matieresPreferees;
  final String? styleApprentissage;
  final String? metierSouhaite;

  EleveRequest({
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone,
    this.motDePasse,
    this.niveauEtude,
    this.etablissementActuel,
    this.filiere,
    required this.typeApprenant,
    this.matieresPreferees,
    this.styleApprentissage,
    this.metierSouhaite,
  });

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'prenom': prenom,
        'email': email,
        if (telephone != null) 'telephone': telephone,
        if (motDePasse != null) 'motDePasse': motDePasse,
        if (niveauEtude != null) 'niveauEtude': niveauEtude,
        if (etablissementActuel != null) 'etablissementActuel': etablissementActuel,
        if (filiere != null) 'filiere': filiere,
        'typeApprenant': typeApprenant.name,
        if (matieresPreferees != null) 'matieresPreferees': matieresPreferees,
        if (styleApprentissage != null) 'styleApprentissage': styleApprentissage,
        if (metierSouhaite != null) 'metierSouhaite': metierSouhaite,
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
  final List<String>? matieresPreferees;
  final String? styleApprentissage;
  final String? metierSouhaite;
  final String? photoUrl;
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
    this.matieresPreferees,
    this.styleApprentissage,
    this.metierSouhaite,
    this.photoUrl,
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
        matieresPreferees: json['matieresPreferees'] != null ? List<String>.from(json['matieresPreferees']) : null,
        styleApprentissage: json['styleApprentissage'],
        metierSouhaite: json['metierSouhaite'],
        photoUrl: json['photoUrl'],
        actif: json['actif'] ?? true,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : null,
      );

  String get nomComplet => '$prenom $nom';
}

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
