// lib/screens/explorer/explorer_screen.dart

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import 'fiche_detail_screen.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({super.key});

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen>
    with SingleTickerProviderStateMixin {
  final _api = ApiService();
  final _searchController = TextEditingController();

  // Onglet actif : 0=Tout, 1=Séries, 2=Filières, 3=Métiers, 4=Établissements
  int _activeTab = 0;

  List<FicheSerieResponse> _series = [];
  List<FicheFiliereResponse> _filieres = [];
  List<FicheMetierResponse> _metiers = [];
  List<FicheEtablissementResponse> _etablissements = [];

  bool _isLoading = true;
  String _searchQuery = '';

  final List<String> _tabs = ['Tout', 'Séries', 'Filières', 'Métiers', 'Établissements'];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    try {
      setState(() => _isLoading = true);
      final results = await Future.wait([
        _api.listerSeries(size: 20),
        _api.listerFilieres(size: 20),
        _api.listerMetiers(size: 20),
        _api.listerEtablissements(size: 20),
      ]);
      setState(() {
        _series = (results[0] as PageResponse<FicheSerieResponse>).content;
        _filieres = (results[1] as PageResponse<FicheFiliereResponse>).content;
        _metiers = (results[2] as PageResponse<FicheMetierResponse>).content;
        _etablissements =
            (results[3] as PageResponse<FicheEtablissementResponse>).content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Filtre de recherche
  List<FicheBase> get _filteredResults {
    final q = _searchQuery.toLowerCase();
    List<FicheBase> all = [];

    if (_activeTab == 0 || _activeTab == 1) {
      all.addAll(_series.where((s) =>
          s.titre.toLowerCase().contains(q) ||
          (s.resume.toLowerCase().contains(q))));
    }
    if (_activeTab == 0 || _activeTab == 2) {
      all.addAll(_filieres.where((f) =>
          f.titre.toLowerCase().contains(q) ||
          (f.domaine?.toLowerCase().contains(q) ?? false)));
    }
    if (_activeTab == 0 || _activeTab == 3) {
      all.addAll(_metiers.where((m) =>
          m.titre.toLowerCase().contains(q) ||
          (m.secteur?.toLowerCase().contains(q) ?? false)));
    }
    if (_activeTab == 0 || _activeTab == 4) {
      all.addAll(_etablissements.where((e) =>
          e.titre.toLowerCase().contains(q) ||
          (e.ville?.toLowerCase().contains(q) ?? false)));
    }
    return all;
  }

  // Fiche mise en avant (première filière)
  FicheFiliereResponse? get _ficheVedette =>
      _filieres.isNotEmpty ? _filieres.first : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ──────────────────────────────────────────────────
            _buildAppBar(),
            // ── Barre de recherche ───────────────────────────────────────
            _buildSearchBar(),
            // ── Onglets ──────────────────────────────────────────────────
            _buildTabs(),
            // ── Contenu ──────────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary))
                  : RefreshIndicator(
                      onRefresh: _loadAll,
                      color: AppColors.primary,
                      child: _buildContent(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── APP BAR ─────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          const Icon(Icons.school_rounded,
              color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          Text('Explorer',
              style: AppTextStyles.headingLarge.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w800)),
          const Spacer(),
          // Filtre
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6)
                ],
              ),
              child: const Icon(Icons.tune_rounded,
                  color: AppColors.primary, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          // Notifs
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
              ],
            ),
            child: const Icon(Icons.notifications_outlined,
                color: AppColors.textMedium, size: 20),
          ),
        ],
      ),
    );
  }

  // ── SEARCH BAR ───────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: 'Rechercher une filière, métier...',
            hintStyle:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
            prefixIcon: const Icon(Icons.search_rounded,
                color: AppColors.textLight, size: 20),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  // ── TABS ─────────────────────────────────────────────────────────────────
  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _tabs.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final isActive = _activeTab == index;
            return GestureDetector(
              onTap: () => setState(() => _activeTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ]
                      : null,
                ),
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? Colors.white : AppColors.textMedium,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── CONTENU PRINCIPAL ────────────────────────────────────────────────────
  Widget _buildContent() {
    final results = _filteredResults;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        // Fiche vedette (seulement si pas de recherche + onglet Tout)
        if (_searchQuery.isEmpty && _activeTab == 0 && _ficheVedette != null)
          _buildFicheVedette(),

        if (_searchQuery.isEmpty && _activeTab == 0)
          const SizedBox(height: 24),

        // Titre section
        if (_searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              '${results.length} résultat${results.length > 1 ? 's' : ''} pour "$_searchQuery"',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textMedium),
            ),
          )
        else if (_activeTab == 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                const Text('Fiches d\'orientation',
                    style: AppTextStyles.headingMedium),
                const Spacer(),
                Text(
                  'Voir tout',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

        // Grille de fiches
        if (results.isEmpty)
          _buildEmpty()
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              return _FicheCard(
                fiche: results[index],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FicheDetailScreen(fiche: results[index]),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  // ── FICHE VEDETTE ────────────────────────────────────────────────────────
  Widget _buildFicheVedette() {
    final f = _ficheVedette!;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => FicheDetailScreen(fiche: f)),
      ),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'FILIÈRE DU MOMENT',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Spacer(),
            Text(
              f.titre,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Très recherché ce mois',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.trending_up_rounded,
                    color: Colors.white, size: 22),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 48,
                color: AppColors.textLight.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            const Text(
              'Aucun résultat trouvé',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── FICHE CARD ───────────────────────────────────────────────────────────────
class _FicheCard extends StatelessWidget {
  final FicheBase fiche;
  final VoidCallback onTap;

  const _FicheCard({required this.fiche, required this.onTap});

  Color get _typeColor {
    final type = fiche.typeFiche?.toLowerCase() ?? '';
    if (type.contains('serie')) return AppColors.primary;
    if (type.contains('filiere')) return const Color(0xFF10B981);
    if (type.contains('metier')) return AppColors.accent;
    return const Color(0xFF8B5CF6);
  }

  String get _typeLabel {
    final type = fiche.typeFiche?.toLowerCase() ?? '';
    if (type.contains('serie')) return 'Série';
    if (type.contains('filiere')) return 'Filière';
    if (type.contains('metier')) return 'Métier';
    return 'Établissement';
  }

  String get _subtitle {
    if (fiche is FicheSerieResponse) {
      return (fiche as FicheSerieResponse).niveau ?? '';
    }
    if (fiche is FicheFiliereResponse) {
      final f = fiche as FicheFiliereResponse;
      return '${f.domaine ?? ''} • ${f.duree ?? ''}';
    }
    if (fiche is FicheMetierResponse) {
      return (fiche as FicheMetierResponse).secteur ?? '';
    }
    if (fiche is FicheEtablissementResponse) {
      final e = fiche as FicheEtablissementResponse;
      return '${e.ville ?? ''} • ${e.estPublic ? 'Public' : 'Privé'}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge type
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _typeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _typeLabel,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _typeColor,
                ),
              ),
            ),
            const Spacer(),
            Text(
              fiche.titre,
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _subtitle,
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Favoris
                GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Icons.favorite_border_rounded,
                    size: 18,
                    color: AppColors.textLight,
                  ),
                ),
                // Flèche
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _typeColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.chevron_right_rounded,
                      size: 16, color: _typeColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
