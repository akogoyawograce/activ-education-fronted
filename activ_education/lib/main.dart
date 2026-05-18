// lib/main.dart
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
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

// Home & Modules
import 'screens/main_scaffold.dart';
import 'screens/explorer/explorer_screen.dart';
import 'screens/diagnostic/quiz_screen.dart';
import 'screens/diagnostic/resultats_screen.dart';
import 'screens/diagnostic/notes_screen.dart'; // ← Import ajouté
import 'screens/messages/messages_list_screen.dart';
import 'screens/messages/chat_screen.dart';
import 'screens/messages/rdv_screen.dart';
import 'screens/home/notifications_screen.dart';
import 'screens/home/faq_screen.dart';
import 'screens/profile/profile_screen.dart';

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

        // Main Navigation
        AppRoutes.home: (_) => const MainScaffold(),
        AppRoutes.dashboard: (_) => const MainScaffold(),

        // Diagnostic
        AppRoutes.quiz: (_) => const QuizScreen(),
        AppRoutes.resultats: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final score = args?['score'] as double?;
          return ResultatsScreen(score: score);
        },
        AppRoutes.notes: (_) => const NotesScreen(), // ← Route ajoutée

        // Autres
        AppRoutes.explorer: (_) => const ExplorerScreen(),
        AppRoutes.messages: (_) => const MessagesListScreen(),
        AppRoutes.chat: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final expediteurId = args?['expediteurId'] as String;
          final expediteurNom = args?['expediteurNom'] as String;
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
        AppRoutes.faq: (_) => const FaqScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
      },
    );
  }
}
