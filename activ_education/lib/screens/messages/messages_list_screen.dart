import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_routes.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../widgets/skeleton_widget.dart';

class MessagesListScreen extends StatefulWidget {
  const MessagesListScreen({super.key});

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  final _api = ApiService();

  List<MessageResponse> _messages = [];
  Map<String, String> _expediteursNoms = {};
  int _unreadCount = 0;
  bool _isLoading = true;
  String? _userTrackingId;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      setState(() => _isLoading = true);
      _userTrackingId = await _api.getTrackingId();
      _userRole = await _api.getUserRole();
      if (_userTrackingId == null) return;

      final result = await _api.getMessagesRecus(_userTrackingId!, size: 50);
      final messages = result.content;

      // Charger les noms des expéditeurs
      final noms = <String, String>{};
      final uniqueExpediteurs = messages.map((m) => m.expediteurTrackingId).toSet();

      for (final expediteurId in uniqueExpediteurs) {
        final info = await _api.getUtilisateurNom(expediteurId);
        noms[expediteurId] = '${info['prenom']} ${info['nom']}';
      }

      // Compter les non-lus
      final nonLus = await _api.getMessagesNonLus(_userTrackingId!);

      setState(() {
        _messages = messages;
        _expediteursNoms = noms;
        _unreadCount = nonLus;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${_api.handleError(e as dynamic)}')),
        );
      }
    }
  }

  void _markAsRead(String expediteurId) async {
    try {
      await _api.marquerConversationLue(expediteurId, _userTrackingId!);
      _loadMessages();
    } catch (e) {
      debugPrint('Erreur mark as read: $e');
    }
  }

  List<MapEntry<String, List<MessageResponse>>> _groupByExpediteur() {
    final Map<String, List<MessageResponse>> grouped = {};
    for (final msg in _messages) {
      grouped.putIfAbsent(msg.expediteurTrackingId, () => []);
      grouped[msg.expediteurTrackingId]!.add(msg);
    }
    // Trier par date décroissante
    for (final key in grouped.keys) {
      grouped[key]!.sort((a, b) {
        final dateA = a.dateEnvoi ?? DateTime(1970);
        final dateB = b.dateEnvoi ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });
    }
    return grouped.entries.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewMessageSheet(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
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
                    'Messages',
                    style: AppTextStyles.headingMedium.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (_unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_unreadCount nouveau',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Message list
            Expanded(
              child: _isLoading
                  ? const SkeletonListPage()
                  : _messages.isEmpty
                      ? _buildEmptyState()
                      : _buildMessageList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucun message',
              style: AppTextStyles.headingMedium.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Envoyez votre premier message\nà un conseiller',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showNewMessageSheet(context),
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Nouveau message'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return RefreshIndicator(
      onRefresh: _loadMessages,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          // We need to show grouped conversations, not each message.
          // Let's compute grouped list inside.
          final grouped = _groupByExpediteur();
          if (index >= grouped.length) return const SizedBox.shrink();
          final entry = grouped[index];
          final expediteurId = entry.key;
          final messages = entry.value;
          final latestMessage = messages.first;
          final isUnread = !(latestMessage.lu);

          return Dismissible(
            key: ValueKey(latestMessage.trackingId),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: AppColors.error,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) async {
              await _deleteMessage(latestMessage.trackingId);
            },
            child: GestureDetector(
              onTap: () {
                _markAsRead(expediteurId);
                Navigator.pushNamed(context, AppRoutes.chat, arguments: {
                  'expediteurId': expediteurId,
                  'expediteurNom': _expediteursNoms[expediteurId] ?? 'Contact',
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isUnread ? AppColors.primary : AppColors.cardBorder,
                    width: isUnread ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _expediteursNoms[expediteurId]?.substring(0, 1).toUpperCase() ?? 'C',
                          style: AppTextStyles.headingMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _expediteursNoms[expediteurId] ?? 'Conseiller',
                                  style: AppTextStyles.label.copyWith(
                                    fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isUnread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            latestMessage.contenu,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isUnread ? AppColors.textDark : AppColors.textMedium,
                              fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (latestMessage.dateEnvoi != null)
                      Text(
                        _formatDate(latestMessage.dateEnvoi!),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  Future<void> _deleteMessage(String trackingId) async {
    try {
      await _api.supprimerMessage(trackingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message supprimé')),
        );
      }
      _loadMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }
  void _navigateToChat(String contactId, String contactName) {
    Navigator.pushNamed(context, AppRoutes.chat, arguments: {
      'expediteurId': contactId,
      'expediteurNom': contactName,
    });
  }

  void _showNewMessageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _NewMessageSheet(
        api: _api,
        userRole: _userRole,
        onSelectContact: (id, name) {
          Navigator.pop(sheetContext);
          _navigateToChat(id, name);
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inHours < 1) return 'Il y a ${diff.inMinutes}m';
    if (diff.inDays < 1) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';

    return '${date.day}/${date.month}';
  }
}

class _NewMessageSheet extends StatefulWidget {
  final ApiService api;
  final String? userRole;
  final void Function(String contactId, String contactName) onSelectContact;

  const _NewMessageSheet({
    required this.api,
    this.userRole,
    required this.onSelectContact,
  });

  @override
  State<_NewMessageSheet> createState() => _NewMessageSheetState();
}

class _NewMessageSheetState extends State<_NewMessageSheet> {
  final _searchController = TextEditingController();
  List<ConseillerResponse> _conseillers = [];
  bool _loadingConseillers = true;
  String _manualId = '';

  @override
  void initState() {
    super.initState();
    _loadConseillers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConseillers() async {
    try {
      final conseillers = await widget.api.getConseillers(size: 200);
      setState(() {
        _conseillers = conseillers.where((c) => c.actif).toList();
        _loadingConseillers = false;
      });
    } catch (e) {
      setState(() => _loadingConseillers = false);
    }
  }

  List<ConseillerResponse> get _filteredConseillers {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _conseillers;
    return _conseillers.where((c) {
      final fullName = '${c.prenom} ${c.nom}'.toLowerCase();
      return fullName.contains(query) || c.trackingId.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  const Text(
                    'Nouveau message',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGrey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Rechercher un conseiller...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: AppColors.backgroundGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Manual ID entry
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Ou entrer un ID manuellement...',
                        isDense: true,
                        filled: true,
                        fillColor: AppColors.backgroundGrey,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      style: const TextStyle(fontSize: 13),
                      onChanged: (v) => setState(() => _manualId = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _manualId.trim().length > 5
                        ? () => widget.onSelectContact(
                              _manualId.trim(),
                              _manualId.trim().substring(0, 8),
                            )
                        : null,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _manualId.trim().length > 5
                            ? AppColors.primary
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Conseillers disponibles',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Divider(color: Colors.grey.shade200)),
                ],
              ),
            ),
            // List of conseillers
            Expanded(
              child: _loadingConseillers
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredConseillers.isEmpty
                      ? Center(
                          child: Text(
                            'Aucun conseiller trouvé',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          itemCount: _filteredConseillers.length,
                          itemBuilder: (context, index) {
                            final c = _filteredConseillers[index];
                            return GestureDetector(
                              onTap: () => widget.onSelectContact(
                                c.trackingId,
                                '${c.prenom} ${c.nom}',
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundGrey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${c.prenom[0]}${c.nom[0]}',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${c.prenom} ${c.nom}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          if (c.specialites != null)
                                            Text(
                                              c.specialites!,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
