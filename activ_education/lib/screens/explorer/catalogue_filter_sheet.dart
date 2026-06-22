import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CatalogueFilters {
  final String? domaine;
  final String? niveau;
  final String? ville;
  final String sortBy;
  final bool onlyPublic;

  const CatalogueFilters({
    this.domaine,
    this.niveau,
    this.ville,
    this.sortBy = 'pertinence',
    this.onlyPublic = false,
  });

  bool get hasActiveFilters =>
      domaine != null || niveau != null || ville != null || onlyPublic;

  CatalogueFilters copyWith({
    String? domaine,
    String? niveau,
    String? ville,
    String? sortBy,
    bool? onlyPublic,
    bool clearDomaine = false,
    bool clearNiveau = false,
    bool clearVille = false,
  }) {
    return CatalogueFilters(
      domaine: clearDomaine ? null : domaine ?? this.domaine,
      niveau: clearNiveau ? null : niveau ?? this.niveau,
      ville: clearVille ? null : ville ?? this.ville,
      sortBy: sortBy ?? this.sortBy,
      onlyPublic: onlyPublic ?? this.onlyPublic,
    );
  }

  CatalogueFilters clear() => const CatalogueFilters();
}

class CatalogueFilterSheet extends StatefulWidget {
  final CatalogueFilters current;
  final ValueChanged<CatalogueFilters> onApply;

  const CatalogueFilterSheet({
    super.key,
    required this.current,
    required this.onApply,
  });

  @override
  State<CatalogueFilterSheet> createState() => _CatalogueFilterSheetState();
}

class _CatalogueFilterSheetState extends State<CatalogueFilterSheet> {
  late String _sortBy;
  String? _domaine;
  String? _niveau;
  String? _ville;
  bool _onlyPublic = false;

  final _domaines = ['Sciences', 'Lettres', 'Commerce', 'Technique', 'Arts'];
  final _niveaux = ['3ème', 'Seconde', 'Première', 'Terminale', 'BAC+1', 'BAC+2', 'BAC+3', 'BAC+5'];
  final _villes = ['Lomé', 'Kara', 'Sokodé', 'Kpalimé', 'Atakpamé', 'Tsévié'];
  final _sortOptions = [
    ('pertinence', 'Pertinence'),
    ('alphabet', 'Ordre alphabétique'),
    ('popularite', 'Les plus consultés'),
  ];

  @override
  void initState() {
    super.initState();
    _sortBy = widget.current.sortBy;
    _domaine = widget.current.domaine;
    _niveau = widget.current.niveau;
    _ville = widget.current.ville;
    _onlyPublic = widget.current.onlyPublic;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Text('Filtrer', style: AppTextStyles.displayMedium),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _sortBy = 'pertinence';
                      _domaine = null;
                      _niveau = null;
                      _ville = null;
                      _onlyPublic = false;
                    });
                  },
                  child: Text('Réinitialiser',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tri
            Text('Trier par', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _sortOptions.map((opt) {
                final isActive = _sortBy == opt.$1;
                return ChoiceChip(
                  label: Text(opt.$2, style: TextStyle(fontSize: 13, color: isActive ? Colors.white : AppColors.textMedium)),
                  selected: isActive,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.backgroundGrey,
                  onSelected: (_) => setState(() => _sortBy = opt.$1),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Domaine
            Text('Domaine', style: AppTextStyles.label),
            const SizedBox(height: 8),
            _buildChipGroup(_domaines, _domaine, (v) => setState(() => _domaine = v)),
            const SizedBox(height: 20),

            // Niveau
            Text('Niveau', style: AppTextStyles.label),
            const SizedBox(height: 8),
            _buildChipGroup(_niveaux, _niveau, (v) => setState(() => _niveau = v)),
            const SizedBox(height: 20),

            // Ville
            Text('Ville', style: AppTextStyles.label),
            const SizedBox(height: 8),
            _buildChipGroup(_villes, _ville, (v) => setState(() => _ville = v)),
            const SizedBox(height: 20),

            // Public/Privé
            Row(
              children: [
                Checkbox(
                  value: _onlyPublic,
                  onChanged: (v) => setState(() => _onlyPublic = v ?? false),
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                Flexible(
                  child: Text('Établissements publics uniquement',
                      style: AppTextStyles.bodyMedium),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Apply
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(CatalogueFilters(
                    sortBy: _sortBy,
                    domaine: _domaine,
                    niveau: _niveau,
                    ville: _ville,
                    onlyPublic: _onlyPublic,
                  ));
                  Navigator.pop(context);
                },
                child: const Text('Appliquer les filtres'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipGroup(List<String> options, String? selected, ValueChanged<String?> onSelected) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: options.map((opt) {
        final isActive = selected == opt;
        return ChoiceChip(
          label: Text(opt, style: TextStyle(fontSize: 13, color: isActive ? Colors.white : AppColors.textMedium)),
          selected: isActive,
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.backgroundGrey,
          onSelected: (_) => onSelected(isActive ? null : opt),
        );
      }).toList(),
    );
  }
}
