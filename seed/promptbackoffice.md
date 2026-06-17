# PROMPT OPENCODE — Backoffice Activ Education (Togo) v2

## CONTEXTE GÉNÉRAL

Tu dois construire le **backoffice web complet** de la plateforme **Activ Education**, une application
d'orientation scolaire et professionnelle pour le Togo. Le backend REST est développé en Spring Boot.
Le frontend mobile est en cours. Ta tâche : créer uniquement le **backoffice web (admin)**.

> ⚠️ **Sécurité API :** Aucune authentification JWT côté backend pour l'instant. Tous les endpoints
> sont publics. Implémente quand même un écran de login côté front avec un accès par rôle stocké en
> `localStorage` (pseudo-auth), pour préparer la future intégration JWT.

**Base URL API :** `http://localhost:8080`
**Swagger :** `http://localhost:8080/swagger-ui.html`

---

## STACK TECHNIQUE

```
React 18 + TypeScript
Vite (bundler)
Tailwind CSS
shadcn/ui (composants)
React Router v6
Axios (appels API)
Recharts (graphiques)
date-fns + fr locale (dates relatives)
React Query / TanStack Query (cache & fetching)
Zustand (state global : utilisateur connecté, rôle)
```

Fichier `.env` :
```
VITE_API_BASE_URL=http://localhost:8080
```

Fichier `src/lib/api.ts` :
```typescript
import axios from 'axios'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
})

export default api
```

---

## DESIGN SYSTEM

```
Bleu principal (sidebar, boutons) : #3730E8
Orange accent (badges, boutons secondaires) : #F59E0B
Vert succès : #10B981
Rouge danger : #EF4444
Gris texte principal : #111827
Gris texte secondaire : #6B7280
Fond page : #F9FAFB
Fond cartes : #FFFFFF
Border radius cartes : 12px
Police : Inter (Google Fonts)
Sidebar : 240px, fond #3730E8, texte blanc
Header : fond blanc, border-bottom 1px #E5E7EB
```

---

## ARCHITECTURE RÔLES & ROUTING

3 espaces distincts dans React Router :

```
/login                         → Page de connexion (pseudo-auth)
/conseiller/*                  → Espace Conseiller
/admin/*                       → Espace Admin
/superadmin/*                  → Espace Super Admin (étend Admin)
```

**Pseudo-auth :**
- Page login avec champs Email + Mot de passe + sélecteur de Rôle (Conseiller / Admin / Super Admin)
- Stocke `{ role, trackingId, nom, email }` dans `localStorage`
- `<ProtectedRoute>` redirige vers `/login` si non connecté
- Zustand store `useAuthStore` expose `user`, `role`, `logout()`
- Chaque espace charge `trackingId` depuis le store pour tous ses appels API

---

## MODULE 1 — ESPACE CONSEILLER (`/conseiller/*`)

### Sidebar
- Logo Activ Education
- Navigation : Tableau de bord, Tickets (= Messages), Rendez-vous, FAQ (lecture), Utilisateurs (= Élèves), Mon Profil, Statistiques
- Bas sidebar : toggle Disponibilité + avatar + nom + "Déconnexion"

> **Note :** Le backend n'a pas de module "Tickets". Les tickets sont simulés via les **Messages**
> (`/api/v1/messages`). Un "ticket" = fil de conversation entre un élève et un conseiller.

---

### 1.1 Dashboard Conseiller (`/conseiller/dashboard`)

**4 KPI cards :**

| Carte | Endpoint | Donnée affichée |
|-------|----------|-----------------|
| Messages non lus | `GET /api/v1/utilisateurs/{conseillerTrackingId}/messages/non-lus/compteur` | `nonLus` |
| Rendez-vous aujourd'hui | `GET /api/v1/rendez-vous/conseiller/{conseillerTrackingId}` filtrer par date du jour | count |
| Élèves suivis | `GET /api/v1/eleves?size=1` | `totalElements` de la page |
| Notifications non lues | `GET /api/v1/utilisateurs/{conseillerTrackingId}/notifications/compteur` | `nonLues` |

**Tableau "Messages récents" :**
- `GET /api/v1/utilisateurs/{conseillerTrackingId}/messages/recus?page=0&size=5`
- Colonnes : Expéditeur, Contenu (extrait 60 chars), Date (date-fns `formatDistanceToNow`)
- Badge "Non lu" si `lu = false`
- Clic → `/conseiller/messages/{expediteurTrackingId}`

**Agenda du jour :**
- `GET /api/v1/rendez-vous/conseiller/{conseillerTrackingId}`
- Filtrer côté client sur `dateHeurePrevue` = aujourd'hui, statut `PLANIFIE`
- Afficher heure + nom élève + `lienVisio` (bouton "Rejoindre" si lien présent)
- Bouton "Terminer" → `PATCH /api/v1/rendez-vous/{trackingId}/terminer`
- Bouton "Annuler" → `PATCH /api/v1/rendez-vous/{trackingId}/annuler`

**Notifications récentes :**
- `GET /api/v1/utilisateurs/{conseillerTrackingId}/notifications/non-lues`
- Afficher les 3 premières avec titre + message + date
- Bouton "Marquer tout lu" → `PATCH /api/v1/utilisateurs/{conseillerTrackingId}/notifications/tout-lire`

---

### 1.2 Messages / Tickets (`/conseiller/messages`)

**Liste des conversations :**
- `GET /api/v1/utilisateurs/{conseillerTrackingId}/messages/recus?page=0&size=20`
- Dédupliquer par `expediteurTrackingId` pour avoir une ligne par élève
- Afficher : avatar initiales, nom expéditeur, extrait dernier message, date, badge "non lu"
- Clic → ouvre la conversation

**Conversation (`/conseiller/messages/:eleveTrackingId`) :**

Layout 2 colonnes :

**Colonne gauche — Profil élève :**
- `GET /api/v1/eleves/{eleveTrackingId}`
  - Afficher : nom, prénom, niveau, typeApprenant, établissement, filière
- `GET /api/v1/eleves/{eleveTrackingId}/notes`
  - Tableau Matière / Note / Coefficient — couleur note : ≥15 bleu, 10-14 noir, <10 rouge
- `GET /api/v1/eleves/{eleveTrackingId}/resultats-diagnostic/dernier`
  - Afficher profil RIASEC découvert + recommandation
- `GET /api/v1/utilisateurs/{eleveTrackingId}/historique?action=UPLOAD_DOCUMENT`
  - Liste des documents uploadés (afficher comme liens téléchargeables)

**Colonne droite — Fil de messages :**
- `GET /api/v1/messages/conversation?user1={conseillerTrackingId}&user2={eleveTrackingId}`
- Bulles de chat (messages du conseiller = droite / élève = gauche)
- Marquer lu : `PATCH /api/v1/messages/conversation/lire?expediteur={eleveTrackingId}&destinataire={conseillerTrackingId}`
- Zone de réponse : textarea + bouton "Envoyer"
- `POST /api/v1/utilisateurs/{conseillerTrackingId}/messages`
  ```json
  { "destinataireTrackingId": "{eleveTrackingId}", "contenu": "..." }
  ```

---

### 1.3 Rendez-Vous (`/conseiller/rendez-vous`)

**Vue calendrier semaine :**
- `GET /api/v1/rendez-vous/conseiller/{conseillerTrackingId}`
- Afficher les RDV dans une grille 7 jours × heures (8h→20h)
- Blocs colorés : `PLANIFIE` = bleu, `TERMINE` = vert, `ANNULE` = rouge/gris barré

**Panneau latéral Disponibilités :**
- `GET /api/v1/conseillers/{conseillerTrackingId}/disponibilites`
- Afficher créneaux existants (jour + heureDebut→heureFin)
- Bouton "Supprimer créneau" → `DELETE /api/v1/disponibilites/{trackingId}`
- Formulaire "Ajouter créneau" :
  - Select jour (1=Lun → 7=Dim), TimePicker début/fin
  - `POST /api/v1/conseillers/{conseillerTrackingId}/disponibilites`
  ```json
  { "jourSemaine": 1, "heureDebut": "09:00", "heureFin": "12:00" }
  ```

**Modal détail RDV (clic sur un bloc) :**
- `GET /api/v1/rendez-vous/{trackingId}`
- Afficher : élève (charger via `GET /api/v1/eleves/{eleveTrackingId}`), date, notes, lienVisio
- Bouton "Rejoindre" (ouvre `lienVisio` dans nouvel onglet)
- Bouton "Dossier" → `/conseiller/messages/{eleveTrackingId}`
- Bouton "Terminer" → `PATCH /api/v1/rendez-vous/{trackingId}/terminer`
- Bouton "Annuler" → `PATCH /api/v1/rendez-vous/{trackingId}/annuler`
- Formulaire édition → `PUT /api/v1/rendez-vous/{trackingId}`

**Bouton "Nouveau RDV" :**
- Modal avec select élève (chercher dans `GET /api/v1/eleves?page=0&size=50`), date/heure, lien visio, notes
- `POST /api/v1/rendez-vous`
```json
{
  "eleveTrackingId": "uuid",
  "conseillerTrackingId": "uuid",
  "dateHeurePrevue": "2026-06-01T10:00:00",
  "lienVisio": "https://meet.google.com/...",
  "notes": "..."
}
```

---

### 1.4 Élèves / Utilisateurs (`/conseiller/eleves`)

**Liste paginée :**
- `GET /api/v1/eleves?page=0&size=20`
- Tableau : Nom, Prénom, Niveau, Type (badge), Établissement, Filière, Actions
- Pagination React Query (prefetch page suivante)
- Clic sur ligne → `/conseiller/eleves/{trackingId}`

**Fiche élève (`/conseiller/eleves/:trackingId`) :**
Combiner les appels :
- `GET /api/v1/eleves/{trackingId}` — infos de base
- `GET /api/v1/eleves/{trackingId}/notes` — notes
- `GET /api/v1/eleves/{trackingId}/resultats-diagnostic/dernier` — diagnostic
- `GET /api/v1/rendez-vous/eleve/{trackingId}` — historique RDV
- `GET /api/v1/messages/conversation?user1={conseillerTrackingId}&user2={trackingId}` — échanges

---

### 1.5 FAQ (lecture seule) (`/conseiller/faq`)

- `GET /api/v1/bibliotheque/faq/categories` → afficher onglets par catégorie
- `GET /api/v1/bibliotheque/faq/categorie/{categorie}` → lister les Q/R
- Barre de recherche IA : `GET /api/v1/bibliotheque/faq/recherche-ia?question=...&limite=5`

---

## MODULE 2 — ESPACE ADMIN (`/admin/*`)

### Sidebar Admin
```
Activ Education — ADMINISTRATION
```
- Tableau de bord, Étudiants, Cours (Filières), Enseignants, Conseillers, Quiz & Diagnostic,
  Seuils d'Admission, FAQ (modération), Statistiques, Paramètres
- Bouton bas (orange) : "⊕ NOUVEAU RAPPORT"

---

### 2.1 Dashboard Admin (`/admin/dashboard`)

**6 KPI cards — tout charger en parallèle (Promise.all) :**

| Carte | Endpoint | Donnée |
|-------|----------|--------|
| Utilisateurs | `GET /api/v1/eleves?size=1` | `page.totalElements` |
| Quiz | `GET /api/v1/quiz?size=1` | `page.totalElements` |
| Fiches | `GET /api/v1/bibliotheque/filieres?size=1` | `page.totalElements` |
| Conseillers | `GET /api/v1/conseillers?size=1` / disponibles : `GET /api/v1/conseillers/disponibles` | total / nb online |
| FAQ | `GET /api/v1/bibliotheque/faq?size=1` | `page.totalElements` |
| Tendances | `GET /api/v1/bibliotheque/analytics/tendances?limite=5` | top fiches consultées |

**Graphique "Activité Hebdomadaire" :**
- Données depuis `GET /api/v1/bibliotheque/analytics/tendances?limite=50`
- Recharts BarChart, axe X = jours de la semaine (simulé côté front si API sans dates)

**Répartition des profils :**
- `GET /api/v1/eleves?size=200` → grouper par `typeApprenant` côté client
- Recharts PieChart : COLLEGIEN, LYCEEN, ETUDIANT, PROFESSIONNEL, AUTRE

**Tableau "Dernières fiches modifiées" :**
- `GET /api/v1/bibliotheque/filieres?size=10` — fiches filières récentes
- Colonnes : Titre, Domaine, Statut (isPublic → PUBLIÉ / non → BROUILLON), Actions (⋮)

---

### 2.2 Gestion des Élèves (`/admin/etudiants`)

**Liste :**
- `GET /api/v1/eleves?page=0&size=20`
- Filtres : typeApprenant, recherche texte (client-side)
- Tableau : Avatar initiales, Nom, Prénom, Email, Niveau, Type, Établissement, Actions
- Actions : Voir, Modifier, Supprimer (`DELETE /api/v1/eleves/{trackingId}`)

**Créer élève (modal) :**
- `POST /api/v1/eleves`
```json
{
  "nom": "", "prenom": "", "email": "", "telephone": "",
  "motDePasse": "", "niveau": "", "typeApprenant": "LYCEEN",
  "etablissement": "", "filiere": ""
}
```

**Éditer élève (modal) :**
- `GET /api/v1/eleves/{trackingId}` → pré-remplir formulaire
- `PUT /api/v1/eleves/{trackingId}`

---

### 2.3 Gestion des Filières (`/admin/cours`)

**Liste avec filtres :**
- `GET /api/v1/bibliotheque/filieres?page=0&size=20`
- `GET /api/v1/bibliotheque/filieres/domaines` → alimenter le filtre "Domaine"
- Filtres : domaine (dropdown), statut public/non-public (dropdown), recherche → `GET /api/v1/bibliotheque/filieres/recherche?motCle=...`
- Boutons filtre statut :
  - Tous : `GET /api/v1/bibliotheque/filieres`
  - Publiées : `GET /api/v1/bibliotheque/filieres/public`
  - Non publiées : `GET /api/v1/bibliotheque/filieres/non-public`

**Tableau des filières :**
- Colonnes : Titre, Domaine, Statut (`isPublic` → badge PUBLIÉ/BROUILLON), Actions
- Clic sur une ligne → panneau latéral droit (slide-in)

**Panneau latéral "Édition de fiche filière" :**
- `GET /api/v1/bibliotheque/filieres/{trackingId}` → charger les données
- Onglets : En bref | Médias | Contenu | Liens
- **En bref :** champs titre, domaine, description, durée, niveau, compétences clés (tags)
- Bouton "Enregistrer" → `PUT /api/v1/bibliotheque/filieres/{trackingId}`

**Bouton "+ Nouvelle filière" :**
- `POST /api/v1/bibliotheque/filieres`
- Upload image couverture → `POST /files/upload/IMAGE` → récupérer URL puis l'inclure dans la fiche

**Seuils d'admission liés :**
- `GET /api/v1/filieres/{filiereTrackingId}/seuils-admission`
- Afficher dans un sous-onglet de la fiche filière
- Formulaire ajout seuil → `POST /api/v1/seuils-admission`
- Modifier seuil → `PUT /api/v1/seuils-admission/{trackingId}`
- Supprimer → `DELETE /api/v1/seuils-admission/{trackingId}`

---

### 2.4 Fiches Métiers (`/admin/metiers`)

Même structure que filières mais avec :
- `GET /api/v1/bibliotheque/metiers` / `/public` / `/non-public` / `/recherche?motCle=`
- `GET /api/v1/bibliotheque/metiers/secteurs` → filtre par secteur
- `GET /api/v1/bibliotheque/metiers/secteur/{secteur}`
- CRUD : `POST`, `PUT`, `DELETE /api/v1/bibliotheque/metiers/{trackingId}`
- Upload médias : `POST /api/v1/bibliotheque/metiers/{trackingId}/medias`

---

### 2.5 Fiches Établissements (`/admin/etablissements`)

- `GET /api/v1/bibliotheque/etablissements` / `/public` / `/non-public` / `/recherche?motCle=`
- `GET /api/v1/bibliotheque/etablissements/villes` → filtre par ville
- `GET /api/v1/bibliotheque/etablissements/ville/{ville}`
- `GET /api/v1/bibliotheque/etablissements/type/{type}` — types : UNIVERSITE, ECOLE_SUPERIEURE, LYCEE, COLLEGE, CENTRE_FORMATION_PROFESSIONNELLE, GRANDE_ECOLE, AUTRE
- CRUD : `POST`, `PUT`, `DELETE /api/v1/bibliotheque/etablissements/{trackingId}`

---

### 2.6 Quiz & Diagnostic (`/admin/quiz`)

**Liste des quiz :**
- `GET /api/v1/quiz?page=0&size=20`
- Tableau : Titre, Description, Actif (toggle), Actions (Éditer, Désactiver, Supprimer)
- Toggle actif → `PUT /api/v1/quiz/{trackingId}` avec `{ "estActif": true/false }`
- Supprimer → `DELETE /api/v1/quiz/{trackingId}`
- Bouton "+ Nouveau Quiz" → `POST /api/v1/quiz`

**Éditeur de quiz (`/admin/quiz/:quizTrackingId/edit`) :**

Layout 3 colonnes :

**Colonne gauche — Arbre des questions :**
- `GET /api/v1/quiz/{quizTrackingId}/questions`
- Liste cliquable des questions (numérotées)
- Bouton ⊕ → modal "Ajouter une question"
- Drag & drop pour réordonner (optionnel)

**Colonne centrale — Édition d'une question :**
- `GET /api/v1/questions/{questionTrackingId}` → charger la question sélectionnée
- Champ : intitulé de la question
- Type de réponse : select (choix multiple / unique / texte libre)
- Limite de sélection : input number
- **Réponses :**
  - `GET /api/v1/questions/{questionTrackingId}/reponses` → liste
  - Chaque réponse : texteReponse + categoriePoint (R/I/A/S/E/C) + points
  - Modifier → `PUT /api/v1/reponses/{trackingId}`
  - Supprimer → `DELETE /api/v1/reponses/{trackingId}`
  - Ajouter → `POST /api/v1/questions/{questionTrackingId}/reponses`
  ```json
  { "texteReponse": "...", "categoriePoint": "R", "points": 1 }
  ```
- Modifier question → `PUT /api/v1/questions/{questionTrackingId}`
- Supprimer question → `DELETE /api/v1/questions/{questionTrackingId}`

**Colonne droite — Score Matrices :**
- `GET /api/v1/score-matrices?page=0&size=50` → filtrer par question côté client
- Afficher les matrices de scoring existantes : filière associée + points
- Formulaire "Relier une filière" → `POST /api/v1/score-matrices`
- Modifier → `PUT /api/v1/score-matrices/{trackingId}`
- Supprimer → `DELETE /api/v1/score-matrices/{trackingId}`

---

### 2.7 Seuils d'Admission (`/admin/seuils`)

**Tableau global :**
- `GET /api/v1/bibliotheque/filieres?size=100` → récupérer toutes les filières
- Pour chaque filière, charger `GET /api/v1/filieres/{filiereTrackingId}/seuils-admission`
- (utiliser React Query + Promise.all pour paralléliser)
- Afficher : Filière, Note minimale, Seuil actif (toggle), Actions

**Modal "Éditer le seuil" :**
- Champ note minimale `/20`
- Select type : PUBLIC / VARIABLE / CONCOURS (mapper sur un champ `typeAdmission`)
- `PUT /api/v1/seuils-admission/{trackingId}`

**Stats résumées (bas de page) :**
- Calculer côté client : moyenne des notes minimales, total places (si dispo dans la réponse)

---

### 2.8 Gestion des Conseillers (`/admin/conseillers`)

**Liste :**
- `GET /api/v1/conseillers?page=0&size=20`
- `GET /api/v1/conseillers/disponibles` → pour badge "en ligne"
- Filtres onglets : Tous | Disponibles | Occupés | Hors ligne (basé sur chargeTravail)
- Grille de cartes (3 colonnes) : photo (ou initiales), nom, spécialité, charge travail (barre %), sessions

**Créer conseiller :**
- `POST /api/v1/conseillers`

**Fiche conseiller (`/admin/conseillers/:trackingId`) :**
- `GET /api/v1/conseillers/{trackingId}`
- `GET /api/v1/conseillers/{trackingId}/disponibilites`
- `GET /api/v1/rendez-vous/conseiller/{trackingId}`
- Modifier → `PUT /api/v1/conseillers/{trackingId}`
- Supprimer → `DELETE /api/v1/conseillers/{trackingId}`

---

### 2.9 Modération FAQ (`/admin/faq`)

**Onglets :** Toutes | Par catégorie

**Liste FAQ :**
- `GET /api/v1/bibliotheque/faq?page=0&size=20`
- `GET /api/v1/bibliotheque/faq/categories` → onglets dynamiques
- `GET /api/v1/bibliotheque/faq/categorie/{categorie}` → filtrer

**Créer une entrée FAQ (modal) :**
- `POST /api/v1/bibliotheque/faq`
- Champs : question, réponse, catégorie (select depuis `/categories`)

**Éditer FAQ (modal) :**
- `GET /api/v1/bibliotheque/faq/{trackingId}` → pré-remplir
- `PUT /api/v1/bibliotheque/faq/{trackingId}`

**Supprimer :**
- `DELETE /api/v1/bibliotheque/faq/{trackingId}`

**Recherche IA :**
- Input texte → `GET /api/v1/bibliotheque/faq/recherche-ia?question=...&limite=5`
- Afficher résultats avec score de pertinence

**KPI "Utilité Globale" :**
- `GET /api/v1/admin/bibliotheque/recherches-orphelines/frequentes?limite=10`
- Afficher les termes de recherche sans résultat → aide à identifier les FAQ manquantes

---

### 2.10 Statistiques (`/admin/statistiques`)

**KPI cards :**
- Élèves : `GET /api/v1/eleves?size=1` → `totalElements`
- Quiz complétés : `GET /api/v1/resultats-diagnostic` (si endpoint existe) ou `GET /api/v1/quiz?size=1`
- Analyses IA : `GET /api/v1/bibliotheque/analytics/tendances?limite=1` (utiliser comme proxy)
- Tendances consultations : `GET /api/v1/bibliotheque/analytics/tendances?limite=10`

**Graphique "Parcours Favoris" :**
- `GET /api/v1/bibliotheque/analytics/tendances?limite=10`
- BarChart horizontal Recharts : titre fiche → nb consultations

**Top 10 Filières :**
- `GET /api/v1/bibliotheque/filieres?size=10` — afficher avec nb favoris si dispo
- `GET /api/v1/bibliotheque/analytics/tendances?limite=10`

**Recherches orphelines (insights) :**
- `GET /api/v1/admin/bibliotheque/recherches-orphelines/frequentes?limite=20`
- Tableau : terme de recherche → nb occurrences → bouton "Créer FAQ"

**Rapports récents :**
- `GET /api/v1/utilisateurs/{adminTrackingId}/historique?page=0&size=10`
- Afficher les dernières actions admin

---

### 2.11 Fiches Séries (`/admin/series`)

Même structure que filières :
- `GET /api/v1/bibliotheque/series` / `/public` / `/non-public` / `/recherche?motCle=`
- CRUD + upload médias : `POST /api/v1/bibliotheque/series/{trackingId}/medias`

---

## MODULE 3 — ESPACE SUPER ADMIN (`/superadmin/*`)

Hérite de tout l'espace Admin et ajoute les pages suivantes.

### 3.1 Gestion des Administrateurs (`/superadmin/administrateurs`)

- `GET /api/v1/administrateurs?page=0&size=20`
- Tableau : Nom, Email, Actions
- Créer → `POST /api/v1/administrateurs`
- Modifier → `PUT /api/v1/administrateurs/{trackingId}`
- Supprimer → `DELETE /api/v1/administrateurs/{trackingId}`

### 3.2 Gestion des Parents (`/superadmin/parents`)

- `GET /api/v1/parents?page=0&size=20`
- Tableau : Nom, Email, Enfants associés, Actions
- `GET /api/v1/parents/par-eleve/{eleveTrackingId}` → voir parents d'un élève
- Ajouter enfant → `POST /api/v1/parents/{trackingId}/enfants/{eleveTrackingId}`
- Retirer enfant → `DELETE /api/v1/parents/{trackingId}/enfants/{eleveTrackingId}`
- CRUD parent : `POST`, `PUT`, `DELETE`

### 3.3 Journaux d'Audit / Historique (`/superadmin/logs`)

- `GET /api/v1/utilisateurs/{userId}/historique/pagine?page=0&size=20`
- Pour une vue globale : charger l'historique des admins + conseillers
- Filtres : utilisateur (input), type d'action (dropdown : CONNEXION, TEST_RIASEC, UPLOAD_DOCUMENT, etc.)
- `GET /api/v1/utilisateurs/{userId}/historique/action?action=CONNEXION`
- Tableau : Horodatage, Utilisateur, Action (badge), Détails
- Bouton "Purger historique" → `DELETE /api/v1/utilisateurs/{userId}/historique`

### 3.4 Paramètres (`/superadmin/parametres`)

**Section "Gestion des rôles" :**
- Tableau statique de permissions (hardcodé, pas d'API dédiée)
- Super Admin, Admin, Directeur Pédagogique, Comptable
- Permissions : Dashboard, Élèves, Finances, Paramètres (checkboxes)

**Section "Notifications système" :**
- Envoyer notification à tous les élèves : formulaire titre + message
- Appel à faire sur chaque élève ou grouper :
  - `GET /api/v1/eleves?size=200` → itérer sur chaque `trackingId`
  - `POST /api/v1/utilisateurs/{trackingId}/notifications`

**Section "Upload fichiers" :**
- Interface de gestion MinIO
- `GET /files/list/IMAGE` / `GET /files/list/PDF` / `GET /files/list/VIDEO`
- Afficher liste des fichiers avec nom, taille, bouton télécharger / supprimer
- Upload : `POST /files/upload/IMAGE` (ou PDF/VIDEO selon le type)
- Supprimer : `DELETE /files/{fileType}/{fileName}`
- Prévisualisation PDF : `GET /files/pdf/thumbnail/{fileName}` (retourne PNG)

---

## COMPOSANTS PARTAGÉS

### `<StatCard title value icon trend trendLabel color />`
Carte KPI avec icône, valeur principale, tendance (+X%), couleur accent.

### `<DataTable columns data loading pagination onRowClick />`
Tableau générique avec skeleton loader, état vide, pagination (React Query).

### `<StatusBadge status />`
Statuts gérés : PLANIFIE (bleu), TERMINE (vert), ANNULE (rouge), PUBLIE (vert), BROUILLON (gris), PUBLIC (vert), NON_PUBLIC (gris), LYCEEN / ETUDIANT / etc.

### `<UserAvatar name imageUrl size online />`
Avatar avec initiales si pas d'image, indicateur online (point vert/rouge).

### `<PageHeader title subtitle actions />`
En-tête de page avec titre, sous-titre optionnel, boutons d'action à droite.

### `<EmptyState icon title description action />`
État vide avec illustration et CTA.

### `<ConfirmDialog title message onConfirm onCancel />`
Modal de confirmation avant suppression ou action irréversible.

### `<Pagination page totalPages onChange />`
Composant de pagination réutilisable.

---

## GESTION D'ÉTAT & DATA FETCHING

Utiliser **TanStack Query (React Query v5)** pour tous les appels API :

```typescript
// Exemple : liste d'élèves avec pagination
const { data, isLoading, error } = useQuery({
  queryKey: ['eleves', page, size],
  queryFn: () => api.get(`/api/v1/eleves?page=${page}&size=${size}`).then(r => r.data),
})
```

Mutations pour les créations/modifications :
```typescript
const mutation = useMutation({
  mutationFn: (body) => api.post('/api/v1/eleves', body).then(r => r.data),
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['eleves'] })
    toast.success('Élève créé avec succès')
  },
  onError: () => toast.error('Une erreur est survenue'),
})
```

---

## ÉTATS UI

- **Loading :** `<Skeleton>` shadcn/ui sur toutes les cartes et tableaux
- **Erreur API :** Toast notification (shadcn/ui `<Toaster>`) en haut à droite
- **Liste vide :** `<EmptyState>` avec icône et texte contextuel
- **Suppression :** `<ConfirmDialog>` obligatoire avant tout `DELETE`
- **Formulaires :** validation React Hook Form + Zod, erreurs inline sous les champs

---

## NOTES TECHNIQUES IMPORTANTES

1. **Pas de JWT** : pas d'`Authorization` header pour l'instant. L'API est en accès libre.
2. **trackingId vs id** : toutes les ressources utilisent `trackingId` (UUID) comme identifiant dans les URLs, pas un `id` numérique.
3. **Pagination Spring** : les réponses paginées ont le format `{ content: [], totalElements, totalPages, number, size }`. Extraire `content` pour les données et `totalPages` / `totalElements` pour la pagination.
4. **Dates** : utiliser `date-fns` avec `fr` locale. Toutes les dates en ISO 8601. `formatDistanceToNow(new Date(date), { locale: fr, addSuffix: true })` pour les temps relatifs.
5. **Fichiers MinIO** : pour afficher une image, construire l'URL : `GET /files/url/IMAGE/{fileName}` retourne l'URL publique. Ou utiliser directement `GET /files/stream/IMAGE/{fileName}` comme `src` d'une balise `<img>`.
6. **Recherche globale** : `GET /api/v1/bibliotheque/recherche-fiche-ia/globale?phrase=...&limite=10` pour une barre de recherche globale dans le header admin.
7. **Nombres** : format français — utiliser `new Intl.NumberFormat('fr-FR').format(n)` — ex: `12 450` et non `12,450`.
8. **Responsive** : Desktop-first (min 1024px), fonctionnel sur tablette (768px). Sidebar collapsible sur tablette.

---

## ORDRE D'IMPLÉMENTATION RECOMMANDÉ

1. **Setup :** Vite + React + TypeScript + Tailwind + shadcn/ui + React Query + Zustand + React Router
2. **Auth & Layout :** Page login (pseudo), store Zustand, ProtectedRoute, SidebarLayout (3 variantes)
3. **Composants partagés :** StatCard, DataTable, StatusBadge, UserAvatar, PageHeader, EmptyState, ConfirmDialog
4. **Dashboard Conseiller** (page la plus visuelle)
5. **Messages/Tickets** (page la plus complexe)
6. **Rendez-vous** (calendrier)
7. **Dashboard Admin** (KPIs + graphiques)
8. **Gestion Filières** (CRUD + panneau latéral)
9. **Quiz & Éditeur** (arbre de questions)
10. **Conseillers** (grille de cartes)
11. **FAQ** (liste + recherche IA)
12. **Statistiques** (graphiques Recharts)
13. **Super Admin** (admins, parents, logs, paramètres, fichiers)