// lib/main.dart
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'models/models.dart';
import 'theme/app_routes.dart';
import 'services/api_service.dart';

// Auth & Onboarding
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/profile_setup_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/register_preferences_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/totp_setup_screen.dart';
import 'screens/auth/totp_verify_screen.dart';

// Home & Modules
import 'screens/main_scaffold.dart';
import 'screens/explorer/explorer_screen.dart';
import 'screens/explorer/favorites_screen.dart';
import 'screens/explorer/fiche_detail_screen.dart';
import 'screens/explorer/etablissements_map_screen.dart';
import 'screens/search/global_search_screen.dart';
import 'screens/conseillers/conseillers_screen.dart';
import 'screens/diagnostic/quiz_screen.dart';
import 'screens/diagnostic/resultats_screen.dart';
import 'screens/diagnostic/notes_screen.dart'; // ← Import ajouté
import 'screens/messages/messages_list_screen.dart';
import 'screens/messages/chat_screen.dart';
import 'screens/messages/rdv_screen.dart';
import 'screens/home/notifications_screen.dart';
import 'screens/home/faq_screen.dart';
import 'screens/home/support_screen.dart';
import 'screens/home/enfant_suivi_screen.dart';
import 'screens/messages/rdv_list_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/errors/not_found_screen.dart';
import 'screens/errors/network_error_screen.dart';
import 'screens/home/recommandation_ia_screen.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  ApiService().init();
  await initializeDateFormatting('fr_FR', null);
  runApp(const ActivEducationApp());
}

class ActivEducationApp extends StatelessWidget {
  const ActivEducationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Activ Education',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      navigatorObservers: [AppRoutes.routeObserver],
      routes: {
        // Auth
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.onboarding: (_) => const OnboardingScreen(),
        AppRoutes.profileSetup: (_) => const ProfileSetupScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.registerPreferences: (_) => const RegisterPreferencesScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.otp: (_) => const OtpScreen(),
        AppRoutes.resetPassword: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return ResetPasswordScreen();
        },
        AppRoutes.totpSetup: (_) => const TotpSetupScreen(),
        AppRoutes.totpVerify: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final challengeToken = args?['challengeToken'] as String? ?? '';
          final email = args?['email'] as String? ?? '';
          return TotpVerifyScreen(challengeToken: challengeToken, email: email);
        },

        // Main Navigation
        AppRoutes.home: (_) => const MainScaffold(),
        AppRoutes.dashboard: (_) => const MainScaffold(),

        // Diagnostic
        AppRoutes.quiz: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final quizTrackingId = args?['quizTrackingId'] as String?;
          return QuizScreen(quizTrackingId: quizTrackingId);
        },
        AppRoutes.resultats: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final score = args?['score'] as double?;
          final profil = args?['profil'] as String?;
          final quizId = args?['quizId'] as String?;
          return ResultatsScreen(score: score, profil: profil, quizId: quizId);
        },
        AppRoutes.notes: (_) => const NotesScreen(), // ← Route ajoutée

        // Autres
        AppRoutes.explorer: (_) => const ExplorerScreen(),
        AppRoutes.messages: (_) => const MessagesListScreen(),
        AppRoutes.chat: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final expediteurId = args?['expediteurId'] as String? ?? '';
          final expediteurNom = args?['expediteurNom'] as String? ?? '';
          return ChatScreen(
              expediteurId: expediteurId, expediteurNom: expediteurNom);
        },
        AppRoutes.rdv: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final conseillerId = args?['conseillerId'] as String?;
          final conseillerNom = args?['conseillerNom'] as String?;
          return RdvScreen(
              conseillerId: conseillerId, conseillerNom: conseillerNom);
        },
        AppRoutes.notifications: (_) => const NotificationsScreen(),
        AppRoutes.favorites: (_) => const FavoritesScreen(),
        AppRoutes.ficheDetail: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final fiche = args?['fiche'] as FicheBase;
          return FicheDetailScreen(fiche: fiche);
        },
        AppRoutes.search: (_) => const GlobalSearchScreen(),
        AppRoutes.support: (_) => const SupportScreen(),
        AppRoutes.faq: (_) => const FaqScreen(),
        AppRoutes.conseillers: (_) => const ConseillersScreen(),
        AppRoutes.enfantSuivi: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final enfantId = args?['enfantTrackingId'] as String;
          return EnfantSuiviScreen(enfantTrackingId: enfantId);
        },
        AppRoutes.rdvList: (_) => const RdvListScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.etablissementsMap: (_) => const EtablissementsMapScreen(),
        AppRoutes.recommandationIA: (_) => const RecommandationIAScreen(),

        // États
        AppRoutes.notFound: (_) => const NotFoundScreen(),
        AppRoutes.networkError: (_) => const NetworkErrorScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => NotFoundScreen(
            message: 'Route "${settings.name}" introuvable.',
          ),
        );
      },
    );
  }
}
