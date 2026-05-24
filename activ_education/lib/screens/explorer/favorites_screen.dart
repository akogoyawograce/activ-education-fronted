import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../widgets/skeleton_widget.dart';
import '../errors/empty_content_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _api = ApiService();

  List<FavoriResponse> _favoris = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoris();
  }

  Future<void> _loadFavoris() async {
    try {
      setState(() => _isLoading = true);
      final userId = await _api.getTrackingId();
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }
      final result = await _api.explorer.getFavorisUtilisateur(userId, size: 100);
      setState(() {
        _favoris = result.content;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFavori(String favoriId, int index) async {
    try {
      await _api.supprimerFavori(favoriId);
      setState(() => _favoris.removeAt(index));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Retiré des favoris'), duration: Duration(seconds: 2)),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text('Mes favoris',
            style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary)),
      ),
      body: _isLoading
          ? const SkeletonListPage()
          : _favoris.isEmpty
              ? const Center(
                  child: EmptyContentScreen(
                    icon: Icons.favorite_border_rounded,
                    title: 'Aucun favori',
                    subtitle: 'Ajoute des fiches en favoris pour les retrouver ici.',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFavoris,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: _favoris.length,
                    itemBuilder: (_, i) => _FavoriCard(
                      favori: _favoris[i],
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context, AppRoutes.home, (route) => false,
                        );
                      },
                      onRemove: () => _removeFavori(_favoris[i].trackingId, i),
                    ),
                  ),
                ),
    );
  }
}

class _FavoriCard extends StatelessWidget {
  final FavoriResponse favori;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriCard({
    required this.favori,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(favori.trackingId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      child: GestureDetector(
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
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bookmark_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      favori.ficheTitre ?? 'Fiche sans titre',
                      style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (favori.notePersonnelle != null && favori.notePersonnelle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        favori.notePersonnelle!,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textLight, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
