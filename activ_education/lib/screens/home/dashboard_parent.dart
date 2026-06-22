import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../services/api_service.dart';
import '../../services/parent_service.dart';
import '../../models/models.dart';
import '../../widgets/skeleton_widget.dart';
import '../documents/documents_screen.dart';
import 'enfant_suivi_screen.dart';

class DashboardParent extends StatefulWidget {
  const DashboardParent({super.key});

  @override
  State<DashboardParent> createState() => _DashboardParentState();
}

class _DashboardParentState extends State<DashboardParent> {
  final _api = ApiService();
  bool _isLoading = true;
  String? _parentTrackingId;
  ParentResponse? _profile;
  List<EleveResponse> _enfants = [];
  int _selectedIndex = 0;
  ResultatDiagnosticResponse? _dernierResultat;
  int _messagesNonLus = 0;
  int _documentsCount = 0;
  List<RendezVousResponse> _upcomingRdvs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _parentTrackingId = await _api.getTrackingId();
      if (_parentTrackingId != null) {
        _profile = await _api.auth.getParent(_parentTrackingId!);
        final enfantsIds = _profile!.enfantsTrackingIds;
        if (enfantsIds.isNotEmpty) {
          final futures = enfantsIds.map((id) => _api.auth.getEleve(id));
          _enfants = await Future.wait(futures);
          await _loadSelectedChildData();
        }
        _messagesNonLus =
            await _api.interaction.getMessagesNonLus(_parentTrackingId!);
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _loadSelectedChildData() async {
    if (_enfants.isEmpty) return;
    final childId = _enfants[_selectedIndex].trackingId;
    _dernierResultat = null;
    _documentsCount = 0;
    _upcomingRdvs = [];
    try {
      final res = await _api.dio.get(
        '/api/v1/eleves/$childId/resultats-diagnostic/dernier',
      );
      _dernierResultat = ResultatDiagnosticResponse.fromJson(res.data);
    } catch (_) {}
    try {
      _documentsCount = await _api.countDocuments(childId);
    } catch (_) {}
    try {
      _upcomingRdvs =
          await _api.interaction.getRDVEleveParStatut(childId, 'PLANIFIE');
    } catch (_) {}
  }

  void _selectEnfant(int index) {
    _selectedIndex = index;
    _loadSelectedChildData();
  }

  EleveResponse? get _selectedEnfant =>
      _enfants.isNotEmpty ? _enfants[_selectedIndex] : null;

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
                      _buildHeaderSection(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_selectedEnfant != null) ...[
                              _buildChildCard(),
                              const SizedBox(height: 16),
                            ],
                            if (_messagesNonLus > 0) ...[
                              _buildAlertBanner(),
                              const SizedBox(height: 16),
                            ],
                            _buildShortcutGrid(),
                            const SizedBox(height: 24),
                            _buildConseillersCta(),
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

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1300C8),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Espace Famille',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bonjour M. ${_profile?.nom ?? ""}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Icon(Icons.family_restroom, color: AppColors.primary),
              ),
            ],
          ),
          if (_enfants.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _enfants.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) =>
                    _buildEnfantPill(_enfants[index], index == _selectedIndex, index),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEnfantPill(EleveResponse enfant, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => setState(() => _selectEnfant(index)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_rounded,
              size: 16,
              color: isSelected ? AppColors.primary : Colors.white,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '${enfant.prenom} · ${enfant.niveauEtude ?? ""}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildCard() {
    final enfant = _selectedEnfant!;
    String joursDepuisQuiz;
    if (_dernierResultat?.datePassage != null) {
      final diff = DateTime.now().difference(_dernierResultat!.datePassage!);
      final jours = diff.inDays;
      joursDepuisQuiz = jours == 0
          ? "Aujourd'hui"
          : jours == 1
              ? 'Hier'
              : 'Il y a $jours jours';
    } else {
      joursDepuisQuiz = 'Pas encore de quiz';
    }

    final hasRecommandation = _dernierResultat?.recommandation != null &&
        _dernierResultat!.recommandation!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  enfant.prenom.isNotEmpty ? enfant.prenom[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enfant.nomComplet,
                      style: AppTextStyles.label.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${enfant.niveauEtude ?? "Niveau non renseigné"} · ${enfant.etablissementActuel ?? ""}',
                      style: AppTextStyles.caption,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatRow(Icons.schedule_rounded,
              _dernierResultat != null ? 'Quiz passé $joursDepuisQuiz' : joursDepuisQuiz),
          const SizedBox(height: 6),
          if (_dernierResultat != null && _dernierResultat!.profilDecouvert != null)
            _buildStatRow(Icons.explore_rounded,
                'Profil : ${_dernierResultat!.profilDecouvert}'),
          if (_dernierResultat != null && _dernierResultat!.scoreFinal != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  const Icon(Icons.trending_up_rounded, size: 16, color: AppColors.textLight),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _dernierResultat!.scoreFinal! / 100,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        color: AppColors.primary,
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_dernierResultat!.scoreFinal!.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          if (hasRecommandation) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '1 recommandation disponible',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniStat(Icons.description_rounded, '$_documentsCount docs',
                  AppColors.primary),
              const SizedBox(width: 16),
              _buildMiniStat(Icons.event_rounded,
                  '${_upcomingRdvs.length} RDV', AppColors.accent),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildActionButton('Suivi', Icons.trending_up_rounded, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EnfantSuiviScreen(
                          enfantTrackingId: enfant.trackingId),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton('Documents', Icons.description_rounded,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DocumentsScreen(trackingId: enfant.trackingId),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textLight),
        const SizedBox(width: 6),
        Flexible(
          child: Text(text, style: AppTextStyles.caption, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildMiniStat(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }

  Widget _buildAlertBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EC),
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Color(0xFFFFA800), width: 3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFFFFA800), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Nouveau message concernant ${_selectedEnfant?.prenom ?? ""}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLinkEnfantDialog() {
    final controller = TextEditingController();
    var loading = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Lier un enfant'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Saisis l\'identifiant (trackingId) de l\'enfant.'),
              const Text('L\'enfant trouve son trackingId dans son profil.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'TrackingId de l\'enfant',
                  border: OutlineInputBorder(),
                ),
                enabled: !loading,
              ),
              if (loading) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: loading
                  ? null
                  : () async {
                      final childId = controller.text.trim();
                      if (childId.isEmpty) return;
                      if (_parentTrackingId == null) return;
                      setDialogState(() => loading = true);
                      try {
                        await ParentService()
                            .ajouterEnfant(_parentTrackingId!, childId);
                        if (ctx.mounted) Navigator.pop(ctx);
                        _loadData();
                      } catch (e) {
                        if (ctx.mounted) {
                          setDialogState(() => loading = false);
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text('Erreur : ${e.toString()}')),
                          );
                        }
                      }
                    },
              child: const Text('Lier'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutGrid() {
    final shortcuts = [
      _ShortcutData(
        Icons.person_add_rounded,
        'Lier un\nenfant',
        _showLinkEnfantDialog,
      ),
      _ShortcutData(
        Icons.chat_rounded,
        'Contacter\nconseiller',
        () => Navigator.pushNamed(context, AppRoutes.messages),
      ),
      _ShortcutData(
        Icons.bookmark_rounded,
        'Fiches\nsauvegardées',
        () => Navigator.pushNamed(context, AppRoutes.favorites),
      ),
      _ShortcutData(
        Icons.history_rounded,
        'Historique',
        () => Navigator.pushNamed(context, AppRoutes.messages),
      ),
    ];

    final rowCount = (shortcuts.length + 1) ~/ 2;
    return Column(
      children: [
        for (int i = 0; i < rowCount; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(child: _buildShortcutTile(shortcuts[i * 2])),
                if (i * 2 + 1 < shortcuts.length) const SizedBox(width: 12),
                if (i * 2 + 1 < shortcuts.length)
                  Expanded(child: _buildShortcutTile(shortcuts[i * 2 + 1])),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildShortcutTile(_ShortcutData data) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(data.icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              data.label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                height: 1.3,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
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
}

class _ShortcutData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShortcutData(this.icon, this.label, this.onTap);
}
