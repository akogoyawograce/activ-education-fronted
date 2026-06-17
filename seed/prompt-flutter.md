# Prompt Flutter Mobile — Activ Education

## Stack & Config

- **Flutter** 3.3+ (Dart 3.3+), `setState` only (no Provider/Riverpod/Bloc)
- **HTTP**: Dio 5.7 (singleton `ApiService` via `BaseService`)
- **Auth token**: JWT stocké dans `flutter_secure_storage` (clé `auth_token`)
- **Env**: `API_BASE_URL=http://4.233.145.112:8080` (pas de suffixe `/api/v1` — c'est le Dio qui l'ajoute dans les URL)
- **Fonts**: Inter (corps) + Poppins (titres)
- **Design tokens**: Fichier `lib/theme/app_theme.dart`

---

## Design System — Couleurs

| Token | Hex | Usage |
|---|---|---|
| `AppColors.primary` | `#1300C8` | Bleu foncé — boutons outline, badges, barre de progression, liens |
| `AppColors.primaryDark` | `#0F00A0` | Hover/actif primaire |
| `AppColors.primaryLight` | `#4A3DFF` | Variante claire primaire |
| `AppColors.accent` | `#FFA800` | Orange — CTA principal (`PrimaryButton`), badges "FILIÈRE DU MOMENT" |
| `AppColors.accentLight` | `#FFD166` | Variante claire accent |
| `AppColors.background` | `#FCF8FF` | Fond blanc cassé (majorité des screens) |
| `AppColors.backgroundGrey` | `#F4F0FA` | Fond gris lavande (explorer, messages, profil) |
| `AppColors.backgroundBlue` | `#1300C8` | Fond bleu (splash) |
| `AppColors.textDark` | `#1A1A2E` | Titres |
| `AppColors.textMedium` | `#454556` | Corps de texte |
| `AppColors.textLight` | `#B0B7C3` | Sous-titres, hints |
| `AppColors.textWhite` | `#FFFFFF` | Texte sur fond foncé |
| `AppColors.success` | `#10B981` | Vert — succès |
| `AppColors.error` | `#EF4444` | Rouge — erreur |
| `AppColors.warning` | `#F59E0B` | Jaune — avertissement |
| `AppColors.cardBorder` | `#E5E7EB` | Bordures de cartes |
| `AppColors.selectedCard` | `#1300C8` | État sélectionné |

### TextStyles

| Style | Font | Poids | Taille | Usage |
|---|---|---|---|---|
| `displayLarge` | Poppins | W800 | 28 | Titres très grands |
| `displayMedium` | Poppins | W800 | 24 | Titres de page |
| `headingLarge` | Poppins | W700 | 20 | Titres sections |
| `headingMedium` | Poppins | W700 | 17 | Sous-titres |
| `headingSmall` | Poppins | W700 | 15 | Petits titres |
| `bodyLarge` | Inter | W400 | 15 | Corps principal |
| `bodyMedium` | Inter | W400 | 14 | Corps secondaire |
| `label` | Inter | W600 | 13 | Labels de champ |
| `caption` | Inter | W400 | 12 | Légendes |
| `buttonText` | Inter | W700 | 16 | Boutons |

---

## Pages / Screens

Toutes les pages sont en `lib/screens/`. Routes définies dans `lib/theme/app_routes.dart` et wiring dans `lib/main.dart`.

---

### 1. SplashScreen (`/`, splash_screen.dart)

**Fond**: `AppColors.backgroundBlue` (#1300C8)
**Description**: Animation 2.8s : logo (carte blanche ronde avec logo.jpeg) apparition + échelle, texte "Activ Education" + tagline en blanc, barre de progression orange en bas, status text ("Initialisation" → "Chargement des données" → "Presque prêt..."), ville "Lomé, Togo". Vérifie si JWT token existe → `/home` ou `/onboarding`.
**Endpoints appelés** : Aucun (lecture locale `flutter_secure_storage`)

---

### 2. OnboardingScreen (`/onboarding`, onboarding_screen.dart)

**Fond**: `AppColors.background` (#FCF8FF)
**Description**: 3 slides (PageView) : "Découvre ta voie" (diagramme CustomPainter bleu/orange) → "Un diagnostic fait pour toi" (mockup téléphone) → "Un conseiller près de toi" (avatar + bulles). DotIndicator, bouton "Suivant" (orange `PrimaryButton`) / "Commencer", lien "Passer" / "J'ai déjà un compte → Se connecter".
**Endpoints** : Aucun

---

### 3. ProfileSetupScreen (`/profile-setup`, auth/)

**Fond**: `AppColors.backgroundGrey` (#F4F0FA)
**Description**: Sélection du rôle (grille 2 colonnes) : Collégien, Lycéen, Étudiant, Parent, Reconversion, Décrocheur. Sélecteur de classe (DropdownButtonFormField) si collégien/lycéen. Champ ville. Step indicator. Pas d'appel API — les données sont passées en arguments à `/register`.
**Endpoints** : Aucun

---

### 4. RegisterScreen (`/register`, auth/)

**Fond**: `AppColors.background` (#FCF8FF)
**Description**: Formulaire : Nom, Prénom, Email, Téléphone (avec sélecteur de pays modal bottom sheet — 18 pays, défaut TG +228), Mot de passe (min 8 car), Confirmation. StepProgressBar (étape 2/2). Logo en haut. Lien "Déjà un compte → Se connecter".
**Pas d'appel API direct** — les données sont passées à `/register-preferences`.

---

### 5. RegisterPreferencesScreen (`/register-preferences`, auth/)

**Fond**: `AppColors.background` (#FCF8FF)
**Description**: Étape 3/3. Matières préférées (Wrap de chips cliquables — Maths, SVT, Physique, Français, Histoire-Géo, Anglais, Philosophie, Économie). Style d'apprentissage (Par les textes / Par les vidéos / Les deux). "Passer cette étape".
**Endpoints appelés** :
- `POST /api/v1/eleves` — Inscription élève (EleveRequest)
- `POST /api/v1/parents` — Inscription parent (ParentRequest)
- `POST /api/v1/auth/login` — Auto-login JWT après inscription

---

### 6. LoginScreen (`/login`, auth/)

**Fond**: `AppColors.background` (#FCF8FF)
**Description**: Logo + "Bon retour !" + Email + Mot de passe (avec toggle visibilité) + "Mot de passe oublié ?" + CTA orange "Se connecter" + Divider + "Continuer avec Google" (OutlinedButton avec icône G) + "Créer mon compte".
**Endpoints appelés** :
- `POST /api/v1/auth/login` → `LoginRequest(email, motDePasse)` → `TokenResponse`
- Google Sign-In : via `google_sign_in` package (pas d'endpoint backend)

---

### 7. ForgotPasswordScreen (`/forgot-password`, auth/)

**Fond**: `AppColors.background` (#FCF8FF)
**Description**: Toggle Email/Téléphone. Champ input. Illustration lock_reset. "Retour à la connexion".
**Pas d'appel API** — navigation simulée vers `/otp` avec arguments.

---

### 8. OtpScreen (`/otp`, auth/)

**Fond**: `AppColors.backgroundGrey` (#F4F0FA)
**Description**: 4 boîtes OTP (chiffres seulement), timer 45s, "Renvoyer le code", bouton "Valider".
**Pas d'appel API réel** — navigation directe vers `/home`.

---

### 9. MainScaffold (`/home`, `main_scaffold.dart`)

**Navigation 5 onglets** (bottom nav) : Accueil (0), Explorer (1), Diagnostic (2), Messages (3), Profil (4).
**Fond**: varie selon dashboard
**Description**: `IndexedStack` + `AppBottomNav`. Charge le rôle utilisateur depuis le storage et affiche le dashboard correspondant : `DashboardBachelier` / `DashboardParent` / `DashboardConseiller` / `DashboardReconversion`.

---

### 10. DashboardBachelier (home/)

**Fond**: `AppColors.backgroundGrey` (#F4F0FA)
**Description**: Header avec nom + avatar + "Bonjour". Carte de progression (profil complété XX%). Notes récentes + moyenne générale. Dernier résultat de diagnostic. RdV à venir. Messages non lus. Section recommandations (via `RecommendationService` local — pas d'API). Widgets réutilisables. Pull-to-refresh.
**Endpoints appelés** :
- `GET /api/v1/eleves/{trackingId}` — Profil élève
- `GET /api/v1/eleves/{trackingId}/notes` — Notes
- `GET /api/v1/rendez-vous/eleve/{trackingId}` — RdV
- `GET /api/v1/utilisateurs/{trackingId}/messages/non-lus/compteur` — Messages non lus
- `GET /api/v1/eleves/{trackingId}/resultats-diagnostic?page=0&size=1` — Dernier résultat
- `GET /api/v1/bibliotheque/filieres?page=0&size=50` — Filières (recommandations)

---

### 11. DashboardParent (home/)

**Fond**: `AppColors.backgroundGrey` (#F4F0FA)
**Description**: Header + nom + liste des enfants avec leur trackingId. Chaque enfant : carte avec progression, lien vers `EnfantSuiviScreen`.
**Endpoints appelés** :
- `GET /api/v1/parents/{trackingId}` — Profil parent (contient `enfantsTrackingIds`)

---

### 12. DashboardConseiller (home/)

**Fond**: `AppColors.backgroundGrey` (#F4F0FA)
**Description**: Header + nom + statistiques (messages en attente, RdV aujourd'hui).
**Endpoints appelés** :
- `GET /api/v1/conseillers/{trackingId}` — Profil conseiller
- `GET /api/v1/utilisateurs/{trackingId}/messages/non-lus/compteur`
- `GET /api/v1/rendez-vous/conseiller/{trackingId}` — RdV du conseiller

---

### 13. DashboardReconversion (home/)

**Fond**: `AppColors.backgroundGrey` (#F4F0FA)
**Description**: Header + nom + cartes actions : Bilan de compétences, Formations accélérées, Passerelles métiers, Conseiller.
**Endpoints appelés** :
- `GET /api/v1/eleves/{trackingId}` (via `getUtilisateurNom`)

---

### 14. EnfantSuiviScreen (`/enfant-suivi`, home/)

**Fond**: `AppColors.backgroundGrey` (#F4F0FA)
**Description**: Vue parent d'un enfant : infos profil, moyenne calculée localement, notes, résultats de quiz, RdV.
**Endpoints appelés** :
- `GET /api/v1/eleves/{enfantTrackingId}`
- `GET /api/v1/eleves/{enfantTrackingId}/notes`
- `GET /api/v1/eleves/{enfantTrackingId}/resultats-diagnostic`
- `GET /api/v1/rendez-vous/eleve/{enfantTrackingId}`

---

### 15. ExplorerScreen (explorer/)

**Fond**: `AppColors.backgroundGrey` (#F4F0FA)
**Description**: Onglets horizontaux : Tout, Séries, Filières, Métiers, Établissements. Barre de recherche avec filtre local. Fiche vedette (première filière avec fond dégradé bleu + badge "FILIÈRE DU MOMENT"). Grille 2 colonnes de cartes. Bouton filtre (CatalogueFilterSheet modal). "Voir tout" → `_AllCategoriesScreen`. Pull-to-refresh. Skeleton loading.
**Endpoints appelés** :
- `GET /api/v1/bibliotheque/series?page=0&size=20`
- `GET /api/v1/bibliotheque/filieres?page=0&size=20`
- `GET /api/v1/bibliotheque/metiers?page=0&size=20`
- `GET /api/v1/bibliotheque/etablissements?page=0&size=20`

---

### 16. FicheDetailScreen (`/fiche-detail`, explorer/)

**Fond**: Blanc (#FFFFFF) scrollable
**Description**: Détail complet d'une fiche (Série/Filière/Métier/Établissement). Image + dégradé + icône bookmark/favori. Titre + sous-titre. Sections accordéon : "Au programme", "Débouchés", "Établissements", "Admission". Fiches similaires (horizontal). Pull-to-refresh. Bouton "Contacter un conseiller".
**Endpoints appelés** :
- `GET /api/v1/bibliotheque/favoris/utilisateur/{userId}?size=100` — Vérification favori
- `GET /api/v1/bibliotheque/series?page=0&size=6` — Similaires (selon type)
- `GET /api/v1/bibliotheque/filieres?page=0&size=6`
- `GET /api/v1/bibliotheque/metiers?page=0&size=6`
- `GET /api/v1/bibliotheque/etablissements?page=0&size=6`
- `POST /api/v1/bibliotheque/favoris` — Ajout favori
- `DELETE /api/v1/bibliotheque/favoris/{id}` — Suppression favori

---

### 17. CategoryListScreen (explorer/)

**Fond**: `AppColors.backgroundGrey` (#F4F0FA)
**Description**: Liste paginée infinie (scroll controller) d'une catégorie spécifique. Filtres + recherche. Pull-to-refresh.
**Endpoints appelés** :
- `GET /api/v1/bibliotheque/series?page={page}&size=20`
- `GET /api/v1/bibliotheque/filieres?page={page}&size=20`
- `GET /api/v1/bibliotheque/metiers?page={page}&size=20`
- `GET /api/v1/bibliotheque/etablissements?page={page}&size=20`

---

### 18. FavoritesScreen (`/favorites`, explorer/)

**Fond**: `AppColors.backgroundGrey` (#F4F0FA)
**Description**: Liste des favoris avec swipe-to-delete (Dismissible rouge). Carte avec icône bookmark + titre.
**Endpoints appelés** :
- `GET /api/v1/bibliotheque/favoris/utilisateur/{userId}?size=100`
- `DELETE /api/v1/bibliotheque/favoris/{id}`

---

### 19. GlobalSearchScreen (`/search`, search/)

**Fond**: Blanc
**Description**: Barre de recherche avec debounce 400ms. Résultats catégorisés par type (Série/Filière/Métier/Établissement) avec icônes et couleurs distinctes. Liens vers `FicheDetailScreen`.
**Endpoints appelés** :
- `GET /api/v1/bibliotheque/recherche-fiche-ia/globale?phrase={q}&limite=10`

---

### 20. QuizScreen (`/quiz`, diagnostic/)

**Fond**: `AppColors.background` (#FCF8FF)
**Description**: Charge un quiz (par trackingId ou premier disponible). Affiche les questions 1 par une (slide animation). Réponses radio (cercles remplis). Barre de progression (questions répondues). Timer. Bouton "Terminer" → soumission → navigation vers `/resultats`.
**Endpoints appelés** :
- `GET /api/v1/quiz/{trackingId}` — Quiz par ID
- `GET /api/v1/quiz?page=0&size=1` — Premier quiz dispo
- `GET /api/v1/quiz/{quizId}/questions` — Questions
- `GET /api/v1/questions/{questionId}/reponses` — Réponses
- `POST /api/v1/resultats-diagnostic` — Soumission résultat (ResultatDiagnosticRequest)

---

### 21. ResultatsScreen (`/resultats`, diagnostic/)

**Fond**: `AppColors.background` (#FCF8FF)
**Description**: Animation élastique. Score animé (pie chart personnalisé avec CustomPainter). Profil RIASEC. Liste de recommandations (filtrées localement selon profil). Section "Filières recommandées" avec cartes cliquables vers FicheDetailScreen. Bouton "Refaire le quiz" + "Explorer les métiers".
**Endpoints appelés** :
- `GET /api/v1/bibliotheque/filieres?page=0&size=50` — Filtrage local par profil RIASEC

---

### 22. NotesScreen (`/notes`, diagnostic/)

**Fond**: `AppColors.background` (#FCF8FF)
**Description**: Gestion des notes scolaires. Formulaire (matière, note, coefficient, trimestre). Liste des notes avec swipe-to-delete. Moyenne calculée localement. Graphique barres via CustomPainter. Animation slide/fade.
**Endpoints appelés** :
- `GET /api/v1/eleves/{trackingId}/notes`
- `POST /api/v1/eleves/{trackingId}/notes`
- `DELETE /api/v1/notes/{noteId}`

---

### 23. MessagesListScreen (`/messages`, messages/)

**Fond**: `AppColors.backgroundGrey` (#F4F0FA)
**Description**: Liste des conversations groupées par expéditeur. Badge non-lus. FAB "Nouveau message" → modal bottom sheet avec sélection destinataire + texte. Swipe-to-delete conversation. Pull-to-refresh.
**Endpoints appelés** :
- `GET /api/v1/utilisateurs/{trackingId}/messages/recus?page=0&size=50`
- `GET /api/v1/utilisateurs/{trackingId}/messages/non-lus/compteur`
- `POST /api/v1/utilisateurs/{expediteurId}/messages` — Envoi message
- `PATCH /api/v1/messages/conversation/lire?expediteur={}&destinataire={}`
- `GET /api/v1/conseillers?page=0&size=100` — Liste conseillers (pour nouveau message)
- `GET /api/v1/eleves/{trackingId}` / `GET /api/v1/conseillers/{trackingId}` — Noms expéditeurs

---

### 24. ChatScreen (`/chat`, messages/)

**Fond**: `AppColors.backgroundGrey` (#F4F0FA)
**Description**: Vue conversation temps réel (polling 4s). Bulles de messages (utilisateur à droite, autre à gauche). Scroll to bottom automatique. Champ de saisie + envoi. Marque comme lu.
**Endpoints appelés** :
- `GET /api/v1/messages/conversation?user1={}&user2={}` — Historique
- `POST /api/v1/utilisateurs/{expediteurId}/messages` — Envoi
- `PATCH /api/v1/messages/conversation/lire?expediteur={}&destinataire={}`

---

### 25. RdvScreen (`/rdv`, messages/)

**Fond**: `AppColors.backgroundGrey` (#F4F0FA)
**Description**: Liste des RdV (passés/à venir). Création de RdV avec sélecteur de conseiller (dropdown), date (DatePicker), heure (TimePicker), objet, commentaire. Animation slide. Vide si aucun RdV.
**Endpoints appelés** :
- `GET /api/v1/rendez-vous/eleve/{trackingId}`
- `GET /api/v1/rendez-vous/conseiller/{trackingId}`
- `GET /api/v1/conseillers/{conseillerId}/disponibilites` — Créneaux dispo
- `POST /api/v1/rendez-vous` — Planifier (RendezVousRequest)
- `PATCH /api/v1/rendez-vous/{rdvId}/annuler`
- `PATCH /api/v1/rendez-vous/{rdvId}/terminer`

---

### 26. FaqScreen (`/faq`, home/)

**Fond**: `AppColors.background` (#FCF8FF)
**Description**: Barre de recherche + filtres par catégorie (chips horizontales). Accordéon (questions cliquables avec animation). Pull-to-refresh.
**Endpoints appelés** :
- `GET /api/v1/bibliotheque/faq?page=0&size=100`

---

### 27. NotificationsScreen (`/notifications`, home/)

**Fond**: `AppColors.background` (#FCF8FF)
**Description**: Liste chronologique des notifications. Badge non-lues. Marquer toutes lues (icône check). Swipe-to-dismiss. Animation slide.
**Endpoints appelés** :
- `GET /api/v1/utilisateurs/{trackingId}/notifications`
- `GET /api/v1/utilisateurs/{trackingId}/notifications/non-lues`
- `PATCH /api/v1/notifications/{id}/lire`
- `PATCH /api/v1/utilisateurs/{trackingId}/notifications/tout-lire`

---

### 28. ProfileScreen (`/profil`, profile/)

**Fond**: `AppColors.backgroundGrey` (#F4F0FA)
**Description**: Avatar + nom + email. Mode édition avec formulaire (nom, prénom, email, téléphone, niveau, établissement, filière via dropdowns). Déconnexion (bouton rouge).
**Endpoints appelés** :
- `GET /api/v1/eleves/{trackingId}` — Profil selon rôle
- `GET /api/v1/parents/{trackingId}`
- `GET /api/v1/conseillers/{trackingId}`
- `PUT /api/v1/eleves/{trackingId}` — Mise à jour (EleveRequest)
- `POST /api/v1/auth/logout` + `storage.deleteAll()` — Déconnexion

---

### 29. NotFoundScreen (`/404`, errors/)

**Fond**: Blanc
**Description**: Icône explore_off + "Page introuvable" + message personnalisé + bouton "Retour à l'accueil".

### 30. NetworkErrorScreen (`/network-error`, errors/)

**Fond**: Blanc
**Description**: Icône wifi_off + message + bouton "Réessayer".

---

## Services & Endpoints (tous les appels HTTP)

Base URL: `API_BASE_URL` (env) — pas de suffixe `/api/v1`. Le préfixe `/api/v1` est dans chaque appel.

### AuthService (`auth_service.dart`)
- `POST /api/v1/auth/login` → `TokenResponse`
- `GET /api/v1/auth/me` → profil courant (JWT requis)
- `POST /api/v1/auth/logout`
- `POST /api/v1/eleves` → `EleveResponse` (inscription élève)
- `POST /api/v1/parents` → `ParentResponse` (inscription parent)
- `POST /api/v1/conseillers` → `ConseillerResponse`
- `POST /api/v1/administrateurs` → `AdministrateurResponse`
- `GET /api/v1/eleves/{trackingId}` → `EleveResponse`
- `GET /api/v1/parents/{trackingId}` → `ParentResponse`
- `GET /api/v1/conseillers/{trackingId}` → `ConseillerResponse`
- `GET /api/v1/administrateurs/{trackingId}` → `AdministrateurResponse`
- `GET /api/v1/administrateurs?page={}&size={}` → page d'admins
- `GET /api/v1/conseillers?page={}&size={}` → liste conseillers (retourne une liste directe, pas PageResponse)

### ExplorerService (`explorer_service.dart`)
- `GET /api/v1/bibliotheque/series?page={}&size={}`
- `GET /api/v1/bibliotheque/filieres?page={}&size={}`
- `GET /api/v1/bibliotheque/metiers?page={}&size={}`
- `GET /api/v1/bibliotheque/etablissements?page={}&size={}`
- `GET /api/v1/bibliotheque/series/recherche?motCle={}&page={}&size={}`
- `GET /api/v1/bibliotheque/filieres/recherche?motCle={}&page={}&size={}`
- `GET /api/v1/bibliotheque/metiers/recherche?motCle={}&page={}&size={}`
- `GET /api/v1/bibliotheque/etablissements/recherche?motCle={}&page={}&size={}`
- `GET /api/v1/bibliotheque/recherche-fiche-ia/globale?phrase={}&limite={}` → recherche IA globale
- `POST /api/v1/bibliotheque/favoris` → ajouter favori
- `GET /api/v1/bibliotheque/favoris/utilisateur/{utilisateurId}?page={}&size={}`
- `DELETE /api/v1/bibliotheque/favoris/{trackingId}`
- `GET /api/v1/bibliotheque/faq?page={}&size={}`
- `GET /api/v1/bibliotheque/faq/categorie/{categorie}`
- `GET /api/v1/bibliotheque/faq/categories`

### DiagnosticService (`diagnostic_service.dart`)
- `GET /api/v1/quiz?page={}&size={}`
- `GET /api/v1/quiz/{quizId}`
- `GET /api/v1/quiz/{quizId}/questions`
- `GET /api/v1/questions/{questionId}/reponses`
- `POST /api/v1/resultats-diagnostic` → soumettre résultat
- `GET /api/v1/eleves/{eleveId}/resultats-diagnostic?page={}&size={}`
- `GET /api/v1/eleves/{eleveId}/resultats-diagnostic/dernier?quizTrackingId={}`

### AcademicService (`academic_service.dart`)
- `POST /api/v1/eleves/{eleveId}/notes`
- `GET /api/v1/eleves/{eleveId}/notes`
- `PUT /api/v1/notes/{trackingId}`
- `DELETE /api/v1/notes/{trackingId}`

### InteractionService (`interaction_service.dart`)
- `POST /api/v1/utilisateurs/{expediteurId}/messages`
- `GET /api/v1/messages/conversation?user1={}&user2={}`
- `GET /api/v1/utilisateurs/{destinataireId}/messages/non-lus/compteur`
- `PATCH /api/v1/messages/conversation/lire?expediteur={}&destinataire={}`
- `DELETE /api/v1/messages/{trackingId}`
- `POST /api/v1/rendez-vous` → planifier
- `GET /api/v1/rendez-vous/eleve/{eleveId}`
- `GET /api/v1/rendez-vous/conseiller/{conseillerId}`
- `PATCH /api/v1/rendez-vous/{rdvId}/annuler`
- `PATCH /api/v1/rendez-vous/{rdvId}/terminer`
- `GET /api/v1/conseillers/{conseillerId}/disponibilites`
- `GET /api/v1/utilisateurs/{utilisateurId}/notifications`
- `GET /api/v1/utilisateurs/{utilisateurId}/notifications/non-lues`
- `GET /api/v1/utilisateurs/{utilisateurId}/notifications/compteur`
- `PATCH /api/v1/notifications/{notificationId}/lire`
- `PATCH /api/v1/utilisateurs/{utilisateurId}/notifications/tout-lire`
- `GET /api/v1/utilisateurs/{utilisateurId}/historique`
- `POST /api/v1/utilisateurs/{utilisateurId}/historique`

### FileService (`file_service.dart`)
- `POST /files/upload/{fileType}` — upload multipart (images/videos/documents)
- `GET /files/url/{fileType}/{fileName}` — URL publique

---

## Navigation — Routes complètes

| Route | Screen | Arguments |
|---|---|---|
| `/` | SplashScreen | — |
| `/onboarding` | OnboardingScreen | — |
| `/profile-setup` | ProfileSetupScreen | — |
| `/register` | RegisterScreen | `{role, class, city}` |
| `/register-preferences` | RegisterPreferencesScreen | `{...all previous data}` |
| `/login` | LoginScreen | — |
| `/forgot-password` | ForgotPasswordScreen | — |
| `/otp` | OtpScreen | `{type, value, role}` |
| `/home` | MainScaffold (dashboard) | — |
| `/dashboard` | MainScaffold | — |
| `/explorer` | ExplorerScreen | — |
| `/search` | GlobalSearchScreen | — |
| `/fiche-detail` | FicheDetailScreen | `{fiche: FicheBase}` |
| `/favorites` | FavoritesScreen | — |
| `/quiz` | QuizScreen | `{quizTrackingId}` (optionnel) |
| `/resultats` | ResultatsScreen | `{score, profil, quizId}` |
| `/notes` | NotesScreen | — |
| `/messages` | MessagesListScreen | — |
| `/chat` | ChatScreen | `{expediteurId, expediteurNom}` |
| `/rdv` | RdvScreen | `{conseillerId, conseillerNom}` (optionnel) |
| `/faq` | FaqScreen | — |
| `/notifications` | NotificationsScreen | — |
| `/enfant-suivi` | EnfantSuiviScreen | `{enfantTrackingId}` |
| `/profil` | ProfileScreen | — |
| `/404` | NotFoundScreen | — |
| `/network-error` | NetworkErrorScreen | — |
