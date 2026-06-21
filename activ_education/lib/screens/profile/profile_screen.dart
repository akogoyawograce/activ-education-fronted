import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../services/api_service.dart';
import '../../services/base_service.dart';
import '../../models/models.dart';
import '../../widgets/skeleton_widget.dart';
import '../errors/empty_content_screen.dart';
import '../../utils/profile_completion.dart';
import '../../utils/image_utils.dart';
import '../historique/historique_screen.dart';
import '../documents/documents_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

enum _ProfileType { eleve, parent, unknown }

class _ProfileScreenState extends State<ProfileScreen> {
  final _api = ApiService();
  _ProfileType _type = _ProfileType.unknown;

  EleveResponse? _eleve;
  ParentResponse? _parent;
  List<FavoriResponse> _favoris = [];
  List<HistoriqueResponse> _historique = [];
  int _totalFavoris = 0;
  int _documentCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadProfile(), _loadFavoris(), _loadHistorique(), _loadDocumentCount()]);
  }

  Future<void> _loadProfile() async {
    try {
      final trackingId = await _api.getTrackingId();
      if (!mounted) return;
      if (trackingId == null) {
        setState(() => _isLoading = false);
        return;
      }
      final role = await _api.getUserRole();
      if (!mounted) return;
      if (role?.toUpperCase() == 'PARENT') {
        _type = _ProfileType.parent;
        final parent = await _api.auth.getParent(trackingId);
        if (!mounted) return;
        setState(() { _parent = parent; _isLoading = false; });
      } else if (role?.toUpperCase() == 'ELEVE') {
        _type = _ProfileType.eleve;
        final eleve = await _api.getEleve(trackingId);
        if (!mounted) return;
        setState(() { _eleve = eleve; _isLoading = false; });
      } else {
        final eleve = await _api.getEleve(trackingId);
        if (!mounted) return;
        setState(() { _eleve = eleve; _isLoading = false; });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFavoris() async {
    try {
      final trackingId = await _api.getTrackingId();
      if (!mounted) return;
      if (trackingId == null) return;
      final page = await _api.explorer.getFavorisUtilisateur(trackingId, page: 0, size: 3);
      if (!mounted) return;
      setState(() { _favoris = page.content; _totalFavoris = page.totalElements; });
    } catch (_) {}
  }

  Future<void> _loadHistorique() async {
    try {
      final trackingId = await _api.getTrackingId();
      if (!mounted) return;
      if (trackingId == null) return;
      final res = await _api.dio.get(
        '/api/v1/utilisateurs/$trackingId/historique',
        queryParameters: {'page': 0, 'size': 3},
      );
      if (!mounted) return;
      final page = PageResponse<HistoriqueResponse>.fromJson(
        res.data, (json) => HistoriqueResponse.fromJson(json),
      );
      setState(() => _historique = page.content);
    } catch (_) {}
  }

  bool get _isLoggedIn => _eleve != null || _parent != null;

  String get _nom => _eleve?.nom ?? _parent?.nom ?? '';
  String get _prenom => _eleve?.prenom ?? _parent?.prenom ?? '';

  String get _initials {
    if (_prenom.isEmpty && _nom.isEmpty) return '??';
    return '${_prenom[0]}${_nom[0]}';
  }

  String get _nomComplet => '$_prenom $_nom';

  String? get _photoUrl => _eleve?.photoUrl;

  bool get _isLyceen => _eleve?.typeApprenant == 'LYCEEN';
  bool get _isEtudiant => _eleve?.typeApprenant == 'ETUDIANT';
  bool get _isCollegien => _eleve?.typeApprenant == 'COLLEGIEN';

  String _parcoursLabel(bool capitalize) {
    if (_isLyceen) return capitalize ? 'Série' : 'série';
    if (_isEtudiant) return capitalize ? 'Filière' : 'filière';
    return '';
  }

  String get _sousTitre {
    if (_type == _ProfileType.parent) {
      final e = _parent;
      if (e == null) return '';
      final parts = <String>['Parent'];
      if (e.telephone != null && e.telephone!.isNotEmpty) parts.add(e.telephone!);
      return parts.join(' — ');
    }
    final e = _eleve;
    if (e == null) return '';
    final parts = <String>[_typeApprenantLabel(e.typeApprenant)];
    if (e.niveauEtude != null && e.niveauEtude!.isNotEmpty) parts.add(e.niveauEtude!);
    final l = _parcoursLabel(false);
    if (e.filiere != null && e.filiere!.isNotEmpty && l.isNotEmpty) {
      parts.add('$l ${e.filiere}');
    }
    return parts.join(' — ');
  }

  String _typeApprenantLabel(String type) {
    switch (type) {
      case 'ECOLIER': return 'Écolier';
      case 'COLLEGIEN': return 'Collégien';
      case 'LYCEEN': return 'Lycéen';
      case 'ETUDIANT': return 'Étudiant';
      case 'PROFESSIONNEL': return 'Professionnel';
      default: return 'Apprenant';
    }
  }

  int get _completionPercent {
    if (_type == _ProfileType.parent) return 100;
    final e = _eleve;
    if (e == null) return 0;
    return calculateProfileCompletion(
      telephone: e.telephone,
      etablissementActuel: e.etablissementActuel,
      filiere: e.filiere,
      matieresPreferees: e.matieresPreferees,
      hasNotes: false,
      hasDiagnostic: false,
    ).round();
  }

  List<String> _getChampsManquants() {
    if (_type == _ProfileType.parent) return [];
    final e = _eleve;
    if (e == null) return [];
    final missing = <String>[];
    if (e.etablissementActuel == null || e.etablissementActuel!.isEmpty) {
      missing.add('Établissement');
    }
    if (e.matieresPreferees == null || e.matieresPreferees!.isEmpty) {
      missing.add("Centres d'intérêt");
    }
    if (!_isCollegien && (e.filiere == null || e.filiere!.isEmpty)) {
      missing.add(_parcoursLabel(true));
    }
    missing.add('Photo de profil');
    return missing;
  }

  String get _matieresLabel {
    final e = _eleve;
    if (e == null || e.matieresPreferees == null || e.matieresPreferees!.isEmpty) {
      return 'Non renseigné';
    }
    return e.matieresPreferees!.join(', ');
  }

  String _relativeDate(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return 'Il y a ${(diff.inDays / 30).round()} mois';
    if (diff.inDays > 7) return 'Il y a ${(diff.inDays / 7).round()} sem';
    if (diff.inDays > 0) return 'Il y a ${diff.inDays}j';
    if (diff.inHours > 0) return 'Il y a ${diff.inHours}h';
    if (diff.inMinutes > 0) return 'Il y a ${diff.inMinutes}min';
    return "À l'instant";
  }

  // ─── MODALS (Élève) ────────────────────────────────────────────────────

  static const _niveauxCollegien = ['6ème', '5ème', '4ème', '3ème'];
  static const _niveauxLyceen = ['Seconde', 'Première', 'Terminale'];
  static const _niveauxEtudiant = ['L1', 'L2', 'L3', 'M1', 'M2', 'Doctorat'];
  static const _series = ['A', 'C', 'D', 'E', 'F', 'G'];

  List<String> get _niveauxDisponibles {
    if (_isCollegien) return _niveauxCollegien;
    if (_isLyceen) return _niveauxLyceen;
    if (_isEtudiant) return _niveauxEtudiant;
    return [];
  }

  Future<void> _showEditParcours() async {
    final initialNiveau = _eleve?.niveauEtude ?? '';
    final initialFiliere = _eleve?.filiere ?? '';
    List<String> filieres = [];
    if (_isEtudiant) {
      try {
        filieres = await _api.getFilieresList();
      } catch (_) {}
    }

    if (!mounted) return;
    String niveau = _niveauxDisponibles.contains(initialNiveau) ? initialNiveau : '';
    String filiere = _isLyceen
        ? (_series.contains(initialFiliere) ? initialFiliere : '')
        : (filieres.contains(initialFiliere) ? initialFiliere : '');

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        bool saving = false;
        String selectedNiveau = niveau;
        String selectedFiliere = filiere;
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mon parcours', style: AppTextStyles.headingMedium),
                const SizedBox(height: 20),
                _buildDropdown('Niveau', _niveauxDisponibles, selectedNiveau, (v) {
                  if (v != null) setSheetState(() => selectedNiveau = v);
                }),
                if (!_isCollegien) ...[
                  const SizedBox(height: 12),
                  _buildDropdown(
                    _parcoursLabel(true),
                    _isLyceen ? _series : filieres,
                    selectedFiliere,
                    (v) { if (v != null) setSheetState(() => selectedFiliere = v); },
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: selectedNiveau.isEmpty || (!_isCollegien && selectedFiliere.isEmpty)
                        ? null
                        : saving ? null : () {
                            setSheetState(() => saving = true);
                            Navigator.pop(ctx, {
                              'niveau': selectedNiveau,
                              'filiere': selectedFiliere,
                            });
                          },
                    child: saving
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white,
                            ),
                          )
                        : const Text('Enregistrer',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );

    if (result != null && mounted) {
      await _updateEleve(
        niveau: result['niveau'] as String,
        filiere: result['filiere'] as String,
      );
    }
  }

  Widget _buildDropdown(String label, List<String> items, String value, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: DropdownButtonFormField<String>(
            value: items.contains(value) ? value : null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            hint: Text('Sélectionner $label',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
            items: items.map((item) => DropdownMenuItem(
              value: item,
              child: Text(item, style: AppTextStyles.bodyLarge),
            )).toList(),
            onChanged: onChanged,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMedium),
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  Future<void> _showEditEtablissement() async {
    final ctrl = TextEditingController(text: _eleve?.etablissementActuel ?? '');
    final result = await _showEditBottomSheet(
      title: 'Mon établissement',
      children: [_buildSheetField('Établissement', ctrl)],
    );
    if (result == true) {
      await _updateEleve(etablissement: ctrl.text);
    }
    ctrl.dispose();
  }

  Future<void> _showEditInterets() async {
    final current = _eleve?.matieresPreferees?.join(', ') ?? '';
    final ctrl = TextEditingController(text: current);
    final result = await _showEditBottomSheet(
      title: "Mes centres d'intérêt",
      children: [
        _buildSheetField(
          'Matières préférées (séparées par des virgules)',
          ctrl,
        ),
      ],
    );
    if (result == true) {
      final matieres = ctrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      await _updateEleve(matieresPreferees: matieres);
    }
    ctrl.dispose();
  }

  Future<void> _showEditMetierSouhaite() async {
    final ctrl = TextEditingController(text: _eleve?.metierSouhaite ?? '');
    final result = await _showEditBottomSheet(
      title: 'Métier souhaité',
      children: [
        _buildSheetField('Quel métier voulez-vous exercer ?', ctrl),
      ],
    );
    if (result == true) {
      await _updateEleve(metierSouhaite: ctrl.text);
    }
    ctrl.dispose();
  }

  // ─── MODALS (Parent) ────────────────────────────────────────────────────

  Future<void> _showEditParentInfo() async {
    final nomCtrl = TextEditingController(text: _parent?.nom ?? '');
    final prenomCtrl = TextEditingController(text: _parent?.prenom ?? '');
    final telCtrl = TextEditingController(text: _parent?.telephone ?? '');
    final result = await _showEditBottomSheet(
      title: 'Mes informations',
      children: [
        _buildSheetField('Nom', nomCtrl),
        const SizedBox(height: 12),
        _buildSheetField('Prénom', prenomCtrl),
        const SizedBox(height: 12),
        _buildSheetField('Téléphone', telCtrl),
      ],
    );
    if (result == true) {
      await _updateParent(
        nom: nomCtrl.text,
        prenom: prenomCtrl.text,
        telephone: telCtrl.text,
      );
    }
    nomCtrl.dispose();
    prenomCtrl.dispose();
    telCtrl.dispose();
  }

  Future<bool?> _showEditBottomSheet({
    required String title,
    required List<Widget> children,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headingMedium),
                const SizedBox(height: 20),
                ...children,
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: saving
                        ? null
                        : () {
                            setSheetState(() => saving = true);
                            Navigator.pop(ctx, true);
                          },
                    child: saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Enregistrer',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildSheetField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.backgroundGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  // ─── UPDATE (Élève) ─────────────────────────────────────────────────────

  Future<void> _updateEleve({
    String? niveau,
    String? filiere,
    String? etablissement,
    List<String>? matieresPreferees,
    String? metierSouhaite,
  }) async {
    final e = _eleve;
    if (e == null) return;
    try {
      final trackingId = await _api.getTrackingId();
      if (trackingId == null) return;
      final req = EleveRequest(
        nom: e.nom,
        prenom: e.prenom,
        email: e.email,
        telephone: e.telephone,
        niveauEtude: niveau ?? e.niveauEtude,
        filiere: filiere ?? e.filiere,
        etablissementActuel: etablissement ?? e.etablissementActuel,
        typeApprenant: TypeApprenant.values.firstWhere(
          (t) => t.name == e.typeApprenant,
          orElse: () => TypeApprenant.AUTRE,
        ),
        matieresPreferees: matieresPreferees ?? e.matieresPreferees,
        styleApprentissage: e.styleApprentissage,
        metierSouhaite: metierSouhaite ?? e.metierSouhaite,
      );
      final updated = await _api.modifierEleve(trackingId, req);
      BaseService.clearCache();
      if (mounted) {
        setState(() { _eleve = updated; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour')),
        );
      }
    } catch (err) {
      if (mounted) {
        final hasToken = await _api.getAccessToken();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${_api.handleError(err)}')),
        );
        if (hasToken == null) {
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.login, (route) => false);
        }
      }
    }
  }

  // ─── UPDATE (Parent) ────────────────────────────────────────────────────

  Future<void> _updateParent({
    String? nom,
    String? prenom,
    String? telephone,
  }) async {
    try {
      final trackingId = await _api.getTrackingId();
      if (trackingId == null) return;
      final data = <String, dynamic>{};
      if (nom != null && nom.isNotEmpty) data['nom'] = nom;
      if (prenom != null && prenom.isNotEmpty) data['prenom'] = prenom;
      if (telephone != null && telephone.isNotEmpty) data['telephone'] = telephone;
      final updated = await _api.modifierParent(trackingId, data);
      BaseService.clearCache();
      if (mounted) {
        setState(() { _parent = updated; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour')),
        );
      }
    } catch (err) {
      if (mounted) {
        final hasToken = await _api.getAccessToken();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${_api.handleError(err)}')),
        );
        if (hasToken == null) {
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.login, (route) => false);
        }
      }
    }
  }

  Future<void> _loadDocumentCount() async {
    if (_type == _ProfileType.parent) return;
    try {
      final trackingId = await _api.getTrackingId();
      if (!mounted || trackingId == null) return;
      final count = await _api.countDocuments(trackingId);
      if (!mounted) return;
      setState(() => _documentCount = count);
    } catch (_) {}
  }

  void _showDocuments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentsScreen(trackingId: _eleve!.trackingId),
      ),
    );
  }

  Future<void> _uploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024);
    if (picked == null) return;
    final trackingId = await _api.getTrackingId();
    if (trackingId == null || !mounted) return;
    try {
      final updated = await _api.uploadPhotoProfil(trackingId, File(picked.path));
      setState(() {
        if (_type == _ProfileType.eleve) {
          _eleve = updated;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo de profil mise à jour')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${_api.handleError(e)}')),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _api.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.login, (route) => false,
        );
      }
    }
  }

  // ─── BUILD ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: _isLoading
            ? const SkeletonListPage()
            : !_isLoggedIn
                ? Center(
                    child: EmptyContentScreen(
                      icon: Icons.person_off_rounded,
                      title: 'Connecte-toi pour voir ton profil',
                      actionLabel: 'Se connecter',
                      onAction: () => Navigator.pushNamedAndRemoveUntil(
                        context, AppRoutes.login, (route) => false,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadAll,
                    child: CustomScrollView(
                      slivers: [
                        _buildHeaderSliver(),
                        if (_type == _ProfileType.eleve)
                          SliverToBoxAdapter(child: _buildCompletionCard()),
                        SliverToBoxAdapter(child: _buildSections()),
                        if (_favoris.isNotEmpty && _type == _ProfileType.eleve)
                          SliverToBoxAdapter(child: _buildFavorisSection()),
                        if (_historique.isNotEmpty && _type == _ProfileType.eleve)
                          SliverToBoxAdapter(child: _buildHistoriqueSection()),
                        SliverToBoxAdapter(child: _buildLogoutSection()),
                        SliverToBoxAdapter(child: _buildVersionInfo()),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 32),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────────────────

  Widget _buildHeaderSliver() {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16,
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'PROFIL',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$_completionPercent%',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Stack(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    image: _photoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(resolveImageUrl(_photoUrl)!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _photoUrl == null
                      ? Center(
                          child: Text(
                            _initials,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _uploadPhoto,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white, size: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _nomComplet,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _sousTitre,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            if (_type == _ProfileType.eleve) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: _completionPercent / 100,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                  minHeight: 4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── COMPLETION CARD ────────────────────────────────────────────────────

  Widget _buildCompletionCard() {
    if (_completionPercent >= 100) return const SizedBox.shrink();
    final missing = _getChampsManquants();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Complète ton profil pour de meilleures recommandations",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: missing.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8EC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  missing[i],
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: () => _showEditEtablissement(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  elevation: 0,
                ),
                child: const Text(
                  'Compléter',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SECTIONS ───────────────────────────────────────────────────────────

  Widget _buildSections() {
    final items = _type == _ProfileType.parent
        ? _buildParentSections()
        : _buildEleveSections();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: items),
    );
  }

  List<Widget> _buildEleveSections() {
    return [
      _sectionItem(
        icon: Icons.school,
        title: 'Mon parcours',
        subtitle: () {
          final niveau = _eleve?.niveauEtude ?? '';
          final filiere = _eleve?.filiere ?? '';
          final l = _parcoursLabel(false);
          if (niveau.isEmpty && filiere.isEmpty) return 'Non renseigné';
          if (_isCollegien) return niveau;
          if (filiere.isEmpty) return niveau;
          return '$niveau — $l $filiere';
        }(),
        onTap: _showEditParcours,
      ),
      const Divider(height: 1, color: AppColors.cardBorder),
      _sectionItem(
        icon: Icons.business,
        title: 'Mon établissement',
        subtitle: _eleve?.etablissementActuel ?? 'Non renseigné',
        onTap: _showEditEtablissement,
      ),
      const Divider(height: 1, color: AppColors.cardBorder),
      _sectionItem(
        icon: Icons.star_outline,
        title: "Mes centres d'intérêt",
        subtitle: _matieresLabel,
        onTap: _showEditInterets,
      ),
      const Divider(height: 1, color: AppColors.cardBorder),
      _sectionItem(
        icon: Icons.work_outline,
        title: 'Métier souhaité',
        subtitle: _eleve?.metierSouhaite ?? 'Non renseigné',
        onTap: _showEditMetierSouhaite,
      ),
      const Divider(height: 1, color: AppColors.cardBorder),
      _sectionItem(
        icon: Icons.bar_chart,
        title: 'Mes notes',
        subtitle: '${_eleve?.niveauEtude ?? ''} — Saisies',
        onTap: () => Navigator.pushNamed(context, AppRoutes.notes),
      ),
      const Divider(height: 1, color: AppColors.cardBorder),
      _sectionItem(
        icon: Icons.folder_open,
        title: 'Mes documents',
        subtitle: '$_documentCount document${_documentCount > 1 ? 's' : ''}',
        onTap: _showDocuments,
      ),
      const Divider(height: 1, color: AppColors.cardBorder),
      _sectionItem(
        icon: Icons.vpn_key_rounded,
        title: 'Mon identifiant',
        subtitle: _eleve?.trackingId ?? '',
        onTap: () {
          if (_eleve?.trackingId != null) {
            Clipboard.setData(ClipboardData(text: _eleve!.trackingId));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Identifiant copié !')),
            );
          }
        },
      ),
    ];
  }

  List<Widget> _buildParentSections() {
    final enfantsCount = _parent?.enfantsTrackingIds.length ?? 0;
    return [
      _sectionItem(
        icon: Icons.person,
        title: 'Mes informations',
        subtitle: '${_parent?.nom ?? ''} ${_parent?.prenom ?? ''}'.trim(),
        onTap: _showEditParentInfo,
      ),
      const Divider(height: 1, color: AppColors.cardBorder),
      _sectionItem(
        icon: Icons.phone,
        title: 'Téléphone',
        subtitle: _parent?.telephone ?? 'Non renseigné',
        onTap: _showEditParentInfo,
      ),
      const Divider(height: 1, color: AppColors.cardBorder),
      _sectionItem(
        icon: Icons.mail,
        title: 'Email',
        subtitle: _parent?.email ?? '',
        onTap: null,
      ),
      const Divider(height: 1, color: AppColors.cardBorder),
      _sectionItem(
        icon: Icons.family_restroom,
        title: 'Enfants liés',
        subtitle: enfantsCount == 1 ? '1 enfant' : '$enfantsCount enfants',
        onTap: null,
      ),
    ];
  }

  Widget _sectionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: AppColors.textMedium,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        trailing: onTap != null
            ? const Icon(Icons.chevron_right_rounded, color: AppColors.textLight)
            : null,
      ),
    );
  }

  // ─── FAVORIS ────────────────────────────────────────────────────────────

  Widget _buildFavorisSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mes favoris',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _favoris.map((f) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.bookmark_outline,
                        color: AppColors.primary, size: 20,
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          f.ficheTitre ?? 'Fiche',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.favorites),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Voir tous mes favoris ($_totalFavoris) →',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HISTORIQUE ─────────────────────────────────────────────────────────

  Widget _buildHistoriqueSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mon historique',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          ..._historique.map((h) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.history_rounded,
                  size: 20, color: AppColors.textMedium,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    h.action,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _relativeDate(h.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          )),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoriqueScreen())),
            child: const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Voir tout →',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── LOGOUT ─────────────────────────────────────────────────────────────

  Widget _buildLogoutSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: OutlinedButton(
        onPressed: _logout,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Se déconnecter',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Center(
        child: Text(
          'Version 1.0.1',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textLight,
          ),
        ),
      ),
    );
  }
}
