import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../widgets/skeleton_widget.dart';
import '../errors/empty_content_screen.dart';

class DiagnosticEnfantScreen extends StatefulWidget {
  final String enfantId;
  const DiagnosticEnfantScreen({super.key, required this.enfantId});

  @override
  State<DiagnosticEnfantScreen> createState() => _DiagnosticEnfantScreenState();
}

class _DiagnosticEnfantScreenState extends State<DiagnosticEnfantScreen> {
  final _api = ApiService();
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';

  EleveResponse? _eleve;
  ResultatDiagnosticResponse? _resultat;
  List<FicheSerieResponse> _series = [];
  List<HistoriqueResponse> _historique = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });
    try {
      final results = await Future.wait([
        _api.getEleve(widget.enfantId),
        _api.diagnostic.getHistoriqueResultats(widget.enfantId),
        _api.listerSeries(page: 0, size: 10),
        _api.dio.get('/api/v1/utilisateurs/${widget.enfantId}/historique'),
      ]);

      final eleve = results[0] as EleveResponse;
      final resultats = results[1] as List<ResultatDiagnosticResponse>;
      final seriesPage = results[2] as PageResponse<FicheSerieResponse>;
      final histData = results[3] as dynamic;

      if (mounted) {
        setState(() {
          _eleve = eleve;
          _resultat = resultats.isNotEmpty ? resultats.first : null;
          _series = seriesPage.content;
          _historique = (histData.data as List)
              .map((e) => HistoriqueResponse.fromJson(e))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isError = true;
          _errorMessage = _api.handleError(e);
        });
      }
    }
  }

  List<double> get _scores {
    switch (_resultat?.profilDecouvert ?? '') {
      case 'Scientifique':
        return [0.9, 0.7, 0.3];
      case 'Technique':
        return [0.6, 0.9, 0.2];
      case 'Littéraire':
        return [0.3, 0.2, 0.9];
      case 'Polyvalent':
        return [0.7, 0.6, 0.7];
      default:
        return [0.33, 0.33, 0.33];
    }
  }

  List<_SeriesRecommendation> get _recommendations {
    final profil = _resultat?.profilDecouvert ?? '';
    switch (profil) {
      case 'Scientifique':
        return [
          _SeriesRecommendation('Série C', 'Sciences Mathématiques',
              _findSerie('Série C'), AppColors.success),
          _SeriesRecommendation('Série D', 'Sciences Expérimentales',
              _findSerie('Série D'), AppColors.warning),
          _SeriesRecommendation('Série A', 'Lettres', null, AppColors.textLight),
        ];
      case 'Technique':
        return [
          _SeriesRecommendation('Série E', 'Sciences Techniques',
              _findSerie('Série E'), AppColors.success),
          _SeriesRecommendation('Série F', 'Sciences Technologiques',
              _findSerie('Série F'), AppColors.warning),
          _SeriesRecommendation('Série A', 'Lettres', null, AppColors.textLight),
        ];
      case 'Littéraire':
        return [
          _SeriesRecommendation('Série A', 'Lettres',
              _findSerie('Série A'), AppColors.success),
          _SeriesRecommendation('Série B', 'Lettres et Sciences',
              _findSerie('Série B'), AppColors.warning),
          _SeriesRecommendation('Série C', 'Sciences', null, AppColors.textLight),
        ];
      case 'Polyvalent':
        return [
          _SeriesRecommendation('Série C', 'Sciences Mathématiques',
              _findSerie('Série C'), AppColors.success),
          _SeriesRecommendation('Série D', 'Sciences Expérimentales',
              _findSerie('Série D'), AppColors.warning),
          _SeriesRecommendation('Série A', 'Lettres',
              _findSerie('Série A'), AppColors.warning),
        ];
      default:
        return _series.take(3).map((s) => _SeriesRecommendation(
            s.titre, s.resume, s, AppColors.textLight)).toList();
    }
  }

  FicheSerieResponse? _findSerie(String titre) {
    try {
      return _series.firstWhere((s) => s.titre.contains(titre));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        leading: BackButton(color: AppColors.primary),
        title: Text("Diagnostic",
            style: AppTextStyles.headingMedium
                .copyWith(color: AppColors.primary)),
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const _DiagnosticSkeleton();
    if (_isError) return _buildErrorState();
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(),
            const SizedBox(height: 20),
            _buildProfilDetecte(),
            const SizedBox(height: 20),
            _buildRadarChartSection(),
            const SizedBox(height: 24),
            _buildRecommandationsSection(),
            const SizedBox(height: 24),
            _buildHistoriqueSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 40, color: AppColors.error),
            ),
            const SizedBox(height: 20),
            Text(
              'Une erreur est survenue',
              style: AppTextStyles.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.rdv),
          icon: const Icon(Icons.forum_rounded, size: 22),
          label: const Text('Contacter un conseiller'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textWhite,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: AppTextStyles.buttonText,
          ),
        ),
      ),
    );
  }

  // ─── Profile Card ───────────────────────────────────────────────────────

  Widget _buildProfileCard() {
    final e = _eleve;
    if (e == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.person_rounded,
                color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${e.prenom} ${e.nom}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                const SizedBox(height: 4),
                if (e.niveauEtude != null || e.etablissementActuel != null)
                  Text(
                    '${e.niveauEtude ?? ''}${e.niveauEtude != null && e.etablissementActuel != null ? ' — ' : ''}${e.etablissementActuel ?? ''}',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textMedium),
                  ),
                if (e.typeApprenant.isNotEmpty)
                  Text(e.typeApprenant,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Profil Détecté ─────────────────────────────────────────────────────

  Widget _buildProfilDetecte() {
    if (_resultat == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)
          ],
        ),
        child: const Column(
          children: [
            Icon(Icons.assessment_rounded,
                size: 48, color: AppColors.textLight),
            SizedBox(height: 12),
            Text('Aucun diagnostic pour le moment',
                style: TextStyle(
                    fontSize: 15, color: AppColors.textMedium)),
          ],
        ),
      );
    }

    final r = _resultat!;
    final dateStr = r.datePassage != null
        ? DateFormat('dd MMMM yyyy', 'fr_FR').format(r.datePassage!)
        : 'Date inconnue';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('PROFIL DÉTECTÉ',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.2)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            r.profilDecouvert ?? 'Non défini',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFamily: 'Poppins',
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 14, color: Colors.white70),
              const SizedBox(width: 6),
              Text(dateStr,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.white70)),
              if (r.scoreFinal != null) ...[
                const SizedBox(width: 16),
                const Icon(Icons.star_rounded,
                    size: 14, color: Colors.white70),
                const SizedBox(width: 6),
                Text('Score : ${r.scoreFinal!.toStringAsFixed(1)}%',
                    style: const TextStyle(
                        fontSize: 13, color: Colors.white70)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ─── Radar Triangle Chart ───────────────────────────────────────────────

  Widget _buildRadarChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              const Icon(Icons.radar_rounded,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Profil multidimensionnel',
                  style: AppTextStyles.headingSmall),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8)
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: 260,
                child: CustomPaint(
                  size: const Size(double.infinity, 260),
                  painter: _RadarTrianglePainter(scores: _scores),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAxisLabel('Sciences', AppColors.primary),
                  _buildAxisLabel('Technique', AppColors.success),
                  _buildAxisLabel('Lettres', AppColors.accent),
                ],
              ),
              const SizedBox(height: 8),
              _buildScoreBars(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAxisLabel(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
      ],
    );
  }

  Widget _buildScoreBars() {
    final labels = ['Sciences', 'Technique', 'Lettres'];
    final colors = [AppColors.primary, AppColors.success, AppColors.accent];
    return Column(
      children: List.generate(3, (i) {
        final pct = (_scores[i] * 100).round();
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                child: Text(labels[i],
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMedium)),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _scores[i],
                    minHeight: 8,
                    backgroundColor:
                        colors[i].withValues(alpha: 0.12),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(colors[i]),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 36,
                child: Text('$pct%',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ─── Recommandations ────────────────────────────────────────────────────

  Widget _buildRecommandationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_rounded,
                  size: 20, color: AppColors.accent),
              const SizedBox(width: 8),
              Text('Recommandations',
                  style: AppTextStyles.headingSmall),
            ],
          ),
        ),
        ..._recommendations.map((rec) => _buildRecommendationCard(rec)),
      ],
    );
  }

  Widget _buildRecommendationCard(_SeriesRecommendation rec) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: rec.badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.school_rounded,
                color: rec.badgeColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(rec.title,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: rec.badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        rec.badgeColor == AppColors.success
                            ? 'Recommandé'
                            : rec.badgeColor == AppColors.warning
                                ? 'Alternative'
                                : 'Optionnel',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: rec.badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(rec.subtitle,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textMedium)),
              ],
            ),
          ),
          if (rec.serie != null)
            GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.ficheDetail,
                arguments: {
                  'ficheId': rec.serie!.trackingId,
                  'type': 'SERIE'
                },
              ),
              child: const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textLight, size: 22),
            ),
        ],
      ),
    );
  }

  // ─── Historique des consultations ───────────────────────────────────────

  Widget _buildHistoriqueSection() {
    final prenom = _eleve?.prenom ?? "l'enfant";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              const Icon(Icons.history_rounded,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Ce que $prenom a exploré',
                  style: AppTextStyles.headingSmall),
            ],
          ),
        ),
        if (_historique.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8)
              ],
            ),
            child: const EmptyContentScreen(
              icon: Icons.explore_rounded,
              title: 'Aucune exploration récente',
              subtitle: 'Les consultations de fiches apparaîtront ici',
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _historique.take(12).map((h) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.cardBorder, width: 1),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4)
                  ],
                ),
                child: Text(
                  h.details ?? h.action,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

// ─── Model for recommendations ───────────────────────────────────────────

class _SeriesRecommendation {
  final String title;
  final String subtitle;
  final FicheSerieResponse? serie;
  final Color badgeColor;
  _SeriesRecommendation(
      this.title, this.subtitle, this.serie, this.badgeColor);
}

// ─── Radar Triangle CustomPainter ────────────────────────────────────────

class _RadarTrianglePainter extends CustomPainter {
  final List<double> scores;

  _RadarTrianglePainter({required this.scores});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 24;

    final angles = [
      -math.pi / 2,
      math.pi / 6,
      5 * math.pi / 6,
    ];

    final vertices = List.generate(3, (i) => Offset(
          center.dx + radius * math.cos(angles[i]),
          center.dy + radius * math.sin(angles[i]),
        ));

    // Grid lines (0.25, 0.5, 0.75)
    for (final level in [0.25, 0.5, 0.75]) {
      final pts = List.generate(3, (i) => Offset(
            center.dx + radius * level * math.cos(angles[i]),
            center.dy + radius * level * math.sin(angles[i]),
          ));
      final path = Path()
        ..moveTo(pts[0].dx, pts[0].dy)
        ..lineTo(pts[1].dx, pts[1].dy)
        ..lineTo(pts[2].dx, pts[2].dy)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.cardBorder.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    // Outer triangle
    final outerPath = Path()
      ..moveTo(vertices[0].dx, vertices[0].dy)
      ..lineTo(vertices[1].dx, vertices[1].dy)
      ..lineTo(vertices[2].dx, vertices[2].dy)
      ..close();
    canvas.drawPath(
      outerPath,
      Paint()
        ..color = AppColors.cardBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Axis lines from center to vertices
    for (final v in vertices) {
      canvas.drawLine(
        center,
        v,
        Paint()
          ..color = AppColors.cardBorder.withValues(alpha: 0.4)
          ..strokeWidth = 1,
      );
    }

    // Data triangle vertices
    final dataVertices = List.generate(3, (i) => Offset(
          center.dx + radius * scores[i] * math.cos(angles[i]),
          center.dy + radius * scores[i] * math.sin(angles[i]),
        ));

    // Data fill
    final dataPath = Path()
      ..moveTo(dataVertices[0].dx, dataVertices[0].dy)
      ..lineTo(dataVertices[1].dx, dataVertices[1].dy)
      ..lineTo(dataVertices[2].dx, dataVertices[2].dy)
      ..close();
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill,
    );

    // Data stroke
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Data points
    for (final v in dataVertices) {
      canvas.drawCircle(
        v,
        4,
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        v,
        4,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Labels
    final labelNames = ['Sciences', 'Technique', 'Lettres'];
    const labelOffset = 22.0;
    for (var i = 0; i < 3; i++) {
      final labelPos = Offset(
        center.dx + (radius + labelOffset) * math.cos(angles[i]),
        center.dy + (radius + labelOffset) * math.sin(angles[i]),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: labelNames[i],
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      tp.paint(
        canvas,
        labelPos - Offset(tp.width / 2, tp.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarTrianglePainter oldDelegate) {
    return oldDelegate.scores != scores;
  }
}

// ─── Skeleton pour l'écran de diagnostic enfant ─────────────────────────

class _DiagnosticSkeleton extends StatelessWidget {
  const _DiagnosticSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile card skeleton
          SkeletonWidget(height: 76, borderRadius: 16),
          const SizedBox(height: 20),
          // Profil détecté skeleton
          SkeletonWidget(height: 160, borderRadius: 20),
          const SizedBox(height: 20),
          // Section title skeleton
          SkeletonWidget(width: 180, height: 18),
          const SizedBox(height: 12),
          // Chart skeleton
          SkeletonWidget(height: 340, borderRadius: 16),
          const SizedBox(height: 24),
          // Section title skeleton
          SkeletonWidget(width: 140, height: 18),
          const SizedBox(height: 12),
          // Recommendation cards skeleton
          SkeletonWidget(height: 72, borderRadius: 14),
          const SizedBox(height: 10),
          SkeletonWidget(height: 72, borderRadius: 14),
          const SizedBox(height: 10),
          SkeletonWidget(height: 72, borderRadius: 14),
          const SizedBox(height: 24),
          // Section title skeleton
          SkeletonWidget(width: 160, height: 18),
          const SizedBox(height: 12),
          // Chips skeleton
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              SkeletonWidget(width: 100, height: 34, borderRadius: 20),
              SizedBox(width: 8),
              SkeletonWidget(width: 120, height: 34, borderRadius: 20),
              SizedBox(width: 8),
              SkeletonWidget(width: 90, height: 34, borderRadius: 20),
              SizedBox(width: 8),
              SkeletonWidget(width: 130, height: 34, borderRadius: 20),
              SizedBox(width: 8),
              SkeletonWidget(width: 110, height: 34, borderRadius: 20),
            ],
          ),
        ],
      ),
    );
  }
}
