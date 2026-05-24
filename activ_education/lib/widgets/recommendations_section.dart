import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/recommendation_service.dart';
import '../screens/explorer/fiche_detail_screen.dart';

class RecommendationsSection extends StatelessWidget {
  final List<RecommendationResult> recommendations;

  const RecommendationsSection({super.key, required this.recommendations});

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) return const SizedBox.shrink();

    final toShow = recommendations.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lightbulb_rounded, color: AppColors.accent, size: 22),
            const SizedBox(width: 8),
            const Text('Recommandations pour vous', style: AppTextStyles.headingMedium),
          ],
        ),
        const SizedBox(height: 12),
        ...toShow.map((r) => _RecommendationCard(recommendation: r)),
        if (recommendations.length > 4) ...[
          const SizedBox(height: 4),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text('Voir les ${recommendations.length} recommandations',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final RecommendationResult recommendation;

  const _RecommendationCard({required this.recommendation});

  Color get _color {
    switch (recommendation.type) {
      case 'Filière': return const Color(0xFF10B981);
      case 'Métier': return AppColors.accent;
      case 'Série': return AppColors.primary;
      default: return const Color(0xFF8B5CF6);
    }
  }

  IconData get _icon {
    switch (recommendation.type) {
      case 'Filière': return Icons.account_tree_rounded;
      case 'Métier': return Icons.work_rounded;
      case 'Série': return Icons.book_rounded;
      default: return Icons.lightbulb_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (recommendation.fiche != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FicheDetailScreen(fiche: recommendation.fiche!),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _color.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, color: _color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(recommendation.titre,
                          style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(recommendation.type,
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _color)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(recommendation.description,
                      style: AppTextStyles.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
