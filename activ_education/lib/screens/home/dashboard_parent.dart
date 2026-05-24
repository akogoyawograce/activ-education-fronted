import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../widgets/skeleton_widget.dart';

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
    _dernierResultat = null;
    try {
      final res = await _api.dio.get(
        '/api/v1/eleves/${_enfants[_selectedIndex].trackingId}/resultats-diagnostic/dernier',
      );
      _dernierResultat = ResultatDiagnosticResponse.fromJson(res.data);
    } catch (_) {
      _dernierResultat = null;
    }
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
            Text(
              '${enfant.prenom} · ${enfant.niveauEtude ?? ""}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : Colors.white,
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
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 16, color: AppColors.textLight),
              const SizedBox(width: 6),
              Text(
                _dernierResultat != null
                    ? 'Quiz passé $joursDepuisQuiz'
                    : joursDepuisQuiz,
                style: AppTextStyles.caption,
              ),
            ],
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
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.diagnosticEnfant,
                arguments: {'enfantId': enfant.trackingId},
              ),
              child: const Text('Voir son diagnostic'),
            ),
          ),
        ],
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

  Widget _buildShortcutGrid() {
    final enfantsId = _selectedEnfant?.trackingId;
    final shortcuts = [
      _ShortcutData(
        Icons.assignment_rounded,
        'Diagnostics\nde l\'enfant',
        () => Navigator.pushNamed(
          context,
          AppRoutes.diagnosticEnfant,
          arguments: {'enfantId': enfantsId},
        ),
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

    return Column(
      children: [
        for (int i = 0; i < 2; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(child: _buildShortcutTile(shortcuts[i * 2])),
                const SizedBox(width: 12),
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
            ),
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
