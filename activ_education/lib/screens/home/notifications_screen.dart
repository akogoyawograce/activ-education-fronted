// lib/screens/home/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../widgets/skeleton_widget.dart';
import '../errors/empty_content_screen.dart';

class _NotifStyle {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  const _NotifStyle(this.icon, this.bgColor, this.iconColor);
}

const Map<String, _NotifStyle> _notifStyles = {
  'MESSAGE': _NotifStyle(Icons.chat_bubble_outline, Color(0xFFEEF2FF), AppColors.primary),
  'DIAGNOSTIC': _NotifStyle(Icons.track_changes, Color(0xFFFFF8EC), AppColors.accent),
  'RDV': _NotifStyle(Icons.calendar_today, Color(0xFFECFDF5), AppColors.success),
  'RECOMMANDATION': _NotifStyle(Icons.star_outline, Color(0xFFFFFBEB), Colors.amber),
};

const _defaultStyle = _NotifStyle(Icons.notifications_outlined, Color(0xFFF3F4F6), AppColors.textLight);

_NotifStyle _styleForTitre(String titre) {
  final upper = titre.toUpperCase();
  if (upper.contains('MESSAGE')) return _notifStyles['MESSAGE']!;
  if (upper.contains('DIAGNOSTIC') || upper.contains('QUIZ')) return _notifStyles['DIAGNOSTIC']!;
  if (upper.contains('RDV') || upper.contains('RENDEZ')) return _notifStyles['RDV']!;
  if (upper.contains('RECOMMAND')) return _notifStyles['RECOMMANDATION']!;
  return _defaultStyle;
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _api = ApiService();

  List<NotificationResponse> _notifications = [];
  int _unreadCount = 0;
  String? _userTrackingId;
  bool _isLoading = true;
  bool _isMarkingAllRead = false;
  int _selectedTab = 0;

  static const _tabs = ['Toutes', 'Non lues', 'Messages'];

  List<NotificationResponse> get _filteredNotifications {
    switch (_selectedTab) {
      case 1:
        return _notifications.where((n) => !n.lue).toList();
      case 2:
        return _notifications.where((n) => n.titre.toUpperCase().contains('MESSAGE')).toList();
      default:
        return _notifications;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() => _isLoading = true);
      _userTrackingId = await _api.getTrackingId();
      if (_userTrackingId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final notifications = await _api.getNotifications(_userTrackingId!);
      final nonLues = await _api.getNotificationsNonLues(_userTrackingId!);

      setState(() {
        _notifications = notifications;
        _unreadCount = nonLues.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${_api.handleError(e)}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _markAsRead(NotificationResponse notif) async {
    if (notif.lue) return;
    try {
      await _api.marquerNotificationLue(notif.trackingId);
      await _loadNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${_api.handleError(e)}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    if (_userTrackingId == null) return;
    setState(() => _isMarkingAllRead = true);
    try {
      await _api.marquerToutesLues(_userTrackingId!);
      await _loadNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${_api.handleError(e)}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isMarkingAllRead = false);
    }
  }

  Future<void> _deleteNotification(NotificationResponse notif) async {
    try {
      await _api.dio.delete('/api/v1/notifications/${notif.trackingId}');
      setState(() => _notifications.removeWhere((n) => n.trackingId == notif.trackingId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification supprimée'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${_api.handleError(e)}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inHours < 1) return 'Il y a ${diff.inMinutes}m';
    if (diff.inDays < 1) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return DateFormat('dd MMMM yyyy', 'fr_FR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabPills(),
            Expanded(
              child: _isLoading
                  ? const SkeletonListPage()
                  : _notifications.isEmpty
                      ? _buildEmptyState()
                      : _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Notifications',
              style: AppTextStyles.headingMedium.copyWith(fontSize: 18),
            ),
          ),
          if (_unreadCount > 0 && !_isMarkingAllRead)
            GestureDetector(
              onTap: _markAllAsRead,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Tout lire',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          else if (_isMarkingAllRead)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
            ),
        ],
      ),
    );
  }

  Widget _buildTabPills() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final isSelected = _selectedTab == i;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.cardBorder,
                  ),
                ),
                child: Text(
                  _tabs[i],
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.textMedium,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_selectedTab == 1) {
      return const EmptyContentScreen(
        icon: Icons.done_all_rounded,
        title: 'Aucune notification non lue',
        subtitle: 'Vous avez lu toutes vos notifications',
      );
    }
    if (_selectedTab == 2) {
      return const EmptyContentScreen(
        icon: Icons.chat_bubble_outline,
        title: 'Aucun message',
        subtitle: "Vous n'avez pas encore reçu de messages",
      );
    }
    return const EmptyContentScreen(
      icon: Icons.notifications_none_rounded,
      title: 'Aucune notification',
      subtitle: 'Vous serez notifié des nouveaux messages et rendez-vous',
    );
  }

  Widget _buildList() {
    final filtered = _filteredNotifications;
    if (filtered.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: filtered.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildOptimizeCard();
        final notif = filtered[index - 1];
        final style = _styleForTitre(notif.titre);
        return _buildNotificationItem(notif, style);
      },
    );
  }

  Widget _buildOptimizeCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1300C8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              Icons.settings_rounded,
              size: 80,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Optimisez vos alertes',
                style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Personnalisez vos préférences de notification pour ne rien manquer',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  minimumSize: const Size(140, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Configurer',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationResponse notif, _NotifStyle style) {
    final isUnread = !notif.lue;
    return Dismissible(
      key: ValueKey(notif.trackingId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      onDismissed: (_) => _deleteNotification(notif),
      child: GestureDetector(
        onTap: () => _markAsRead(notif),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnread ? AppColors.primary.withValues(alpha: 0.3) : AppColors.cardBorder,
              width: isUnread ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: style.bgColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(style.icon, color: style.iconColor, size: 22),
                  ),
                  if (isUnread)
                    Positioned(
                      top: -2,
                      left: -2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.titre,
                            style: AppTextStyles.label.copyWith(
                              fontSize: 15,
                              fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                              color: isUnread ? AppColors.textDark : AppColors.textMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.message,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isUnread ? AppColors.textDark : AppColors.textMedium,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (notif.createdAt != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _formatDate(notif.createdAt!),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
