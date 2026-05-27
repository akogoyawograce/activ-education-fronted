import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../widgets/skeleton_widget.dart';

class DashboardReconversion extends StatefulWidget {
  const DashboardReconversion({super.key});

  @override
  State<DashboardReconversion> createState() => _DashboardReconversionState();
}

class _DashboardReconversionState extends State<DashboardReconversion> {
  final _api = ApiService();
  bool _isLoading = true;
  String? _prenom;
  List<FicheMetierResponse> _metiers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final trackingId = await _api.getTrackingId();
      if (trackingId != null) {
        final info = await _api.getUtilisateurNom(trackingId);
        _prenom = info['prenom'];
      }
      final metiersRes = await _api.listerMetiers(page: 0, size: 2);
      _metiers = metiersRes.content;
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const SkeletonDashboard()
            : RefreshIndicator(
                onRefresh: _loadData,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildCitationCard(),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildTimelineSection(),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildRessourcesSection(),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildConseillersCta(),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildExpertSection(),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -10,
            child: Icon(
              Icons.star,
              size: 120,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour ${_prenom ?? ""} !',
                          style: AppTextStyles.displayMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Reconversion professionnelle',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.wb_sunny,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"La reconversion professionnelle est le moment idéal pour '
            'aligner vos valeurs avec votre métier."',
            style: AppTextStyles.bodyMedium.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.quiz),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Commencer ma réflexion',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Votre parcours recommandé',
          style: AppTextStyles.headingMedium,
        ),
        const SizedBox(height: 20),
        _buildTimelineStep(
          number: '1',
          title: 'Parler à un conseiller',
          subtitle: 'Échangez avec un expert pour définir vos objectifs',
          isActive: true,
          actionLabel: 'Prendre RDV maintenant',
          actionRoute: AppRoutes.rdv,
          isFirst: true,
        ),
        _buildTimelineStep(
          number: '2',
          title: 'Quiz de reconversion',
          subtitle: 'Identifiez vos compétences transférables',
          isActive: false,
          actionLabel: 'Commencer le quiz',
          actionRoute: AppRoutes.quiz,
        ),
        _buildTimelineStep(
          number: '3',
          title: 'Explorer les formations',
          subtitle: 'Trouvez la formation adaptée à votre projet',
          isActive: false,
          actionLabel: 'Découvrir',
          actionRoute: AppRoutes.explorer,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required String number,
    required String title,
    required String subtitle,
    required bool isActive,
    required String actionLabel,
    required String actionRoute,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 12,
                    color: AppColors.cardBorder,
                  )
                else
                  const SizedBox(height: 12),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.cardBorder,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.cardBorder,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  title,
                  style: AppTextStyles.label.copyWith(
                    fontSize: 15,
                    color: isActive
                        ? AppColors.textDark
                        : AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.caption),
                const SizedBox(height: 12),
                if (isActive)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, actionRoute),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        actionLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, actionRoute),
                    child: Text(
                      actionLabel,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRessourcesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ressources utiles',
          style: AppTextStyles.headingMedium,
        ),
        const SizedBox(height: 16),
        if (_metiers.isEmpty)
          const SizedBox(
            height: 100,
            child: Center(
              child: Text(
                'Aucune ressource disponible',
                style: AppTextStyles.caption,
              ),
            ),
          )
        else
          Row(
            children: [
              Expanded(child: _buildMetierCard(_metiers[0])),
              if (_metiers.length > 1) ...[
                const SizedBox(width: 12),
                Expanded(child: _buildMetierCard(_metiers[1])),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildMetierCard(FicheMetierResponse metier) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.ficheDetail,
        arguments: metier.trackingId,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.work_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              metier.titre,
              style: AppTextStyles.label.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              metier.secteur ?? metier.resume,
              style: AppTextStyles.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConseillersCta() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.conseillers),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.people_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nos conseillers',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Trouve un conseiller et échange avec lui',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textMedium),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLight,
            child: Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Votre expert',
                  style: AppTextStyles.label.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Conseiller disponible',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textLight,
            size: 22,
          ),
        ],
      ),
    );
  }
}
