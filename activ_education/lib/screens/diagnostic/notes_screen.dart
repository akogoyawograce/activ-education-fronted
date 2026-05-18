// lib/screens/diagnostic/notes_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen>
    with SingleTickerProviderStateMixin {
  final _api = ApiService();
  final _formKey = GlobalKey<FormState>();

  final _matiereController = TextEditingController();
  final _noteController = TextEditingController();
  final _coefController = TextEditingController();
  final _trimestreController = TextEditingController();

  List<NoteResponse> _notes = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _eleveId;

  bool _isAddingMode = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadNotes();
  }

  void _initAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(_fadeAnim);
  }

  @override
  void dispose() {
    _matiereController.dispose();
    _noteController.dispose();
    _coefController.dispose();
    _trimestreController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    try {
      setState(() => _isLoading = true);
      final trackingId = await _api.getTrackingId();
      if (trackingId == null) {
        setState(() {
          _isLoading = false;
          _eleveId = null;
        });
        return;
      }
      _eleveId = trackingId;
      final notes = await _api.getNotesEleve(trackingId);
      setState(() {
        _notes = notes;
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

  double? get _moyenneGenerale {
    if (_notes.isEmpty) return null;
    double totalNotes = 0;
    double totalCoefs = 0;
    for (final note in _notes) {
      final coef = note.coefficient ?? 1;
      totalNotes += note.note * coef;
      totalCoefs += coef;
    }
    return totalCoefs > 0 ? totalNotes / totalCoefs : null;
  }

  void _openAddForm() {
    setState(() => _isAddingMode = true);
    _animController.forward();
  }

  void _cancelAdd() {
    _formKey.currentState?.reset();
    _matiereController.clear();
    _noteController.clear();
    _coefController.clear();
    _trimestreController.clear();
    setState(() => _isAddingMode = false);
  }

  Future<void> _submitNote() async {
    if (!_formKey.currentState!.validate()) return;
    if (_eleveId == null) return;

    setState(() => _isSubmitting = true);

    try {
      final note = double.parse(_noteController.text);
      final coef = int.tryParse(_coefController.text) ?? 1;

      await _api.ajouterNote(
        _eleveId!,
        NoteRequest(
          matiere: _matiereController.text,
          note: note,
          coefficient: coef,
          semestreOuTrimestre:
              _trimestreController.text.isNotEmpty ? _trimestreController.text : null,
        ),
      );

      _cancelAdd();
      await _loadNotes();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note ajoutée avec succès'),
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

  Future<void> _deleteNote(String trackingId) async {
    try {
      await _api.supprimerNote(trackingId);
      await _loadNotes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note supprimée'),
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

  void _showDeleteConfirm(NoteResponse note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer cette note ?'),
        content: Text(
          '${note.matiere}: ${note.note}/${note.coefficient ?? 1}',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler', style: TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteNote(note.trackingId);
            },
            child: const Text('Supprimer', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text(_isAddingMode ? 'Ajouter une note' : 'Mes notes'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: _isAddingMode ? _cancelAdd : () => Navigator.pop(context),
        ),
        actions: [
          if (!_isAddingMode)
            IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: _openAddForm,
              color: AppColors.primary,
            ),
        ],
      ),
      body: _isAddingMode ? _buildAddForm() : _buildNotesList(),
    );
  }

  Widget _buildAddForm() {
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit_note_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nouvelle note',
                              style: AppTextStyles.headingMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Ajoutez une note manuellement',
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
                const Text('Matière', style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _matiereController,
                  decoration: const InputDecoration(
                    hintText: 'Ex: Mathématiques',
                    prefixIcon: Icon(Icons.book_rounded, color: AppColors.textLight),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Note /20', style: AppTextStyles.label),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _noteController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              hintText: '15.5',
                              prefixText: '',
                              prefixIcon: Icon(Icons.star_rounded, color: AppColors.accent),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Requis';
                              final note = double.tryParse(v);
                              if (note == null || note < 0 || note > 20) return '0-20';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Coefficient', style: AppTextStyles.label),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _coefController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '2',
                              prefixIcon: Icon(Icons.trending_up_rounded, color: AppColors.primary),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return null;
                              final coef = int.tryParse(v);
                              if (coef == null || coef < 1) return '≥1';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Trimestre (optionnel)', style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _trimestreController,
                  decoration: const InputDecoration(
                    hintText: 'T1, T2, T3 ou S1, S2',
                    prefixIcon: Icon(Icons.calendar_today_rounded, color: AppColors.textLight),
                  ),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Enregistrer la note',
                  onPressed: _isSubmitting ? null : _submitNote,
                  isLoading: _isSubmitting,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_eleveId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline_rounded, size: 80, color: AppColors.textLight),
            const SizedBox(height: 24),
            const Text(
              'Connectez-vous pour voir vos notes',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Se connecter',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
            ),
          ],
        ),
      );
    }

    if (_notes.isEmpty) {
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
              child: const Icon(Icons.edit_note_rounded, size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucune note saisie',
              style: AppTextStyles.headingLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Commencez par ajouter vos premières notes',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Ajouter une note',
              onPressed: _openAddForm,
              trailingIcon: Icons.add_rounded,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header avec moyenne
        if (_moyenneGenerale != null) ...[
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.analytics_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Moyenne générale',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMedium),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_moyenneGenerale!.toStringAsFixed(2)} / 20',
                        style: AppTextStyles.displayMedium.copyWith(
                          color: _moyenneGenerale! >= 10 ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _moyenneGenerale! >= 10
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _moyenneGenerale! >= 10 ? Icons.thumb_up_rounded : Icons.warning_rounded,
                    color: _moyenneGenerale! >= 10 ? AppColors.success : AppColors.error,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Liste des notes
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            itemCount: _notes.length,
            itemBuilder: (context, index) {
              final note = _notes[index];
              return _NoteCard(
                note: note,
                onDelete: () => _showDeleteConfirm(note),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  final NoteResponse note;
  final VoidCallback onDelete;

  const _NoteCard({required this.note, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final noteColor = note.note >= 10 ? AppColors.success : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: noteColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                note.note.toStringAsFixed(1),
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: noteColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.matiere,
                  style: AppTextStyles.label.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (note.coefficient != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundGrey,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Coef: ${note.coefficient}',
                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (note.semestreOuTrimestre != null)
                      Text(
                        note.semestreOuTrimestre!,
                        style: AppTextStyles.caption.copyWith(color: AppColors.textMedium),
                      ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textLight),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
