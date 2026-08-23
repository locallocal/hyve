import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/chat_repository.dart';
import 'package:hyve/domain/repositories/message_repository.dart';
import 'package:hyve/ui/core/view_models/disposable_change_notifier.dart';
import 'package:hyve/ui/core/view_models/token_usage_timeline.dart';

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

class BotTokenUsageViewModel extends DisposableChangeNotifier {
  BotTokenUsageViewModel({
    required this.botId,
    required MessageRepository messageRepository,
    required ChatRepository chatRepository,
    DateTime Function()? now,
  }) : _messageRepository = messageRepository,
       _chatRepository = chatRepository,
       _timeline = TokenUsageTimelineState(now: now) {
    _messageSubscription = messageRepository.changes.listen(
      (_) => _scheduleLoad(),
    );
    _chatSubscription = chatRepository.changes.listen((_) => _scheduleLoad());
  }

  final String botId;
  final MessageRepository _messageRepository;
  final ChatRepository _chatRepository;
  final TokenUsageTimelineState _timeline;
  late final StreamSubscription<void> _messageSubscription;
  late final StreamSubscription<List<Chat>> _chatSubscription;

  ModelTokenUsage _usage = ModelTokenUsage.empty;
  List<BotConversationTokenUsage> _conversationUsages = const [];
  AppFailure? _error;
  bool _isLoading = false;
  bool _loadScheduled = false;
  int _loadGeneration = 0;

  ModelTokenUsage get usage => _usage;
  List<BotConversationTokenUsage> get conversationUsages => _conversationUsages;
  List<TokenUsageBucket> get dailyBuckets => _timeline.dailyBuckets;
  List<TokenUsageBucket> get visibleBuckets => _timeline.visibleBuckets;
  DateTime? get selectedDay => _timeline.selectedDay;
  TokenUsageGranularity get granularity => _timeline.granularity;
  AppFailure? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    final generation = ++_loadGeneration;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final (records, chats) =
          await (
            _messageRepository.getTokenUsageRecordsForBot(botId),
            _chatRepository.getChats(),
          ).wait;
      if (isDisposed || generation != _loadGeneration) return;

      _timeline.replaceRecords(records);
      final usageByChat = <String, ModelTokenUsage>{};
      for (final record in records) {
        if (!record.usage.hasData) continue;
        usageByChat[record.chatId] =
            (usageByChat[record.chatId] ?? ModelTokenUsage.empty) +
            record.usage;
      }
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
      _usage = _timeline.totalUsage;
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
      if (isDisposed || generation != _loadGeneration) return;
      _error = AppFailure.from(error, code: 'bot_usage_load_failed');
    } finally {
      if (!isDisposed && generation == _loadGeneration) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void selectDay(DateTime day) {
    if (_timeline.selectDay(day)) notifyListeners();
  }

  void showDaily() {
    if (_timeline.showDaily()) notifyListeners();
  }

  void _scheduleLoad() {
    if (isDisposed || _loadScheduled) return;
    _loadScheduled = true;
    scheduleMicrotask(() {
      _loadScheduled = false;
      if (!isDisposed) unawaited(load());
    });
  }

  @override
  void disposeResources() {
    unawaited(_messageSubscription.cancel());
    unawaited(_chatSubscription.cancel());
  }
}
