import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class ChatScreen extends StatefulWidget {
  final String expediteurId;
  final String expediteurNom;

  const ChatScreen({
    super.key,
    required this.expediteurId,
    required this.expediteurNom,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final _api = ApiService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  WebSocketChannel? _wsChannel;
  Timer? _pollingTimer;

  List<MessageResponse> _messages = [];
  String? _userTrackingId;
  String? _accessToken;
  bool _isLoading = true;
  bool _isSending = false;
  bool _isForeground = true;
  bool _useWebSocket = true;

  static final _uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  bool get _expediteurIdInvalide =>
      !_uuidRegex.hasMatch(widget.expediteurId);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_expediteurIdInvalide) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Contact invalide : "${widget.expediteurId}" n\'est pas un identifiant valide',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      });
      return;
    }
    _init();
  }

  Future<void> _init() async {
    _userTrackingId = await _api.getTrackingId();
    _accessToken = await _api.getAccessToken();
    if (_userTrackingId == null) return;
    await _loadMessages(showLoading: true);
    _connectWebSocket();
  }

  void _connectWebSocket() {
    if (_accessToken == null || _userTrackingId == null) {
      _useWebSocket = false;
      _startPolling();
      return;
    }
    try {
      final baseUrl = const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:8080',
      );
      final wsUrl = baseUrl
          .replaceFirst('https://', 'wss://')
          .replaceFirst('http://', 'ws://');
      _wsChannel = WebSocketChannel.connect(
        Uri.parse('$wsUrl/ws/chat?token=$_accessToken'),
      );
      _wsChannel!.stream.listen(
        (data) {
          try {
            final json = jsonDecode(data as String) as Map<String, dynamic>;
            if (json['type'] == 'delivered') return;
            final msg = MessageResponse(
              trackingId: json['messageId'] ?? '',
              contenu: json['contenu'] ?? '',
              expediteurTrackingId: json['expediteurTrackingId'] ?? '',
              destinataireTrackingId: json['destinataireTrackingId'] ?? '',
              dateEnvoi: DateTime.now(),
              lu: json['lu'] ?? false,
            );
            if (msg.expediteurTrackingId == widget.expediteurId ||
                msg.expediteurTrackingId == _userTrackingId) {
              setState(() => _messages.add(msg));
              _scrollToBottom();
            }
          } catch (_) {}
        },
        onError: (_) {
          _useWebSocket = false;
          _startPolling();
        },
        onDone: () {
          if (_useWebSocket) {
            Future.delayed(const Duration(seconds: 3), _connectWebSocket);
          }
        },
      );
    } catch (_) {
      _useWebSocket = false;
      _startPolling();
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted && !_isSending && _isForeground) {
        _loadMessages(showLoading: false);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isForeground = state == AppLifecycleState.resumed;
    if (_isForeground) {
      if (!_useWebSocket) _startPolling();
      _loadMessages(showLoading: false);
    } else {
      _pollingTimer?.cancel();
      _pollingTimer = null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    _pollingTimer?.cancel();
    _wsChannel?.sink.close();
    super.dispose();
  }

  Future<void> _loadMessages({bool showLoading = true}) async {
    if (_expediteurIdInvalide) return;
    try {
      if (showLoading) setState(() => _isLoading = true);
      _userTrackingId = await _api.getTrackingId();
      if (_userTrackingId == null) return;

      final messages = await _api.getConversation(
        widget.expediteurId,
        _userTrackingId!,
      );

      final newLastId = messages.isNotEmpty ? messages.last.trackingId : null;
      if (!showLoading && _messages.isNotEmpty &&
          newLastId == _messages.last.trackingId &&
          messages.length == _messages.length) return;

      setState(() {
        _messages = messages;
        if (showLoading) _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final contenu = _messageController.text.trim();
    if (contenu.isEmpty || _userTrackingId == null) return;
    if (_expediteurIdInvalide) return;

    setState(() => _isSending = true);

    try {
      final request = MessageRequest(
        contenu: contenu,
        destinataireTrackingId: widget.expediteurId,
      );
      await _api.envoyerMessage(_userTrackingId!, request);
      _messageController.clear();

      if (_useWebSocket && _wsChannel != null) {
        _wsChannel!.sink.add(jsonEncode({
          'messageId': '${DateTime.now().millisecondsSinceEpoch}',
          'expediteurTrackingId': _userTrackingId,
          'destinataireTrackingId': widget.expediteurId,
          'contenu': contenu,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }));
      }
      await _loadMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              bottom: 8,
              left: 16,
              right: 16,
            ),
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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      widget.expediteurNom.substring(0, 1).toUpperCase(),
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.expediteurNom,
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _useWebSocket ? 'En ligne' : 'Polling 15s',
                        style: AppTextStyles.caption.copyWith(
                          color: _useWebSocket
                              ? AppColors.success
                              : AppColors.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? _buildEmptyState()
                    : _buildMessagesList(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: 24),
          Text(
            'Commencez la conversation',
            style: AppTextStyles.headingMedium.copyWith(
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Envoyez un message à ${widget.expediteurNom}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isMe = message.expediteurTrackingId == _userTrackingId;

        return Padding(
          padding: EdgeInsets.only(
            bottom: 12,
            left: isMe ? 50 : 0,
            right: isMe ? 0 : 50,
          ),
          child: Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      widget.expediteurNom.substring(0, 1).toUpperCase(),
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.contenu,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isMe ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      if (message.dateEnvoi != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(message.dateEnvoi!),
                          style: AppTextStyles.caption.copyWith(
                            color: isMe
                                ? Colors.white.withValues(alpha: 0.7)
                                : AppColors.textLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (isMe) const SizedBox(width: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textDark,
                ),
                decoration: const InputDecoration(
                  hintText: 'Écrivez votre message...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.textLight),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _isSending ? null : _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
