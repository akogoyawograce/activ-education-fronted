// lib/screens/diagnostic/quiz_question_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart'; // ← Import ajouté
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';

class QuizQuestionScreen extends StatefulWidget {
  final QuizResponse quiz;

  const QuizQuestionScreen({super.key, required this.quiz});

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  final ApiService _api = ApiService();

  List<QuestionResponse> _questions = [];
  Map<String, String> _userAnswers =
      {}; // questionTrackingId → reponseTrackingId
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      _questions = await _api.getQuestionsQuiz(widget.quiz.trackingId);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur de chargement des questions")),
        );
      }
    }
  }

  Future<List<ReponseResponse>> _getReponses(String questionId) async {
    try {
      return await _api.getReponsesQuestion(questionId);
    } catch (e) {
      debugPrint('Erreur chargement réponses: $e');
      return [];
    }
  }

  void _selectAnswer(String questionId, String reponseId) {
    setState(() {
      _userAnswers[questionId] = reponseId;
    });
  }

  void _next() {
    final currentQuestion = _questions[_currentIndex];
    if (!_userAnswers.containsKey(currentQuestion.trackingId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une réponse')),
      );
      return;
    }

    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _submitQuiz();
    }
  }

  Future<void> _submitQuiz() async {
    setState(() => _isSubmitting = true);

    try {
      final trackingId = await _api.getTrackingId();
      if (trackingId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur non identifié')),
        );
        return;
      }

      // Calcul du score
      int totalPoints = 0;
      const int pointsPerQuestion = 10;
      final int maxPoints = _questions.length * pointsPerQuestion;

      for (final question in _questions) {
        final selectedReponseId = _userAnswers[question.trackingId];
        if (selectedReponseId != null) {
          final reponses = await _getReponses(question.trackingId);
          final selectedReponse = reponses.firstWhere(
            (r) => r.trackingId == selectedReponseId,
            orElse: () => ReponseResponse(
              trackingId: '',
              texteReponse: '',
              points: 0,
              questionTrackingId: question.trackingId,
            ),
          );
          totalPoints += selectedReponse.points;
        }
      }

      final score = maxPoints > 0 ? (totalPoints / maxPoints * 100) : 0.0;

      // Enregistrement du résultat
      final request = ResultatDiagnosticRequest(
        eleveTrackingId: trackingId,
        quizTrackingId: widget.quiz.trackingId,
        scoreFinal: score,
        profilDecouvert: 'Profil en cours d\'analyse',
        recommandation: 'Continuez à explorer les filières selon vos intérêts.',
      );

      await _api.enregistrerResultat(request);

      // Navigation vers les résultats
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.resultats,
          arguments: {
            'score': score,
            'quizId': widget.quiz.trackingId,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de la soumission : ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = _questions[_currentIndex];
    final selectedId = _userAnswers[question.trackingId];

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: Column(
          children: [
            // Header + Progression
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          "Question ${_currentIndex + 1}/${_questions.length}",
                          style: AppTextStyles.headingMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / _questions.length,
                      backgroundColor: AppColors.cardBorder,
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.texteQuestion,
                      style: AppTextStyles.headingLarge,
                    ),
                    const SizedBox(height: 32),
                    FutureBuilder<List<ReponseResponse>>(
                      future: _getReponses(question.trackingId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text("Aucune réponse disponible"));
                        }

                        final reponses = snapshot.data!;
                        return Column(
                          children: reponses.map((reponse) {
                            final isSelected = selectedId == reponse.trackingId;
                            return GestureDetector(
                              onTap: () => _selectAnswer(
                                  question.trackingId, reponse.trackingId),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withOpacity(0.08)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.cardBorder,
                                    width: isSelected ? 2 : 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        reponse.texteReponse,
                                        style: AppTextStyles.bodyLarge,
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(Icons.check_circle,
                                          color: AppColors.primary),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  PrimaryButton(
                    label: _currentIndex < _questions.length - 1
                        ? "Suivant"
                        : "Terminer le quiz",
                    isLoading: _isSubmitting,
                    onPressed: _next,
                  ),
                  if (_currentIndex > 0)
                    TextButton(
                      onPressed: () => setState(() => _currentIndex--),
                      child: const Text("Précédent"),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
