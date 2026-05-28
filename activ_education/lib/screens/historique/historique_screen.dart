import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class HistoriqueScreen extends StatefulWidget {
  const HistoriqueScreen({super.key});

  @override
  State<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen> {
  final _api = ApiService();
  List<HistoriqueResponse> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tid = await _api.getTrackingId();
    if (tid == null) return;
    try {
      final items = await _api.interaction.getHistorique(tid);
      if (mounted) setState(() { _items = items; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _actionLabel(String action) {
    switch (action) {
      case 'CONNEXION': return 'Connexion';
      case 'TEST_RIASEC': return 'Test RIASEC';
      case 'UPLOAD_DOCUMENT': return 'Upload de document';
      case 'SAISIE_NOTE': return 'Saisie de note';
      case 'RDV_PRIS': return 'Rendez-vous pris';
      case 'RDV_ANNULE': return 'Rendez-vous annulé';
      case 'MESSAGE_ENVOYE': return 'Message envoyé';
      case 'MESSAGE_RECU': return 'Message reçu';
      case 'INSCRIPTION': return 'Inscription';
      case 'MODIFICATION_PROFIL': return 'Modification profil';
      default: return action;
    }
  }

  IconData _actionIcon(String action) {
    switch (action) {
      case 'CONNEXION': return Icons.login_rounded;
      case 'TEST_RIASEC': return Icons.quiz_rounded;
      case 'UPLOAD_DOCUMENT': return Icons.upload_file_rounded;
      case 'SAISIE_NOTE': return Icons.grade_rounded;
      case 'RDV_PRIS': return Icons.event_rounded;
      case 'RDV_ANNULE': return Icons.event_busy_rounded;
      case 'MESSAGE_ENVOYE': return Icons.send_rounded;
      case 'MESSAGE_RECU': return Icons.mail_rounded;
      case 'INSCRIPTION': return Icons.person_add_rounded;
      case 'MODIFICATION_PROFIL': return Icons.edit_rounded;
      default: return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text('Journal d\'activité'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(
                  child: Text('Aucune activité', style: TextStyle(color: AppColors.textLight)))
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Icon(_actionIcon(item.action), color: AppColors.primary, size: 20),
                        ),
                        title: Text(_actionLabel(item.action), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: item.details != null && item.details!.isNotEmpty
                            ? Text(item.details!, style: const TextStyle(fontSize: 12, color: AppColors.textLight))
                            : null,
                        trailing: item.createdAt != null
                            ? Text(
                                '${item.createdAt!.day}/${item.createdAt!.month}/${item.createdAt!.year}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textLight))
                            : null,
                      );
                    },
                  ),
                ),
    );
  }
}
