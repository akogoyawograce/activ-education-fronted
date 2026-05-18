import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _api = ApiService();

  EleveResponse? _eleve;
  bool _isLoading = true;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  TextEditingController? _nomController;
  TextEditingController? _prenomController;
  TextEditingController? _emailController;
  TextEditingController? _telephoneController;
  TextEditingController? _etablissementController;
  TextEditingController? _filiereController;
  String? _selectedNiveau;
  String? _selectedEtablissement;
  String? _selectedFiliere;

  final List<String> _niveaux = [
    '6ème', '5ème', '4ème', '3ème',
    'Seconde', 'Première', 'Terminale',
    'Licence 1', 'Licence 2', 'Licence 3',
    'Master 1', 'Master 2',
  ];

  List<String> _etablissements = [];
  List<String> _filieres = [];
  bool _isLoadingDropdowns = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadDropdowns();
  }

  Future<void> _loadDropdowns() async {
    try {
      setState(() => _isLoadingDropdowns = true);
      final etablissements = await _api.getEtablissementsList();
      final filieres = await _api.getFilieresList();
      setState(() {
        _etablissements = etablissements;
        _filieres = filieres;
        _isLoadingDropdowns = false;
      });
    } catch (_) {
      setState(() => _isLoadingDropdowns = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadDropdowns();
  }

  @override
  void dispose() {
    _nomController?.dispose();
    _prenomController?.dispose();
    _emailController?.dispose();
    _telephoneController?.dispose();
    _etablissementController?.dispose();
    _filiereController?.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() => _isLoading = true);
      final trackingId = await _api.getTrackingId();
      if (trackingId == null) return;

      final eleve = await _api.getEleve(trackingId);

      _nomController = TextEditingController(text: eleve.nom);
      _prenomController = TextEditingController(text: eleve.prenom);
      _emailController = TextEditingController(text: eleve.email);
      _telephoneController = TextEditingController(text: eleve.telephone ?? '');
      _selectedNiveau = eleve.niveauEtude;
      _selectedEtablissement = eleve.etablissementActuel;
      _selectedFiliere = eleve.filiere;

      setState(() {
        _eleve = eleve;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);
      final trackingId = await _api.getTrackingId();
      if (trackingId == null) return;

      final request = EleveRequest(
        nom: _nomController!.text,
        prenom: _prenomController!.text,
        email: _emailController!.text,
        telephone: _telephoneController!.text.isEmpty ? null : _telephoneController!.text,
        motDePasse: 'placeholder', // Le backend ne devrait pas exiger le mdp pour update
        niveauEtude: _selectedNiveau,
        etablissementActuel: _selectedEtablissement,
        filiere: _selectedFiliere,
        typeApprenant: _getTypeApprenantFromNiveau(_selectedNiveau),
      );

      await _api.modifierEleve(trackingId, request);

      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  TypeApprenant _getTypeApprenantFromNiveau(String? niveau) {
    if (niveau == null) return TypeApprenant.AUTRE;
    if (['6ème', '5ème', '4ème', '3ème'].contains(niveau)) {
      return TypeApprenant.COLLEGIEN;
    }
    if (['Seconde', 'Première', 'Terminale'].contains(niveau)) {
      return TypeApprenant.LYCEEN;
    }
    if (niveau.contains('Licence') || niveau.contains('Master')) {
      return TypeApprenant.ETUDIANT;
    }
    return TypeApprenant.AUTRE;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                      child: Row(
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
                              child: const Icon(Icons.arrow_back_ios_new_rounded,
                                  color: AppColors.textDark, size: 16),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Mon Profil',
                            style: AppTextStyles.headingMedium.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              if (_isEditing) {
                                _saveProfile();
                              } else {
                                setState(() => _isEditing = true);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: _isEditing
                                    ? AppColors.primary
                                    : AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isEditing ? Icons.check_rounded : Icons.edit_rounded,
                                    color: _isEditing ? Colors.white : AppColors.primary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _isEditing ? 'Enregistrer' : 'Modifier',
                                    style: AppTextStyles.caption.copyWith(
                                      color: _isEditing
                                          ? Colors.white
                                          : AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Avatar section
                  SliverToBoxAdapter(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${_eleve!.prenom[0]}${_eleve!.nom[0]}',
                                style: AppTextStyles.displayMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _eleve!.nomComplet,
                            style: AppTextStyles.headingLarge.copyWith(
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _eleve!.typeApprenant,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Form section
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField(
                                label: 'Prénom',
                                controller: _prenomController!,
                                enabled: _isEditing,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Nom',
                                controller: _nomController!,
                                enabled: _isEditing,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Email',
                                controller: _emailController!,
                                enabled: _isEditing,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: 'Téléphone',
                                controller: _telephoneController!,
                                enabled: _isEditing,
                                keyboardType: TextInputType.phone,
                                prefixText: '+228 ',
                              ),
                              const SizedBox(height: 16),
                              _buildDropdownField(
                                label: 'Niveau d\'étude',
                                value: _selectedNiveau,
                                items: _niveaux,
                                enabled: _isEditing,
                                onChanged: (v) => setState(() => _selectedNiveau = v),
                              ),
                              const SizedBox(height: 16),
                              _buildDropdownField(
                                label: 'Établissement',
                                value: _selectedEtablissement,
                                items: _etablissements,
                                enabled: _isEditing,
                                isLoading: _isLoadingDropdowns,
                                onChanged: (v) => setState(() => _selectedEtablissement = v),
                              ),
                              const SizedBox(height: 16),
                              _buildDropdownField(
                                label: 'Filière',
                                value: _selectedFiliere,
                                items: _filieres,
                                enabled: _isEditing,
                                isLoading: _isLoadingDropdowns,
                                onChanged: (v) => setState(() => _selectedFiliere = v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Settings options
                        _buildSettingsSection(),
                      ]),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    TextInputType? keyboardType,
    String? prefixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyLarge.copyWith(
            color: enabled ? AppColors.textDark : AppColors.textMedium,
          ),
          decoration: InputDecoration(
            prefixText: prefixText,
            filled: true,
            fillColor: enabled ? Colors.white : AppColors.backgroundGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required bool enabled,
    bool isLoading = false,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.white : AppColors.backgroundGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled ? AppColors.cardBorder : AppColors.textLight,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : DropdownButtonFormField<String>(
                  initialValue: items.contains(value) ? value : null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  hint: Text(
                    'Sélectionner',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                  items: items.map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  )).toList(),
                  onChanged: enabled ? onChanged : null,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textMedium),
                ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Gérer les alertes',
            onTap: () {},
          ),
          const Divider(height: 1, color: AppColors.cardBorder),
          _buildSettingsItem(
            icon: Icons.lock_outline_rounded,
            title: 'Mot de passe',
            subtitle: 'Changer le mot de passe',
            onTap: () {},
          ),
          const Divider(height: 1, color: AppColors.cardBorder),
          _buildSettingsItem(
            icon: Icons.help_outline_rounded,
            title: 'Aide & Support',
            subtitle: 'FAQ et contact',
            onTap: () {},
          ),
          const Divider(height: 1, color: AppColors.cardBorder),
          _buildSettingsItem(
            icon: Icons.info_outline_rounded,
            title: 'À propos',
            subtitle: 'Version 1.0.0',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              onPressed: () async {
                await _api.logout();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                }
              },
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
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(color: AppColors.textMedium),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
    );
  }
}
