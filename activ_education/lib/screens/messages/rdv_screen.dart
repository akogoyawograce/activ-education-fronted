// lib/screens/messages/rdv_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/skeleton_widget.dart';

class RdvScreen extends StatefulWidget {
  final String? conseillerId;
  final String? conseillerNom;

  const RdvScreen({
    super.key,
    this.conseillerId,
    this.conseillerNom,
  });

  @override
  State<RdvScreen> createState() => _RdvScreenState();
}

class _RdvScreenState extends State<RdvScreen>
    with SingleTickerProviderStateMixin {
  final _api = ApiService();
  final _formKey = GlobalKey<FormState>();

  final _objetController = TextEditingController();
  final _commentaireController = TextEditingController();

  List<RendezVousResponse> _rdvs = [];
  String? _userTrackingId;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isCreatingMode = false;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadRdvs();
  }

  void _initAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(_fadeAnim);
  }

  @override
  void dispose() {
    _objetController.dispose();
    _commentaireController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadRdvs() async {
    try {
      setState(() => _isLoading = true);
      _userTrackingId = await _api.getTrackingId();
      if (_userTrackingId == null) {
        setState(() => _isLoading = false);
        return;
      }

      List<RendezVousResponse> rdvs;
      if (widget.conseillerId != null) {
        rdvs = await _api.getRDVConseiller(widget.conseillerId!);
      } else {
        rdvs = await _api.getRDVEleve(_userTrackingId!);
      }

      setState(() {
        _rdvs = rdvs;
        _isLoading = false;
      });
      _animController.forward();
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.textDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _selectTime();
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submitRdv() async {
    if (!_formKey.currentState!.validate()) return;
    if (_userTrackingId == null) return;
    if (widget.conseillerId == null) return;
    if (_selectedDate == null || _selectedTime == null) return;

    setState(() => _isSubmitting = true);

    try {
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final request = RendezVousRequest(
        eleveTrackingId: _userTrackingId!,
        conseillerTrackingId: widget.conseillerId!,
        dateHeurePrevue: dateTime,
        notes: _commentaireController.text.isNotEmpty
            ? _commentaireController.text
            : null,
      );

      await _api.planifierRDV(request);

      _cancelForm();
      await _loadRdvs();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rendez-vous planifié avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
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

  Future<void> _cancelRdv(String trackingId) async {
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

  void _showCancelConfirm(RendezVousResponse rdv) {
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
              _cancelRdv(rdv.trackingId);
            },
            child:
                const Text('Annuler', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _cancelForm() {
    _formKey.currentState?.reset();
    _objetController.clear();
    _commentaireController.clear();
    setState(() {
      _isCreatingMode = false;
      _selectedDate = null;
      _selectedTime = null;
    });
  }

  Color _getStatusColor(String statut) {
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

  IconData _getStatusIcon(String statut) {
    switch (statut.toLowerCase()) {
      case 'planifie':
        return Icons.event_available_rounded;
      case 'termine':
        return Icons.check_circle_rounded;
      case 'annule':
        return Icons.cancel_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                    widget.conseillerNom != null
                        ? 'RDV avec ${widget.conseillerNom}'
                        : 'Mes rendez-vous',
                    style: AppTextStyles.headingMedium.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (!_isCreatingMode)
                    GestureDetector(
                      onTap: () {
                        setState(() => _isCreatingMode = true);
                        _animController.forward();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.add_rounded,
                                color: AppColors.primary, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Nouveau',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
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

            // Content
            Expanded(
              child: _isLoading
                  ? const SkeletonListPage()
                  : _isCreatingMode
                      ? _buildCreateForm()
                      : _buildRdvsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateForm() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.event_rounded,
                          color: AppColors.accent,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nouveau rendez-vous',
                              style: AppTextStyles.headingMedium.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Avec ${widget.conseillerNom ?? "un conseiller"}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Date picker
                const Text('Date', style: AppTextStyles.label),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedDate != null
                            ? AppColors.primary
                            : AppColors.cardBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: _selectedDate != null
                              ? AppColors.primary
                              : AppColors.textLight,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDate != null
                              ? DateFormat('EEEE dd MMMM yyyy', 'fr_FR')
                                  .format(_selectedDate!)
                              : 'Sélectionner une date',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: _selectedDate != null
                                ? AppColors.textDark
                                : AppColors.textLight,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            color: AppColors.textLight, size: 14),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Time picker
                const Text('Heure', style: AppTextStyles.label),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _selectTime,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedTime != null
                            ? AppColors.primary
                            : AppColors.cardBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: _selectedTime != null
                              ? AppColors.primary
                              : AppColors.textLight,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _selectedTime != null
                              ? _selectedTime!.format(context)
                              : 'Sélectionner une heure',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: _selectedTime != null
                                ? AppColors.textDark
                                : AppColors.textLight,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            color: AppColors.textLight, size: 14),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Objet
                const Text('Objet du rendez-vous', style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _objetController,
                  decoration: const InputDecoration(
                    hintText: 'Ex: Choix d\'orientation, Bilan scolaire...',
                    prefixIcon:
                        Icon(Icons.title_rounded, color: AppColors.textLight),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 20),

                // Commentaire
                const Text('Commentaire (optionnel)',
                    style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _commentaireController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Précisez votre demande...',
                    prefixIcon:
                        Icon(Icons.note_rounded, color: AppColors.textLight),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 32),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _isSubmitting ? null : _cancelForm,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textMedium,
                            side: const BorderSide(color: AppColors.cardBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Annuler'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Confirmer',
                        onPressed: _isSubmitting ? null : _submitRdv,
                        isLoading: _isSubmitting,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRdvsList() {
    if (_rdvs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.event_busy_rounded,
                  size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucun rendez-vous',
              style: AppTextStyles.headingLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Planifiez un rendez-vous avec un conseiller',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (widget.conseillerId == null)
              PrimaryButton(
                label: 'Voir les conseillers',
                onPressed: () => _showConseillersDialog(),
              ),
          ],
        ),
      );
    }

    // Grouper par statut
    final upcoming =
        _rdvs.where((r) => r.statut.toLowerCase() == 'planifie').toList();
    final past =
        _rdvs.where((r) => r.statut.toLowerCase() != 'planifie').toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (upcoming.isNotEmpty) ...[
          Text(
            'À venir',
            style: AppTextStyles.headingMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...upcoming.map((rdv) => _buildRdvCard(rdv)),
          const SizedBox(height: 24),
        ],
        if (past.isNotEmpty) ...[
          Text(
            'Passés',
            style: AppTextStyles.headingMedium.copyWith(
              color: AppColors.textMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...past.map((rdv) => _buildRdvCard(rdv)),
        ],
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildRdvCard(RendezVousResponse rdv) {
    final statusColor = _getStatusColor(rdv.statut);
    final statusIcon = _getStatusIcon(rdv.statut);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rdv.statut.toLowerCase() == 'planifie'
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.cardBorder,
          width: rdv.statut.toLowerCase() == 'planifie' ? 2 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rdv.notes ?? 'Rendez-vous',
                      style: AppTextStyles.label.copyWith(fontSize: 15),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  rdv.statut,
                  style: AppTextStyles.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (rdv.notes != null && rdv.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.note_alt_rounded,
                      color: AppColors.textMedium, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rdv.notes!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (rdv.statut.toLowerCase() == 'planifie') ...[
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
                        if (uri != null && await canLaunchUrl(uri)) {
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
                              'Lien visio',
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
                    onTap: () => _showCancelConfirm(rdv),
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

  Future<void> _showConseillersDialog() async {
    final conseillers = await _api.getConseillers();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sélectionner un conseiller'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: conseillers.length,
            itemBuilder: (context, index) {
              final conseiller = conseillers[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text('${conseiller.prenom} ${conseiller.nom}'),
                onTap: () {
                  Navigator.pop(ctx); // Close the dialog
                  // Replace the current route with a new RdvScreen for the selected conseiller
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RdvScreen(
                        conseillerId: conseiller.trackingId,
                        conseillerNom: '${conseiller.prenom} ${conseiller.nom}',
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
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
