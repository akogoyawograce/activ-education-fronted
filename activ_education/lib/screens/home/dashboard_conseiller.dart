import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../widgets/skeleton_widget.dart';
import '../errors/empty_content_screen.dart';

class DashboardConseiller extends StatefulWidget {
  const DashboardConseiller({super.key});

  @override
  State<DashboardConseiller> createState() => _DashboardConseillerState();
}

class _DashboardConseillerState extends State<DashboardConseiller> {
  final _api = ApiService();
  bool _isLoading = true;
  String? _userTrackingId;
  ConseillerResponse? _profile;
  int _pendingQuestions = 0;
  int _totalMessagesRecus = 0;
  List<RendezVousResponse> _todayRdvs = [];
  bool _isAvailable = true;
  final Map<String, String> _eleveNames = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      _userTrackingId = await _api.getTrackingId();
      if (_userTrackingId == null) return;
      _profile = await _api.auth.getConseiller(_userTrackingId!);
      _isAvailable = _profile?.actif ?? true;
      try {
        _pendingQuestions = await _api.getMessagesNonLus(_userTrackingId!);
      } catch (_) {}
      try {
        final page = await _api.getMessagesRecus(_userTrackingId!, size: 1);
        _totalMessagesRecus = page.totalElements;
      } catch (_) {}
      try {
        final allRdvs = await _api.getRDVConseiller(_userTrackingId!);
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        _todayRdvs = allRdvs
            .where((r) =>
                r.dateHeurePrevue != null &&
                r.statut == 'PLANIFIE' &&
                r.dateHeurePrevue!.year == today.year &&
                r.dateHeurePrevue!.month == today.month &&
                r.dateHeurePrevue!.day == today.day)
            .toList()
          ..sort((a, b) => a.dateHeurePrevue!.compareTo(b.dateHeurePrevue!));
        for (final rdv in _todayRdvs) {
          if (!_eleveNames.containsKey(rdv.eleveTrackingId)) {
            try {
              final info =
                  await _api.getUtilisateurNom(rdv.eleveTrackingId);
              _eleveNames[rdv.eleveTrackingId] =
                  '${info['prenom']} ${info['nom']}';
            } catch (_) {
              _eleveNames[rdv.eleveTrackingId] = 'Élève';
            }
          }
        }
      } catch (_) {}
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _toggleDisponibilite(bool value) async {
    setState(() => _isAvailable = value);
    try {
      await _api.dio.put('/api/v1/conseillers/$_userTrackingId',
          data: {'disponible': value});
    } catch (_) {
      setState(() => _isAvailable = !value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            _buildPendingBanner(),
                            const SizedBox(height: 20),
                            _buildStatsGrid(),
                            const SizedBox(height: 24),
                            _buildDisponibiliteToggle(),
                            const SizedBox(height: 24),
                            const Text('Rendez-vous du jour',
                                style: AppTextStyles.headingMedium),
                            const SizedBox(height: 12),
                            _buildRdvsSection(),
                            const SizedBox(height: 24),
                            _buildBackofficeButton(),
                          ],
                        ),
                      ),
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
      padding: const EdgeInsets.fromLTRB(20, 24, 12, 28),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour ${_profile?.prenom ?? ""} !',
                  style: AppTextStyles.displayMedium
                      .copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
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
                    Flexible(
                      child: Text(
                        'Conseiller orientation | En ligne',
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: Colors.white),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.notifications),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFA800),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.help_outline, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$_pendingQuestions question${_pendingQuestions > 1 ? 's' : ''} en attente de réponse',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.messages),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text(
              'Voir sur le site',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('$_totalMessagesRecus', 'Tickets traités')),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('${_todayRdvs.length}', 'RDV aujourd\'hui')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('★ 4.9', 'Satisfaction')),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('8h', 'Temps réponse')),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.displayMedium.copyWith(
              color: AppColors.primary,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDisponibiliteToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.toggle_on_outlined,
              color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Flexible(
            child: Text('Disponibilité',
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.label.copyWith(fontSize: 15)),
          ),
          const Spacer(),
          Switch(
            value: _isAvailable,
            onChanged: _toggleDisponibilite,
            activeTrackColor: AppColors.success.withValues(alpha: 0.2),
            thumbColor: WidgetStateProperty.all(AppColors.success),
          ),
          const SizedBox(width: 8),
          Text(
            _isAvailable ? 'Je suis disponible' : 'Je suis indisponible',
            style: AppTextStyles.caption.copyWith(
              color: _isAvailable ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRdvsSection() {
    if (_todayRdvs.isEmpty) {
      return const EmptyContentScreen(
        icon: Icons.event_busy_rounded,
        title: 'Aucun rendez-vous aujourd\'hui',
        subtitle: 'Vous n\'avez pas de rendez-vous planifié pour aujourd\'hui.',
      );
    }
    return Column(
      children: _todayRdvs.map((rdv) => _buildRdvItem(rdv)).toList(),
    );
  }

  Widget _buildRdvItem(RendezVousResponse rdv) {
    final heure =
        '${rdv.dateHeurePrevue!.hour.toString().padLeft(2, '0')}h${rdv.dateHeurePrevue!.minute.toString().padLeft(2, '0')}';
    final nom = _eleveNames[rdv.eleveTrackingId] ?? rdv.eleveTrackingId;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                heure,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nom,
                    style: AppTextStyles.label.copyWith(fontSize: 15)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Planifié',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (rdv.lienVisio != null && rdv.lienVisio!.isNotEmpty)
            TextButton.icon(
              onPressed: () async {
                final uri = Uri.parse(rdv.lienVisio!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri,
                      mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.videocam_rounded, size: 18),
              label: const Text('Rejoindre',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline_rounded,
                  color: AppColors.primary),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.messages,
                  arguments: rdv.eleveTrackingId),
            ),
        ],
      ),
    );
  }

  Widget _buildBackofficeButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final uri = Uri.parse('https://backoffice.activeducation.tg');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        icon: const Icon(Icons.open_in_new_rounded, size: 20),
        label: const Text('Ouvrir le back-office complet'),
      ),
    );
  }
}