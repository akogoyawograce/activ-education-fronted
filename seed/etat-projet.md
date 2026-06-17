# État du Projet Activ Education

---

## 📋 Structure du projet

```
Projet-activ-education/
├── activ-education/                # Frontend (Flutter + React)
│   ├── activ_education/            # App mobile Flutter
│   └── activ_education_admin/      # App admin React/Vite
└── activ-education-backend/        # Backend Spring Boot (Java 21)
```

Services actuellement en cours d'exécution :

| Service | Accès |
|---------|-------|
| Spring Boot API | http://localhost:8080 |
| PostgreSQL | localhost:5432 |
| MinIO API | http://localhost:9000 |
| MinIO Console | http://localhost:9001 |
| App mobile (Flutter/Chrome) | http://localhost:3000 |

---

## 📱 Frontend Mobile (Flutter)

### Stack technique
- **Framework :** Flutter (Material 3)
- **Langage :** Dart
- **HTTP :** Dio
- **Stockage token :** flutter_secure_storage
- **State management :** ❌ Aucun (tout en `setState`)
- **Stockage offline :** ❌ Aucun
- **Police :** Nunito
- **Tests :** 5 tests (1 smoke + 4 API)

### Écrans codés (20)

#### 1. Onboarding & Auth

| Écran | Fichier | Statut | Notes |
|-------|---------|--------|-------|
| Splash Screen | `splash_screen.dart` | ✅ 100% | Animation logo + barre de progression |
| Onboarding (3 slides) | `onboarding_screen.dart` | ✅ 100% | PageView, "Passer", "Suivant" |
| Profile Setup (Step 1) | `profile_setup_screen.dart` | ✅ 100% | Rôle, classe, ville |
| Register (Step 2) | `register_screen.dart` | ✅ 100% | Nom, email, téléphone, mot de passe |
| Register Preferences (Step 3) | `register_preferences_screen.dart` | ⚠️ 95% | City mappée sur etablissementActuel (bug) |
| Login | `login_screen.dart` | ⚠️ 90% | Google Sign-In non implémenté |
| Forgot Password | `forgot_password_screen.dart` | ⚠️ 80% | API simulée (pas réelle) |
| OTP | `otp_screen.dart` | ⚠️ 60% | Pas relié au vrai endpoint |

#### 2. Dashboard & Navigation

| Écran | Fichier | Statut | Notes |
|-------|---------|--------|-------|
| Main Scaffold (5 tabs) | `main_scaffold.dart` | ✅ 100% | Accueil, Explorer, Diagnostic, Messages, Profil |
| Dashboard Bachelier | `dashboard_bachelier.dart` | ✅ 100% | Stats, notes, RDV, messages, quick actions, pull-to-refresh |
| Profile | `profile_screen.dart` | ✅ 90% | Édition, dropdowns, sauvegarde (password placeholder) |
| Notifications | `notifications_screen.dart` | ✅ 90% | Marquer lu, tri ; delete API stub |
| FAQ | `faq_screen.dart` | ✅ 100% | Catégories, recherche en temps réel |

#### 3. Explorer (Bibliothèque)

| Écran | Fichier | Statut | Notes |
|-------|---------|--------|-------|
| Explorer (liste) | `explorer_screen.dart` | ✅ 95% | 5 tabs, recherche, grille, favoris (onTap vide) |
| Fiche Détail | `fiche_detail_screen.dart` | ✅ 90% | Accordéons par type ; vidéo + "Contacter" stubs |

#### 4. Diagnostic

| Écran | Fichier | Statut | Notes |
|-------|---------|--------|-------|
| Quiz | `quiz_screen.dart` | ✅ 100% | Algorithme RIASEC complet |
| Résultats | `resultats_screen.dart` | ✅ 95% | Score + recommandations ; navigation vers fiche stub |
| Notes (CRUD) | `notes_screen.dart` | ✅ 100% | Ajout/suppression/liste avec coefficients |

#### 5. Messagerie & RDV

| Écran | Fichier | Statut | Notes |
|-------|---------|--------|-------|
| Messages liste | `messages_list_screen.dart` | ✅ 100% | Groupé, swipe-to-delete, compteur non-lus |
| Chat | `chat_screen.dart` | ✅ 100% | Polling 4s, bulles, auto-scroll |
| Prise de RDV | `rdv_screen.dart` | ✅ 95% | CRUD, sélection conseiller ; lien visio stub |

### ❌ Écrans Figma manquants (mobile)

| Écran | Description |
|-------|-------------|
| **Accueil Reconversion** | Dashboard pour profil reconversion (Mme Akpene) |
| **Espace Famille / Résultats Parent** | Vue parent des résultats |
| **Dashboard Conseiller** | Tableau de bord conseiller |
| **Catalogue Filières/Métiers/Séries/Établissements** | Pages catalogue dédiées avec filtres |
| **Tabs Fiche Série C** (Bref, Programme, Débouchés, Vidéos) | Sous-pages de détail |
| **Tabs Fiche UL** (Bref, Formations, Accès) | Sous-pages de détail |
| **Fiche Médecin / DUT Info** | Détails spécifiques |
| **Mes Favoris** | Écran standalone |
| **Résultats de recherche** | Page de résultats |
| **Exploration Guidée** | Mode découverte pas à pas |
| **Fiche Incomplète** | État fiche vide |
| **Erreur 404** | Page non trouvée |
| **Erreur Réseau** | Page hors-ligne |
| **Skeleton Loading** | État de chargement |
| **Partage Fiche** | Bottom sheet partage |
| **Vidéothèque** | Composant vidéo |
| **Témoignages** | Composant témoignages |
| **Comparaison Desktop** | Tableau comparatif |

### 📝 TODOs dans le code (10)
1. `login_screen.dart` — Google Sign-In non implémenté
2. `otp_screen.dart` — OTP non relié au vrai endpoint
3. `otp_screen.dart` — API resend non implémentée
4. `register_preferences_screen.dart` — City mappée incorrectement (etablissementActuel)
5. `profile_screen.dart` — `motDePasse: 'placeholder'` en dur
6. `fiche_detail_screen.dart` — Lecteur vidéo non implémenté
7. `fiche_detail_screen.dart` — "Contacter" conseiller non câblé
8. `notifications_screen.dart` — API delete non disponible
9. `rdv_screen.dart` — Lien visio non connecté
10. `resultats_screen.dart` — Navigation vers fiche détail non connectée

---

## 🖥️ Backend (Spring Boot)

### Stack technique
- **Framework :** Spring Boot 4.0.5 (Spring 7.0.6)
- **Langage :** Java 21
- **Base de données :** PostgreSQL 16 + pgvector
- **Stockage fichiers :** MinIO (S3-compatible)
- **IA :** Google Gemini (embedding + generate)
- **Build :** Maven
- **Tests :** 1 test (contextLoads)
- **Sécurité :** ❌ **Aucune** (pas de Spring Security, pas de JWT)

### Architecture
```
tg.edtch.activEducation/
├── shared/          # Config, MinIO, Gemini, BaseEntity
├── profil/          # Utilisateurs (Eleve, Parent, Conseiller, Admin)
├── diagnostic/      # Quiz, Questions, Réponses, Résultats
├── bibliotheque/    # Fiches (Série, Filière, Métier, Établissement), FAQ, Favoris
└── accompagnement/  # Messages, RDV, Disponibilités
```

### Entités (23 JPA)

#### Profil (10)
| Entité | Table | Détail |
|--------|-------|--------|
| `Utilisateur` (abstract) | `utilisateurs` | Base avec `trackingId` (UUID), email, nom, motDePasseHash |
| `Eleve` | `eleves` | Hérite Utilisateur, niveau, TypeApprenant |
| `Parent` | `parents` | Hérite Utilisateur, ManyToMany -> Eleve |
| `Conseiller` | `conseillers` | Hérite Utilisateur, spécialités, chargeTravail |
| `Administrateur` | `administrateurs` | Hérite Utilisateur, niveauAccès |
| `Role` | `roles` | Enum : ROLE_ELEVE, ROLE_PARENT, ROLE_CONSEILLER, ROLE_ADMIN |
| `Document` | `documents` | Fichiers liés à un élève |
| `Notification` | `notifications` | Titre, message, lue |
| `Historique` | `historique_utilisateur` | Log d'actions |
| `NoteSaisiManuel` | `notes_saisies_manuellement` | Matière, note, coefficient |

#### Diagnostic (6)
| Entité | Table | Détail |
|--------|-------|--------|
| `Quiz` | `quiz` | Titre, description, estActif |
| `Question` | `questions` | Texte, ordre |
| `Reponse` | `reponses` | Texte, catégorie RIASEC (R,I,A,S,E,C), points |
| `ResultatDiagnostic` | `resultats_diagnostic` | Score, recommandation, profil découvert |
| `ScoreMatrice` | `score_matrices` | Grille de pondération |
| `SeuilAdmission` | `seuils_admission` | Note minimum par matière pour une filière |

#### Bibliothèque (8)
| Entité | Table | Détail |
|--------|-------|--------|
| `Fiche` (abstract) | `fiches` | Titre, résumé, contenu, médias, embedding pgvector |
| `FicheMetier` | `fiches_metier` | Secteur, missions, compétences, salaire |
| `FicheSerie` | `fiches_serie` | Niveau, matières principales, coefficients |
| `FicheFiliere` | `fiches_filiere` | Durée, conditions admission, débouchés, domaine |
| `FicheEtablissement` | `fiches_etablissement` | Adresse, type, contacts, offre de formation |
| `Favori` | `favoris` | Lien Utilisateur <-> Fiche |
| `EntreeFAQ` | `entrees_faq` | Question/réponse, catégorie, embedding |
| `RechercheOrpheline` | `recherches_orphelines` | Termes de recherche sans résultat |

#### Accompagnement (3)
| Entité | Table | Détail |
|--------|-------|--------|
| `RendezVous` | `rendez_vous` | Date, statut (PLANIFIE/TERMINE/ANNULE), lien visio |
| `Message` | `messages` | Contenu, expéditeur, destinataire, lu |
| `Disponibilite` | `disponibilites` | Jour (1-7), heure début/fin |

### APIs REST (179 endpoints)

#### Profil (utilisateurs)
```
POST   /api/v1/eleves                                            # Inscription élève
GET    /api/v1/eleves/{trackingId}                                # Profil élève
GET    /api/v1/eleves                                             # Liste élèves
PUT    /api/v1/eleves/{trackingId}                                # Modifier élève
DELETE /api/v1/eleves/{trackingId}                                # Désactiver élève

POST   /api/v1/parents                                            # Créer parent
GET    /api/v1/parents/{trackingId}                               # Profil parent
POST   /api/v1/parents/{trackingId}/enfants/{eleveTrackingId}    # Lier enfant
DELETE /api/v1/parents/{trackingId}/enfants/{eleveTrackingId}    # Délier enfant

POST   /api/v1/conseillers                                        # Créer conseiller
GET    /api/v1/conseillers/disponibles                            # Conseillers disponibles
GET    /api/v1/conseillers/{trackingId}                           # Profil conseiller

POST   /api/v1/administrateurs                                    # Créer admin
GET    /api/v1/administrateurs/{trackingId}                       # Profil admin
```

#### Notes
```
POST   /api/v1/eleves/{eleveTrackingId}/notes                    # Ajouter note
GET    /api/v1/eleves/{eleveTrackingId}/notes                     # Notes d'un élève
PUT    /api/v1/notes/{trackingId}                                 # Modifier note
DELETE /api/v1/notes/{trackingId}                                 # Supprimer note
```

#### Historique & Notifications
```
POST   /api/v1/utilisateurs/{id}/historique                       # Ajouter entrée
GET    /api/v1/utilisateurs/{id}/historique                        # Historique
DELETE /api/v1/utilisateurs/{id}/historique                        # Purger

POST   /api/v1/utilisateurs/{id}/notifications                    # Envoyer notification
GET    /api/v1/utilisateurs/{id}/notifications                     # Notifications
GET    /api/v1/utilisateurs/{id}/notifications/non-lues            # Non lues
PATCH  /api/v1/utilisateurs/{id}/notifications/tout-lire           # Tout marquer lu
```

#### Diagnostic
```
POST   /api/v1/quiz                                                # Créer quiz
GET    /api/v1/quiz                                                # Quiz actifs
GET    /api/v1/quiz/{trackingId}/questions                         # Questions d'un quiz
POST   /api/v1/quiz/{quizTrackingId}/questions                     # Ajouter question
POST   /api/v1/questions/{questionTrackingId}/reponses             # Ajouter réponse
GET    /api/v1/questions/{questionTrackingId}/reponses             # Réponses d'une question
POST   /api/v1/resultats-diagnostic                                # Enregistrer résultat
GET    /api/v1/eleves/{eleveTrackingId}/resultats-diagnostic       # Résultats d'un élève
```

#### Bibliothèque
```
# CRUD pour chaque type de fiche
POST   /api/v1/bibliotheque/metiers                                # Créer fiche métier
GET    /api/v1/bibliotheque/metiers                                 # Lister
GET    /api/v1/bibliotheque/metiers/{trackingId}                   # Détail
GET    /api/v1/bibliotheque/metiers/recherche?motCle=...            # Recherche
GET    /api/v1/bibliotheque/metiers/secteurs                        # Tous les secteurs

GET    /api/v1/bibliotheque/series                                  # Séries
GET    /api/v1/bibliotheque/filieres                                # Filières
GET    /api/v1/bibliotheque/filieres/domaines                       # Domaines
GET    /api/v1/bibliotheque/etablissements                          # Établissements
GET    /api/v1/bibliotheque/etablissements/villes                   # Villes

# Favoris
POST   /api/v1/bibliotheque/favoris                                 # Ajouter
GET    /api/v1/bibliotheque/favoris/utilisateur/{id}                # Mes favoris
DELETE /api/v1/bibliotheque/favoris/{trackingId}                    # Supprimer

# FAQ
GET    /api/v1/bibliotheque/faq                                     # FAQ publiées
GET    /api/v1/bibliotheque/faq/categories                          # Catégories
GET    /api/v1/bibliotheque/faq/recherche-ia?question=...           # Recherche IA (Gemini RAG)

# Recherche intelligente
GET    /api/v1/bibliotheque/recherche-fiche-ia/globale?phrase=...   # Recherche sémantique globale
GET    /api/v1/bibliotheque/analytics/tendances                     # Tendances (7 jours)
GET    /api/v1/bibliotheque/analytics/similaires/{trackingId}       # Fiches similaires
```

#### Accompagnement
```
# Messages
POST   /api/v1/utilisateurs/{id}/messages                          # Envoyer message
GET    /api/v1/messages/conversation?user1=...&user2=...            # Conversation
GET    /api/v1/utilisateurs/{id}/messages/recus                     # Messages reçus
GET    /api/v1/utilisateurs/{id}/messages/non-lus/compteur          # Compteur non-lus
PATCH  /api/v1/messages/conversation/lire                           # Marquer lu
DELETE /api/v1/messages/{trackingId}                                # Supprimer

# RDV
POST   /api/v1/rendez-vous                                          # Planifier RDV
GET    /api/v1/rendez-vous/eleve/{id}                               # RDV élève
GET    /api/v1/rendez-vous/conseiller/{id}                          # RDV conseiller
PATCH  /api/v1/rendez-vous/{id}/annuler                             # Annuler
PATCH  /api/v1/rendez-vous/{id}/terminer                            # Terminer

# Disponibilités
POST   /api/v1/conseillers/{id}/disponibilites                      # Ajouter créneau
GET    /api/v1/conseillers/{id}/disponibilites                      # Créneaux conseiller
```

#### Fichiers (MinIO)
```
POST   /files/upload/{fileType}                                     # Upload fichier
GET    /files/download/{fileType}/{fileName}                        # Télécharger
GET    /files/url/{fileType}/{fileName}                             # URL publique
DELETE /files/{fileType}/{fileName}                                 # Supprimer
```

### Intégrations

#### 🤖 Gemini AI
- **Embedding :** `gemini-embedding-2` → vecteurs 768 dimensions
- **Génération :** `gemini-2.0-flash-lite` → RAG FAQ (recherche sémantique + réponse générée)
- **Utilisation :** Embeddings stockés en base (pgvector) pour similarité cosinus

#### 🗄️ PostgreSQL + pgvector
- Extension pgvector pour stockage et requêtes vectorielles
- Opérateur `<=>` (distance cosinus) dans les requêtes natives
- Utilisé pour : fiches similaires, FAQ sémantique, recherche globale

#### 📦 MinIO (Stockage objet)
- 3 buckets : images, vidéos, documents
- Upload multiple, presigned URLs, streaming
- Processing PDF : extraction texte, thumbnail, métadonnées

### ❌ Absent / À faire (backend)
1. **🔴 SÉCURITÉ** — Aucune. Pas de Spring Security, pas de JWT, pas d'authentification. Tous les endpoints sont publics.
2. **Tests** — 1 seul test (contextLoads). Aucun test unitaire, d'intégration ou de repository.
3. **Migrations** — Pas de Flyway/Liquibase. `ddl-auto=update` seulement.
4. **Tâches planifiées** — Aucune (`@Scheduled`)

---

## 🎨 Design Figma vs Code

### Écrans Figma (Page 1)
```
Page 1 (39 screens)
├── Splash Screen ✅
├── Onboarding 1, 2, 3 ✅ (regroupé en 1 écran)
├── Inscription Étape 1/3 ✅
├── Inscription Étape 2/3 ✅
├── Inscription Étape 3/3 ✅
├── Connexion ✅
├── Récupération de compte ⚠️ (simulé)
├── Saisie OTP ⚠️ (simulé)
├── Tableau de bord (Koffi, Amina) ✅
├── Quiz orientation ✅
├── Fiche Série C ✅
├── FAQ ✅
├── Accueil (Koffi, Amina, Reconversion) ⚠️ (1 seul dashboard)
├── Résultats Diagnostic ✅
├── Saisie notes ✅
├── Messagerie ✅
├── Prise de RDV ✅
├── Conversation ✅
├── Mon Profil ✅
├── Espace Famille ❌
├── Résultats Parent ❌
├── Dashboard Conseiller ❌
├── Notifications ✅
├── Bibliothèque Explorer ✅
├── Back-office admin (10 écrans) ❌
└── + toutes les pages "Fiche scolaire" ❌
```

### Discordances design
| Élément | Figma | Code Flutter |
|---------|-------|-------------|
| **Primaire** | `#1300C8` (bleu foncé) | `#3D35D9` (bleu violet) |
| **Background** | `#FCF8FF` | `#FFFFFF` |
| **Texte medium** | `#454556` | `#6B7280` |
| **Police** | Inter / Poppins | Nunito |
| **Inscription** | 3 étapes distinctes | 3 écrans mais mapping bug (city->etablissement) |
| **Onboarding** | 3 écrans dont "Accompagnement" séparé | 1 carrousel unifié |
| **Dashboard** | Variantes (Koffi, Amina, Reconversion) | Un seul DashboardBachelier |

---

## 🚧 Priorités

### Critique
1. **🔴 Sécurité backend** — Spring Security + JWT (tous les endpoints sont ouverts)
2. **Back-office admin** (10 écrans) — Les API existent mais aucun frontend React ne les utilise

### Important
3. Écrans d'état : 404, Erreur Réseau, Skeleton, Fiche Incomplète
4. Catalogues dédiés (Filières, Métiers, Séries, Établissements)
5. Tabs de détail (Programme, Débouchés, Vidéos, Témoignages)
6. Favoris standalone / Recherche / Exploration Guidée
7. Variantes dashboard (Reconversion, Parent, Conseiller)

### Améliorations
8. State management (Provider/Riverpod/Bloc)
9. Stockage offline (SQLite/Hive)
10. Tests (backend + frontend)
11. Migrations DB (Flyway)
12. WebSocket pour le chat (au lieu du polling 4s)
13. Lecteur vidéo
14. Google Sign-In
