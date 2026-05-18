import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../widgets/common_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _continue() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Récupérer les arguments de l'écran précédent (ProfileSetup)
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() => _isLoading = false);
      // Passer toutes les données accumulées à l'écran final
      Navigator.pushNamed(
        context, 
        AppRoutes.registerPreferences,
        arguments: {
          ...?args,
          'nom': _nomController.text,
          'prenom': _prenomController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'password': _passwordController.text,
        }
      );
    }
  }

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Email requis';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(v)) return 'Email invalide';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Mot de passe requis';
    if (v.length < 8) return 'Minimum 8 caractères';
    return null;
  }

  String? _validateConfirmPassword(String? v) {
    if (v != _passwordController.text) return 'Les mots de passe ne correspondent pas';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGrey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textDark, size: 16),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Inscription',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),

            // Step progress
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: StepProgressBar(totalSteps: 2, currentStep: 1),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),

                      // Logo
                      ClipOval(
                        child: Image.asset(
                          'assets/images/logo.jpeg',
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text('Créer un compte',
                          style: AppTextStyles.displayMedium),
                      const SizedBox(height: 6),
                      const Text(
                        'Rejoignez la plateforme d\'orientation',
                        style: AppTextStyles.bodyLarge,
                      ),
                      const SizedBox(height: 28),

                      // Fields
                      AppTextField(
                        label: 'Nom',
                        hint: 'Votre nom',
                        controller: _nomController,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Nom requis' : null,
                      ),
                      const SizedBox(height: 18),

                      AppTextField(
                        label: 'Prénom',
                        hint: 'Votre prénom',
                        controller: _prenomController,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Prénom requis' : null,
                      ),
                      const SizedBox(height: 18),

                      AppTextField(
                        label: 'Email',
                        hint: 'kofi@email.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 18),

                      // Phone field with country code
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Numéro', style: AppTextStyles.label),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: AppTextStyles.bodyLarge
                                .copyWith(color: AppColors.textDark),
                            decoration: InputDecoration(
                              hintText: '+228 00 00 00 00',
                              prefixIcon: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundGrey,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '🇹🇬',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              prefixIconConstraints:
                                  const BoxConstraints(minWidth: 0, minHeight: 0),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      AppTextField(
                        label: 'Mot de passe',
                        hint: '••••••••',
                        controller: _passwordController,
                        isPassword: true,
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 18),

                      AppTextField(
                        label: 'Confirmer le mot de passe',
                        hint: '••••••••',
                        controller: _confirmPasswordController,
                        isPassword: true,
                        validator: _validateConfirmPassword,
                      ),

                      const SizedBox(height: 32),

                      PrimaryButton(
                        label: 'Continuer',
                        isLoading: _isLoading,
                        onPressed: _continue,
                        trailingIcon: Icons.arrow_forward_rounded,
                      ),

                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Déjà un compte ? ',
                            style: AppTextStyles.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(
                                context, AppRoutes.login),
                            child: Text(
                              'Se connecter',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
