# Audit des endpoints API — État déployé (29 Mai 2026)



---

## Légende

| Code | Signification |
|------|--------------|
| ✅ | Fonctionne |
| 🔴 Bloqué | 401 à cause de la SecurityConfig (bug déployé) |
| ❌ Autre | Serveur down / timeout / rate-limit |

---

## 🔓 Endpoints publics (permitAll) — ✅ Tout OK

| Endpoint | Statut |
|----------|--------|
| `POST /auth/login` | ✅ 200 |
| `POST /auth/refresh` | ✅ 200 |
| `POST /eleves` (inscription) | ✅ 201 |
| `POST /parents` (inscription) | ✅ 201 |
| `GET /bibliotheque/series/**` | ✅ 200 |
| `GET /bibliotheque/filieres/**` | ✅ 200 |
| `GET /bibliotheque/metiers/**` | ✅ 200 |
| `GET /bibliotheque/etablissements/**` | ✅ 200 |
| `GET /bibliotheque/faq/**` | ✅ 200 |
| `GET /bibliotheque/recherche-fiche-ia/**` | ✅ 200 |
| `GET /api-docs/**` (Swagger) | ✅ 200 |

---

## ✅ Endpoints authentifiés (anyRequest) — ✅ Tout OK

Ces endpoints tombent sous `.anyRequest().authenticated()` — n'importe quel utilisateur connecté y accède.

| Endpoint | Statut |
|----------|--------|
| `GET /auth/me` | ✅ 200 |
| `POST /auth/logout` | ✅ 200 |
| `GET /eleves` (liste) | ✅ 200 |
| `GET /eleves/{trackingId}` | ✅ 200 |
| `GET /parents` (liste) | ✅ 200 |
| `GET /parents/{trackingId}` | ✅ 200 |
| `GET /conseillers` (liste) | ✅ 200 |
| `GET /conseillers/{trackingId}` | ✅ 200 |
| `GET /conseillers/disponibles` | ✅ 200 |
| `GET /notes/{trackingId}` | ✅ 200 |
| `PUT /notes/{trackingId}` | ✅ 200 |
| `DELETE /notes/{trackingId}` | ✅ 204 |
| `GET /eleves/{id}/notes` | ✅ 200 |
| `GET /eleves/{id}/notes/pagine` | ✅ 200 |
| `GET /messages/**` | ✅ 200 |
| `POST /rendez-vous` | ✅ 201 |
| `GET /rendez-vous/**` | ✅ 200 |
| `PUT /rendez-vous/{id}` | ✅ 200 |
| `PATCH /rendez-vous/{id}/annuler\|terminer` | ✅ 200 |
| `GET /utilisateurs/{id}/**` | ✅ 200 |
| `POST /utilisateurs/{id}/messages` | ✅ 201 |
| `POST /utilisateurs/{id}/notifications` | ✅ 201 |
| `GET /notifications/**` | ✅ 200 |
| `PATCH /notifications/{id}/lire` | ✅ 200 |
| `DELETE /notifications/{id}` | ✅ 204 |
| `GET /resultats-diagnostic/**` | ✅ 200 |
| `POST /resultats-diagnostic` | ✅ 201 |
| `GET /files/download/**` | ✅ 200 |
| `GET /disponibilites/**` | ✅ 200 |

---

## 🔴 Endpoints bloqués par la SecurityConfig (même avec token valide)

### Cause racine

La SecurityConfig déployée a l'ordre suivant :

```
1. POST /auth/login, /auth/refresh, /eleves, /parents       → permitAll
2. GET /bibliotheque/**                                      → permitAll
3. ...
4. RÈGLES ADMIN (arrivent trop tôt) :
   POST /api/v1/eleves/** → hasRole("ADMIN")    ← attrape POST /eleves/{id}/notes
   PUT  /api/v1/eleves/** → hasRole("ADMIN")    ← attrape PUT /eleves/{id}
   PUT  /api/v1/parents/** → hasRole("ADMIN")   ← attrape PUT /parents/{id}
   POST /api/v1/bibliotheque/** → hasRole("ADMIN")  ← attrape POST /favoris
5. anyRequest().authenticated()
```

**Problème :** Les règles avec `**` (multi-segments) attrapent **tout**, y compris les requêtes légitimes d'un propriétaire. Les `@PreAuthorize` sur les contrôleurs ne sont jamais atteints.

### Liste des endpoints bloqués

#### 🔴 Profil — PUT (élève/parent/conseiller ne peut pas modifier son propre profil)

| Endpoint | Appelé par | Comportement attendu | Comportement réel |
|----------|-----------|---------------------|-------------------|
| `PUT /eleves/{trackingId}` | Flutter (sauvegarde profil) | `@PreAuthorize("@security.isOwner or hasRole('ADMIN')")` | **401** car match `PUT /api/v1/eleves/**` → ADMIN |
| `PUT /parents/{trackingId}` | Flutter | `@security.isOwner or hasRole('ADMIN')` | **401** |
| `PUT /conseillers/{trackingId}` | Flutter | `@security.isOwner or hasRole('ADMIN')` | **401** |

#### 🔴 Notes — POST (élève ne peut pas ajouter une note)

| Endpoint | Appelé par | Comportement attendu | Comportement réel |
|----------|-----------|---------------------|-------------------|
| `POST /eleves/{eleveId}/notes` | Flutter (ajout note) | `@security.isOwner or hasRole('ADMIN')` | **401** car match `POST /api/v1/eleves/**` → ADMIN |

#### 🔴 Favoris — POST/DELETE (aucun utilisateur connecté ne peut gérer ses favoris)

| Endpoint | Appelé par | Comportement attendu | Comportement réel |
|----------|-----------|---------------------|-------------------|
| `POST /bibliotheque/favoris` | Flutter (ajout favori) | `anyRequest().authenticated()` | **401** car match `POST /api/v1/bibliotheque/**` → ADMIN |
| `DELETE /bibliotheque/favoris/{trackingId}` | Flutter (retrait favori) | `anyRequest().authenticated()` | **401** car match `DELETE /api/v1/bibliotheque/**` → ADMIN |

#### 🔴 Parents/enfants — lien/délien (parent ne peut pas lier son enfant)

| Endpoint | Appelé par | Comportement attendu | Comportement réel |
|----------|-----------|---------------------|-------------------|
| `POST /parents/{parentId}/enfants/{eleveId}` | Flutter (lier enfant) | `@security.isOwner or hasRole('ADMIN')` | **401** car match `POST /api/v1/eleves/**` ET `POST /api/v1/parents/**` → ADMIN |
| `DELETE /parents/{parentId}/enfants/{eleveId}` | Flutter (délier enfant) | `@security.isOwner or hasRole('ADMIN')` | **401** |

#### 🔴 Quiz recommandations (élève ne peut pas obtenir des questions personnalisées)

| Endpoint | Appelé par | Comportement attendu | Comportement réel |
|----------|-----------|---------------------|-------------------|
| `GET /quiz/recommandations/{eleveId}/{quizId}` | Flutter (recommandations) | `@PreAuthorize("hasAnyRole('ELEVE', 'ADMIN')")` | **401** (probablement le JwtAuthenticationFilter qui échoue silencieusement) |

---

## ✅ Pourquoi le backoffice n'est PAS impacté

Le backoffice utilise `admin@activeducation.tg` qui a `ROLE_ADMIN`. Toutes les règles `hasRole("ADMIN")` de la SecurityConfig **acceptent** ses requêtes. Donc :

| Action backoffice | Endpoint | Résultat |
|------------------|----------|----------|
| Modifier un élève | `PUT /eleves/{id}` | ✅ 200 (admin a ROLE_ADMIN) |
| Ajouter une filière | `POST /bibliotheque/filieres` | ✅ 201 |
| Lister les quiz | `GET /quiz` | ✅ 200 |
| Créer un conseiller | `POST /conseillers` | ✅ 201 |

**Aucun endpoint backoffice n'est bloqué** par le SecurityConfig actuel.

---

## 🔧 Le fix (commit `1137d76`)

Ajoute des exceptions `.authenticated()` **AVANT** les règles ADMIN :

```
AVANT                                   APRÈS
─────────────────────────────           ─────────────────────────────
1. permitAll (auth, pub GET)            1. permitAll (auth, pub GET)
2. hasRole("ADMIN") sur tout           2. .authenticated() exceptions :
   POST/PUT/DELETE .../**                  PUT /eleves/*               ← NOUVEAU
3. anyRequest().authenticated()            POST /eleves/*/notes        ← NOUVEAU
                                          PUT /notes/**                ← NOUVEAU
                                          POST /bibliotheque/favoris   ← NOUVEAU
                                          DELETE /bibliotheque/favoris ← NOUVEAU
                                          POST /parents/*/enfants/*   ← NOUVEAU
                                          DELETE /parents/*/enfants/* ← NOUVEAU
                                       3. hasRole("ADMIN") sur
                                          POST/PUT/DELETE .../**
                                       4. anyRequest().authenticated()
```

Le `*` (mono-segment) est plus spécifique que `**` (multi-segments), donc `PUT /api/v1/eleves/{id}` match l'exception et passe, tandis que `PUT /api/v1/eleves/{id}/admin-secret` matche encore ADMIN.

---

## 📦 Commits à déployer

```bash
git checkout richard
git pull origin richard

./mvnw clean package -DskipTests
# copier target/*.jar sur le serveur et redémarrer Docker
```

| Commit | Fichiers modifiés |
|--------|-------------------|
| `1137d76` | `SecurityConfig.java`, `EleveController.java`, `NoteSaisiManuelController.java`, `ParentController.java` |
| `a14ed8f` | `QuizRecommendationController.java` + champs Question/Eleve |
| `9a8ce4e` | Suppression MoteurDiagnosticController (3 fichiers) |
| `6d431ce` | `ParentRequest.java`, `ConseillerRequest.java` — retrait @NotBlank sur motDePasse |
