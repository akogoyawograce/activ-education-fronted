import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../widgets/skeleton_widget.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _api = ApiService();
  List<MessageResponse> _recentMessages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentMessages();
  }

  Future<void> _loadRecentMessages() async {
    try {
      final trackingId = await _api.getTrackingId();
      if (trackingId == null) return;
      final page = await _api.getMessagesRecus(trackingId, page: 0, size: 3);
      if (mounted) setState(() { _recentMessages = page.content; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Support', style: AppTextStyles.headingMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildActionCard(
            icon: Icons.help_outline_rounded,
            title: 'Foire Aux Questions',
            subtitle: 'Consultez les questions fréquentes',
            color: AppColors.primary,
            onTap: () => Navigator.pushNamed(context, AppRoutes.faq),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            icon: Icons.support_agent_rounded,
            title: 'Contacter un conseiller',
            subtitle: 'Envoyez un message à notre équipe',
            color: AppColors.accent,
            onTap: () => Navigator.pushNamed(context, AppRoutes.messages),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            icon: Icons.calendar_month_rounded,
            title: 'Prendre rendez-vous',
            subtitle: 'Planifiez un entretien personnalisé',
            color: AppColors.success,
            onTap: () => Navigator.pushNamed(context, AppRoutes.conseillers),
          ),
          const SizedBox(height: 24),
          _buildRecentSection(),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark,
                    )),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 12, color: AppColors.textMedium,
                    )),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mes derniers messages', style: TextStyle(
          fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark,
        )),
        const SizedBox(height: 12),
        if (_isLoading)
          const SkeletonCard()
        else if (_recentMessages.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.chat_bubble_outline_rounded, size: 40, color: AppColors.textLight),
                SizedBox(height: 12),
                Text("Aucun message pour l'instant", style: TextStyle(
                  fontFamily: 'Inter', fontSize: 14, color: AppColors.textMedium,
                )),
              ],
            ),
          )
        else
          ...List.generate(_recentMessages.length.clamp(0, 3), (i) {
            final msg = _recentMessages[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.messages),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Conseiller', style: const TextStyle(
                                fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark,
                              )),
                              const SizedBox(height: 2),
                              Text(msg.contenu, style: const TextStyle(
                                fontFamily: 'Inter', fontSize: 12, color: AppColors.textMedium,
                              ), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        if (!msg.lu) Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.accent, shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
