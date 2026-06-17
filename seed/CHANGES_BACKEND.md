# Changements backend à déployer

## Problèmes corrigés (11 fichiers modifiés)

### 1. Timeout GET /filieres et /etablissements
**Fichiers :**
- `src/.../repository/FicheFiliereRepository.java`
- `src/.../repository/FicheEtablissementRepository.java`
- `src/.../repository/FicheMetierRepository.java`
- `src/.../repository/FicheSerieRepository.java`

**Cause :** Les `@EntityGraph` incluaient des `@ManyToMany` (`etablissements`, `filieresProposees`, `filieresPreparantes`, `filieresAssociees`) → LEFT JOIN produit cartésien × 5 → timeout.

**Fix :** Retiré les `@ManyToMany` des `@EntityGraph` (chargés en lazy dans le mapper).

**Supplément :** `FicheFiliereRepository.java` — méthode duplicata `findByDomaineIgnoreCaseAndEstPublieTrue` supprimée (bloquait la compilation).

### 2. Sécurité manquante sur 8 endpoints
**Fichiers :**
- `src/.../controller/NoteSaisiManuelController.java`
- `src/.../controller/ResultatDiagnosticController.java`
- `src/.../controller/RendezVousController.java`

**Cause :** 8 endpoints GET retournaient les données de n'importe quel élève sans vérifier que l'utilisateur est lié à cet enfant.

**Fix :** Ajouté `@PreAuthorize` avec `@security.isOwner(#eleveTrackingId) or @security.isOwnChild(#eleveTrackingId) or @security.isOwnConseiller(#eleveTrackingId) or hasRole('ADMIN')` sur :

| Controller | Méthodes |
|---|---|
| `NoteSaisiManuelController` | `getNotesByEleve`, `getNotesByElevePagine` |
| `ResultatDiagnosticController` | `getResultatsEleve`, `getDernierResultat` |
| `RendezVousController` | `getRendezVousEleve`, `getRendezVousElevePagine`, `getEleveParStatut` |

### 4. Parent peut auto-lier ses enfants
**Fichiers :**
- `src/.../config/SecurityConfig.java`
- `src/.../controller/ParentController.java`
- `src/.../controller/EleveController.java`
- `src/.../service/EleveService.java`
- `src/.../service/EleveServiceImpl.java`

**Problème :** Les endpoints `POST/DELETE /parents/{id}/enfants/{id}` requéraient le rôle ADMIN, empêchant un parent de lier ses propres enfants.

**Fix :**
- SecurityConfig : règles spécifiques `POST/DELETE /parents/*/enfants/*` → `authenticated()` placées avant les règles ADMIN
- `ParentController.ajouterEnfant/retirerEnfant` : `@PreAuthorize("@security.isOwner(#trackingId) or hasRole('ADMIN')")`
- Nouvel endpoint `GET /eleves/by-email/{email}` pour chercher un enfant par email (authenticated)
- Nouvelle méthode `getEleveByEmail` dans EleveService + EleveServiceImpl

### 5. Dockerfile optimisé
**Fichier :** `Dockerfile`

**Avant :** Multi-stage build avec Maven → `dependency:go-offline` lent, timeout 5min.

**Après :** Copie directe du JAR pré-compilé (`target/*.jar`) dans l'image JRE.

## Déploiement

```bash
# 1. Builder l'image
docker build -t activeducation-app:latest .

# 2. Sauvegarder
docker save activeducation-app:latest -o activeducation-app.tar

# 3. Copier sur le serveur (quand SSH dispo)
scp activeducation-app.tar user@4.233.145.112:~/

# 4. Sur le serveur
docker load -i activeducation-app.tar
docker compose up -d app
```

## Image pré-construite
- Nom : `activeducation-app:latest` (209MB)
- JAR inclus : `activEducation-0.0.1-SNAPSHOT.jar` (100MB)
