import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final _searchController = TextEditingController();
  final _api = ApiService();

  List<RechercheGlobaleResponse> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query.trim()));
  }

  Future<void> _search(String query) async {
    try {
      setState(() => _isSearching = true);
      final results = await _api.rechercherGlobalement(query);
      setState(() {
        _results = results;
        _isSearching = false;
        _hasSearched = true;
      });
    } catch (_) {
      setState(() {
        _isSearching = false;
        _hasSearched = true;
      });
    }
  }

  Color _typeColor(String type) {
    switch (type.toUpperCase()) {
      case 'SERIE': return AppColors.primary;
      case 'FILIERE': return const Color(0xFF10B981);
      case 'METIER': return AppColors.accent;
      case 'ETABLISSEMENT': return const Color(0xFF8B5CF6);
      default: return AppColors.textLight;
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'SERIE': return Icons.book_rounded;
      case 'FILIERE': return Icons.account_tree_rounded;
      case 'METIER': return Icons.work_rounded;
      case 'ETABLISSEMENT': return Icons.location_city_rounded;
      default: return Icons.search_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Recherche', style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary)),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                autofocus: true,
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: 'Rechercher une formation, métier...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textLight, size: 22),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _results = [];
                              _hasSearched = false;
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                : !_hasSearched
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_rounded, size: 64, color: AppColors.textLight.withValues(alpha: 0.4)),
                            const SizedBox(height: 16),
                            Text('Que cherchez-vous ?', style: AppTextStyles.headingMedium.copyWith(color: AppColors.textLight)),
                            const SizedBox(height: 8),
                            Text('Filières, métiers, séries, établissements...',
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
                          ],
                        ),
                      )
                    : _results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off_rounded, size: 64, color: AppColors.textLight.withValues(alpha: 0.4)),
                                const SizedBox(height: 16),
                                Text('Aucun résultat', style: AppTextStyles.headingMedium.copyWith(color: AppColors.textLight)),
                                const SizedBox(height: 8),
                                Text('Essayez d\'autres mots-clés',
                                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            itemCount: _results.length,
                            itemBuilder: (_, i) {
                              final r = _results[i];
                              final color = _typeColor(r.typeResultat);
                              return GestureDetector(
                                onTap: () {},
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44, height: 44,
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(_typeIcon(r.typeResultat), color: color, size: 22),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(r.titre,
                                                style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                                                maxLines: 1, overflow: TextOverflow.ellipsis),
                                            const SizedBox(height: 2),
                                            Text(r.resume,
                                                style: AppTextStyles.caption,
                                                maxLines: 1, overflow: TextOverflow.ellipsis),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          r.typeResultat,
                                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.chevron_right_rounded, color: AppColors.textLight, size: 20),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
