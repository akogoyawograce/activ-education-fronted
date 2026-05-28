// lib/screens/explorer/explorer_screen.dart

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../widgets/skeleton_widget.dart';
import '../../widgets/common_widgets.dart';
import '../errors/empty_content_screen.dart';
import 'fiche_detail_screen.dart';
import 'category_list_screen.dart';
import 'catalogue_filter_sheet.dart';

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
  Set<String> _favorisSet = {};

  bool _isLoading = true;
  String _searchQuery = '';
  CatalogueFilters _filters = const CatalogueFilters();

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

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CatalogueFilterSheet(
        current: _filters,
        onApply: (f) {
          setState(() => _filters = f);
        },
      ),
    );
  }

  void _showAllCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DefaultTabController(
          length: 4,
          child: _AllCategoriesScreen(filters: _filters),
        ),
      ),
    );
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    final userId = await _api.getTrackingId();

    Future<T?> _safeLoad<T>(Future<T> Function() fn, {T? fallback}) async {
      try {
        return await fn().timeout(const Duration(seconds: 3));
      } catch (_) {
        return fallback;
      }
    }

    final results = await Future.wait([
      _safeLoad(() => _api.listerSeries(size: 10),
          fallback: PageResponse<FicheSerieResponse>(
              totalElements: 0, totalPages: 0, size: 0, number: 0,
              first: true, last: true, content: [])),
      _safeLoad(() => _api.listerFilieres(size: 10),
          fallback: PageResponse<FicheFiliereResponse>(
              totalElements: 0, totalPages: 0, size: 0, number: 0,
              first: true, last: true, content: [])),
      _safeLoad(() => _api.listerMetiers(size: 10),
          fallback: PageResponse<FicheMetierResponse>(
              totalElements: 0, totalPages: 0, size: 0, number: 0,
              first: true, last: true, content: [])),
      _safeLoad(() => _api.listerEtablissements(size: 10),
          fallback: PageResponse<FicheEtablissementResponse>(
              totalElements: 0, totalPages: 0, size: 0, number: 0,
              first: true, last: true, content: [])),
      if (userId != null)
        _safeLoad(() => _api.explorer.getFavorisUtilisateur(userId, page: 0, size: 100),
            fallback: PageResponse<FavoriResponse>(
                totalElements: 0, totalPages: 0, size: 0, number: 0,
                first: true, last: true, content: []))
      else
        Future.value(PageResponse<FavoriResponse>(
          totalElements: 0, totalPages: 0, size: 0, number: 0,
          first: true, last: true, content: [],
        )),
    ]);
    if (mounted) {
      setState(() {
        _series = (results[0] as PageResponse<FicheSerieResponse>?)?.content ?? [];
        _filieres = (results[1] as PageResponse<FicheFiliereResponse>?)?.content ?? [];
        _metiers = (results[2] as PageResponse<FicheMetierResponse>?)?.content ?? [];
        _etablissements = (results[3] as PageResponse<FicheEtablissementResponse>?)?.content ?? [];
        _favorisSet = (results[4] as PageResponse<FavoriResponse>?)?.content
            .map((f) => f.ficheTrackingId).toSet() ?? {};
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavori(FicheBase fiche) async {
    final userId = await _api.getTrackingId();
    if (userId == null) return;
    try {
      if (_favorisSet.contains(fiche.trackingId)) {
        // Need the favoriId to delete — find it from the response
        final page = await _api.explorer.getFavorisUtilisateur(userId, page: 0, size: 100);
        final match = page.content.cast<FavoriResponse?>().firstWhere(
          (f) => f!.ficheTrackingId == fiche.trackingId,
          orElse: () => null,
        );
        if (match != null) {
          await _api.supprimerFavori(match.trackingId);
          setState(() => _favorisSet.remove(fiche.trackingId));
        }
      } else {
        await _api.ajouterFavori(FavoriRequest(
          utilisateurTrackingId: userId,
          ficheTrackingId: fiche.trackingId,
        ));
        setState(() => _favorisSet.add(fiche.trackingId));
      }
    } catch (_) {}
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
                  ? const SkeletonListPage()
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
            onTap: _showFilters,
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
              child: Badge(
                isLabelVisible: _filters.hasActiveFilters,
                label: const Text('!', style: TextStyle(fontSize: 9, color: Colors.white)),
                child: const Icon(Icons.tune_rounded,
                    color: AppColors.primary, size: 20),
              ),
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
                    fontFamily: 'Inter',
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
                GestureDetector(
                  onTap: _showAllCategories,
                  child: Text(
                    'Voir tout',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
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
                isFavori: _favorisSet.contains(results[index].trackingId),
                onToggleFavorite: () => _toggleFavori(results[index]),
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
                  fontFamily: 'Inter',
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
                fontFamily: 'Inter',
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
                      fontFamily: 'Inter',
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
    if (_searchQuery.isNotEmpty) {
      return const SizedBox(
        height: 200,
        child: EmptyContentScreen(
          icon: Icons.search_off_rounded,
          title: 'Aucun résultat trouvé',
          subtitle: 'Essayez un autre mot-clé',
        ),
      );
    }
    return const SizedBox(
      height: 200,
      child: EmptyContentScreen(
        icon: Icons.library_books_outlined,
        title: 'Aucune fiche disponible',
        subtitle: 'Revenez plus tard, le catalogue s\'enrichit régulièrement.',
      ),
    );
  }
}

// ─── TOUTES LES CATÉGORIES ───────────────────────────────────────────────────
class _AllCategoriesScreen extends StatelessWidget {
  final CatalogueFilters filters;

  const _AllCategoriesScreen({required this.filters});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text('Toutes les fiches',
            style: AppTextStyles.headingMedium),
        bottom: const TabBar(
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textLight,
          indicatorColor: AppColors.primary,
          labelStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w700),
          tabs: [
            Tab(text: 'Séries'),
            Tab(text: 'Filières'),
            Tab(text: 'Métiers'),
            Tab(text: 'Étab.'),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          CategoryListScreen(type: CategoryType.series, title: 'Séries'),
          CategoryListScreen(type: CategoryType.filieres, title: 'Filières'),
          CategoryListScreen(type: CategoryType.metiers, title: 'Métiers'),
          CategoryListScreen(type: CategoryType.etablissements, title: 'Établissements'),
        ],
      ),
    );
  }
}

// ─── FICHE CARD ───────────────────────────────────────────────────────────────
class _FicheCard extends StatelessWidget {
  final FicheBase fiche;
  final VoidCallback onTap;
  final bool isFavori;
  final VoidCallback onToggleFavorite;

  const _FicheCard({
    required this.fiche,
    required this.onTap,
    this.isFavori = false,
    required this.onToggleFavorite,
  });

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
            // Image
            if (fiche.imageUrl != null && fiche.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: Stack(
                  children: [
                    AuthImage(
                      imageUrl: fiche.imageUrl,
                      height: 72,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          height: 80,
                          color: _typeColor.withValues(alpha: 0.08),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(_typeColor),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (fiche.videoUrls.isNotEmpty)
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
              ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge type
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _typeLabel,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: _typeColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fiche.titre,
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Favoris
                      GestureDetector(
                        onTap: onToggleFavorite,
                        child: Icon(
                          isFavori
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 16,
                          color: isFavori ? AppColors.error : AppColors.textLight,
                        ),
                      ),
                      // Flèche
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _typeColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.chevron_right_rounded,
                            size: 14, color: _typeColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
