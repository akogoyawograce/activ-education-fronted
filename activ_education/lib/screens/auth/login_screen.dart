import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../widgets/common_widgets.dart';
import '../../services/api_service.dart';
import '../../services/google_sign_in_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _googleSignIn() async {
    try {
      setState(() => _isLoading = true);
      final api = ApiService();
      final google = GoogleSignInService();
      final profile = await google.signInAndGetProfile();
      if (profile == null) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connexion Google indisponible. Configuration requise (SHA-1, OAuth).'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final email = profile['email'] ?? '';
      final linkedId = await google.getLinkedTrackingId(email);

      if (linkedId != null) {
        final role = await api.getUserRole();
        await api.auth.saveUserData(trackingId: linkedId, role: role ?? 'ELEVE');
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
        }
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Compte non lié'),
              content: Text('Aucun compte lié à $email.\nConnectez-vous avec email/mot de passe pour lier votre compte Google.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur de connexion Google. Réessayez plus tard.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final api = ApiService();
      final token = await api.auth.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      await api.auth.saveToken(token.accessToken);
      await api.auth.saveRefreshToken(token.refreshToken);
      await api.auth.saveUserData(
        trackingId: token.trackingId,
        role: token.typeUtilisateur,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.home, (route) => false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email ou mot de passe incorrect')),
        );
      }
    }
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
                      cacheWidth: 56,
                      cacheHeight: 56,
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
                    'Connecte-toi avec ton email',
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 32),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.textDark),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Email requis' : null,
                    decoration: const InputDecoration(
                      hintText: 'ex: prenom@email.com',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.textDark),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Mot de passe requis' : null,
                    decoration: InputDecoration(
                      hintText: 'Mot de passe',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.forgotPassword),
                      child: const Text('Mot de passe oublié ?'),
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

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _googleSignIn,
                      icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                      label: const Text('Continuer avec Google'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textDark,
                        side: const BorderSide(color: AppColors.cardBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Pas encore de compte ?',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 12),

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
