import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../widgets/common_widgets.dart';
import '../../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuidController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _uuidController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final api = ApiService();
      final trackingId = _uuidController.text.trim();

      // Récupérer l'élève par son trackingId (UUID)
      final response = await api.auth.getEleve(trackingId);

      // Sauvegarder la session
      await api.auth.saveUserData(
        trackingId: response.trackingId,
        role: 'ELEVE',
      );

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.home, (route) => false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'UUID introuvable ou erreur de connexion : ${e.toString()}')),
        );
      }
    }
  }

  void _loginWithGoogle() {
    // TODO: implement Google Sign-In
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),

                  // Logo
                  ClipOval(
                    child: Image.asset(
                      'assets/images/logo.jpeg',
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Erreur chargement logo: $error');
                        return Container(
                          width: 56,
                          height: 56,
                          color: Colors.red,
                          child: const Icon(Icons.error, color: Colors.white),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text('Bon retour !',
                      style: AppTextStyles.displayMedium),
                  const SizedBox(height: 6),
                  const Text(
                    'Ravi de te revoir',
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 32),

                  // Google button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: _loginWithGoogle,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textDark,
                        side: const BorderSide(
                            color: AppColors.cardBorder, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        backgroundColor: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Google G icon
                          Container(
                            width: 22,
                            height: 22,
                            decoration:
                                const BoxDecoration(shape: BoxShape.circle),
                            child: const Center(
                              child: Text(
                                'G',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF4285F4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Continuer avec Google',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const DividerWithText(text: 'Connexion avec identifiant'),
                  const SizedBox(height: 20),

                  // UUID field
                  TextFormField(
                    controller: _uuidController,
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.textDark),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Identifiant requis' : null,
                    decoration: const InputDecoration(
                      hintText: 'Entrez votre UUID (trackingId)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Cet identifiant a été fourni lors de votre inscription',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMedium,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Se connecter',
                    isLoading: _isLoading,
                    onPressed: _login,
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: AppColors.cardBorder),
                  const SizedBox(height: 20),

                  const Text(
                    'Pas encore de compte ?',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 12),

                  // Create account button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.profileSetup),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Créer mon compte',
                        style: AppTextStyles.buttonText
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
