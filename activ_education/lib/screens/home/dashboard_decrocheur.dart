import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../services/api_service.dart';
import '../../widgets/skeleton_widget.dart';

class DashboardDecrocheur extends StatefulWidget {
  const DashboardDecrocheur({super.key});

  @override
  State<DashboardDecrocheur> createState() => _DashboardDecrocheurState();
}

class _DashboardDecrocheurState extends State<DashboardDecrocheur> {
  final _api = ApiService();
  bool _isLoading = true;
  String? _prenom;
  int _nbMessagesNonLus = 0;
  bool _aRendezvous = false;

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
        _nbMessagesNonLus = await _api.getMessagesNonLus(trackingId);
        try {
          final rdvs = await _api.getRDVEleve(trackingId);
          _aRendezvous = rdvs.isNotEmpty;
        } catch (_) {}
      }
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
                        child: _buildBienveillanceCard(),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildQuickActions(),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildParcoursSection(),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildRessourcesSection(),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildConseillerCta(),
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
        gradient: LinearGradient(
          colors: [Color(0xFFFF8A65), Color(0xFFFF6B35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour ${_prenom ?? ""} !',
                style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                'On est là pour toi, pas à pas.',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatBadge(Icons.chat_bubble_rounded, '$_nbMessagesNonLus nouveaux messages'),
                  const SizedBox(width: 12),
                  _buildStatBadge(
                    Icons.calendar_today_rounded,
                    _aRendezvous ? 'RDV à venir' : 'Aucun RDV',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBienveillanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_rounded, color: Color(0xFFE65100), size: 24),
              const SizedBox(width: 10),
              Text('On ne lâche rien !',
                  style: AppTextStyles.headingMedium.copyWith(color: const Color(0xFFE65100))),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Chaque parcours est unique. Que tu sois en réflexion, en reprise '
            'd\'études ou à la recherche de nouvelles opportunités, '
            'tu n\'es pas seul·e. Des conseillers sont là pour t\'accompagner.',
            style: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFF5D4037)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(child: _buildActionCard(
          icon: Icons.chat_bubble_outline_rounded,
          label: 'Parler à un conseiller',
          color: AppColors.primary,
          route: AppRoutes.conseillers,
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildActionCard(
          icon: Icons.explore_outlined,
          label: 'Explorer les métiers',
          color: const Color(0xFFFF6B35),
          route: AppRoutes.explorer,
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildActionCard(
          icon: Icons.calendar_month_rounded,
          label: 'Prendre RDV',
          color: const Color(0xFF4CAF50),
          route: AppRoutes.rdv,
        )),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParcoursSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ton parcours pas à pas', style: AppTextStyles.headingMedium),
        const SizedBox(height: 16),
        _buildStepCard(
          number: '1',
          title: 'Fais le point',
          subtitle: 'Un quiz pour mieux cerner tes envies et tes atouts',
          icon: Icons.psychology_rounded,
          isActive: true,
          route: AppRoutes.quiz,
        ),
        const SizedBox(height: 12),
        _buildStepCard(
          number: '2',
          title: 'Découvre des pistes',
          subtitle: 'Explore les métiers et formations qui te correspondent',
          icon: Icons.explore_rounded,
          isActive: false,
          route: AppRoutes.explorer,
        ),
        const SizedBox(height: 12),
        _buildStepCard(
          number: '3',
          title: 'Échange avec un conseiller',
          subtitle: 'Un accompagnement personnalisé pour construire ton projet',
          icon: Icons.people_rounded,
          isActive: false,
          route: AppRoutes.conseillers,
        ),
      ],
    );
  }

  Widget _buildStepCard({
    required String number,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isActive,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : AppColors.backgroundGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.cardBorder,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.textLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textMedium)),
                ],
              ),
            ),
            Icon(
              isActive ? Icons.arrow_forward_rounded : Icons.lock_outline_rounded,
              color: isActive ? AppColors.primary : AppColors.textLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRessourcesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ressources pour t\'aider', style: AppTextStyles.headingMedium),
        const SizedBox(height: 16),
        _buildRessourceTile(
          icon: Icons.school_rounded,
          title: 'Dispositifs de réinsertion',
          subtitle: 'Découvre les structures près de chez toi',
        ),
        const Divider(height: 1),
        _buildRessourceTile(
          icon: Icons.assignment_rounded,
          title: 'Formations qualifiantes',
          subtitle: 'Des formations courtes pour rebondir rapidement',
        ),
        const Divider(height: 1),
        _buildRessourceTile(
          icon: Icons.work_rounded,
          title: 'Jobs et stages',
          subtitle: 'Trouve des opportunités près de toi',
        ),
      ],
    );
  }

  Widget _buildRessourceTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
      onTap: () {},
    );
  }

  Widget _buildConseillerCta() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.conseillers),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Besoin d\'un coup de pouce ?',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nos conseillers sont là pour t\'écouter et t\'accompagner, sans jugement.',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}
