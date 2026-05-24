import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../widgets/skeleton_widget.dart';
import 'package:intl/intl.dart';

class EnfantSuiviScreen extends StatefulWidget {
  final String enfantTrackingId;
  const EnfantSuiviScreen({super.key, required this.enfantTrackingId});

  @override
  State<EnfantSuiviScreen> createState() => _EnfantSuiviScreenState();
}

class _EnfantSuiviScreenState extends State<EnfantSuiviScreen> {
  final _api = ApiService();
  bool _isLoading = true;
  EleveResponse? _eleve;
  List<NoteResponse> _notes = [];
  List<ResultatDiagnosticResponse> _resultats = [];
  List<RendezVousResponse> _rdvs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final eleve = await _api.getEleve(widget.enfantTrackingId);
      final notes = await _api.academic.getNotesEleve(widget.enfantTrackingId);
      final resultats = await _api.diagnostic.getHistoriqueResultats(widget.enfantTrackingId);
      final rdvs = await _api.interaction.getRDVEleve(widget.enfantTrackingId);
      if (mounted) {
        setState(() {
          _eleve = eleve;
          _notes = notes;
          _resultats = resultats;
          _rdvs = rdvs;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double get _moyenne {
    if (_notes.isEmpty) return 0;
    double total = 0;
    int coeffSum = 0;
    for (final n in _notes) {
      final c = n.coefficient ?? 1;
      total += n.note * c;
      coeffSum += c;
    }
    return coeffSum > 0 ? total / coeffSum : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text(_eleve != null ? '${_eleve!.prenom} ${_eleve!.nom}' : 'Suivi enfant'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoading
          ? const SkeletonDashboard()
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileCard(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Notes', Icons.grading_rounded),
                    const SizedBox(height: 10),
                    _buildNotesSection(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Quiz & Diagnostics', Icons.quiz_rounded),
                    const SizedBox(height: 10),
                    _buildDiagnosticsSection(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Rendez-vous', Icons.calendar_month_rounded),
                    const SizedBox(height: 10),
                    _buildRdvsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileCard() {
    final e = _eleve;
    if (e == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28, backgroundColor: AppColors.primary,
            child: Icon(Icons.person_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${e.prenom} ${e.nom}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 4),
                if (e.niveauEtude != null || e.etablissementActuel != null)
                  Text(
                    '${e.niveauEtude ?? ''}${e.niveauEtude != null && e.etablissementActuel != null ? ' — ' : ''}${e.etablissementActuel ?? ''}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textMedium),
                  ),
                if (e.typeApprenant.isNotEmpty)
                  Text(e.typeApprenant, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.headingMedium),
      ],
    );
  }

  Widget _buildNotesSection() {
    if (_notes.isEmpty) {
      return _buildEmptyCard('Aucune note enregistrée');
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Moyenne : ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              Text(_moyenne.toStringAsFixed(2), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
              const Spacer(),
              Text('${_notes.length} matière(s)', style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
            ],
          ),
          const Divider(height: 24),
          ..._notes.take(5).map((n) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(child: Text(n.matiere, style: const TextStyle(fontSize: 14, color: AppColors.textDark))),
                Text(n.note.toStringAsFixed(1), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _noteColor(n.note))),
                if (n.coefficient != null && n.coefficient! > 1)
                  Text(' (×${n.coefficient})', style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Color _noteColor(double note) {
    if (note >= 16) return const Color(0xFF10B981);
    if (note >= 12) return AppColors.primary;
    if (note >= 10) return AppColors.accent;
    return const Color(0xFFEF4444);
  }

  Widget _buildDiagnosticsSection() {
    if (_resultats.isEmpty) {
      return _buildEmptyCard('Aucun diagnostic passé');
    }
    return Column(
      children: _resultats.take(3).map((r) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.assessment_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (r.profilDecouvert != null)
                    Text('Profil : ${r.profilDecouvert}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  if (r.scoreFinal != null)
                    Text('Score : ${r.scoreFinal!.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
                  if (r.datePassage != null)
                    Text(DateFormat('dd/MM/yyyy').format(r.datePassage!), style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textLight, size: 20),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildRdvsSection() {
    final futurs = _rdvs.where((r) => r.dateHeurePrevue != null && r.dateHeurePrevue!.isAfter(DateTime.now())).toList();
    if (futurs.isEmpty) {
      return _buildEmptyCard('Aucun rendez-vous à venir');
    }
    return Column(
      children: futurs.take(3).map((r) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.event_rounded, color: AppColors.accent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (r.dateHeurePrevue != null)
                    Text(DateFormat('EEEE dd/MM/yyyy', 'fr_FR').format(r.dateHeurePrevue!), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  if (r.dateHeurePrevue != null)
                    Text('À ${DateFormat('HH:mm').format(r.dateHeurePrevue!)}', style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
                  if (r.lienVisio != null)
                    Text('Visio', style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _statutColor(r.statut).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(_statutLabel(r.statut), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statutColor(r.statut))),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Color _statutColor(String statut) {
    switch (statut) {
      case 'PLANIFIE': return AppColors.primary;
      case 'TERMINE': return const Color(0xFF10B981);
      case 'ANNULE': return const Color(0xFFEF4444);
      default: return AppColors.textLight;
    }
  }

  String _statutLabel(String statut) {
    switch (statut) {
      case 'PLANIFIE': return 'Planifié';
      case 'TERMINE': return 'Terminé';
      case 'ANNULE': return 'Annulé';
      default: return statut;
    }
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 40, color: AppColors.textLight.withValues(alpha: 0.4)),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(fontSize: 14, color: AppColors.textLight)),
        ],
      ),
    );
  }
}
