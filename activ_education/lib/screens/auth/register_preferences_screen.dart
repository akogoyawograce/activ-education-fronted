import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../widgets/common_widgets.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import 'profile_setup_screen.dart'; // Pour UserRole

class RegisterPreferencesScreen extends StatefulWidget {
  const RegisterPreferencesScreen({super.key});

  @override
  State<RegisterPreferencesScreen> createState() =>
      _RegisterPreferencesScreenState();
}

class _RegisterPreferencesScreenState extends State<RegisterPreferencesScreen> {
  final Set<String> _selectedMatieres = {};
  String? _selectedStyle;
  bool _isLoading = false;

  final List<String> _matieres = [
    'Maths',
    'SVT',
    'Physique',
    'Français',
    'Histoire-Géo',
    'Anglais',
    'Philosophie',
    'Économie',
  ];

  final List<_LearningStyle> _styles = [
    const _LearningStyle(
      key: 'textes',
      label: 'Par les textes',
      icon: Icons.menu_book_outlined,
    ),
    const _LearningStyle(
      key: 'videos',
      label: 'Par les vidéos',
      icon: Icons.play_circle_outline_rounded,
    ),
    const _LearningStyle(
      key: 'both',
      label: 'Les deux',
      icon: Icons.star_outline_rounded,
    ),
  ];

  void _finish() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    setState(() => _isLoading = true);
    final api = ApiService();

    try {
      // Mapper UserRole vers TypeApprenant
      final userRole = args['role'] as UserRole?;
      TypeApprenant typeApprenant = TypeApprenant.AUTRE;
      if (userRole == UserRole.collegien)
        typeApprenant = TypeApprenant.COLLEGIEN;
      else if (userRole == UserRole.lyceen)
        typeApprenant = TypeApprenant.LYCEEN;
      else if (userRole == UserRole.etudiant)
        typeApprenant = TypeApprenant.ETUDIANT;
      else if (userRole == UserRole.reconversion)
        typeApprenant = TypeApprenant.PROFESSIONNEL;

      // Création de la requête
      final request = EleveRequest(
        nom: args['nom'] ?? '',
        prenom: args['prenom'] ?? '',
        email: args['email'] ?? '',
        telephone: args['phone'],
        motDePasse: args['password'] ?? '',
        niveauEtude: args['class'],
        typeApprenant: typeApprenant,
        etablissementActuel: args[
            'city'], // Utilisation de la ville comme placeholder pour l'instant
        matieresPreferees: _selectedMatieres.toList(),
        styleApprentissage: _selectedStyle,
      );

      debugPrint('Inscription élève - requête: ${request.toJson()}');

      // Appel API
      final response = await api.auth.inscrireEleve(request);

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
      debugPrint('Erreur lors de l’inscription élève: $e');
      if (e is DioException) {
        debugPrint(
            'DioException response: ${e.response?.statusCode} ${e.response?.data}');
      }
      if (mounted) {
        final message = api.handleError(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de la création du compte: $message')),
        );
      }
    }
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
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Étape 3 sur 3',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Step progress
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: StepProgressBar(totalSteps: 3, currentStep: 3),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const Text('Presque fini !',
                        style: AppTextStyles.displayMedium),
                    const SizedBox(height: 6),
                    const Text(
                      'Ces infos nous aident à personnaliser tes recommandations',
                      style: AppTextStyles.bodyLarge,
                    ),

                    const SizedBox(height: 28),

                    // Matières
                    Row(
                      children: [
                        const Text('Tes matières préférées',
                            style: AppTextStyles.headingMedium),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundGrey,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'OPTIONNEL',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _matieres.map((m) {
                        final selected = _selectedMatieres.contains(m);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selected) {
                                _selectedMatieres.remove(m);
                              } else {
                                _selectedMatieres.add(m);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 9),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.cardBorder,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              m,
                              style: AppTextStyles.label.copyWith(
                                color: selected
                                    ? Colors.white
                                    : AppColors.textDark,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Comment tu préfères apprendre ?',
                      style: AppTextStyles.headingMedium,
                    ),
                    const SizedBox(height: 14),

                    ..._styles.map((s) {
                      final selected = _selectedStyle == s.key;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedStyle = s.key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary.withValues(alpha: 0.06)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.cardBorder,
                              width: selected ? 2 : 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.backgroundGrey,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  s.icon,
                                  color: selected
                                      ? Colors.white
                                      : AppColors.textMedium,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  s.label,
                                  style: AppTextStyles.headingMedium.copyWith(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.textDark,
                                  ),
                                ),
                              ),
                              if (selected)
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 14),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: "C'est parti !",
                      isLoading: _isLoading,
                      onPressed: _finish,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: _finish,
                        child: Text(
                          'Passer cette étape',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textMedium,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningStyle {
  final String key;
  final String label;
  final IconData icon;
  const _LearningStyle(
      {required this.key, required this.label, required this.icon});
}
