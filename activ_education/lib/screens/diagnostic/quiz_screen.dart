// emplacement : lib/screens/diagnostic/quiz_screen.dart

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class QuizScreen extends StatefulWidget {
  final String? quizTrackingId;
  const QuizScreen({super.key, this.quizTrackingId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  final _api = ApiService();

  QuizResponse? _quiz;
  List<QuestionResponse> _questions = [];
  Map<String, List<ReponseResponse>> _reponsesParQuestion = {};
  final Map<String, String> _reponsesChoisies = {};

  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _fadeAnimation =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _loadQuiz();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadQuiz() async {
    try {
      setState(() => _isLoading = true);
      QuizResponse quiz;
      if (widget.quizTrackingId != null) {
        quiz = await _api.getQuiz(widget.quizTrackingId!);
      } else {
        final page = await _api.listerQuiz(size: 1);
        if (page.content.isEmpty) {
          setState(() {
            _error = 'Aucun quiz disponible';
            _isLoading = false;
          });
          return;
        }
        quiz = page.content.first;
      }
      final questions = await _api.getQuestionsQuiz(quiz.trackingId);
      final reponsesResults = await Future.wait(
        questions.map((q) => _api.getReponsesQuestion(q.trackingId)),
      );
      final Map<String, List<ReponseResponse>> repMap = {};
      for (int i = 0; i < questions.length; i++) {
        repMap[questions[i].trackingId] = reponsesResults[i];
      }
      setState(() {
        _quiz = quiz;
        _questions = questions;
        _reponsesParQuestion = repMap;
        _isLoading = false;
      });
      _animController.forward();
    } catch (e) {
      setState(() {
        _error = 'Erreur de chargement du quiz';
        _isLoading = false;
      });
    }
  }

  QuestionResponse? get _currentQuestion =>
      _questions.isNotEmpty ? _questions[_currentIndex] : null;

  List<ReponseResponse> get _currentReponses {
    if (_currentQuestion == null) return [];
    return _reponsesParQuestion[_currentQuestion!.trackingId] ?? [];
  }

  bool get _hasAnswered =>
      _currentQuestion != null &&
      _reponsesChoisies.containsKey(_currentQuestion!.trackingId);

  double get _progress =>
      _questions.isEmpty ? 0 : (_currentIndex + 1) / _questions.length;

  void _selectReponse(String reponseId) {
    if (_currentQuestion == null) return;
    setState(() {
      _reponsesChoisies[_currentQuestion!.trackingId] = reponseId;
    });
  }

  void _nextQuestion() async {
    if (!_hasAnswered) return;
    if (_currentIndex < _questions.length - 1) {
      await _animController.reverse();
      setState(() => _currentIndex++);
      _animController.forward();
    } else {
      _submitQuiz();
    }
  }

  void _previousQuestion() async {
    if (_currentIndex == 0) return;
    await _animController.reverse();
    setState(() => _currentIndex--);
    _animController.forward();
  }

  Future<void> _submitQuiz() async {
    setState(() => _isSaving = true);
    try {
      double scoreFinal = 0;
      for (final entry in _reponsesChoisies.entries) {
        final reponses = _reponsesParQuestion[entry.key] ?? [];
        final chosen = reponses.firstWhere(
          (r) => r.trackingId == entry.value,
          orElse: () => ReponseResponse(
              trackingId: '',
              texteReponse: '',
              points: 0,
              questionTrackingId: ''),
        );
        scoreFinal += chosen.points;
      }
      final profil = _determinerProfil(scoreFinal);
      final eleveId = await _api.getTrackingId();
      if (eleveId != null && _quiz != null) {
        await _api.enregistrerResultat(ResultatDiagnosticRequest(
          eleveTrackingId: eleveId,
          quizTrackingId: _quiz!.trackingId,
          scoreFinal: scoreFinal,
          profilDecouvert: profil,
          recommandation: _getRecommandation(profil),
        ));
      }
      setState(() => _isSaving = false);
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.resultats,
          arguments: {
            'score': scoreFinal,
            'profil': profil,
            'quizId': _quiz?.trackingId,
            'eleveId': eleveId,
          },
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  /// Calcule le profil RIASEC à partir des réponses
  /// R = Réaliste, I = Investigateur, A = Artistique, S = Social, E = Entreprenant, C = Conventionnel
  Map<String, double> _calculerProfilRIASEC() {
    final scores = {'R': 0.0, 'I': 0.0, 'A': 0.0, 'S': 0.0, 'E': 0.0, 'C': 0.0};

    for (final entry in _reponsesChoisies.entries) {
      final reponses = _reponsesParQuestion[entry.key] ?? [];
      final chosen = reponses.firstWhere(
        (r) => r.trackingId == entry.value,
        orElse: () => ReponseResponse(
            trackingId: '', texteReponse: '', points: 0, questionTrackingId: ''),
      );

      // La catégorie RIASEC est stockrée dans categoriePoint (ex: 'R', 'I', 'A', 'S', 'E', 'C')
      final categorie = chosen.categoriePoint;
      if (categorie != null && scores.containsKey(categorie.toUpperCase())) {
        scores[categorie.toUpperCase()] = (scores[categorie.toUpperCase()] ?? 0) + chosen.points;
      }
    }

    return scores;
  }

  String _determinerProfil(double score) {
    final riasec = _calculerProfilRIASEC();

    // Trouver les 2 dominantes
    final entries = riasec.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final dominante1 = entries.isNotEmpty ? entries.first.key : 'X';
    final dominante2 = entries.length > 1 ? entries[1].key : 'X';

    final labelRIASEC = {
      'R': 'Réaliste',
      'I': 'Investigateur',
      'A': 'Artistique',
      'S': 'Social',
      'E': 'Entreprenant',
      'C': 'Conventionnel',
    };

    return 'Profil ${labelRIASEC[dominante1]} - ${labelRIASEC[dominante2]}';
  }

  String _getRecommandation(String profil) {
    if (profil.contains('Réaliste')) {
      return 'Métiers manuels, technique, ingénierie, agriculture, BTP';
    }
    if (profil.contains('Investigateur')) {
      return 'Sciences, recherche, informatique, santé, analyse';
    }
    if (profil.contains('Artistique')) {
      return 'Arts, design, communication, musique, écriture';
    }
    if (profil.contains('Social')) {
      return 'Enseignement, santé, travail social, ressources humaines';
    }
    if (profil.contains('Entreprenant')) {
      return 'Commerce, management, marketing, entrepreneuriat';
    }
    if (profil.contains('Conventionnel')) {
      return 'Administration, comptabilité, gestion, secrétariat';
    }
    return 'Explorez nos différentes filières pour trouver celle qui vous correspond';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: _isLoading
            ? const _QuizSkeleton()
            : _error != null
                ? _buildError()
                : Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: _buildContent(),
                          ),
                        ),
                      ),
                      _buildFooter(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _showQuitDialog,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.textDark, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_quiz?.titre ?? 'Quiz d\'orientation',
                        style: AppTextStyles.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text('${_currentIndex + 1} sur ${_questions.length}',
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1}/${_questions.length}',
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: AppColors.backgroundGrey,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final question = _currentQuestion;
    if (question == null) return const SizedBox.shrink();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Tes habitudes',
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.accent, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.lightbulb_outline_rounded,
                color: AppColors.accent, size: 32),
          ),
          const SizedBox(height: 20),
          Text(
            question.texteQuestion,
            style: AppTextStyles.displayMedium.copyWith(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ..._currentReponses.map((r) => _ReponseOption(
                reponse: r,
                isSelected:
                    _reponsesChoisies[question.trackingId] == r.trackingId,
                onTap: () => _selectReponse(r.trackingId),
              )),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final isLast = _currentIndex == _questions.length - 1;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Row(
        children: [
          if (_currentIndex > 0) ...[
            GestureDetector(
              onTap: _previousQuestion,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.backgroundGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.textMedium, size: 20),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _hasAnswered && !_isSaving ? _nextQuestion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _hasAnswered ? AppColors.accent : AppColors.cardBorder,
                  disabledBackgroundColor: AppColors.cardBorder,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLast ? 'Terminer le quiz' : 'Question suivante',
                            style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                              isLast
                                  ? Icons.check_rounded
                                  : Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 64, color: AppColors.error.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(_error ?? 'Erreur',
              style: AppTextStyles.headingMedium, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadQuiz,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child:
                const Text('Réessayer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Quitter le quiz ?', style: AppTextStyles.headingMedium),
        content: const Text('Ta progression sera perdue.',
            style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Continuer',
                  style: TextStyle(color: AppColors.primary))),
          TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Quitter', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
  }
}

class _ReponseOption extends StatelessWidget {
  final ReponseResponse reponse;
  final bool isSelected;
  final VoidCallback onTap;
  const _ReponseOption(
      {required this.reponse, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primary.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.cardBorder,
              width: isSelected ? 2 : 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    isSelected ? AppColors.primary : AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.radio_button_unchecked_rounded,
                  color: isSelected ? Colors.white : AppColors.textMedium,
                  size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                reponse.texteReponse,
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textDark),
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 14),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuizSkeleton extends StatelessWidget {
  const _QuizSkeleton();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 80, color: Colors.white),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(18))),
                const SizedBox(height: 24),
                Container(
                    height: 24,
                    decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(8))),
                const SizedBox(height: 32),
                ...List.generate(
                    4,
                    (i) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        height: 64,
                        decoration: BoxDecoration(
                            color: AppColors.cardBorder,
                            borderRadius: BorderRadius.circular(14)))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
