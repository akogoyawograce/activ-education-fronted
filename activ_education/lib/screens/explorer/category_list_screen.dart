import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../widgets/skeleton_widget.dart';
import '../errors/empty_content_screen.dart';
import 'fiche_detail_screen.dart';
import 'catalogue_filter_sheet.dart';

enum CategoryType { series, filieres, metiers, etablissements }

class CategoryListScreen extends StatefulWidget {
  final CategoryType type;
  final String title;

  const CategoryListScreen({
    super.key,
    required this.type,
    required this.title,
  });

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final _api = ApiService();
  final _scrollController = ScrollController();

  List<FicheBase> _items = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 0;
  bool _hasMore = true;
  CatalogueFilters _filters = const CatalogueFilters();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadPage(0);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadPage(int page) async {
    try {
      setState(() => _isLoading = page == 0);

      final size = 20;
      PageResponse result;
      switch (widget.type) {
        case CategoryType.series:
          result = await _api.listerSeries(page: page, size: size);
          break;
        case CategoryType.filieres:
          result = await _api.listerFilieres(page: page, size: size);
          break;
        case CategoryType.metiers:
          result = await _api.listerMetiers(page: page, size: size);
          break;
        case CategoryType.etablissements:
          result = await _api.listerEtablissements(page: page, size: size);
          break;
      }

      final newItems = result.content as List<FicheBase>;

      setState(() {
        if (page == 0) {
          _items = newItems;
        } else {
          _items.addAll(newItems);
        }
        _currentPage = page;
        _hasMore = !result.last;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    _isLoadingMore = true;
    await _loadPage(_currentPage + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text(widget.title, style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary)),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _filters.hasActiveFilters,
              label: Text('!', style: const TextStyle(fontSize: 10, color: Colors.white)),
              child: const Icon(Icons.tune_rounded),
            ),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: _isLoading
          ? const SkeletonListPage()
          : _items.isEmpty
              ? Center(
                  child: EmptyContentScreen(
                    icon: Icons.search_off_rounded,
                    title: 'Aucun résultat',
                    subtitle: _filters.hasActiveFilters
                        ? 'Essayez de modifier vos filtres'
                        : 'Revenez plus tard, le catalogue s\'enrichit.',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadPage(0),
                  color: AppColors.primary,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _items.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                        );
                      }
                      return _CategoryCard(
                        fiche: _items[index],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FicheDetailScreen(fiche: _items[index]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
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
          _loadPage(0);
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final FicheBase fiche;
  final VoidCallback onTap;

  const _CategoryCard({required this.fiche, required this.onTap});

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
      return '${f.domaine ?? ''}${f.duree != null ? ' • ${f.duree}' : ''}';
    }
    if (fiche is FicheMetierResponse) {
      return (fiche as FicheMetierResponse).secteur ?? '';
    }
    if (fiche is FicheEtablissementResponse) {
      final e = fiche as FicheEtablissementResponse;
      return '${e.ville ?? ''}${e.estPublic ? ' • Public' : ' • Privé'}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: _typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  fiche is FicheSerieResponse ? Icons.book_rounded :
                  fiche is FicheFiliereResponse ? Icons.account_tree_rounded :
                  fiche is FicheMetierResponse ? Icons.work_rounded :
                  Icons.location_city_rounded,
                  color: _typeColor, size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fiche.titre,
                    style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(_typeLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _typeColor)),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textLight, size: 20),
          ],
        ),
      ),
    );
  }
}
