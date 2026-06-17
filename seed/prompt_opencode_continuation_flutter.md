# PROMPT OPENCODE — Continuation Flutter Mobile Activ Education

## CONTEXTE

Tu continues le développement de l'application Flutter **Activ Education**.
Le projet a déjà été initié. Voici ce qui est **déjà implémenté** et ce qu'il reste à faire.

**Base URL API :** `http://4.233.145.112:8080`
**Stack :** Flutter 3.3+ / Dart 3.3+ / setState only / Dio 5.7 / flutter_secure_storage

> ⚠️ **Pas de JWT côté backend** — tous les endpoints sont publics. Ne pas ajouter de header Authorization.
> Toutes les ressources utilisent **`trackingId`** (UUID) comme identifiant dans les URLs.
> Réponses paginées Spring : `{ content: [], totalElements, totalPages, number, size }`

---

## CE QUI EST DÉJÀ FAIT ✅

### Infrastructure
- [x] `lib/theme/app_theme.dart` — design tokens couleurs + TextStyles
- [x] `lib/theme/app_routes.dart` — toutes les routes définies
- [x] `lib/lib/api.dart` — Dio singleton BaseService
- [x] Widgets partagés : `PrimaryButton`, `OutlineButton`, `AppTextField`, `StepProgressBar`, `DotIndicator`, `BadgeChip`, `CompatibilityBadge`, `FicheCard`, `ConseillerCard`, `SkeletonLoader`, `EmptyStateWidget`

### Auth & Onboarding
- [x] `SplashScreen` — animation 2.8s + vérification token
- [x] `OnboardingScreen` — 3 slides avec CustomPainter slide 1
- [x] `ProfileSetupScreen` — sélection rôle + classe + ville
- [x] `RegisterScreen` — formulaire + sélecteur pays téléphone
- [x] `RegisterPreferencesScreen` — matières + style apprentissage + toggle rappels → POST /api/v1/eleves
- [x] `LoginScreen` — email + mdp → POST /api/v1/auth/login
- [x] `ForgotPasswordScreen` — toggle Email/Téléphone + illustration
- [x] `OtpScreen` — 4 boîtes + timer 45s

### Navigation
- [x] `MainScaffold` — IndexedStack + bottom nav dynamique selon rôle

### Dashboards
- [x] `DashboardLyceen` — header bleu + badge BEPC + séries + carte conseiller
- [x] `DashboardBachelier` — header + carte diagnostic + 3 mini-stats + recommandations + Aide Personnalisée
- [x] `DashboardBachelierAvance` — diagnostic complété + hexagone score + grille 4 raccourcis + fiche du jour

### Diagnostic
- [x] `QuizScreen` — questions + réponses radio + barre progression → POST /api/v1/resultats-diagnostic
- [x] `ResultatsScreen` — profil + tags + recommandations + badges Goûts%/Niveau%
- [x] `NotesScreen` — saisie notes + couleurs dynamiques + moyenne temps réel

### Explorer
- [x] `ExplorerScreen` — carte vedette + onglets + grille FicheCard + infinite scroll
- [x] `FicheDetailScreen` — vidéo + accordéon + favoris FAB
- [x] `CategoryListScreen` — liste paginée par type
- [x] `FavoritesScreen` — liste + swipe-to-delete
- [x] `GlobalSearchScreen` — recherche IA globale avec debounce

### Messages
- [x] `MessagesListScreen` — conversations dédupliquées + badge non-lus + FAB
- [x] `ChatScreen` — bulles + polling 4s + pièce jointe + emoji

### Autres
- [x] `FaqScreen` — accordéon catégories + recherche IA + bouton conseiller fixe
- [x] `NotFoundScreen`
- [x] `NetworkErrorScreen`

---

## CE QUI RESTE À FAIRE ❌

### Priorité 1 — Screens manquants critiques

#### A. `ProfileScreen` — `lib/screens/profile/profile_screen.dart`
#### B. `DashboardParent` — `lib/screens/home/dashboard_parent.dart`
#### C. `DiagnosticEnfantScreen` — `lib/screens/home/diagnostic_enfant_screen.dart`
#### D. `DashboardReconversion` — `lib/screens/home/dashboard_reconversion.dart`
#### E. `DashboardConseiller` — `lib/screens/home/dashboard_conseiller.dart`
#### F. `NotificationsScreen` — `lib/screens/home/notifications_screen.dart`
#### G. `PriseRdvScreen` — `lib/screens/messages/rdv_screen.dart`
#### H. `RdvListScreen` — `lib/screens/messages/rdv_list_screen.dart`

### Priorité 2 — Services manquants

#### I. `FileService` — `lib/services/file_service.dart`
#### J. Finalisation `InteractionService` (disponibilités + RDV complet)
#### K. Gestion Parents (`ParentService`)
#### L. Administrateurs (`AdminService`)
#### M. Score Matrices (`ScoreMatriceService`)

### Priorité 3 — Fonctionnalités manquantes dans screens existants

#### N. Upload photo de profil (FileService dans ProfileScreen)
#### O. Documents dans FicheDetailScreen (PDF viewer)
#### P. Historique utilisateur dans ProfileScreen
#### Q. Saisie notes avec PDF bulletin upload

---

## SPECS DÉTAILLÉES — CE QUI RESTE À IMPLÉMENTER

---

### A. ProfileScreen (`/profil`) — `lib/screens/profile/profile_screen.dart`

**Design tokens :**
- Header fond bleu `#1300C8`, radius bas 28px
- Fond corps `AppColors.backgroundGrey`

**Header :**
```
[Avatar 72px cercle blanc, initiales bleues Poppins W700 24px]
  └─ Badge crayon ✏️ overlay bas-droite : cercle 22px orange, icône blanc 12px
[Nom Poppins W800 20px blanc]
[Sous-titre : "{typeApprenant} — {niveau} — {ville}" Inter W400 blanc opacity 0.8]
[Row] "PROFIL" Inter W600 11px blanc letterSpacing 1.5   |   "75%" Inter W700 blanc
[LinearProgressIndicator orange, hauteur 4px, radius 2]
```

**Carte "Compléter ton profil" (fond blanc, radius 16, shadow) :**
- Titre "Complète ton profil pour de meilleures recommandations" Inter W500 14px
- Chips scrollables horizontalement (fond `#FFF8EC`, texte orange, radius 20) :
  - Afficher uniquement les champs vides parmi : "Notes Terminale", "Série Bac", "Centres d'intérêt", "Photo de profil", "Établissement"
- Bouton "Compléter" (fond orange, texte blanc, radius 10, hauteur 36px) aligné droite
- `Visibility(visible: completionPercent < 100)`
- Source : calculer depuis `EleveResponse` (champs null = manquants)

**Sections liste (fond blanc, ListTile avec dividers) :**

```dart
// Chaque item : icône bleue | titre | sous-titre | flèche ›
// Clic → modal BottomSheet d'édition ou navigation

ProfileSectionItem(
  icon: Icons.school,
  title: "Mon parcours",
  subtitle: "${eleve.niveau} ${eleve.filiere ?? ''}",
  onTap: () => _showEditParcours(),
),
ProfileSectionItem(
  icon: Icons.business,
  title: "Mon établissement",
  subtitle: eleve.etablissement ?? "Non renseigné",
  onTap: () => _showEditEtablissement(),
),
ProfileSectionItem(
  icon: Icons.star_outline,
  title: "Mes centres d'intérêt",
  subtitleWidget: _buildInterestChips(), // chips inline
  onTap: () => _showEditInterets(),
),
ProfileSectionItem(
  icon: Icons.bar_chart,
  title: "Mes notes",
  subtitle: "Terminale C — Saisies",
  trailing: BadgeChip(label: "VÉRIFIÉ", variant: BadgeVariant.green),
  onTap: () => Navigator.pushNamed(context, '/notes'),
),
ProfileSectionItem(
  icon: Icons.folder_outlined,
  title: "Mes documents",
  subtitle: "${docs.length} fichiers (bulletins)",
  onTap: () => _showDocuments(),
),
```

**Modals d'édition (BottomSheet) :**
- Champ texte pré-rempli + bouton "Enregistrer" → `PUT /api/v1/eleves/{trackingId}`
- Body : `EleveRequest` avec TOUS les champs (pré-remplir depuis l'état actuel, modifier seulement le champ édité)

**Section "Mes favoris" :**
```
GET /api/v1/bibliotheque/favoris/utilisateur/{userId}?page=0&size=3
```
- Row de 3 cartes (fond blanc, radius 12, border gris, hauteur 80px) :
  - Icône 32px bleu (selon type fiche)
  - Nom Inter W500 12px centré
- Lien "Voir tous mes favoris ({total}) →" bleu
- `onTap` → `/favorites`

**Section "Mon historique" :**
```
GET /api/v1/utilisateurs/{userId}/historique?page=0&size=3
```
- 3 items : icône rond coloré + texte action + date relative
- Lien "Voir tout →"

**Upload photo de profil :**
- Clic sur badge crayon → `ImagePicker.getImage(source: ImageSource.gallery)`
- Upload : `POST /files/upload/IMAGE` (multipart)
- Récupérer URL : `GET /files/url/IMAGE/{fileName}`
- Mettre à jour : `PUT /api/v1/eleves/{trackingId}` (ajouter champ `photoUrl` si disponible dans EleveRequest)
- Afficher photo avec `CachedNetworkImage` si URL disponible

**Bouton déconnexion :**
- `TextButton` rouge bas "Se déconnecter"
- `showDialog` confirmation
- `storage.deleteAll()` + `Navigator.pushNamedAndRemoveUntil('/login', (_) => false)`

**Endpoints utilisés :**
```
GET  /api/v1/eleves/{trackingId}           — charger profil
PUT  /api/v1/eleves/{trackingId}           — sauvegarder éditions
GET  /api/v1/bibliotheque/favoris/utilisateur/{id}?page=0&size=3
GET  /api/v1/utilisateurs/{id}/historique?page=0&size=3
POST /files/upload/IMAGE                   — upload avatar
GET  /files/url/IMAGE/{fileName}           — URL avatar
```

---

### B. DashboardParent — `lib/screens/home/dashboard_parent.dart`

**Header (fond bleu #1300C8, radius bas 32px) :**
```
Row:
  Column:
    "Espace Famille" Poppins W800 22px blanc
    "Bonjour M. {nom}" Inter W400 14px blanc opacity 0.8
  Spacer()
  CircleAvatar(radius: 20, backgroundColor: Colors.white,
    child: Icon(Icons.family_restroom, color: AppColors.primary))
```

**Onglets enfants (dans le header, après le titre) :**
```dart
// Pills Tab bar
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: enfants.map((enfant) =>
      GestureDetector(
        onTap: () => setState(() => selectedEnfant = enfant),
        child: Container(
          margin: EdgeInsets.only(right: 8),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            border: Border.all(color: Colors.white.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "${enfant.prenom} (${enfant.niveau})",
            style: TextStyle(
              color: selected ? AppColors.primary : Colors.white,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      )
    ).toList(),
  ),
)
```

**Carte enfant sélectionné (fond blanc, radius 16, shadow) :**
```
Row:
  CircleAvatar(radius: 22, bg: AppColors.accent, initiales blanches)
  Column:
    "{Prénom} {Nom}" Poppins W700 16px
    "Classe de {niveau} — {établissement}" Inter W400 13px gris
  
• "Quiz passé il y a X jours" (point vert + Inter W400 14px)
BadgeChip "X recommandations disponibles" (bleu)
OutlineButton "Voir son diagnostic" bleu → /diagnostic-enfant?enfantId={id}
```

**Bannière alerte (conditionnel si msgNonLus > 0) :**
```dart
Container(
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Color(0xFFFFF8EC),
    border: Border(left: BorderSide(color: AppColors.accent, width: 3)),
    borderRadius: BorderRadius.circular(10),
  ),
  child: Row(
    children: [
      Icon(Icons.notifications, color: AppColors.accent),
      SizedBox(width: 8),
      Expanded(child: Text("Nouveau message concernant ${selectedEnfant.prenom}")),
    ],
  ),
)
```

**Grille 4 raccourcis (2×2) :**
```dart
GridView.count(
  crossAxisCount: 2, shrinkWrap: true, physics: NeverScrollableScrollPhysics(),
  childAspectRatio: 1.3,
  children: [
    _QuickActionCard(Icons.analytics, "Diagnostics de ${enfant.prenom}", AppColors.primary,
      onTap: () => Navigator.pushNamed(context, '/diagnostic-enfant', arguments: {'enfantId': id})),
    _QuickActionCard(Icons.chat_bubble_outline, "Contacter conseillère", AppColors.accent, ...),
    _QuickActionCard(Icons.bookmark_outline, "Fiches sauvegardées", AppColors.primary,
      onTap: () => Navigator.pushNamed(context, '/favorites')),
    _QuickActionCard(Icons.history, "Historique des échanges", AppColors.accent,
      onTap: () => Navigator.pushNamed(context, '/messages')),
  ],
)
```

**Bottom nav Parent :**
```dart
BottomNavigationBar(items: [
  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
  BottomNavigationBarItem(icon: Icon(Icons.family_restroom), label: 'Mes enfants'),
  BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
  BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Mon profil'),
])
```

**Endpoints :**
```
GET /api/v1/parents/{trackingId}                             — liste enfants (enfantsTrackingIds[])
GET /api/v1/eleves/{enfantId}                                — pour chaque enfant (prénom, classe, établissement)
GET /api/v1/eleves/{enfantId}/resultats-diagnostic/dernier   — date du dernier quiz
GET /api/v1/utilisateurs/{conseillerTrackingId}/messages/non-lus/compteur
```

**Note :** `ParentResponse` contient un champ `enfantsTrackingIds: List<String>`. Pour chaque ID, charger `GET /api/v1/eleves/{id}` en parallèle avec `Future.wait([...])`.

---

### C. DiagnosticEnfantScreen (`/diagnostic-enfant`) — `lib/screens/home/diagnostic_enfant_screen.dart`

**Arguments de route :** `{ 'enfantId': String, 'enfantPrenom': String, 'enfantNiveau': String }`

**Header :**
```dart
AppBar(
  leading: BackButton(color: AppColors.primary),
  title: Text("Diagnostic de ${args.prenom}", style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary)),
  actions: [
    Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
      child: Text(args.niveau, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
    ),
  ],
)
```

**Carte "PROFIL DÉTECTÉ" :**
```
"PROFIL DÉTECTÉ" Inter W600 11px gris letterSpacing 1.5
"{profilDecouvert}" Poppins W800 20px
"Réalisé le {date} — Quiz + Notes {niveau}" Inter W400 13px gris
```

**Graphique Radar Triangulaire (CustomPainter) :**

```dart
class TriangleRadarPainter extends CustomPainter {
  final double sciences;   // 0.0 à 1.0
  final double technique;  // 0.0 à 1.0
  final double lettres;    // 0.0 à 1.0

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;

    // 3 axes : haut (sciences), bas-gauche (technique), bas-droite (lettres)
    final angles = [-pi / 2, pi / 2 + pi / 6 * 2, pi / 6 * 2]; // 90°, 210°, 330°

    // 1. Cercle guide gris
    canvas.drawCircle(center, radius, Paint()..color = Colors.grey.shade200..style = PaintingStyle.stroke..strokeWidth = 1);

    // 2. Triangle de fond gris très clair (max)
    final maxPath = Path();
    for (int i = 0; i < 3; i++) {
      final pt = Offset(center.dx + radius * cos(angles[i]), center.dy + radius * sin(angles[i]));
      i == 0 ? maxPath.moveTo(pt.dx, pt.dy) : maxPath.lineTo(pt.dx, pt.dy);
    }
    maxPath.close();
    canvas.drawPath(maxPath, Paint()..color = Colors.grey.shade100);

    // 3. Triangle données (semi-transparent bleu)
    final values = [sciences, technique, lettres];
    final dataPath = Path();
    for (int i = 0; i < 3; i++) {
      final r = radius * values[i];
      final pt = Offset(center.dx + r * cos(angles[i]), center.dy + r * sin(angles[i]));
      i == 0 ? dataPath.moveTo(pt.dx, pt.dy) : dataPath.lineTo(pt.dx, pt.dy);
    }
    dataPath.close();
    canvas.drawPath(dataPath, Paint()..color = Color(0xFF1300C8).withOpacity(0.18));
    canvas.drawPath(dataPath, Paint()..color = Color(0xFF1300C8)..style = PaintingStyle.stroke..strokeWidth = 2);

    // 4. Points aux sommets
    for (int i = 0; i < 3; i++) {
      final r = radius * values[i];
      final pt = Offset(center.dx + r * cos(angles[i]), center.dy + r * sin(angles[i]));
      canvas.drawCircle(pt, 5, Paint()..color = Color(0xFF1300C8));
    }

    // 5. Labels axes (dessiner avec TextPainter)
    final labels = ['SCIENCES', 'TECHNIQUE', 'LETTRES'];
    final labelOffsets = [
      Offset(center.dx - 28, center.dy - radius - 18),
      Offset(center.dx - radius - 50, center.dy + radius * 0.7),
      Offset(center.dx + radius * 0.6, center.dy + radius * 0.7),
    ];
    for (int i = 0; i < 3; i++) {
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, labelOffsets[i]);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

**Mapper `profilDecouvert` (ex: "R-I-A") vers scores radar :**
```dart
// profilDecouvert = "R-I-A" ou "Scientifique & Curieux"
// Si format RIASEC disponible, parser les scores
// Sinon mapper selon le profil textuel :
Map<String, List<double>> profilToRadar = {
  'Scientifique': [0.9, 0.7, 0.3],   // sciences, technique, lettres
  'Technique': [0.6, 0.9, 0.2],
  'Littéraire': [0.3, 0.2, 0.9],
  'Polyvalent': [0.7, 0.6, 0.7],
};
```

**Section "Recommandations pour {Prénom}" :**
```dart
// Cartes de recommandations depuis resultats-diagnostic
List<_RecommendationItem> recs = [
  _RecommendationItem(lettre: 'C', nom: 'Série C', desc: 'Idéal pour Kofi selon son profil',
    badge: 'SUCCÈS', badgeColor: AppColors.success),
  _RecommendationItem(lettre: 'D', nom: 'Série D', desc: 'Bon choix alternatif',
    badge: 'ALTERNATIF', badgeColor: AppColors.warning),
  _RecommendationItem(lettre: 'A', nom: 'Série A', desc: 'Moins adapté',
    badge: 'MOINS ADAPTÉ', badgeColor: Colors.grey),
];

// Chaque card :
Card(
  child: ListTile(
    leading: CircleAvatar(backgroundColor: item.color.withOpacity(0.15),
      child: Text(item.lettre, style: TextStyle(color: item.color, fontWeight: FontWeight.w700, fontSize: 16))),
    title: Row(children: [
      Text(item.nom, style: AppTextStyles.headingSmall),
      Spacer(),
      BadgeChip(label: item.badge, color: item.badgeColor),
    ]),
    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(item.desc, style: AppTextStyles.bodyMedium),
      TextButton(onPressed: () => ..., child: Text("En savoir plus", style: TextStyle(color: AppColors.primary))),
    ]),
  ),
)
```

**Section "Ce que {Prénom} a exploré" :**
- Chips gris clair depuis `GET /api/v1/utilisateurs/{enfantId}/historique`
- Filtrer les actions de type consultation → afficher les `details` comme chips

**FAB fixe bas :**
```dart
Positioned(
  bottom: 16, left: 16, right: 16,
  child: PrimaryButton(
    label: "💬 Contacter un conseiller pour ${enfant.prenom}",
    onPressed: () => Navigator.pushNamed(context, '/rdv'),
  ),
)
```

**Endpoints :**
```
GET /api/v1/eleves/{enfantId}/resultats-diagnostic/dernier
GET /api/v1/bibliotheque/series?page=0&size=10
GET /api/v1/utilisateurs/{enfantId}/historique
```

---

### D. DashboardReconversion — `lib/screens/home/dashboard_reconversion.dart`

**Header bleu (radius bas 28px) :**
```dart
Stack(children: [
  // Illustration étoile fond, opacité 0.08
  Positioned(right: -20, bottom: -10, child: Icon(Icons.star, size: 120, color: Colors.white.withOpacity(0.08))),
  SafeArea(child: Padding(padding: EdgeInsets.all(20), child:
    Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Bonjour ${user.prenom} !", style: AppTextStyles.displayMedium.copyWith(color: Colors.white)),
        Text("Reconversion professionnelle", style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
      ])),
      // Toggle thème (visuel seulement)
      GestureDetector(
        onTap: () => setState(() => _isDark = !_isDark),
        child: CircleAvatar(radius: 20, backgroundColor: Colors.white,
          child: Icon(_isDark ? Icons.dark_mode : Icons.wb_sunny, color: AppColors.primary, size: 20)),
      ),
    ]),
  )),
])
```

**Carte citation (fond #FFF8EC, border radius 16) :**
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(color: Color(0xFFFFF8EC), borderRadius: BorderRadius.circular(16)),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Icon(Icons.favorite, color: Colors.red, size: 20),
      SizedBox(width: 8),
      Expanded(child: Text(
        '"Chaque parcours est unique. On est là pour t\'accompagner dans cette nouvelle étape."',
        style: AppTextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic),
      )),
    ]),
    SizedBox(height: 8),
    GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/quiz'),
      child: Text("Commencer ma réflexion", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
    ),
  ]),
)
```

**Timeline "Votre parcours recommandé" :**
```dart
// 3 étapes avec ligne verticale connectrice
Column(children: [
  _TimelineStep(
    isActive: true,
    icon: Icons.person_outline,
    title: "Parler à un conseiller",
    subtitle: "C'est la première étape, sans engagement",
    actionWidget: PrimaryButton(label: "Prendre RDV maintenant",
      onPressed: () => Navigator.pushNamed(context, '/rdv')),
  ),
  _TimelineStep(isActive: false, icon: Icons.quiz_outlined, title: "Quiz de reconversion"),
  _TimelineStep(isActive: false, icon: Icons.menu_book_outlined, title: "Explorer les formations"),
])

// Widget _TimelineStep :
// - Ligne verticale grise à gauche (sauf dernier)
// - Cercle : actif = fond bleu + icône blanc | inactif = fond gris clair + icône gris
// - Contenu à droite : tout grisé si inactif
```

**Section "Ressources utiles" :**
```
GET /api/v1/bibliotheque/metiers?page=0&size=2
```
- 2 cartes côte à côte (fond blanc, radius 12, border gris) : icône + titre

**Section "VOTRE EXPERT" :**
```
GET /api/v1/conseillers/disponibles   (premier résultat)
```
- Photo + nom + spécialité + badge "● Disponible" vert

---

### E. DashboardConseiller — `lib/screens/home/dashboard_conseiller.dart`

**Header bleu :**
```dart
Column(children: [
  Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Bonjour ${conseiller.prenom} !", style: AppTextStyles.displayMedium.copyWith(color: Colors.white)),
      Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
        SizedBox(width: 6),
        Text("Conseillère orientation | En ligne", style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
      ]),
    ])),
    IconButton(icon: Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () => Navigator.pushNamed(context, '/notifications')),
  ]),
])
```

**Bannière questions en attente (fond #FFA800, radius 12) :**
```dart
// Source : GET /api/v1/utilisateurs/{id}/messages/non-lus/compteur
Container(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(12)),
  child: Row(children: [
    Icon(Icons.confirmation_number_outlined, color: Colors.white),
    SizedBox(width: 8),
    Expanded(child: Text("$nbQuestions questions en attente de réponse",
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
    TextButton(
      onPressed: () => _launchBackoffice(),
      child: Row(children: [
        Text("Voir sur le site", style: TextStyle(color: Colors.white, decoration: TextDecoration.underline)),
        Icon(Icons.open_in_new, color: Colors.white, size: 14),
      ]),
    ),
  ]),
)
// url_launcher : launchUrl(Uri.parse(backofficeUrl))
```

**Grille 2×2 stats (fond blanc, radius 12) :**
```dart
// Source calculée localement depuis les données chargées
GridView.count(crossAxisCount: 2, shrinkWrap: true, childAspectRatio: 1.4,
  children: [
    _StatCard("$ticketsTraites", "tickets traités", color: AppColors.primary),
    _StatCard("$rdvAujourdHui", "RDV aujourd'hui", color: AppColors.accent),
    _StatCard("★ ${conseiller.satisfaction ?? '4.9'}", "satisfaction", icon: Icons.star, iconColor: Colors.amber),
    _StatCard("8h", "temps réponse", icon: Icons.access_time),
  ],
)
```

**Toggle Disponibilité :**
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
  child: Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Disponibilité", style: AppTextStyles.headingSmall),
      Text(
        _isDisponible ? "Je suis disponible" : "Je suis indisponible",
        style: TextStyle(color: _isDisponible ? AppColors.success : AppColors.error, fontSize: 13),
      ),
    ])),
    Switch(
      value: _isDisponible,
      onChanged: (val) async {
        setState(() => _isDisponible = val);
        await conseillerService.updateDisponibilite(conseiller.trackingId, val);
        // PATCH /api/v1/conseillers/{trackingId} body: ConseillerRequest complet avec disponible=val
      },
      activeColor: AppColors.primary,
    ),
  ]),
)
```

**Section RDV du jour :**
```
GET /api/v1/rendez-vous/conseiller/{trackingId}
→ Filtrer côté client : dateHeurePrevue.date == aujourd'hui && statut == "PLANIFIE"
→ Trier par heure croissante
```

```dart
// Chaque item RDV :
Container(
  margin: EdgeInsets.only(bottom: 12),
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
  child: Column(children: [
    Row(children: [
      // Badge heure
      Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)),
        child: Text(heure, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
      ),
      SizedBox(width: 10),
      Expanded(child: Text(nomEtudiant, style: AppTextStyles.headingSmall)),
      // Badge statut
      BadgeChip(
        label: rdv.statut == 'PLANIFIE' ? 'CONFIRMÉ' : 'EN ATTENTE',
        variant: rdv.statut == 'PLANIFIE' ? BadgeVariant.green : BadgeVariant.orange,
      ),
    ]),
    SizedBox(height: 8),
    Row(children: [
      Icon(_getTypeIcon(rdv.notes), size: 14, color: Colors.grey),  // Visio/Tel/Présentiel depuis notes
      SizedBox(width: 4),
      Text(_getTypeLabel(rdv), style: AppTextStyles.caption),
      Spacer(),
      if (rdv.lienVisio != null)
        ElevatedButton(
          onPressed: () => launchUrl(Uri.parse(rdv.lienVisio!)),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: Text("Rejoindre", style: TextStyle(color: Colors.white)),
        )
      else
        OutlinedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/chat', arguments: {'interlocuteurId': rdv.eleveTrackingId}),
          icon: Icon(Icons.mail_outline, size: 16),
          label: Text(""),
        ),
    ]),
  ]),
)
```

**Bouton "Ouvrir le back-office complet" :**
```dart
OutlinedButton.icon(
  onPressed: () => launchUrl(Uri.parse('http://votre-backoffice.com')),  // env variable
  icon: Icon(Icons.lock_outline, color: AppColors.primary),
  label: Text("Ouvrir le back-office complet", style: TextStyle(color: AppColors.primary)),
  style: OutlinedButton.styleFrom(
    side: BorderSide(color: AppColors.primary),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    padding: EdgeInsets.symmetric(vertical: 16),
    minimumSize: Size(double.infinity, 52),
  ),
)
// Ajouter: url_launcher dans pubspec.yaml
```

**Bottom nav Conseiller (4 onglets) :**
```dart
BottomNavigationBar(items: [
  BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Accueil'),
  BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_outlined), label: 'Tickets'),
  BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Agenda'),
  BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Paramètres'),
])
// Tickets → MessagesListScreen, Agenda → RdvListScreen
```

**Endpoints :**
```
GET /api/v1/conseillers/{trackingId}
GET /api/v1/rendez-vous/conseiller/{trackingId}
GET /api/v1/utilisateurs/{trackingId}/messages/non-lus/compteur
PUT /api/v1/conseillers/{trackingId}   — toggle disponibilité (body: ConseillerRequest complet)
```

---

### F. NotificationsScreen (`/notifications`) — `lib/screens/home/notifications_screen.dart`

**Header :**
```dart
AppBar(
  leading: Row(children: [
    SizedBox(width: 16),
    Icon(Icons.school, color: AppColors.primary),
    SizedBox(width: 4),
    Text("Activ Education", style: AppTextStyles.headingSmall.copyWith(color: AppColors.primary)),
  ]),
  actions: [
    Stack(children: [
      IconButton(icon: Icon(Icons.notifications_outlined), onPressed: () {}),
      if (nbNonLues > 0) Positioned(top: 8, right: 8,
        child: CircleAvatar(radius: 6, backgroundColor: AppColors.error,
          child: Text("$nbNonLues", style: TextStyle(color: Colors.white, fontSize: 9)))),
    ]),
  ],
)
```

**Onglets :**
```dart
// Row de 3 pills, pas TabBar
String _selectedTab = 'toutes'; // 'toutes' | 'non_lues' | 'messages'

Row(children: _tabs.map((tab) =>
  GestureDetector(
    onTap: () => setState(() => _selectedTab = tab.key),
    child: Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _selectedTab == tab.key ? AppColors.primary : Colors.white,
        border: Border.all(color: _selectedTab == tab.key ? AppColors.primary : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "${tab.label} (${tab.count})",
        style: TextStyle(
          color: _selectedTab == tab.key ? Colors.white : Colors.grey.shade700,
          fontWeight: FontWeight.w600, fontSize: 13,
        ),
      ),
    ),
  )
).toList())
```

**Liste des notifications :**
```dart
// Icône et couleur par type
Map<String, _NotifStyle> notifStyles = {
  'MESSAGE': _NotifStyle(Icons.chat_bubble_outline, Color(0xFFEEF2FF), AppColors.primary),
  'DIAGNOSTIC': _NotifStyle(Icons.track_changes, Color(0xFFFFF8EC), AppColors.accent),
  'RDV': _NotifStyle(Icons.calendar_today, Color(0xFFECFDF5), AppColors.success),
  'RECOMMANDATION': _NotifStyle(Icons.star_outline, Color(0xFFFFFBEB), Colors.amber),
};

// Chaque item :
ListTile(
  leading: Stack(children: [
    Container(
      width: 44, height: 44, decoration: BoxDecoration(
        color: style.bgColor, shape: BoxShape.circle,
      ),
      child: Icon(style.icon, color: style.iconColor, size: 20),
    ),
    if (!notif.lu)
      Positioned(top: 0, left: 0,
        child: Container(width: 10, height: 10,
          decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle))),
  ]),
  title: Text(notif.titre,
    style: TextStyle(fontWeight: notif.lu ? FontWeight.w400 : FontWeight.w600, fontSize: 14)),
  subtitle: Text(notif.message, maxLines: 1, overflow: TextOverflow.ellipsis,
    style: AppTextStyles.caption),
  trailing: Text(formatDistanceToNow(notif.createdAt), style: AppTextStyles.caption),
  onTap: () async {
    await notifService.marquerLue(notif.trackingId);
    setState(() => notif.lu = true);
    _naviguerSelonType(notif);
  },
)
```

**Swipe-to-dismiss :**
```dart
Dismissible(
  key: Key(notif.trackingId),
  background: Container(color: AppColors.error, alignment: Alignment.centerRight,
    padding: EdgeInsets.only(right: 16), child: Icon(Icons.delete, color: Colors.white)),
  direction: DismissDirection.endToStart,
  onDismissed: (_) => notifService.supprimer(notif.trackingId),
  child: _NotifItem(notif: notif),
)
```

**Carte "Optimisez vos alertes" (fond #1300C8, radius 16) :**
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
  child: Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Optimisez vos alertes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
      SizedBox(height: 4),
      Text("Personnalisez vos préférences pour ne recevoir que les opportunités qui comptent vraiment.",
        style: TextStyle(color: Colors.white70, fontSize: 13)),
      SizedBox(height: 12),
      OutlinedButton(
        onPressed: () => _showPreferencesModal(),
        style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
        child: Text("Configurer", style: TextStyle(color: Colors.white, fontSize: 13)),
      ),
    ])),
    Icon(Icons.settings, color: Colors.white.withOpacity(0.3), size: 48),
  ]),
)
```

**Endpoints :**
```
GET /api/v1/utilisateurs/{id}/notifications          — onglet Toutes
GET /api/v1/utilisateurs/{id}/notifications/non-lues — onglet Non lues
PATCH /api/v1/utilisateurs/{id}/notifications/tout-lire
PATCH /api/v1/notifications/{notifId}/lire
DELETE /api/v1/notifications/{notifId}
```

---

### G. PriseRdvScreen (`/rdv`) — `lib/screens/messages/rdv_screen.dart`

**Arguments :** `{ 'conseillerId': String?, 'conseillerNom': String? }`

**Sélecteur conseiller (si conseillerId null) :**
```
GET /api/v1/conseillers/disponibles
→ DropdownButton avec liste des conseillers disponibles
```

**Section profil conseiller sélectionné :**
```dart
Row(children: [
  CircleAvatar(radius: 24, backgroundImage: CachedNetworkImageProvider(conseiller.photoUrl ?? '')),
  SizedBox(width: 12),
  Expanded(child: Column(children: [
    Text(conseiller.nom, style: AppTextStyles.headingMedium),
    Text(conseiller.specialite, style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey)),
  ])),
  Row(children: [Icon(Icons.star, color: Colors.amber, size: 16), Text(" 4.8/5")]),
])
// Tags spécialités
Wrap(children: conseiller.domaines.map((d) => BadgeChip(label: d)).toList())
```

**3 boutons Type d'entretien :**
```dart
String _typeRdv = 'PRESENTIEL'; // 'TELEPHONE' | 'VISIO' | 'PRESENTIEL'

Row(children: [
  _TypeButton(Icons.phone, 'Téléphone', 'TELEPHONE'),
  _TypeButton(Icons.videocam_outlined, 'Visioconférence', 'VISIO'),
  _TypeButton(Icons.location_on_outlined, 'En présentiel', 'PRESENTIEL'),
])
// _TypeButton selected: fond blanc + border bleue 2px + icône bleue + texte bleu W600
// Non selected: fond gris clair + tout gris
```

**Calendrier custom :**
```dart
// Mois + navigation < >
// Chargement des disponibilités :
// GET /api/v1/conseillers/{conseillerId}/disponibilites
// → DisponibiliteResponse(jourSemaine: 1-7, heureDebut, heureFin)
// → Construire un Set<int> des jours disponibles de la semaine (1=Lun, 7=Dim)

// Grille 7 colonnes : LU MA ME JE VE SA DI
// Chaque cellule : texte date
// - Passé : gris opacity 0.4, non cliquable
// - Disponible : normal, cliquable
// - Aujourd'hui : Container cercle orange AppColors.accent
// - Sélectionné : Container cercle bleu AppColors.primary

// Au clic sur un jour : calculer les créneaux disponibles
List<String> _genererCreneaux(DisponibiliteResponse dispo, DateTime date) {
  // Générer slots de 30 min entre heureDebut et heureFin
  // Ex: 09:00 → 12:00 donne [09:00, 09:30, 10:00, 10:30, 11:00, 11:30]
  List<String> slots = [];
  TimeOfDay current = TimeOfDay(hour: int.parse(dispo.heureDebut.split(':')[0]),
                                minute: int.parse(dispo.heureDebut.split(':')[1]));
  TimeOfDay fin = TimeOfDay(hour: int.parse(dispo.heureFin.split(':')[0]),
                            minute: int.parse(dispo.heureFin.split(':')[1]));
  while (current.hour < fin.hour || (current.hour == fin.hour && current.minute < fin.minute)) {
    slots.add("${current.hour.toString().padLeft(2,'0')}h${current.minute.toString().padLeft(2,'0')}");
    int totalMin = current.hour * 60 + current.minute + 30;
    current = TimeOfDay(hour: totalMin ~/ 60, minute: totalMin % 60);
  }
  return slots;
}
```

**Chips créneaux horaires :**
```dart
// Généré depuis les disponibilités du conseiller pour le jour sélectionné
Wrap(children: _creneaux.map((h) =>
  GestureDetector(
    onTap: () => setState(() => _selectedCreneau = h),
    child: Container(
      margin: EdgeInsets.all(4),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _selectedCreneau == h ? AppColors.primary : Colors.white,
        border: Border.all(color: _selectedCreneau == h ? AppColors.primary : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(h, style: TextStyle(
        color: _selectedCreneau == h ? Colors.white : Colors.grey.shade700,
        fontWeight: FontWeight.w600,
      )),
    ),
  )
).toList())
```

**TextField situation :**
```dart
AppTextField(
  label: "Décris brièvement ta situation (optionnel)",
  hintText: "Ex: J'hésite entre un BTS et une licence...",
  maxLines: 4,
  controller: _situationController,
)
```

**Bouton confirmer + logique :**
```dart
PrimaryButton(
  label: "Confirmer le rendez-vous",
  onPressed: _selectedDate != null && _selectedCreneau != null ? () async {
    // Construire dateHeurePrevue
    final heure = int.parse(_selectedCreneau!.split('h')[0]);
    final minute = int.parse(_selectedCreneau!.split('h')[1].padRight(2, '0'));
    final dateHeure = DateTime(_selectedDate!.year, _selectedDate!.month,
                               _selectedDate!.day, heure, minute);

    await rdvService.creerRdv({
      "eleveTrackingId": userId,
      "conseillerTrackingId": conseiller.trackingId,
      "dateHeurePrevue": dateHeure.toIso8601String(),
      "lienVisio": _typeRdv == 'VISIO' ? "https://meet.google.com/new" : null,
      "notes": "${_typeRdv}: ${_situationController.text}",
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Rendez-vous confirmé !"), backgroundColor: AppColors.success),
    );
    Navigator.pop(context);
  } : null,
)
```

**Endpoints :**
```
GET /api/v1/conseillers/disponibles
GET /api/v1/conseillers/{id}/disponibilites
POST /api/v1/rendez-vous
Body: { eleveTrackingId, conseillerTrackingId, dateHeurePrevue, lienVisio?, notes }
```

---

### H. RdvListScreen — `lib/screens/messages/rdv_list_screen.dart`

**2 onglets :** À venir | Passés

```dart
// Source :
// GET /api/v1/rendez-vous/eleve/{trackingId} (si rôle élève)
// GET /api/v1/rendez-vous/conseiller/{trackingId} (si rôle conseiller)
// Filtrer côté client : dateHeurePrevue > now → "À venir" | <= now → "Passés"

// Chaque card RDV :
Card(child: Padding(child: Column(children: [
  Row(children: [
    CircleAvatar(initiales du conseiller/élève),
    Column(children: [
      Text(nomInterlocuteur, style: AppTextStyles.headingSmall),
      Text(dateFormatted, style: AppTextStyles.caption),
    ]),
    Spacer(),
    BadgeChip(label: rdv.statut),
  ]),
  Divider(),
  if (rdv.lienVisio != null)
    PrimaryButton("Rejoindre", onPressed: () => launchUrl(rdv.lienVisio)),
  if (rdv.statut == 'PLANIFIE')
    TextButton("Annuler", onPressed: () => rdvService.annuler(rdv.trackingId)),  // PATCH /annuler
])))
```

---

### I. FileService — `lib/services/file_service.dart`

```dart
class FileService {
  final Dio _dio;
  FileService(this._dio);

  // Upload image (avatar, bulletin)
  Future<String> uploadFile(File file, String fileType) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path,
        filename: path.basename(file.path)),
    });
    final response = await _dio.post('/files/upload/$fileType', data: formData);
    // Response: FileUploadResponse { fileName, url, fileType }
    return response.data['fileName'] as String;
  }

  // Obtenir URL publique
  Future<String> getPublicUrl(String fileType, String fileName) async {
    final response = await _dio.get('/files/url/$fileType/$fileName');
    return response.data as String;
  }

  // Obtenir thumbnail PDF
  Future<Uint8List> getPdfThumbnail(String fileName, {int width = 200, int height = 280}) async {
    final response = await _dio.get(
      '/files/pdf/thumbnail/$fileName',
      queryParameters: {'width': width, 'height': height},
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data);
  }

  // Lister fichiers par type
  Future<List<dynamic>> listFiles(String fileType) async {
    final response = await _dio.get('/files/list/$fileType');
    return response.data as List;
  }

  // Supprimer
  Future<void> deleteFile(String fileType, String fileName) async {
    await _dio.delete('/files/$fileType/$fileName');
  }

  // Upload multiple
  Future<List<String>> uploadMultiple(List<File> files, String fileType) async {
    final formData = FormData();
    for (final file in files) {
      formData.files.add(MapEntry('files',
        await MultipartFile.fromFile(file.path, filename: path.basename(file.path))));
    }
    final response = await _dio.post('/files/upload/multiple/$fileType', data: formData);
    return (response.data as List).map((e) => e['fileName'] as String).toList();
  }
}
```

---

### J. ParentService — `lib/services/parent_service.dart`

```dart
// Endpoints manquants dans le code actuel :
Future<ParentResponse> getParent(String trackingId) async {
  final r = await _dio.get('/api/v1/parents/$trackingId');
  return ParentResponse.fromJson(r.data);
}

Future<List<ParentResponse>> getParentsByEleve(String eleveTrackingId) async {
  final r = await _dio.get('/api/v1/parents/par-eleve/$eleveTrackingId');
  return (r.data as List).map((e) => ParentResponse.fromJson(e)).toList();
}

Future<ParentResponse> ajouterEnfant(String parentId, String eleveId) async {
  final r = await _dio.post('/api/v1/parents/$parentId/enfants/$eleveId');
  return ParentResponse.fromJson(r.data);
}

Future<ParentResponse> retirerEnfant(String parentId, String eleveId) async {
  final r = await _dio.delete('/api/v1/parents/$parentId/enfants/$eleveId');
  return ParentResponse.fromJson(r.data);
}
```

---

### K. Endpoints manquants à câbler dans les services existants

#### Dans `AcademicService` (notes paginées) :
```dart
// Manque : version paginée
Future<Page<NoteSaisiManuelResponse>> getNotesPagine(String eleveId, {int page = 0, int size = 20}) async {
  final r = await _dio.get('/api/v1/eleves/$eleveId/notes/pagine', queryParameters: {'page': page, 'size': size});
  return Page.fromJson(r.data, (e) => NoteSaisiManuelResponse.fromJson(e));
}

// Modifier une note existante (manque dans l'implémentation actuelle)
Future<NoteSaisiManuelResponse> updateNote(String noteId, NoteSaisiManuelRequest req) async {
  final r = await _dio.put('/api/v1/notes/$noteId', data: req.toJson());
  return NoteSaisiManuelResponse.fromJson(r.data);
}
```

#### Dans `InteractionService` (RDV complet) :
```dart
// Manque : modifier un RDV
Future<RendezVousResponse> updateRdv(String rdvId, RendezVousRequest req) async {
  final r = await _dio.put('/api/v1/rendez-vous/$rdvId', data: req.toJson());
  return RendezVousResponse.fromJson(r.data);
}

// Manque : RDV d'un élève par statut
Future<List<RendezVousResponse>> getRdvEleveByStatut(String eleveId, String statut) async {
  final r = await _dio.get('/api/v1/rendez-vous/eleve/$eleveId/statut/$statut');
  return (r.data as List).map((e) => RendezVousResponse.fromJson(e)).toList();
}

// Manque : disponibilités CRUD
Future<DisponibiliteResponse> addDisponibilite(String conseillerId, DisponibiliteRequest req) async {
  final r = await _dio.post('/api/v1/conseillers/$conseillerId/disponibilites', data: req.toJson());
  return DisponibiliteResponse.fromJson(r.data);
}

Future<void> deleteDisponibilite(String disponibiliteId) async {
  await _dio.delete('/api/v1/disponibilites/$disponibiliteId');
}

Future<List<DisponibiliteResponse>> getDispoByJour(String conseillerId, int jourSemaine) async {
  final r = await _dio.get('/api/v1/conseillers/$conseillerId/disponibilites/jour/$jourSemaine');
  return (r.data as List).map((e) => DisponibiliteResponse.fromJson(e)).toList();
}
```

#### Dans `ExplorerService` (endpoints manquants bibliothèque) :
```dart
// Fiches non publiques (admin)
Future<Page<FicheSerieResponse>> getSeriesNonPublic({int page = 0, int size = 20}) async {
  final r = await _dio.get('/api/v1/bibliotheque/series/non-public', queryParameters: {'page': page, 'size': size});
  return Page.fromJson(r.data, (e) => FicheSerieResponse.fromJson(e));
}

// Recherche orphelines (admin analytics)
Future<Map<String, int>> getRecherchesOrphelines({int limite = 20}) async {
  final r = await _dio.get('/api/v1/admin/bibliotheque/recherches-orphelines/frequentes', queryParameters: {'limite': limite});
  return Map<String, int>.from(r.data);
}

// Fiches similaires
Future<List<dynamic>> getFichesSimilaires(String trackingId, {int limite = 5}) async {
  final r = await _dio.get('/api/v1/bibliotheque/analytics/similaires/$trackingId', queryParameters: {'limite': limite});
  return r.data as List;
}

// Consultations récentes utilisateur
Future<List<dynamic>> getConsultationsRecentes(String userId, {int limite = 10}) async {
  final r = await _dio.get('/api/v1/bibliotheque/analytics/recentes/$userId', queryParameters: {'limite': limite});
  return r.data as List;
}
```

---

## ORDRE D'IMPLÉMENTATION RECOMMANDÉ

```
Semaine 1 (Screens critiques manquants) :
  1. FileService (I) — requis par ProfileScreen et autres
  2. ProfileScreen (A) — manquant et lié à tous les rôles
  3. NotificationsScreen (F) — requis depuis header de tous les dashboards
  4. PriseRdvScreen (G) — requis depuis DashboardBachelier et Conseiller

Semaine 2 (Dashboards manquants) :
  5. DashboardConseiller (E) — rôle clé
  6. DashboardParent (B) — avec DiagnosticEnfant (C)
  7. DashboardReconversion (D)
  8. RdvListScreen (H)

Semaine 3 (Finalisation services) :
  9. ParentService (J) + endpoints manquants (K)
  10. Tests intégration API réelle sur http://4.233.145.112:8080
  11. Gestion des erreurs réseau (DioException → NetworkErrorScreen)
  12. Pull-to-refresh sur tous les screens listés
```

---

## RAPPELS TECHNIQUES CRITIQUES

```dart
// 1. trackingId dans toutes les URLs (pas id)
GET /api/v1/eleves/{trackingId}  ✅
GET /api/v1/eleves/{id}          ❌

// 2. Pas de JWT — ne pas ajouter Authorization header
// api.options.headers['Authorization'] = ...  ← NE PAS FAIRE

// 3. Pagination Spring
final page = response.data;
final items = page['content'] as List;  // Les données
final total = page['totalElements'];     // Total
final totalPages = page['totalPages'];   // Nb pages

// 4. Dates relatives avec intl
import 'package:intl/intl.dart';
String formatRelative(String isoDate) {
  final date = DateTime.parse(isoDate);
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 60) return "Il y a ${diff.inMinutes} min";
  if (diff.inHours < 24) return "Il y a ${diff.inHours}h";
  if (diff.inDays == 1) return "Hier";
  if (diff.inDays < 7) return "Il y a ${diff.inDays} jours";
  return DateFormat('dd/MM/yyyy', 'fr').format(date);
}

// 5. Polling ChatScreen — toujours annuler dans dispose()
Timer? _pollingTimer;
@override void initState() { _startPolling(); }
void _startPolling() {
  _pollingTimer = Timer.periodic(Duration(seconds: 4), (_) => _loadMessages());
}
@override void dispose() { _pollingTimer?.cancel(); super.dispose(); }

// 6. Future.wait pour chargements parallèles
final results = await Future.wait([
  eleveService.getEleve(id),
  notesService.getNotes(id),
  diagnosticService.getDernierResultat(id),
]);

// 7. url_launcher pour lienVisio et backoffice
// pubspec.yaml: url_launcher: ^6.2.0
import 'package:url_launcher/url_launcher.dart';
await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
```

---

## PACKAGES À AJOUTER DANS pubspec.yaml

```yaml
dependencies:
  url_launcher: ^6.2.0          # Liens visio + backoffice
  image_picker: ^1.0.7          # Upload photo profil
  file_picker: ^6.1.1           # Upload documents PDF
  path: ^1.9.0                  # path.basename() pour FileService
  table_calendar: ^3.0.9        # Optionnel — ou calendrier custom pour PriseRdv
  syncfusion_flutter_pdfviewer: ^24.1.41  # Optionnel — viewer PDF documents
```
