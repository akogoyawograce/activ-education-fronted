# API REST — Activ Education Backend

**Base URL :** `http://localhost:8080`  
**Swagger UI :** `http://localhost:8080/swagger-ui.html`  
**OpenAPI JSON :** `http://localhost:8080/api-docs`

> **⚠️ Sécurité :** JWT obligatoire sur tous les endpoints sauf `/api/v1/auth/login`, `/api/v1/auth/refresh`, `/api/v1/eleves` (POST inscription), `/api/v1/parents` (POST inscription), bibliothèque (GET public), `/actuator/health`, Swagger. Le filtre JWT et `@PreAuthorize` assurent le contrôle d'accès par rôle.

---

## Table des matières

1. [Fichiers (MinIO)](#-1-fichiers-minio)
2. [Élèves](#-2-élèves)
3. [Parents](#-3-parents)
4. [Conseillers](#-4-conseillers)
5. [Administrateurs](#-5-administrateurs)
6. [Notes](#-6-notes)
7. [Historique](#-7-historique)
8. [Notifications](#-8-notifications)
9. [Quiz](#-9-quiz)
10. [Questions](#-10-questions)
11. [Réponses](#-11-réponses)
12. [Résultats Diagnostic](#-12-résultats-diagnostic)
13. [Score Matrices](#-13-score-matrices)
14. [Seuils d'Admission](#-14-seuils-dadmission)
15. [Fiches Métiers](#-15-fiches-métiers)
16. [Fiches Séries](#-16-fiches-séries)
17. [Fiches Filières](#-17-fiches-filières)
18. [Fiches Établissements](#-18-fiches-établissements)
19. [Favoris](#-19-favoris)
20. [FAQ](#-20-faq)
21. [Recherche & Analytics](#-21-recherche--analytics)
22. [Admin Analytics](#-22-admin-analytics)
23. [Messages](#-23-messages)
24. [Rendez-Vous](#-24-rendez-vous)
25. [Disponibilités](#-25-disponibilités)

---

## 📦 1. Fichiers (MinIO)

### Upload
```http
POST /files/upload/{fileType}
POST /files/upload/multiple/{fileType}
```
| Paramètre | Type | Description |
|-----------|------|-------------|
| `fileType` | path | `IMAGE`, `VIDEO`, `PDF`, `DOCUMENT` |
| Body | `multipart/form-data` | Fichier(s) + optional `customFileName` |

**Response :** `FileUploadResponse` / `List<FileUploadResponse>`

### Téléchargement
```http
GET /files/download/{fileType}/{fileName}     # ➜ attachment
GET /files/stream/{fileType}/{fileName}       # ➜ inline
```

### Métadonnées
```http
GET /files/metadata/{fileType}/{fileName}     # ➜ FileMetadata
GET /files/list/{fileType}                    # ➜ List<FileMetadata>
GET /files/exists/{fileType}/{fileName}       # ➜ Boolean
```

### URLs
```http
GET /files/url/{fileType}/{fileName}          # ➜ URL publique (String)
GET /files/presigned-url/{fileType}/{fileName}  # ➜ Presigned URL (String)
```
Query param : `expiryMinutes` (default 60)

### Suppression
```http
DELETE /files/{fileType}/{fileName}           # ➜ 200 OK
```

### PDF
```http
GET /files/pdf/thumbnail/{fileName}           # ➜ PNG (byte[])
GET /files/pdf/text/{fileName}                # ➜ Texte brut (String)
```
Query params thumbnail : `width`, `height`

---

## 👤 2. Élèves

### Inscription
```http
POST /api/v1/eleves
```
**Body :** `EleveRequest`
```json
{
  "nom": "string",
  "prenom": "string",
  "email": "string",
  "telephone": "string",
  "motDePasse": "string",
  "niveau": "string",
  "typeApprenant": "COLLEGIEN|LYCEEN|ETUDIANT|PROFESSIONNEL|AUTRE",
  "etablissement": "string",
  "filiere": "string"
}
```
**Response :** `EleveResponse` (201 Created)

### Profil
```http
GET  /api/v1/eleves/{trackingId}       # ➜ EleveResponse
PUT  /api/v1/eleves/{trackingId}       # Body: EleveRequest ➜ EleveResponse
DELETE /api/v1/eleves/{trackingId}     # ➜ 204 (soft-delete)
```

### Liste
```http
GET /api/v1/eleves
```
| Query | Type | Default |
|-------|------|---------|
| `page` | int | 0 |
| `size` | int | 20 |

**Response :** `Page<EleveResponse>`

---

## 👪 3. Parents

### CRUD
```http
POST   /api/v1/parents                            # ➜ ParentResponse (201)
GET    /api/v1/parents/{trackingId}                # ➜ ParentResponse
PUT    /api/v1/parents/{trackingId}                # ➜ ParentResponse
DELETE /api/v1/parents/{trackingId}                # ➜ 204 (soft-delete)
```

### Liste
```http
GET /api/v1/parents                                # ➜ Page<ParentResponse>
```
| Query | Type | Default |
|-------|------|---------|
| `page` | int | 0 |
| `size` | int | 20 |

### Relations
```http
GET  /api/v1/parents/par-eleve/{eleveTrackingId}       # ➜ List<ParentResponse>
POST /api/v1/parents/{trackingId}/enfants/{eleveTrackingId}  # ➜ ParentResponse
DELETE /api/v1/parents/{trackingId}/enfants/{eleveTrackingId} # ➜ ParentResponse
```

---

## 🎯 4. Conseillers

### CRUD
```http
POST   /api/v1/conseillers                         # ➜ ConseillerResponse (201)
GET    /api/v1/conseillers/{trackingId}             # ➜ ConseillerResponse
PUT    /api/v1/conseillers/{trackingId}             # ➜ ConseillerResponse
DELETE /api/v1/conseillers/{trackingId}             # ➜ 204 (soft-delete)
```

### Liste & Disponibilité
```http
GET /api/v1/conseillers                             # ➜ Page<ConseillerResponse>
GET /api/v1/conseillers/disponibles                 # ➜ List<ConseillerResponse>
```
| Query | Type | Default |
|-------|------|---------|
| `page` | int | 0 |
| `size` | int | 20 |
| `seuil` | int | 10 (chargeTravail) |

---

## 🔧 5. Administrateurs

```http
POST   /api/v1/administrateurs                     # ➜ AdministrateurResponse (201)
GET    /api/v1/administrateurs/{trackingId}         # ➜ AdministrateurResponse
GET    /api/v1/administrateurs                      # ➜ Page<AdministrateurResponse>
PUT    /api/v1/administrateurs/{trackingId}         # ➜ AdministrateurResponse
DELETE /api/v1/administrateurs/{trackingId}         # ➜ 204 (soft-delete)
```

---

## 📝 6. Notes

### Ajouter
```http
POST /api/v1/eleves/{eleveTrackingId}/notes
```
**Body :** `NoteSaisiManuelRequest`
```json
{
  "matiere": "string",
  "note": 15.5,
  "coefficient": 2,
  "anneeScolaire": "2025-2026",
  "semestreOuTrimestre": "Trimestre 1"
}
```
**Response :** `NoteSaisiManuelResponse` (201)

### Lecture
```http
GET /api/v1/eleves/{eleveTrackingId}/notes              # ➜ List<NoteSaisiManuelResponse>
GET /api/v1/eleves/{eleveTrackingId}/notes/pagine       # ➜ Page<NoteSaisiManuelResponse>
GET /api/v1/notes/{trackingId}                          # ➜ NoteSaisiManuelResponse
```

### Modification
```http
PUT    /api/v1/notes/{trackingId}                       # ➜ NoteSaisiManuelResponse
DELETE /api/v1/notes/{trackingId}                       # ➜ 204
```

---

## 📜 7. Historique

```http
POST   /api/v1/utilisateurs/{utilisateurTrackingId}/historique       # ➜ HistoriqueResponse (201)
GET    /api/v1/historique/{trackingId}                                # ➜ HistoriqueResponse
GET    /api/v1/utilisateurs/{utilisateurTrackingId}/historique        # ➜ List<HistoriqueResponse>
GET    /api/v1/utilisateurs/{utilisateurTrackingId}/historique/pagine # ➜ Page<HistoriqueResponse>
GET    /api/v1/utilisateurs/{utilisateurTrackingId}/historique/action # ➜ List<HistoriqueResponse>
DELETE /api/v1/utilisateurs/{utilisateurTrackingId}/historique        # ➜ 204 (purge)
```
Query param `action` : filtre par type d'action (CONNEXION, TEST_RIASEC, UPLOAD_DOCUMENT...)

**Body POST :**
```json
{
  "action": "CONNEXION",
  "details": "Connexion réussie"
}
```

---

## 🔔 8. Notifications

### Envoi
```http
POST /api/v1/utilisateurs/{utilisateurTrackingId}/notifications
```
```json
{
  "titre": "Rappel RDV",
  "message": "Vous avez un RDV demain à 10h"
}
```

### Lecture
```http
GET    /api/v1/notifications/{trackingId}                           # ➜ NotificationResponse
GET    /api/v1/utilisateurs/{utilisateurTrackingId}/notifications    # ➜ List<NotificationResponse>
GET    /api/v1/utilisateurs/{utilisateurTrackingId}/notifications/pagine # ➜ Page<NotificationResponse>
GET    /api/v1/utilisateurs/{utilisateurTrackingId}/notifications/non-lues # ➜ List<NotificationResponse>
GET    /api/v1/utilisateurs/{utilisateurTrackingId}/notifications/compteur # ➜ {"nonLues": 3}
```

### Actions
```http
PATCH  /api/v1/notifications/{trackingId}/lire                       # ➜ NotificationResponse
PATCH  /api/v1/utilisateurs/{utilisateurTrackingId}/notifications/tout-lire # ➜ 204
DELETE /api/v1/notifications/{trackingId}                             # ➜ 204
```

---

## ❓ 9. Quiz

### CRUD
```http
POST   /api/v1/quiz                                  # ➜ QuizResponse (201)
GET    /api/v1/quiz/{trackingId}                     # ➜ QuizResponse
GET    /api/v1/quiz                                  # ➜ Page<QuizResponse>
PUT    /api/v1/quiz/{trackingId}                     # ➜ QuizResponse
DELETE /api/v1/quiz/{trackingId}                     # ➜ 204 (désactive)
```

**Body POST/PUT :**
```json
{
  "titre": "Quiz d'orientation",
  "description": "Découvre ton profil RIASEC",
  "estActif": true
}
```

---

## ❓ 10. Questions

```http
POST   /api/v1/quiz/{quizTrackingId}/questions                     # ➜ QuestionResponse (201)
GET    /api/v1/quiz/{quizTrackingId}/questions                      # ➜ List<QuestionResponse>
GET    /api/v1/questions/{trackingId}                               # ➜ QuestionResponse
PUT    /api/v1/questions/{trackingId}                               # ➜ QuestionResponse
DELETE /api/v1/questions/{trackingId}                               # ➜ 204
```

---

## ✅ 11. Réponses

```http
POST   /api/v1/questions/{questionTrackingId}/reponses              # ➜ ReponseResponse (201)
GET    /api/v1/questions/{questionTrackingId}/reponses               # ➜ List<ReponseResponse>
GET    /api/v1/reponses/{trackingId}                                 # ➜ ReponseResponse
PUT    /api/v1/reponses/{trackingId}                                 # ➜ ReponseResponse
DELETE /api/v1/reponses/{trackingId}                                 # ➜ 204
```

**Body POST/PUT :**
```json
{
  "texteReponse": "J'aime résoudre des problèmes",
  "categoriePoint": "R",
  "points": 1
}
```
`categoriePoint` : `R` (Réaliste), `I` (Investigateur), `A` (Artistique), `S` (Social), `E` (Entreprenant), `C` (Conventionnel)

---

## 📊 12. Résultats Diagnostic

```http
POST   /api/v1/resultats-diagnostic                                 # ➜ ResultatDiagnosticResponse (201)
GET    /api/v1/resultats-diagnostic/{trackingId}                     # ➜ ResultatDiagnosticResponse
GET    /api/v1/eleves/{eleveTrackingId}/resultats-diagnostic         # ➜ Page<ResultatDiagnosticResponse>
GET    /api/v1/eleves/{eleveTrackingId}/resultats-diagnostic/dernier # ➜ ResultatDiagnosticResponse | 204
DELETE /api/v1/resultats-diagnostic/{trackingId}                     # ➜ 204
```

**Body POST :**
```json
{
  "eleveTrackingId": "uuid",
  "quizTrackingId": "uuid",
  "scoreFinal": 85,
  "recommandation": "string",
  "profilDecouvert": "R-I-A"
}
```

---

## 📈 13. Score Matrices

```http
POST   /api/v1/score-matrices                        # ➜ ScoreMatriceResponse (201)
GET    /api/v1/score-matrices                         # ➜ Page<ScoreMatriceResponse>
GET    /api/v1/score-matrices/{trackingId}            # ➜ ScoreMatriceResponse
PUT    /api/v1/score-matrices/{trackingId}            # ➜ ScoreMatriceResponse
DELETE /api/v1/score-matrices/{trackingId}            # ➜ 204
```

---

## 🚧 14. Seuils d'Admission

```http
POST   /api/v1/seuils-admission                                       # ➜ SeuilAdmissionResponse (201)
GET    /api/v1/seuils-admission/{trackingId}                           # ➜ SeuilAdmissionResponse
GET    /api/v1/filieres/{filiereTrackingId}/seuils-admission           # ➜ List<SeuilAdmissionResponse>
PUT    /api/v1/seuils-admission/{trackingId}                           # ➜ SeuilAdmissionResponse
DELETE /api/v1/seuils-admission/{trackingId}                           # ➜ 204
```

---

## 💼 15. Fiches Métiers

### CRUD
```http
POST   /api/v1/bibliotheque/metiers                                    # ➜ FicheMetierResponse (201)
POST   /api/v1/bibliotheque/metiers/avec-medias                         # ➜ Multipart + JSON
PUT    /api/v1/bibliotheque/metiers/{trackingId}/medias                 # ➜ Remplacer médias
POST   /api/v1/bibliotheque/metiers/{trackingId}/medias                 # ➜ Ajouter médias
GET    /api/v1/bibliotheque/metiers/{trackingId}                        # ➜ FicheMetierResponse
PUT    /api/v1/bibliotheque/metiers/{trackingId}                        # ➜ FicheMetierResponse
DELETE /api/v1/bibliotheque/metiers/{trackingId}                        # ➜ 204
```

### Liste & Recherche
```http
GET    /api/v1/bibliotheque/metiers                                     # ➜ Page<FicheMetierResponse>
GET    /api/v1/bibliotheque/metiers/public                              # ➜ Publiées seulement
GET    /api/v1/bibliotheque/metiers/non-public                          # ➜ Non publiées
GET    /api/v1/bibliotheque/metiers/recherche?motCle=...                # ➜ Recherche
GET    /api/v1/bibliotheque/metiers/secteur/{secteur}                   # ➜ Par secteur
GET    /api/v1/bibliotheque/metiers/secteurs                            # ➜ Tous les secteurs (List<String>)
```

---

## 📚 16. Fiches Séries

```http
POST   /api/v1/bibliotheque/series                                      # ➜ FicheSerieResponse (201)
POST   /api/v1/bibliotheque/series/avec-medias
GET    /api/v1/bibliotheque/series/{trackingId}                         # ➜ FicheSerieResponse
GET    /api/v1/bibliotheque/series                                      # ➜ Page<FicheSerieResponse>
GET    /api/v1/bibliotheque/series/public
GET    /api/v1/bibliotheque/series/non-public
GET    /api/v1/bibliotheque/series/recherche?motCle=...
PUT    /api/v1/bibliotheque/series/{trackingId}
DELETE /api/v1/bibliotheque/series/{trackingId}
PUT    /api/v1/bibliotheque/series/{trackingId}/medias
POST   /api/v1/bibliotheque/series/{trackingId}/medias
```

---

## 🎓 17. Fiches Filières

```http
POST   /api/v1/bibliotheque/filieres                                    # ➜ FicheFiliereResponse (201)
POST   /api/v1/bibliotheque/filieres/avec-medias
GET    /api/v1/bibliotheque/filieres/{trackingId}                       # ➜ FicheFiliereResponse
GET    /api/v1/bibliotheque/filieres                                    # ➜ Page<FicheFiliereResponse>
GET    /api/v1/bibliotheque/filieres/public
GET    /api/v1/bibliotheque/filieres/non-public
GET    /api/v1/bibliotheque/filieres/recherche?motCle=...
GET    /api/v1/bibliotheque/filieres/domaine/{domaine}
GET    /api/v1/bibliotheque/filieres/domaines                           # ➜ List<String>
PUT    /api/v1/bibliotheque/filieres/{trackingId}
DELETE /api/v1/bibliotheque/filieres/{trackingId}
PUT    /api/v1/bibliotheque/filieres/{trackingId}/medias
POST   /api/v1/bibliotheque/filieres/{trackingId}/medias
```

---

## 🏫 18. Fiches Établissements

```http
POST   /api/v1/bibliotheque/etablissements                              # ➜ FicheEtablissementResponse (201)
POST   /api/v1/bibliotheque/etablissements/avec-medias
GET    /api/v1/bibliotheque/etablissements/{trackingId}                 # ➜ FicheEtablissementResponse
GET    /api/v1/bibliotheque/etablissements                              # ➜ Page<FicheEtablissementResponse>
GET    /api/v1/bibliotheque/etablissements/public
GET    /api/v1/bibliotheque/etablissements/non-public
GET    /api/v1/bibliotheque/etablissements/recherche?motCle=...
GET    /api/v1/bibliotheque/etablissements/ville/{ville}
GET    /api/v1/bibliotheque/etablissements/type/{type}
GET    /api/v1/bibliotheque/etablissements/villes                       # ➜ List<String>
PUT    /api/v1/bibliotheque/etablissements/{trackingId}
DELETE /api/v1/bibliotheque/etablissements/{trackingId}
PUT    /api/v1/bibliotheque/etablissements/{trackingId}/medias
POST   /api/v1/bibliotheque/etablissements/{trackingId}/medias
```

Types d'établissement : `UNIVERSITE`, `ECOLE_SUPERIEURE`, `LYCEE`, `COLLEGE`, `CENTRE_FORMATION_PROFESSIONNELLE`, `GRANDE_ECOLE`, `AUTRE`

---

## ⭐ 19. Favoris

```http
POST   /api/v1/bibliotheque/favoris                                     # ➜ FavoriResponse (201)
GET    /api/v1/bibliotheque/favoris/{trackingId}                        # ➜ FavoriResponse
GET    /api/v1/bibliotheque/favoris/utilisateur/{utilisateurTrackingId}  # ➜ Page<FavoriResponse>
DELETE /api/v1/bibliotheque/favoris/{trackingId}                        # ➜ 204
```

**Body POST :**
```json
{
  "utilisateurTrackingId": "uuid",
  "ficheTrackingId": "uuid",
  "notePersonnelle": "Ma série préférée"
}
```

---

## ❓ 20. FAQ

### CRUD
```http
POST   /api/v1/bibliotheque/faq                                         # ➜ EntreeFAQResponse (201)
GET    /api/v1/bibliotheque/faq/{trackingId}                            # ➜ EntreeFAQResponse
PUT    /api/v1/bibliotheque/faq/{trackingId}                            # ➜ EntreeFAQResponse
DELETE /api/v1/bibliotheque/faq/{trackingId}                            # ➜ 204
```

### Consultation
```http
GET /api/v1/bibliotheque/faq                                            # ➜ Page<EntreeFAQResponse>
GET /api/v1/bibliotheque/faq/categorie/{categorie}                      # ➜ List<EntreeFAQResponse>
GET /api/v1/bibliotheque/faq/categories                                 # ➜ List<String>
```

### Recherche IA (Gemini RAG)
```http
GET /api/v1/bibliotheque/faq/recherche-ia?question=...&limite=5
```
Recherche sémantique : embedding de la question → pgvector similarity → contexte → réponse générée par Gemini

---

## 🔍 21. Recherche & Analytics

### Recherche sémantique globale
```http
GET /api/v1/bibliotheque/recherche-fiche-ia/globale?phrase=...&limite=10
```
Recherche vectorielle multi-types (Séries, Filières, Métiers, Établissements) via Gemini + pgvector.

### Tendances
```http
GET /api/v1/bibliotheque/analytics/tendances?limite=10
```
Fiches les plus consultées (7 jours).

### Consultations récentes
```http
GET /api/v1/bibliotheque/analytics/recentes/{utilisateurTrackingId}?limite=10
```

### Fiches similaires
```http
GET /api/v1/bibliotheque/analytics/similaires/{trackingId}?limite=5
```
Similarité cosinus via pgvector (exclut la fiche source).

---

## 🛠️ 22. Admin Analytics

```http
GET /api/v1/admin/bibliotheque/recherches-orphelines/frequentes?limite=20
```
Termes de recherche sans résultat les plus fréquents → `Map<String, Long>`

---

## 💬 23. Messages

### Envoi
```http
POST /api/v1/utilisateurs/{expediteurTrackingId}/messages
```
```json
{
  "destinataireTrackingId": "uuid",
  "contenu": "Bonjour, j'aimerais un conseil..."
}
```
**Response :** `MessageResponse` (201)

### Conversation
```http
GET /api/v1/messages/conversation?user1={uuid}&user2={uuid}
```
**Response :** `List<MessageResponse>` (trié par date)

### Boîte de réception
```http
GET  /api/v1/utilisateurs/{destinataireTrackingId}/messages/recus      # ➜ Page<MessageResponse>
GET  /api/v1/utilisateurs/{expediteurTrackingId}/messages/envoyes      # ➜ Page<MessageResponse>
GET  /api/v1/utilisateurs/{destinataireTrackingId}/messages/non-lus/compteur # ➜ {"nonLus": 3}
```

### Actions
```http
PATCH /api/v1/messages/conversation/lire?expediteur={uuid}&destinataire={uuid} # ➜ 204
DELETE /api/v1/messages/{trackingId}                                             # ➜ 204
```

---

## 📅 24. Rendez-Vous

### Création
```http
POST /api/v1/rendez-vous
```
```json
{
  "eleveTrackingId": "uuid",
  "conseillerTrackingId": "uuid",
  "dateHeurePrevue": "2026-06-01T10:00:00",
  "lienVisio": "https://meet.google.com/...",
  "notes": "Orientation filière informatique"
}
```
**Response :** `RendezVousResponse` (201), statut par défaut : `PLANIFIE`

### Consultation
```http
GET /api/v1/rendez-vous/{trackingId}                                # ➜ RendezVousResponse
GET /api/v1/rendez-vous/eleve/{eleveTrackingId}                     # ➜ List<RendezVousResponse>
GET /api/v1/rendez-vous/eleve/{eleveTrackingId}/pagine              # ➜ Page<RendezVousResponse>
GET /api/v1/rendez-vous/eleve/{eleveTrackingId}/statut/{statut}     # ➜ Filtré par statut
GET /api/v1/rendez-vous/conseiller/{conseillerTrackingId}           # ➜ List<RendezVousResponse>
GET /api/v1/rendez-vous/conseiller/{conseillerTrackingId}/pagine    # ➜ Page<RendezVousResponse>
GET /api/v1/rendez-vous/conseiller/{conseillerTrackingId}/statut/{statut}
```

### Actions
```http
PUT    /api/v1/rendez-vous/{trackingId}                             # ➜ Modifier
PATCH  /api/v1/rendez-vous/{trackingId}/terminer                    # ➜ Statut = TERMINE
PATCH  /api/v1/rendez-vous/{trackingId}/annuler                     # ➜ Statut = ANNULE
```
Statuts : `PLANIFIE`, `TERMINE`, `ANNULE`

---

## 🕐 25. Disponibilités

### Ajout
```http
POST /api/v1/conseillers/{conseillerTrackingId}/disponibilites
```
```json
{
  "jourSemaine": 1,
  "heureDebut": "09:00",
  "heureFin": "12:00"
}
```
`jourSemaine` : 1 = Lundi ... 7 = Dimanche (norme ISO)

### Consultation
```http
GET /api/v1/disponibilites/{trackingId}                                    # ➜ DisponibiliteResponse
GET /api/v1/conseillers/{conseillerTrackingId}/disponibilites              # ➜ List<DisponibiliteResponse>
GET /api/v1/conseillers/{conseillerTrackingId}/disponibilites/pagine       # ➜ Page<DisponibiliteResponse>
GET /api/v1/conseillers/{conseillerTrackingId}/disponibilites/jour/{jourSemaine}
```

### Modification
```http
PUT    /api/v1/disponibilites/{trackingId}                                 # ➜ DisponibiliteResponse
DELETE /api/v1/disponibilites/{trackingId}                                  # ➜ 204
```

---

## 📊 Résumé

| Module | Nb endpoints | Statut |
|--------|:-----------:|--------|
| Fichiers (MinIO) | 12 | ✅ |
| Élèves | 5 | ✅ |
| Parents | 8 | ✅ |
| Conseillers | 5 | ✅ |
| Administrateurs | 5 | ✅ |
| Notes | 6 | ✅ |
| Historique | 7 | ✅ |
| Notifications | 10 | ✅ |
| Quiz | 5 | ✅ |
| Questions | 5 | ✅ |
| Réponses | 5 | ✅ |
| Résultats Diagnostic | 6 | ✅ |
| Score Matrices | 5 | ✅ |
| Seuils Admission | 5 | ✅ |
| Fiches Métiers | 12 | ✅ |
| Fiches Séries | 10 | ✅ |
| Fiches Filières | 12 | ✅ |
| Fiches Établissements | 13 | ✅ |
| Favoris | 4 | ✅ |
| FAQ | 7 | ✅ |
| Recherche & Analytics | 5 | ✅ |
| Admin Analytics | 1 | ✅ |
| Messages | 8 | ✅ |
| Rendez-Vous | 12 | ✅ |
| Disponibilités | 7 | ✅ |
| **Total** | **~179** | **✅ 100%** |
