import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/chat_repository.dart';
import 'package:stars/domain/repositories/message_repository.dart';

@immutable
class BotConversationTokenUsage {
  const BotConversationTokenUsage({
    required this.chatId,
    required this.preview,
    required this.usage,
  });

  final String chatId;
  final String preview;
  final ModelTokenUsage usage;
}

class BotTokenUsageViewModel extends ChangeNotifier {
  BotTokenUsageViewModel({
    required this.botId,
    required MessageRepository messageRepository,
    required ChatRepository chatRepository,
  }) : _messageRepository = messageRepository,
       _chatRepository = chatRepository {
    _messageSubscription = messageRepository.changes.listen(
      (_) => _scheduleLoad(),
    );
    _chatSubscription = chatRepository.changes.listen((_) => _scheduleLoad());
  }

  final String botId;
  final MessageRepository _messageRepository;
  final ChatRepository _chatRepository;
  late final StreamSubscription<void> _messageSubscription;
  late final StreamSubscription<List<Chat>> _chatSubscription;

  ModelTokenUsage _usage = ModelTokenUsage.empty;
  List<BotConversationTokenUsage> _conversationUsages = const [];
  Object? _error;
  bool _isLoading = false;
  bool _loadScheduled = false;
  bool _disposed = false;
  int _loadGeneration = 0;

  ModelTokenUsage get usage => _usage;
  List<BotConversationTokenUsage> get conversationUsages => _conversationUsages;
  Object? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    final generation = ++_loadGeneration;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final (usage, usageByChat, chats) =
          await (
            _messageRepository.getTokenUsageForBot(botId),
            _messageRepository.getTokenUsageByChatForBot(botId),
            _chatRepository.getChats(),
          ).wait;
      if (_disposed || generation != _loadGeneration) return;

      final chatsById = {for (final chat in chats) chat.id: chat};
      final entries =
          usageByChat.entries.where((entry) => entry.value.hasData).toList()
            ..sort((left, right) {
              final usageOrder = right.value.effectiveTotalTokens.compareTo(
                left.value.effectiveTotalTokens,
              );
              return usageOrder != 0
                  ? usageOrder
                  : left.key.compareTo(right.key);
            });
      _usage = usage;
      _conversationUsages = List<BotConversationTokenUsage>.unmodifiable(
        entries.map((entry) {
          return BotConversationTokenUsage(
            chatId: entry.key,
            preview: chatsById[entry.key]?.lastMessage.trim() ?? '',
            usage: entry.value,
          );
        }),
      );
    } catch (error) {
      if (_disposed || generation != _loadGeneration) return;
      _error = error;
    } finally {
      if (!_disposed && generation == _loadGeneration) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void _scheduleLoad() {
    if (_disposed || _loadScheduled) return;
    _loadScheduled = true;
    scheduleMicrotask(() {
      _loadScheduled = false;
      if (!_disposed) unawaited(load());
    });
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_messageSubscription.cancel());
    unawaited(_chatSubscription.cancel());
    super.dispose();
  }
}
