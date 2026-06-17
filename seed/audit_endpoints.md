# Audit des endpoints API — 28 Mai 2026

**Serveur :** http://4.233.145.112:8080  
**Token :** admin@activeducation.tg / admin123!  
**Statut :** Serveur down depuis ~12:45 (probable crash Docker/VM)

---

## Légende
| Code | Signification |
|------|--------------|
| ✅ 200 | OK |
| ✅ 201 | Créé |
| ✅ 204 | Pas de contenu (succès) |
| ✅ 302 | Redirection |
| ⚠️ 400 | Erreur de validation / mauvaise requête |
| ⚠️ 401 | **Non authentifié — BUG** (token valide mais rejeté) |
| ⚠️ 403 | Accès refusé (rôle insuffisant) |
| ❌ 000 | Serveur down |

---

## 1. AUTH
| Endpoint | Méthode | Body | Statut | Notes |
|----------|---------|------|--------|-------|
| `/auth/login` | POST | `{email, motDePasse}` | ✅ 200 | Login OK |
| `/auth/refresh` | POST | `{refreshToken}` | ❌ 401 | Refresh token valide → 401 (BUG) |
| `/auth/me` | GET | — | ❌ 000 | Serveur down |
| `/auth/logout` | POST | `{}` | ❌ 000 | Serveur down |
| `/auth/logout-all` | POST | `{}` | ❌ 000 | Pas testé |

## 2. ÉLÈVES
| Endpoint | Méthode | Body | Statut | Notes |
|----------|---------|------|--------|-------|
| `/eleves` (liste) | GET | — | ✅ 200 | Paginé, OK |
| `/eleves/{trackingId}` | GET | — | ✅ 200 | OK |
| `/eleves/by-email/{email}` | GET | — | ✅ 200 | OK |
| `/eleves/{trackingId}` | **PUT** | `EleveRequest` | **⚠️ 401** | **BUG : retourne 401 même avec token admin valide** |
| `/eleves` (create) | POST | `EleveRequest` | ✅ 201 | Création publique OK |
| `/eleves/{trackingId}` | DELETE | — | ✅ 204 | Soft-delete OK |
| `/eleves/{trackingId}/notes` | POST | `NoteRequest` | ✅ 201 | Ajout note OK |
| `/eleves/{trackingId}/notes` | GET | — | ✅ 200 | Liste notes OK |
| `/notes/{noteId}` | DELETE | — | ❌ 000 | Serveur down |

## 3. PARENTS
| Endpoint | Méthode | Body | Statut | Notes |
|----------|---------|------|--------|-------|
| `/parents` (liste) | GET | — | ✅ 200 | OK |
| `/parents/{trackingId}` | GET | — | ✅ 200 | OK |
| `/parents/{trackingId}` | **PUT** | `Map` | **⚠️ 401** | **MÊME BUG que eleves PUT** |
| `/parents` (create) | POST | `ParentRequest` | ❌ 000 | Serveur down |

## 4. CONSEILLERS
| Endpoint | Méthode | Body | Statut | Notes |
|----------|---------|------|--------|-------|
| `/conseillers` (liste) | GET | — | ✅ 200 | OK |
| `/conseillers/{trackingId}` | GET | — | ✅ 200 | OK |
| `/conseillers/{trackingId}` | **PUT** | `Map` | **⚠️ 401** | **MÊME BUG** |
| `/conseillers` (create) | POST | `ConseillerRequest` | ❌ 000 | Serveur down |

## 5. BIBLIOTHÈQUE (PUBLIC GET)
| Endpoint | Méthode | Statut | Notes |
|----------|---------|--------|-------|
| `/bibliotheque/series` | GET | ✅ 200 | OK |
| `/bibliotheque/filieres` | GET | ✅ 200 | OK |
| `/bibliotheque/metiers` | GET | ✅ 200 | OK |
| `/bibliotheque/etablissements` | GET | ✅ 200 | OK |
| `/bibliotheque/faq` | GET | ✅ 200 | OK |
| `/bibliotheque/series/{id}` | GET | ✅ 200 | OK |
| `/bibliotheque/recherche-fiche-ia` | GET | ✅ 200 | OK |
| `/bibliotheque/favoris` (add) | POST | — | ❌ 000 | Serveur down |
| `/bibliotheque/favoris/{id}` (del) | DELETE | — | ❌ 000 | Serveur down |

## 6. QUIZ / DIAGNOSTIC
| Endpoint | Méthode | Statut | Notes |
|----------|---------|--------|-------|
| `/quiz` (liste) | GET | ❌ 000 | Serveur down |
| `/quiz/{id}` | GET | ❌ 000 | Serveur down |
| `/quiz` (create) | POST | ✅ 201 | Admin OK |
| Résultats diagnostic | POST/GET | ❌ 000 | Serveur down |

## 7. ADMIN / UTILISATEURS
| Endpoint | Méthode | Statut | Notes |
|----------|---------|--------|-------|
| `/administrateurs` (liste) | GET | ❌ 000 | Serveur down |
| `/administrateurs` (create) | POST | ❌ 000 | Serveur down |

---

## BUGS IDENTIFIÉS

### BUG 1 — PUT/POST avec body sur `/api/v1/{entity}/{id}` retourne 401
**Constat :** `PUT /api/v1/eleves/{id}`, `PUT /api/v1/parents/{id}`, `PUT /api/v1/conseillers/{id}` retournent 401 avec body vide, même avec un token admin valide.  
**Paradoxe :** 
- `DELETE /api/v1/eleves/{id}` → ✅ 204 (admin OK, sans body)
- `POST /api/v1/eleves/{id}/notes` → ✅ 201 (admin OK, body + sous-chemin)
- `POST /api/v1/quiz` → ✅ 201 (admin OK)

**Cause probable :** Le `@Valid @RequestBody` dans le contrôleur provoque une erreur de validation (même avec body complet) qui redirige vers `/error`, et le endpoint `/error` n'est pas correctement authentifié → 401.  
**OU :** Les règles `PUT /api/v1/eleves/**` dans SecurityConfig ne matchent pas correctement.

**Solution :** Déployer le JAR du commit `1137d76` qui corrige SecurityConfig + ajoute `@PreAuthorize` manquants.

### BUG 2 — Le serveur est down
Depuis ~12:45, tous les services (app:8080, minio:9000, db:5433) sont injoignables. Probable crash Docker/VM.

---

## COMMANDE DE BUILD
```bash
cd activ-education-backend
./mvnw clean package -DskipTests
# Génère : target/activEducation-0.0.1-SNAPSHOT.jar (100 MB)
```

## PROCÉDURE DE DÉPLOIEMENT
```bash
# Sur le serveur (accès requis)
git pull
docker compose build app
docker compose up -d app
```
