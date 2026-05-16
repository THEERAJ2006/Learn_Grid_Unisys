// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../../ai/router/ai_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/entities.dart';
import '../../../data/providers/data_providers.dart';
import '../../../data/repositories/repository_interfaces.dart';

// ── Sentinel exception ───────────────────────────────────────────────────────

class ModelNotReadyException implements Exception {
  final String message;
  const ModelNotReadyException([this.message = 'Offline model not ready']);
  @override
  String toString() => message;
}

// ── Data models ──────────────────────────────────────────────────────────────

enum MessageRole { user, assistant }

enum MessageSource { offline, gemini, groq, huggingface, error }

class ChatMessage {
  final String id;
  final MessageRole role;
  final String text;
  final MessageSource source;
  final DateTime timestamp;
  final bool isStreaming;
  final bool isModelError;

  ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.source,
    required this.timestamp,
    this.isStreaming = false,
    this.isModelError = false,
  });

  ChatMessage copyWith({
    String? text,
    bool? isStreaming,
    MessageSource? source,
    bool? isModelError,
  }) =>
      ChatMessage(
        id: id,
        role: role,
        text: text ?? this.text,
        source: source ?? this.source,
        timestamp: timestamp,
        isStreaming: isStreaming ?? this.isStreaming,
        isModelError: isModelError ?? this.isModelError,
      );
}

// ── Session management ───────────────────────────────────────────────────────

/// Converts a flat list of chat messages to a JSON string for cache storage.
String _serializeMessages(List<ChatMessage> msgs) {
  return jsonEncode(msgs
      .map((m) => {
            'id': m.id,
            'role': m.role.name,
            'text': m.text,
            'source': m.source.name,
            'timestamp': m.timestamp.millisecondsSinceEpoch,
          })
      .toList());
}

List<ChatMessage> _deserializeMessages(String raw) {
  try {
    final list = jsonDecode(raw) as List;
    return list.map((e) {
      final map = e as Map<String, dynamic>;
      return ChatMessage(
        id: map['id'] as String,
        role: MessageRole.values.firstWhere(
          (r) => r.name == map['role'],
          orElse: () => MessageRole.assistant,
        ),
        text: map['text'] as String,
        source: MessageSource.values.firstWhere(
          (s) => s.name == map['source'],
          orElse: () => MessageSource.offline,
        ),
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          map['timestamp'] as int,
        ),
      );
    }).toList();
  } catch (_) {
    return [];
  }
}

// ── Providers ────────────────────────────────────────────────────────────────

/// Stable session ID for this app run — persisted to AIResponseCache with
/// cacheKey = sessionId.
final _sessionIdProvider = Provider<String>((ref) => const Uuid().v4());

class ChatNotifier extends Notifier<List<ChatMessage>> {
  static const _expiryMs = Duration(days: 30);

  @override
  List<ChatMessage> build() {
    // Load persisted messages on first build.
    _loadFromCache();
    return [];
  }

  AIRouter get _router => ref.read(aiRouterProvider);
  CacheRepository get _cacheRepo => ref.read(cacheRepositoryProvider);
  String get _sessionId => ref.read(_sessionIdProvider);

  Future<void> _loadFromCache() async {
    try {
      final entry = await _cacheRepo.get(_sessionId);
      if (entry == null) return;
      final msgs = _deserializeMessages(entry.responseJson);
      if (msgs.isNotEmpty) {
        state = msgs;
      }
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await _cacheRepo.set(AIResponseCacheEntity(
        id: _sessionId,
        cacheKey: _sessionId,
        responseJson: _serializeMessages(state),
        source: 'session',
        model: null,
        createdAt: now,
        expiresAt: now + _expiryMs.inMilliseconds,
      ));
    } catch (_) {}
  }

  Future<void> sendMessage(String text) async {
    final userMsg = ChatMessage(
      id: 'u_${DateTime.now().microsecondsSinceEpoch}',
      role: MessageRole.user,
      text: text,
      source: MessageSource.offline,
      timestamp: DateTime.now(),
    );
    final thinkingId = 'a_${DateTime.now().microsecondsSinceEpoch}';
    final thinkingMsg = ChatMessage(
      id: thinkingId,
      role: MessageRole.assistant,
      text: '',
      source: MessageSource.offline,
      timestamp: DateTime.now(),
      isStreaming: true,
    );
    state = [...state, userMsg, thinkingMsg];
    await _persist();

    try {
      final response = await _router.getExplanation(text);

      // Detect source from response text prefix.
      MessageSource src;
      String cleaned = response;
      if (response.startsWith('Offline explanation')) {
        src = MessageSource.offline;
      } else if (response.contains('gemini') ||
          response.contains('Gemini')) {
        src = MessageSource.gemini;
      } else if (response.contains('groq') || response.contains('Groq')) {
        src = MessageSource.groq;
      } else if (response.contains('HuggingFace') ||
          response.contains('huggingface')) {
        src = MessageSource.huggingface;
      } else {
        // Generic cloud: try to infer from stored cache entry.
        final cacheEntry = await _cacheRepo.get(text);
        if (cacheEntry != null) {
          src = cacheEntry.source == 'offline'
              ? MessageSource.offline
              : MessageSource.gemini;
        } else {
          src = MessageSource.gemini;
        }
      }

      state = state.map((m) {
        if (m.id == thinkingId) {
          return m.copyWith(
            text: cleaned,
            source: src,
            isStreaming: false,
          );
        }
        return m;
      }).toList();
    } on ModelNotReadyException {
      state = state.map((m) {
        if (m.id == thinkingId) {
          return m.copyWith(
            text: 'MODEL_NOT_READY',
            source: MessageSource.error,
            isStreaming: false,
            isModelError: true,
          );
        }
        return m;
      }).toList();
    } catch (e) {
      state = state.map((m) {
        if (m.id == thinkingId) {
          return m.copyWith(
            text: 'Sorry, I could not generate a response.\n\n$e',
            source: MessageSource.error,
            isStreaming: false,
          );
        }
        return m;
      }).toList();
    }

    await _persist();
  }

  Future<void> clearChat() async {
    state = [];
    try {
      // Delete the session cache entry.
      await _cacheRepo.set(AIResponseCacheEntity(
        id: _sessionId,
        cacheKey: _sessionId,
        responseJson: '[]',
        source: 'session',
        model: null,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        expiresAt: DateTime.now().millisecondsSinceEpoch,
      ));
    } catch (_) {}
  }
}

final chatProvider =
    NotifierProvider<ChatNotifier, List<ChatMessage>>(ChatNotifier.new);

// ── Screen ───────────────────────────────────────────────────────────────────

class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _controller.clear();
    await ref.read(chatProvider.notifier).sendMessage(text);
    setState(() => _sending = false);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);

    // Auto-scroll whenever new messages arrive.
    ref.listen<List<ChatMessage>>(chatProvider, (prev, next) => _scrollToBottom());

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.accent, Color(0xFF6C63FF)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Tutor',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Offline-first · Cloud-enhanced',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: Colors.white54),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white70),
              onPressed: () => _showClearConfirm(context),
              tooltip: 'Clear chat',
            ),
        ],
      ),
      body: Column(
        children: [
          // Messages list.
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, i) =>
                        _MessageBubble(message: messages[i]),
                  ),
          ),

          // Input bar.
          _buildInputBar(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.accent, Color(0xFF6C63FF)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.auto_awesome,
                color: Colors.white, size: 40),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(
                  end: 1.08,
                  duration: 2.seconds,
                  curve: Curves.easeInOut),
          const SizedBox(height: 24),
          Text(
            'Ask me anything!',
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'I can explain concepts, answer questions,\nand adapt to your learning level.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 14, color: Colors.white54),
          ),
          const SizedBox(height: 32),
          _buildSuggestions(context),
        ],
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    final suggestions = [
      'Explain photosynthesis simply',
      'What is the Pythagorean theorem?',
      'How does the heart pump blood?',
      'Summarise World War 2',
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: suggestions
          .map(
            (s) => ActionChip(
              label:
                  Text(s, style: GoogleFonts.inter(fontSize: 12)),
              backgroundColor: AppTheme.surface,
              side: const BorderSide(
                  color: AppTheme.accent, width: 0.8),
              labelStyle:
                  const TextStyle(color: Colors.white70),
              onPressed: () {
                _controller.text = s;
                _send();
              },
            ),
          )
          .toList(),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(
            top: BorderSide(color: Color(0xFF253050), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(24),
                border:
                    Border.all(color: const Color(0xFF2E4070)),
              ),
              child: TextField(
                controller: _controller,
                style: GoogleFonts.inter(
                    color: Colors.white, fontSize: 14),
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Ask anything…',
                  hintStyle: GoogleFonts.inter(
                      color: Colors.white38, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _send(),
                textInputAction: TextInputAction.send,
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: _sending
                  ? const LinearGradient(colors: [
                      Color(0xFF2E4070),
                      Color(0xFF2E4070)
                    ])
                  : const LinearGradient(
                      colors: [AppTheme.accent, Color(0xFF6C63FF)]),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white))
                  : const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
              onPressed: _send,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Clear conversation?',
            style: TextStyle(color: Colors.white)),
        content: const Text('This cannot be undone.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent),
            onPressed: () {
              ref.read(chatProvider.notifier).clearChat();
              Navigator.pop(ctx);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    // Model-not-ready inline error card.
    if (message.isModelError) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _ModelNotReadyCard(),
      );
    }

    final isUser = message.role == MessageRole.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _Avatar(source: message.source),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onLongPress: () =>
                      Clipboard.setData(
                          ClipboardData(text: message.text)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isUser
                          ? const LinearGradient(
                              colors: [
                                AppTheme.primary,
                                AppTheme.accent
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isUser
                          ? null
                          : const Color(0xFF1E2E4A),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft:
                            Radius.circular(isUser ? 16 : 4),
                        bottomRight:
                            Radius.circular(isUser ? 4 : 16),
                      ),
                      border: isUser
                          ? null
                          : Border.all(
                              color: const Color(0xFF2A3F60),
                              width: 0.8),
                    ),
                    child: message.isStreaming
                        ? _ThinkingDots()
                        : SelectableText(
                            message.text,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 250.ms)
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: 4),
                if (!isUser && !message.isStreaming)
                  _SourceBadge(source: message.source),
                Text(
                  _formatTime(message.timestamp),
                  style: GoogleFonts.inter(
                      fontSize: 10, color: Colors.white30),
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

// ── Model-not-ready card ──────────────────────────────────────────────────────

class _ModelNotReadyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1515),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Colors.redAccent.withValues(alpha: 0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline,
                  color: Colors.redAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Offline Model Not Ready',
                style: GoogleFonts.nunito(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w700,
                    fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'The on-device AI model is not downloaded yet.',
            style: GoogleFonts.inter(
                color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            'To download:\n'
            '1. Go to Settings → AI Mode\n'
            '2. Tap "Download Offline Model"\n'
            '3. Wait for download to complete\n'
            '4. Return here and ask again.\n\n'
            'Alternatively, enable Cloud AI (Gemini/Groq) in Settings.',
            style: GoogleFonts.inter(
                color: Colors.white54, fontSize: 12, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.source});
  final MessageSource source;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppTheme.accent, Color(0xFF6C63FF)]),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.auto_awesome,
          color: Colors.white, size: 16),
    );
  }
}

// ── Source badge ──────────────────────────────────────────────────────────────

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source});
  final MessageSource source;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (source) {
      MessageSource.offline =>
        ('Offline', const Color(0xFF06A77D)),
      MessageSource.gemini =>
        ('Gemini', const Color(0xFF4285F4)),
      MessageSource.groq =>
        ('Groq', const Color(0xFFFF6B35)),
      MessageSource.huggingface =>
        ('HuggingFace', const Color(0xFFFFB800)),
      MessageSource.error =>
        ('Error', Colors.redAccent),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
              color: color.withValues(alpha: 0.4), width: 0.6),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ── Thinking dots ─────────────────────────────────────────────────────────────

class _ThinkingDots extends StatefulWidget {
  @override
  State<_ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<_ThinkingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, widget) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final offset =
                ((_ctrl.value * 3) - i).clamp(0.0, 1.0);
            final scale = 0.6 +
                0.4 *
                    (offset < 0.5
                        ? offset * 2
                        : (1 - offset) * 2);
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white70,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
