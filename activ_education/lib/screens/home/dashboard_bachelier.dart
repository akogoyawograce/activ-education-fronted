// lib/screens/home/dashboard_bachelier.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../widgets/skeleton_widget.dart';
import '../../services/recommendation_service.dart';
import '../../widgets/recommendations_section.dart';

class DashboardBachelier extends StatefulWidget {
  const DashboardBachelier({super.key});

  @override
  State<DashboardBachelier> createState() => _DashboardBachelierState();
}

class _DashboardBachelierState extends State<DashboardBachelier> {
  final _api = ApiService();

  String? _userTrackingId;
  String? _userName;
  double? _moyenneGenerale;
  List<NoteResponse> _recentNotes = [];
  List<RendezVousResponse> _upcomingRdvs = [];
  int _unreadMessagesCount = 0;
  ResultatDiagnosticResponse? _dernierResultat;
  EleveResponse? _userProfile;
  double _completionPercentage = 0.3; // Par défaut 30%
  final _recommendationService = RecommendationService();
  List<RecommendationResult> _recommendations = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() => _isLoading = true);
      _userTrackingId = await _api.getTrackingId();

      if (_userTrackingId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Charger profil utilisateur
      try {
        _userProfile = await _api.getEleve(_userTrackingId!);
        _userName = _userProfile?.prenom;
        _completionPercentage = _calculateCompletion();
      } catch (_) {
        _userName = 'Invité';
      }

      // Charger notes et calculer moyenne
      try {
        final notes = await _api.getNotesEleve(_userTrackingId!);
        _recentNotes = notes.take(5).toList();
        if (notes.isNotEmpty) {
          double total = 0;
          double totalCoefs = 0;
          for (final note in notes) {
            final coef = note.coefficient ?? 1;
            total += note.note * coef;
            totalCoefs += coef;
          }
          _moyenneGenerale = totalCoefs > 0 ? total / totalCoefs : null;
        }
      } catch (_) {}

      // Charger RDV à venir
      try {
        final rdvs = await _api.getRDVEleve(_userTrackingId!);
        _upcomingRdvs = rdvs
            .where((r) =>
                r.statut.toLowerCase() == 'planifie' &&
                r.dateHeurePrevue!.isAfter(DateTime.now()))
            .take(3)
            .toList();
      } catch (_) {}

      // Charger compteur messages non lus
      try {
        _unreadMessagesCount = await _api.getMessagesNonLus(_userTrackingId!);
      } catch (_) {}

      // Charger dernier résultat diagnostic
      try {
        final resultatsPage = await _api.getResultatsEleve(_userTrackingId!, page: 0, size: 1);
        if (resultatsPage.content.isNotEmpty) {
          _dernierResultat = resultatsPage.content.first;
          _completionPercentage = _calculateCompletion();
        }
      } catch (_) {}

      // Générer recommandations Quiz × Notes
      _recommendations = _recommendationService.generate(
        profilDecouvert: _dernierResultat?.profilDecouvert,
        recommandation: _dernierResultat?.recommandation,
        notes: _recentNotes,
      );

      _completionPercentage = _calculateCompletion();
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Erreur chargement dashboard: $e');
      if (mounted) setState(() => _isLoading = false);
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
                onRefresh: _loadDashboardData,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header avec salutation et notifications
                      _buildHeader(),

                      const SizedBox(height: 24),

                      // Carte Diagnostic / Action Requise
                      _buildActionRequiseCard(),

                      const SizedBox(height: 24),

                      // Carte moyenne générale
                      _buildMoyenneCard(),

                      const SizedBox(height: 24),

                      // Actions rapides
                      _buildQuickActions(),

                      const SizedBox(height: 32),

                      // Recommandations personnalisées (Quiz × Notes)
                      if (_recommendations.isNotEmpty) ...[
                        RecommendationsSection(recommendations: _recommendations),
                        const SizedBox(height: 24),
                      ],

                      // Rendez-vous à venir
                      _buildUpcomingRdvs(),

                      const SizedBox(height: 24),

                      // Messages récents
                      _buildRecentMessages(),

                      const SizedBox(height: 24),

                      // Explorer CTA
                      _buildExplorerCta(),

                      const SizedBox(height: 24),

                      // Aide & FAQ
                      _buildHelpSection(),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Bonjour ${_userProfile?.prenom ?? "Bachelier"} !',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_userProfile?.niveauEtude != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _userProfile!.niveauEtude!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${_userProfile?.typeApprenant ?? "Nouveau Bachelier"} — ${_userProfile?.filiere ?? "Série ?"}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMedium,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.search),
          child: Container(
            width: 38,
            height: 38,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6),
              ],
            ),
            child: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
          ),
        ),
        Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.backgroundGrey,
                  child: Text(
                    _userName != null && _userName!.isNotEmpty
                        ? _userName![0].toUpperCase()
                        : 'B',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            if (_unreadMessagesCount > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      _unreadMessagesCount > 9 ? '9+' : _unreadMessagesCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMoyenneCard() {
    if (_moyenneGenerale == null && _recentNotes.isEmpty) {
      return _buildEmptyMoyenneCard();
    }

    final color = _moyenneGenerale != null
        ? _moyenneGenerale! >= 10
            ? AppColors.success
            : AppColors.error
        : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.analytics_rounded, color: color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Moyenne générale',
                      style: TextStyle(fontSize: 14, color: AppColors.textMedium),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _moyenneGenerale != null
                          ? '${_moyenneGenerale!.toStringAsFixed(2)} / 20'
                          : 'Non disponible',
                      style: AppTextStyles.displayMedium.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_recentNotes.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.cardBorder),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Dernières notes :',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.notes),
                  child: Text(
                    'Voir tout',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: _recentNotes.take(3).map((note) {
                final noteColor = note.note >= 10 ? AppColors.success : AppColors.error;
                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: noteColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          note.matiere.length > 10
                              ? '${note.matiere.substring(0, 8)}..'
                              : note.matiere,
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          note.note.toStringAsFixed(1),
                          style: AppTextStyles.label.copyWith(
                            color: noteColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyMoyenneCard() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.notes),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saisir tes notes',
                    style: TextStyle(fontSize: 14, color: AppColors.textMedium),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ajoute tes notes pour voir ta moyenne',
                    style: AppTextStyles.headingMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary, size: 16),
          ],
        ),
      ),
    );
  }

  double _calculateCompletion() {
    int score = 0;
    int total = 0;

    // Nom/Prénom (toujours là si connecté)
    total++;
    if (_userProfile?.nom != null && _userProfile!.nom.isNotEmpty) score++;

    // Téléphone
    total++;
    if (_userProfile?.telephone != null && _userProfile!.telephone!.isNotEmpty) score++;

    // Établissement
    total++;
    if (_userProfile?.etablissementActuel != null && _userProfile!.etablissementActuel!.isNotEmpty) score++;

    // Série / Filière
    total++;
    if (_userProfile?.filiere != null && _userProfile!.filiere!.isNotEmpty) score++;

    // Notes
    total++;
    if (_recentNotes.isNotEmpty) score++;

    // Diagnostic
    total++;
    if (_dernierResultat != null) score++;

    return total > 0 ? score / total : 0.3;
  }

  Widget _buildActionRequiseCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Que faire après le Bac ?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Découvre les filières et métiers qui te correspondent. Lance ton diagnostic maintenant.',
            style: TextStyle(
              color: AppColors.textMedium,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profil: ${(_completionPercentage * 100).toInt()}% complété',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMedium,
                ),
              ),
              const Text(
                'Action requise',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _completionPercentage,
              minHeight: 8,
              backgroundColor: AppColors.backgroundGrey,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.quiz),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Commencer le diagnostic',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions rapides',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.quiz_rounded,
                title: 'Quiz',
                subtitle: 'Orientation',
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, AppRoutes.quiz),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.edit_note_rounded,
                title: 'Notes',
                subtitle: 'Mes résultats',
                color: AppColors.accent,
                onTap: () => Navigator.pushNamed(context, AppRoutes.notes),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.event_rounded,
                title: 'RDV',
                subtitle: 'Réserver',
                color: AppColors.success,
                onTap: () => Navigator.pushNamed(context, AppRoutes.rdv),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.folder_rounded,
                title: 'Explorer',
                subtitle: 'Filières',
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, AppRoutes.explorer),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingRdvs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Rendez-vous à venir',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            if (_upcomingRdvs.isNotEmpty)
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.rdv),
                child: Text(
                  'Voir tout',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_upcomingRdvs.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.event_busy_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aucun rendez-vous prévu',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Planifie un RDV avec un conseiller',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textMedium),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.rdv),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
                  ),
                ),
              ],
            ),
          )
        else
          ..._upcomingRdvs.map((rdv) => _RdvCard(rdv: rdv)),
      ],
    );
  }

  Widget _buildRecentMessages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Messages',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.messages),
              child: Row(
                children: [
                  if (_unreadMessagesCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_unreadMessagesCount nouveau',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    'Voir tout',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.messages),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Boîte de réception',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _unreadMessagesCount > 0
                            ? '$_unreadMessagesCount message(s) non lu(s)'
                            : 'Aucun nouveau message',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textMedium),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textLight, size: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExplorerCta() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.15),
            AppColors.accent.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Explorer les filières',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Découvre toutes les formations disponibles',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMedium),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.explorer),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Besoin d\'aide ?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Consultez notre foire aux questions ou contactez l\'assistance.',
            style: TextStyle(color: AppColors.textMedium),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HelpAction(
                  icon: Icons.help_outline_rounded,
                  label: 'FAQ',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.faq),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HelpAction(
                  icon: Icons.support_agent_rounded,
                  label: 'Support',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.messages),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(color: AppColors.textMedium),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RdvCard extends StatelessWidget {
  final RendezVousResponse rdv;

  const _RdvCard({required this.rdv});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rdv.notes ?? 'Rendez-vous',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(rdv.dateHeurePrevue!),
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMedium),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              rdv.statut,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final diff = date.difference(now);

  if (diff.inDays == 0) {
    return "Aujourd'hui à ${DateFormat('HH:mm', 'fr_FR').format(date)}";
  } else if (diff.inDays == 1) {
    return "Demain à ${DateFormat('HH:mm', 'fr_FR').format(date)}";
  } else {
    return DateFormat('EEEE dd MMMM', 'fr_FR').format(date);
  }
}

class _HelpAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HelpAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.backgroundGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

