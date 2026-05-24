import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../widgets/skeleton_widget.dart';
import '../errors/empty_content_screen.dart';

class RdvListScreen extends StatefulWidget {
  const RdvListScreen({super.key});

  @override
  State<RdvListScreen> createState() => _RdvListScreenState();
}

class _RdvListScreenState extends State<RdvListScreen>
    with SingleTickerProviderStateMixin {
  final _api = ApiService();

  late TabController _tabController;

  List<RendezVousResponse> _upcomingRdvs = [];
  List<RendezVousResponse> _pastRdvs = [];
  Map<String, String> _otherPartyNames = {};
  String? _userTrackingId;
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRdvs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRdvs() async {
    try {
      setState(() => _isLoading = true);
      _userTrackingId = await _api.getTrackingId();
      _userRole = await _api.getUserRole();
      if (_userTrackingId == null) return;

      List<RendezVousResponse> rdvs;
      if (_userRole == 'ELEVE') {
        rdvs = await _api.getRDVEleve(_userTrackingId!);
      } else {
        rdvs = await _api.getRDVConseiller(_userTrackingId!);
      }

      final otherIds = <String>{};
      for (final rdv in rdvs) {
        final otherId = _userRole == 'ELEVE'
            ? rdv.conseillerTrackingId
            : rdv.eleveTrackingId;
        if (otherId.isNotEmpty) otherIds.add(otherId);
      }

      final noms = <String, String>{};
      for (final id in otherIds) {
        try {
          final info = await _api.getUtilisateurNom(id);
          noms[id] = '${info['prenom']} ${info['nom']}';
        } catch (_) {
          noms[id] = 'Contact';
        }
      }

      final now = DateTime.now();
      final upcoming = <RendezVousResponse>[];
      final past = <RendezVousResponse>[];

      for (final rdv in rdvs) {
        if (rdv.dateHeurePrevue != null && rdv.dateHeurePrevue!.isAfter(now)) {
          upcoming.add(rdv);
        } else {
          past.add(rdv);
        }
      }

      upcoming.sort((a, b) {
        final da = a.dateHeurePrevue ?? DateTime(1970);
        final db = b.dateHeurePrevue ?? DateTime(1970);
        return da.compareTo(db);
      });
      past.sort((a, b) {
        final da = a.dateHeurePrevue ?? DateTime(1970);
        final db = b.dateHeurePrevue ?? DateTime(1970);
        return db.compareTo(da);
      });

      setState(() {
        _upcomingRdvs = upcoming;
        _pastRdvs = past;
        _otherPartyNames = noms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${_api.handleError(e as dynamic)}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _otherPartyId(RendezVousResponse rdv) {
    return _userRole == 'ELEVE'
        ? rdv.conseillerTrackingId
        : rdv.eleveTrackingId;
  }

  String _otherPartyName(RendezVousResponse rdv) {
    return _otherPartyNames[_otherPartyId(rdv)] ?? 'Contact';
  }

  Color _statusColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'planifie':
        return AppColors.primary;
      case 'termine':
        return AppColors.success;
      case 'annule':
        return AppColors.error;
      default:
        return AppColors.textMedium;
    }
  }

  String _statusLabel(String statut) {
    switch (statut.toLowerCase()) {
      case 'planifie':
        return 'Planifié';
      case 'termine':
        return 'Terminé';
      case 'annule':
        return 'Annulé';
      default:
        return statut;
    }
  }

  Future<void> _annulerRdv(String trackingId) async {
    try {
      await _api.annulerRDV(trackingId);
      await _loadRdvs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rendez-vous annulé'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${_api.handleError(e as dynamic)}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showCancelConfirmation(RendezVousResponse rdv) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Annuler ce rendez-vous ?'),
        content: Text(
          'Le ${_formatDate(rdv.dateHeurePrevue!)} à ${_formatTime(rdv.dateHeurePrevue!)}',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Garder',
                style: TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _annulerRdv(rdv.trackingId);
            },
            child: const Text('Annuler',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundGrey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textDark,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Mes rendez-vous',
                        style: AppTextStyles.headingMedium.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textLight,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: AppTextStyles.label,
                    tabs: const [
                      Tab(text: 'À venir'),
                      Tab(text: 'Passés'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const SkeletonListPage()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTabContent(_upcomingRdvs, isUpcoming: true),
                        _buildTabContent(_pastRdvs, isUpcoming: false),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(List<RendezVousResponse> rdvs,
      {required bool isUpcoming}) {
    if (rdvs.isEmpty) {
      return EmptyContentScreen(
        icon: isUpcoming
            ? Icons.event_busy_rounded
            : Icons.history_rounded,
        title: isUpcoming
            ? 'Aucun rendez-vous à venir'
            : 'Aucun rendez-vous passé',
        subtitle: isUpcoming
            ? 'Planifiez un rendez-vous avec un conseiller'
            : 'Vos rendez-vous passés apparaîtront ici',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRdvs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rdvs.length,
        itemBuilder: (context, index) => _buildRdvCard(rdvs[index], isUpcoming),
      ),
    );
  }

  Widget _buildRdvCard(RendezVousResponse rdv, bool isUpcoming) {
    final name = _otherPartyName(rdv);
    final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
    final statusColor = _statusColor(rdv.statut);
    final isPlanifie = rdv.statut.toLowerCase() == 'planifie';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPlanifie
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.cardBorder,
          width: isPlanifie ? 2 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials.isNotEmpty ? initials : '?',
                    style: AppTextStyles.headingMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.label.copyWith(fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (rdv.dateHeurePrevue != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${_formatDate(rdv.dateHeurePrevue!)} à ${_formatTime(rdv.dateHeurePrevue!)}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(rdv.statut),
                  style: AppTextStyles.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (isUpcoming && isPlanifie) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.cardBorder),
            const SizedBox(height: 8),
            Row(
              children: [
                if (rdv.lienVisio != null) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final uri = Uri.tryParse(rdv.lienVisio!);
                        if (uri != null) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.videocam_rounded,
                                color: AppColors.primary, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Rejoindre',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showCancelConfirmation(rdv),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cancel_rounded,
                              color: AppColors.error, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Annuler',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE dd MMMM yyyy', 'fr_FR').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm', 'fr_FR').format(date);
  }
}
