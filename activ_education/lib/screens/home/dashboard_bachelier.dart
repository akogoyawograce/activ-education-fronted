// lib/screens/home/dashboard_bachelier.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../widgets/skeleton_widget.dart';
import '../../utils/profile_completion.dart';
import '../../utils/image_utils.dart';

class DashboardBachelier extends StatefulWidget {
  final String? typeApprenant;
  const DashboardBachelier({super.key, this.typeApprenant});

  @override
  State<DashboardBachelier> createState() => _DashboardBachelierState();
}

class _DashboardBachelierState extends State<DashboardBachelier> with RouteAware {
  final _api = ApiService();

  String? _userTrackingId;
  String? _userName;
  double? _moyenneGenerale;
  List<NoteResponse> _recentNotes = [];
  List<RendezVousResponse> _upcomingRdvs = [];
  int _unreadMessagesCount = 0;
  ResultatDiagnosticResponse? _dernierResultat;
  EleveResponse? _userProfile;
  double _completionPercentage = 30; // Par défaut 30%
  String? _iaRecommandation;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppRoutes.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    AppRoutes.routeObserver.unsubscribe(this);
    super.dispose();
  }

  DateTime _lastLoad = DateTime(2000);

  @override
  void didPopNext() {
    if (DateTime.now().difference(_lastLoad).inSeconds > 30) {
      _loadDashboardData();
    }
  }

  @override
  void didPush() {
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

      // 1. Chargement critique : profil + notes
      await Future.wait([
        _api.getEleve(_userTrackingId!).then((p) {
          _userProfile = p;
          _userName = p.prenom;
        }).catchError((_) { _userName = 'Invité'; }),
        _api.getNotesEleve(_userTrackingId!).then((notes) {
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
        }).catchError((_) {}),
      ]);
      _lastLoad = DateTime.now();
      if (mounted) setState(() => _isLoading = false);

      // 2. Chargement non-critique en arrière-plan
      await Future.wait([
        _api.getRDVEleve(_userTrackingId!).then((rdvs) {
          _upcomingRdvs = rdvs
              .where((r) =>
                  r.statut.toLowerCase() == 'planifie' &&
                  r.dateHeurePrevue!.isAfter(DateTime.now()))
              .take(3)
              .toList();
        }).catchError((_) {}),
        _api.getMessagesNonLus(_userTrackingId!).then((c) {
          _unreadMessagesCount = c;
        }).catchError((_) {}),
        _api.getResultatsEleve(_userTrackingId!, page: 0, size: 1).then((page) {
          if (page.content.isNotEmpty) {
            _dernierResultat = page.content.first;
          }
        }).catchError((_) {}),
      ]);
      try {
        final iaRes = await _api.getRecommandationIA(_userTrackingId!);
        _iaRecommandation = iaRes;
      } catch (_) {
        _iaRecommandation = _dernierResultat?.recommandation;
      }
      _completionPercentage = _calculateCompletion();
      if (mounted) setState(() {});
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

                      // Recommandation personnalisée IA
                      if (_iaRecommandation != null) ...[
                        _buildIaRecommandation(),
                        const SizedBox(height: 24),
                      ],

                      // Annuaire conseillers
                      _buildConseillersCta(),

                      const SizedBox(height: 24),

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
                  Flexible(
                    child: Text(
                      'Bonjour ${_userProfile?.prenom ?? "Bachelier"} !',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        fontFamily: 'Inter',
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (_userProfile?.niveauEtude != null) ...[
                    const SizedBox(width: 8),
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
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _buildHeaderSubtitle(),
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
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.backgroundGrey,
                    image: _userProfile?.photoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(resolveImageUrl(_userProfile!.photoUrl)!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _userProfile?.photoUrl == null
                      ? Center(
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
                        )
                      : null,
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

  String _buildHeaderSubtitle() {
    final p = _userProfile;
    if (p == null) return 'Nouveau Bachelier';
    final type = p.typeApprenant;
    final niveau = p.niveauEtude ?? '';
    final filiere = p.filiere ?? '';
    if (type == 'COLLEGIEN') {
      return niveau.isNotEmpty ? '$type — $niveau' : type;
    }
    if (type == 'LYCEEN') {
      final parts = [type];
      if (niveau.isNotEmpty) parts.add(niveau);
      if (filiere.isNotEmpty) parts.add('série $filiere');
      return parts.join(' — ');
    }
    if (type == 'ETUDIANT') {
      final parts = [type];
      if (niveau.isNotEmpty) parts.add(niveau);
      if (filiere.isNotEmpty) parts.add(filiere);
      return parts.join(' — ');
    }
    return type;
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
    return calculateProfileCompletion(
      telephone: _userProfile?.telephone,
      etablissementActuel: _userProfile?.etablissementActuel,
      filiere: _userProfile?.filiere,
      matieresPreferees: _userProfile?.matieresPreferees,
      hasNotes: _recentNotes.isNotEmpty,
      hasDiagnostic: _dernierResultat != null,
    );
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
              Flexible(
                child: Text(
                  'Profil: ${_completionPercentage.toInt()}% complété',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMedium,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
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
              value: _completionPercentage / 100,
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
                Flexible(
                  child: Text(
                    'Commencer le diagnostic',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
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

  Widget _buildIaRecommandation() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.recommandationIA),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Ma recommandation',
                        style: AppTextStyles.label.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _iaRecommandation!.length > 120
                        ? '${_iaRecommandation!.substring(0, 120)}...'
                        : _iaRecommandation!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Voir la recommandation complète →',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
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

