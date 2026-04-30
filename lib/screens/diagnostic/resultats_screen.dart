// lib/screens/diagnostic/resultats_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';

class ResultatsScreen extends StatefulWidget {
  final double? score;
  final String? quizId;
  final String? profil; // Profil RIASEC calculé

  const ResultatsScreen({super.key, this.score, this.quizId, this.profil});

  @override
  State<ResultatsScreen> createState() => _ResultatsScreenState();
}

class _ResultatsScreenState extends State<ResultatsScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();

  ResultatDiagnosticResponse? _resultat;
  List<FicheFiliereResponse> _recommandations = [];
  bool _isLoading = true;

  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadResultats();
  }

  void _initAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadResultats() async {
    try {
      setState(() => _isLoading = true);

      final trackingId = await _api.getTrackingId();
      if (trackingId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Cas 1 : On vient de terminer un quiz (score passé en argument)
      if (widget.score != null && widget.quizId != null) {
        final page = await _api.listerFilieres(page: 0, size: 50);
        final toutesFilieres = page.content;

        // Filtrer selon le profil RIASEC si disponible
        final profil = widget.profil ?? '';
        List<FicheFiliereResponse> filtrees;

        if (profil.contains('Réaliste') || profil.contains('Investigateur')) {
          // Profils techniques/scientifiques
          filtrees = toutesFilieres
              .where((f) =>
                  f.domaine?.toLowerCase().contains('informatique') == true ||
                  f.domaine?.toLowerCase().contains('science') == true ||
                  f.domaine?.toLowerCase().contains('ingénieur') == true ||
                  f.domaine?.toLowerCase().contains('technique') == true ||
                  f.titre.toLowerCase().contains('génie') == true ||
                  f.titre.toLowerCase().contains('math') == true)
              .toList();
        } else if (profil.contains('Artistique')) {
          filtrees = toutesFilieres
              .where((f) =>
                  f.domaine?.toLowerCase().contains('art') == true ||
                  f.domaine?.toLowerCase().contains('design') == true ||
                  f.domaine?.toLowerCase().contains('communication') == true ||
                  f.titre.toLowerCase().contains('art') == true ||
                  f.titre.toLowerCase().contains('design') == true)
              .toList();
        } else if (profil.contains('Social')) {
          filtrees = toutesFilieres
              .where((f) =>
                  f.domaine?.toLowerCase().contains('santé') == true ||
                  f.domaine?.toLowerCase().contains('social') == true ||
                  f.domaine?.toLowerCase().contains('éducation') == true ||
                  f.titre.toLowerCase().contains('enseignement') == true ||
                  f.titre.toLowerCase().contains('médecine') == true)
              .toList();
        } else if (profil.contains('Entreprenant') || profil.contains('Conventionnel')) {
          filtrees = toutesFilieres
              .where((f) =>
                  f.domaine?.toLowerCase().contains('gestion') == true ||
                  f.domaine?.toLowerCase().contains('économie') == true ||
                  f.domaine?.toLowerCase().contains('commerce') == true ||
                  f.titre.toLowerCase().contains('comptabilité') == true ||
                  f.titre.toLowerCase().contains('management') == true)
              .toList();
        } else {
          filtrees = toutesFilieres;
        }

        // Si pas de résultats filtrés, prendre les premières filières
        if (filtrees.isEmpty) filtrees = toutesFilieres;

        setState(() {
          _recommandations = filtrees.take(8).toList();
          _isLoading = false;
        });
      }
      // Cas 2 : Consultation de l'historique des résultats
      else {
        final resultatsPage =
            await _api.getResultatsEleve(trackingId, page: 0, size: 5);
        if (resultatsPage.content.isNotEmpty) {
          setState(() {
            _resultat = resultatsPage.content.first;
            _isLoading = false;
          });
          // Charger des filières en complément
          final filieresPage = await _api.listerFilieres(page: 0, size: 50);
          setState(() {
            _recommandations = filieresPage.content.take(8).toList();
          });
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des résultats')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.score ?? (_resultat?.scoreFinal ?? 0.0);
    final intScore = score.toInt();

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundGrey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: AppColors.textDark,
                                  size: 18),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Résultats du diagnostic',
                            style: AppTextStyles.headingMedium
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ),
                  ),

                  // Score Card avec animation
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: ScaleTransition(
                          scale: _scaleAnim,
                          child: _buildScoreCard(score, intScore),
                        ),
                      ),
                    ),
                  ),

                  // Titre des recommandations
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Filières recommandées pour vous',
                        style: AppTextStyles.headingMedium,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Liste des recommandations
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: _recommandations.isEmpty
                        ? SliverToBoxAdapter(
                            child: _buildEmptyRecommandations())
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final filiere = _recommandations[index];
                                final matchScore =
                                    (95 - (index * 8)).clamp(65, 95);
                                return _RecommandationCard(
                                  filiere: filiere,
                                  matchScore: matchScore,
                                );
                              },
                              childCount: _recommandations.length,
                            ),
                          ),
                  ),
                ],
              ),
      ),
      // Floating Action Button pour actions rapides
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.quiz),
        label: const Text('Refaire un quiz'),
        icon: const Icon(Icons.replay_rounded),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildScoreCard(double score, int intScore) {
    String title;
    String subtitle;
    Color accentColor;

    if (intScore >= 85) {
      title = "Excellent résultat !";
      subtitle = "Votre profil est très clair et affirmé";
      accentColor = AppColors.success ?? Colors.green;
    } else if (intScore >= 70) {
      title = "Très bon résultat !";
      subtitle = "Vous avez de solides orientations";
      accentColor = AppColors.primary;
    } else if (intScore >= 50) {
      title = "Bon début";
      subtitle = "Continuez à explorer vos intérêts";
      accentColor = AppColors.accent;
    } else {
      title = "Diagnostic en cours";
      subtitle = "Plus de réponses permettront d'affiner votre profil";
      accentColor = AppColors.textMedium;
    }

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.12),
            accentColor.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor.withOpacity(0.25), width: 2),
      ),
      child: Column(
        children: [
          // Cercle de score
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 14,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$intScore',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                      ),
                    ),
                    Text(
                      '%',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: accentColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: AppTextStyles.headingLarge.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style:
                AppTextStyles.bodyLarge.copyWith(color: AppColors.textMedium),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRecommandations() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.explore_outlined,
              size: 64, color: AppColors.primary.withOpacity(0.6)),
          const SizedBox(height: 20),
          Text(
            'Découvrez plus de filières',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Explorez notre catalogue complet pour trouver celle qui vous correspond le mieux.',
            textAlign: TextAlign.center,
            style:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textMedium),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Explorer toutes les filières',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.explorer),
          ),
        ],
      ),
    );
  }
}

class _RecommandationCard extends StatelessWidget {
  final FicheFiliereResponse filiere;
  final int matchScore;

  const _RecommandationCard({
    super.key,
    required this.filiere,
    required this.matchScore,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Naviguer vers détail de la filière
        // Navigator.pushNamed(context, AppRoutes.filiereDetail, arguments: filiere.trackingId);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    filiere.titre,
                    style: AppTextStyles.label.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$matchScore% match',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (filiere.domaine != null && filiere.domaine!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                filiere.domaine!,
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.textMedium),
              ),
            ],
            if (filiere.resume != null && filiere.resume!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                filiere.resume!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Voir le détail',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded,
                        color: AppColors.primary, size: 16),
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
