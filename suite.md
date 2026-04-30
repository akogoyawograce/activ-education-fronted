Je travaille sur le projet "Activ Education" — une plateforme 
d'orientation scolaire et professionnelle pour le Togo.

CONTEXTE DU PROJET :
- CDC : 5 modules (Profils, Bibliothèque, Diagnostic, 
  Accompagnement, Back-office Admin)
- Backend : Spring Boot, API REST, base URL ngrok
- Frontend Mobile : Flutter (Dart)
- Frontend Web : React (back-office — pas encore commencé)

CE QUI EST DÉJÀ DÉVELOPPÉ (Flutter) :
✅ lib/theme/app_theme.dart        → Couleurs + typographie
✅ lib/theme/app_routes.dart       → Routes nommées
✅ lib/models/models.dart          → Tous les modèles API
✅ lib/services/api_service.dart   → Service HTTP Dio (tous endpoints)
✅ lib/widgets/common_widgets.dart → PrimaryButton, AppTextField...
✅ lib/widgets/bottom_nav.dart     → Barre de navigation
✅ lib/screens/main_scaffold.dart  → Scaffold + 5 onglets
✅ lib/screens/splash/splash_screen.dart
✅ lib/screens/onboarding/onboarding_screen.dart (3 slides)
✅ lib/screens/auth/profile_setup_screen.dart
✅ lib/screens/auth/register_screen.dart
✅ lib/screens/auth/register_preferences_screen.dart
✅ lib/screens/auth/login_screen.dart
✅ lib/screens/auth/forgot_password_screen.dart
✅ lib/screens/auth/otp_screen.dart
✅ lib/screens/home/dashboard_bachelier.dart
✅ lib/screens/explorer/explorer_screen.dart
✅ lib/screens/explorer/fiche_detail_screen.dart

ENDPOINTS API (base: http://[ngrok-url]):
- POST /api/v1/eleves              → Inscription
- GET/PUT /api/v1/eleves/{id}      → Profil élève
- POST /api/v1/eleves/{id}/notes   → Notes
- GET /api/v1/bibliotheque/series|filieres|metiers|etablissements
- GET/POST /api/v1/bibliotheque/favoris
- GET /api/v1/bibliotheque/faq
- GET/POST /api/v1/quiz
- GET /api/v1/quiz/{id}/questions
- POST /api/v1/resultats-diagnostic
- POST /api/v1/utilisateurs/{id}/messages
- GET /api/v1/messages/conversation
- POST /api/v1/rendez-vous
- GET /api/v1/utilisateurs/{id}/notifications
- POST /api/v1/conseillers
- GET /api/v1/conseillers/disponibles

⚠️ PAS ENCORE D'AUTH LOGIN/JWT côté backend

DESIGN :
- Couleurs : Primary #3D35D9 (bleu), Accent #FFA800 (orange)
- Police : Nunito
- Style : Mobile-first, cards arrondies, maquettes Figma fournies

PROCHAINS ÉCRANS À DÉVELOPPER :
⏳ lib/screens/diagnostic/quiz_screen.dart
⏳ lib/screens/diagnostic/notes_screen.dart
⏳ lib/screens/diagnostic/resultats_screen.dart
⏳ lib/screens/messages/messages_list_screen.dart
⏳ lib/screens/messages/chat_screen.dart
⏳ lib/screens/messages/rdv_screen.dart
⏳ lib/screens/profile/profile_screen.dart
⏳ lib/screens/home/notifications_screen.dart
⏳ Back-office React (Dashboard Conseiller + Admin)

Continue le développement en respectant :
1. La structure des fichiers existants
2. Les imports relatifs (../../theme/app_theme.dart)
3. Le style de code Flutter déjà établi
4. La connexion aux endpoints API listés
5. L'emplacement exact de chaque fichier à chaque livraison