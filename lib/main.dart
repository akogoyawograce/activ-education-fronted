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
import 'screens/home/dashboard_bachelier.dart';
import 'screens/explorer/explorer_screen.dart';
import 'screens/diagnostic/quiz_screen.dart';
import 'screens/diagnostic/resultats_screen.dart';
import 'screens/diagnostic/notes_screen.dart'; // ← Import ajouté
import 'screens/messages/messages_list_screen.dart';
import 'screens/profile/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiService().init();
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
        AppRoutes.profile: (_) => const ProfileScreen(),
      },
    );
  }
}
