import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final _sujetController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _tickets = [];

  @override
  void initState() {
    super.initState();
    _chargerTickets();
  }

  @override
  void dispose() {
    _sujetController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _chargerTickets() async {
    try {
      final res = await ApiService().dio.get('/api/v1/tickets/mes-tickets');
      setState(() => _tickets = List<Map<String, dynamic>>.from(res.data['content'] ?? []));
    } catch (_) {}
  }

  Future<void> _creerTicket() async {
    if (_sujetController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await ApiService().dio.post('/api/v1/tickets', data: {
        'sujet': _sujetController.text.trim(),
        'categorie': 'GENERAL',
      });
      _sujetController.clear();
      _messageController.clear();
      await _chargerTickets();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ticket créé')));
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Color _couleurStatut(String statut) {
    switch (statut) {
      case 'OUVERT': return AppColors.warning;
      case 'ASSIGNE': return AppColors.primary;
      case 'EN_COURS': return AppColors.accent;
      case 'RESOLU': return AppColors.success;
      case 'FERME': return AppColors.textLight;
      default: return AppColors.textMedium;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mes tickets'), backgroundColor: AppColors.background),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _sujetController,
                  decoration: const InputDecoration(hintText: 'Sujet du ticket'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _messageController,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'Description'),
                ),
                const SizedBox(height: 12),
                PrimaryButton(label: 'Créer un ticket', isLoading: _isLoading, onPressed: _creerTicket),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _tickets.isEmpty
                ? const Center(child: Text('Aucun ticket'))
                : ListView.builder(
                    itemCount: _tickets.length,
                    itemBuilder: (_, i) {
                      final t = _tickets[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text(t['sujet'] ?? ''),
                          subtitle: Text(t['categorie'] ?? ''),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _couleurStatut(t['statut'] ?? '').withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(t['statut'] ?? '', style: TextStyle(
                              color: _couleurStatut(t['statut'] ?? ''),
                              fontSize: 12, fontWeight: FontWeight.w600,
                            )),
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
