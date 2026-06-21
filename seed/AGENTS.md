# Activ Education — AGENTS.md

## Repo structure (3 apps + seed/)

```
activ-education/
├── activ_education/          # Flutter mobile (Dart, setState only), entry: lib/main.dart
└── backoffice/               # React 19 + TS 6 + Tailwind v4, entry: src/main.tsx → App.tsx
activ-education-backend/      # Spring Boot 4.0.5 (Java 21, Maven)
seed/                         # SQL + shell scripts to seed deployed API
```

## Commands

### Backend (workdir: activ-education-backend/)
```
docker compose up             # DB :5433 + MinIO :9000/9001 + app :8080
./mvnw spring-boot:run        # local dev (needs DB on :5432)
./mvnw clean compile -DskipTests
```
- DB defaults: `localhost:5432`, user `postgres`, pass `abalakata`, db `activ_education`
- `ddl-auto=update` (no Flyway/Liquibase — schema changes risk data loss)
- Swagger: `http://localhost:8080/swagger-ui.html`
- **Redis** configured in properties (rate limiting, token blacklist) but **no Redis container in docker-compose** — won't work in Docker

### Flutter (workdir: activ-education/activ_education/)
```
flutter pub get && flutter run && flutter test
flutter analyze               # dart analyze lib/ — 0 errors expected
```
- `Dio` HTTP, `flutter_secure_storage` for JWT, `flutter_dotenv` for `.env`
- `API_BASE_URL=http://4.233.145.112:8080` — **no `/api/v1` suffix** (backoffice has it)
- 401 interceptor at `base_service.dart:34-40`: `_refreshWithLock()` (Completer) + `storage.deleteAll()` si refresh échoue
- Splash screen (`splash_screen.dart:86`): décode le JWT et vérifie `exp` avant navigation — si expiré, `deleteAll()` + redirection onboarding

### Backoffice (workdir: activ-education/backoffice/)
```
npm install && npm run dev     # Vite :5174
npm run build                  # tsc -b && vite build
npm run lint
```
- **No test framework**; **TS 6 strict** (`erasableSyntaxOnly`: no enums, no namespaces, no parameterProperties)
- Stack: react-router-dom v7, @tanstack/react-query v5, Zustand, Tailwind v4, Recharts, Lucide
- `@/` alias → `src/`; `VITE_API_BASE_URL=http://4.233.145.112:8080/api/v1`

## Backend architecture

5 modules (Package by Feature): `profil` (users/auth), `bibliotheque` (library/fiches), `diagnostic` (quizzes), `accompagnement` (appointments/messages), `shared` (MinIO, security, utils). All entities extend `BaseEntity` (Long PK + UUID trackingId exposed in URLs). `@PreAuthorize` + custom SPEL on every controller. `@Valid` on request DTOs — validation errors produce 400 at `/error`, which the JWT filter treats as 401.

27 controllers, 133 endpoints — all consumed by at least one client.

## Security

**JWT filter is always active** (SecurityConfig.java) — deployed and local.
- Key file: `src/main/java/.../shared/security/config/SecurityConfig.java` — URL rules + `@PreAuthorize` on controllers
- Custom SPEL: `@security.isOwner(#trackingId)`, `@security.isOwnChild(#eleveTrackingId)`, `@security.isOwnConseiller(#conseillerTrackingId)`

### 401 interceptor patterns
- **Backoffice** (`client.ts`): refresh token with queue (`isRefreshing`), retry original, redirect `/login` on failure. Excludes `/auth/login` and `/auth/refresh`.
- **Flutter** (`base_service.dart:146-150`): `_refreshWithLock()` (Completer), if retry after refresh still 4xx → `handler.next(error)` to break loop.

## Architecture quirks

### Backend
- **Two-phase pgvector**: native SQL for vector search, then JPQL for entity hydration (JPA `InheritanceType.JOINED` loses discriminator in native queries)
- **MinIO**: 3 buckets (images/videos/documents), upload via `/files/upload/{fileType}`, max 500MB
- **Gemini** for embeddings; OpenCode Zen (not deployed) for text gen
- **Lombok `@SuperBuilder`** on abstract `Fiche` hierarchy; BCrypt strength 12
- **`matieresPreferees`** stored as CSV in `TEXT` column, parsed by `EleveMapper`
- **⚠️ `GEMINI_API_KEY` committed** in `activ-education-backend/.env` — rotate it
- **`@Async`** orphan search tracking writes to `recherches_orphelines`
- **`ParentRequest.java` / `ConseillerRequest.java`**: `@NotBlank` / `@Size(min=8)` removed from `motDePasse` — was causing 401 on update (validation error → `/error` → caught by JWT filter)

### Flutter
- **4-second polling** for chat (no WebSocket)
- `resolveImageUrl()` rewrites `http://minio:9000/...` to API download path
- `AuthImage` widget reads JWT for image downloads via `/files/download/IMAGE/{fileName}`
- `EleveRequest.motDePasse` is `String?` — not sent on profile updates

### Backoffice
- 3 role levels in router: `CONSEILLER`, `ADMIN`, `SUPER_ADMIN` via `ProtectedRoute`
- Login: `POST /auth/login` → access/refresh tokens in localStorage; axios interceptor injects `Bearer`
- Admin pages partially built (some use mock data / stubs)

## Seed scripts

Deployed DB is empty. Run in order with JWT (admin@activeducation.tg / admin123!):
1. `seed_users.sql` — raw SQL (7 users: superadmin/moderateur/gestionnaire/conseiller/eleve/parent)
2. `seed_bibliotheque.sh` — POST via API (13 séries, 32 filières, 42 métiers, 22 établissements, 12 FAQ)
3. `seed_etablissement_images.sh` — POST via multipart (images placeholder pour tous les établissements)
4. `seed_quiz.sh` — POST via API (RIASEC 30Q + Personnalité 5Q)
5. `seed_universites.sh` — POST via API (117 établissements supérieurs)

## Universites directory (`seed/universites/`)

117 dossiers (un pour chaque établissement de `seed_universites.sh`), chacun avec un `.md`.

### 14 écoles avec site web confirmé + logo

| # | Établissement | Site web | Logo |
|---|--------------|----------|------|
| 2 | Université de Kara (UK) | https://univ-kara.tg | `logo_uk.png` |
| 3 | Université de Lomé (UL) | https://univ-lome.tg | `LOGO-COULEUR-TRANSP.png` |
| 14 | DEFITECH Togo | https://defitech.tg | `images.png` |
| 29 | IAEC | https://iaectogo.com | `iaec.ico` |
| 44 | Institut de Technologie IPNET IT | https://www.ipnetuniversity.com | `logo.png` |
| 50 | IAI-TOGO | https://new.iai-togo.tg | `iai_togo_logo.jpeg` |
| 80 | Lomé Business School (LBS) | https://lome-bs.com | `lom_business_school_lbs_logo.png` |
| 83 | UCAO-UUT | https://ucao-uut.tg | `ucao_uut.ico` |
| 84 | UST-TG | https://rusta-usttg.org | ❌ (err 521) |
| 86 | EAMAU | https://www.eamau.org | `eamau_logo.jpg` |
| 92 | EMARITO | https://emarito.org | `emarito_logo.png` |
| 93 | ENA Togo | https://ena.tg | ❌ (DNS) |
| 95 | ESAG-NDE | https://esagnde.org | `esag_nde.ico` |
| 99 | ESIG Global Success | https://esig.tg | `esig_global_success.ico` |
| 105 | ESGIS | https://www.esgis.org | `esgis.ico` |

### Format des fichiers `.md`
```
# Nom Établissement

https://site-web.tg site web de l'école
https://youtu.be/xxxxx video youtube   (optionnel)
```

### Récupération des liens
- `seed/universites/prompt_recherche_liens.md` — prompt à copier dans ChatGPT/DeepSeek pour trouver site web + YouTube des 117 écoles
- `seed/fetch_logos.py` — script de téléchargement automatique des favicons/logos

## Testing status
- **Backend**: 0 real tests — only Spring Boot `contextLoads()` in `ActivEducationApplicationTests.java`
- **Flutter**: `flutter test` — 3 files (widget smoke, model serialization, API integration)
- **Backoffice**: **no test framework** installed

## Critical gaps
1. **No CI/CD**, no pre-commit hooks, no test framework (backoffice)
2. **`ddl-auto=update`** — no schema migration tooling
3. **Backoffice admin pages**: quiz editor, FAQ moderation, stats, roles, agenda are stubs
4. **Deployed DB empty** — seed scripts required
5. **`GET /api/v1/eleves/{id}/resultats-diagnostic`** — Flutter calls without pagination, backend returns `Page<>`
6. **`GEMINI_API_KEY` committed** to repo
7. **No Redis in docker-compose** — rate limiting / token blacklist broken in Docker
8. **Bug 401 Flutter**: refresh token succeeds but retry still 401 — likely cause: incomplete PUT body → `@Valid` → `/error` → caught by JWT filter
9. **Backoffice lenteur** — too many API calls at startup (check TanStack Query cache)
