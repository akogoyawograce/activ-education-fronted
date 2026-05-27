import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class ConseillersScreen extends StatefulWidget {
  const ConseillersScreen({super.key});

  @override
  State<ConseillersScreen> createState() => _ConseillersScreenState();
}

class _ConseillersScreenState extends State<ConseillersScreen> {
  final _api = ApiService();
  final _searchController = TextEditingController();

  List<ConseillerResponse> _conseillers = [];
  List<ConseillerResponse> _filtered = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConseillers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConseillers() async {
    try {
      final conseillers = await _api.getConseillers(size: 200);
      setState(() {
        _conseillers = conseillers.where((c) => c.actif).toList();
        _filtered = _conseillers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filter(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _conseillers
          : _conseillers.where((c) {
              final name = '${c.prenom} ${c.nom}'.toLowerCase();
              final specialites = c.specialites?.toLowerCase() ?? '';
              return name.contains(q) || specialites.contains(q);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text('Annuaire des conseillers'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: TextField(
        controller: _searchController,
        onChanged: _filter,
        decoration: InputDecoration(
          hintText: 'Rechercher un conseiller...',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _filter('');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.backgroundGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'Aucun conseiller disponible'
                  : 'Aucun conseiller trouvé',
              style: const TextStyle(fontSize: 16, color: AppColors.textMedium),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConseillers,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _filtered.length,
        itemBuilder: (context, index) => _ConseillerCard(
          conseiller: _filtered[index],
          onContacter: () => _contacter(_filtered[index]),
          onPrendreRDV: () => _prendreRDV(_filtered[index]),
        ),
      ),
    );
  }

  void _contacter(ConseillerResponse c) {
    Navigator.pushNamed(context, AppRoutes.chat, arguments: {
      'expediteurId': c.trackingId,
      'expediteurNom': '${c.prenom} ${c.nom}',
    });
  }

  void _prendreRDV(ConseillerResponse c) {
    Navigator.pushNamed(context, AppRoutes.rdv, arguments: {
      'conseillerId': c.trackingId,
      'conseillerNom': '${c.prenom} ${c.nom}',
    });
  }
}

class _ConseillerCard extends StatelessWidget {
  final ConseillerResponse conseiller;
  final VoidCallback onContacter;
  final VoidCallback onPrendreRDV;

  const _ConseillerCard({
    required this.conseiller,
    required this.onContacter,
    required this.onPrendreRDV,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${conseiller.prenom[0]}${conseiller.nom[0]}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
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
                      '${conseiller.prenom} ${conseiller.nom}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (conseiller.specialites != null && conseiller.specialites!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          conseiller.specialites!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              if (conseiller.anneesExperience != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${conseiller.anneesExperience} ans',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),
          if (conseiller.biographie != null && conseiller.biographie!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                conseiller.biographie!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMedium,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (conseiller.qualifications != null && conseiller.qualifications!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: conseiller.qualifications!
                    .split(',')
                    .where((q) => q.trim().isNotEmpty)
                    .map((q) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundGrey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            q.trim(),
                            style: const TextStyle(fontSize: 11, color: AppColors.textMedium),
                          ),
                        ))
                    .toList(),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onContacter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Contacter',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onPrendreRDV,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_rounded, size: 16, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text(
                          'Prendre RDV',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
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
      ),
    );
  }
}
