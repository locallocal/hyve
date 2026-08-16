import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/chat_repository.dart';
import 'package:hyve/domain/repositories/message_repository.dart';
import 'package:hyve/ui/core/view_models/token_usage_timeline.dart';

export 'package:hyve/ui/core/view_models/token_usage_timeline.dart'
    show TokenUsageBucket, TokenUsageGranularity;

class ChatTokenUsageViewModel extends ChangeNotifier {
  ChatTokenUsageViewModel({
    required this.chatId,
    required MessageRepository messageRepository,
    required ChatRepository chatRepository,
    DateTime Function()? now,
  }) : _messageRepository = messageRepository,
       _timeline = TokenUsageTimelineState(now: now) {
    _messageSubscription = messageRepository.changes.listen(
      (_) => _scheduleLoad(),
    );
    _chatSubscription = chatRepository.changes.listen((_) => _scheduleLoad());
  }

  final String chatId;
  final MessageRepository _messageRepository;
  final TokenUsageTimelineState _timeline;
  late final StreamSubscription<void> _messageSubscription;
  late final StreamSubscription<List<Chat>> _chatSubscription;

  AppFailure? _error;
  bool _isLoading = false;
  bool _loadScheduled = false;
  bool _disposed = false;
  int _loadGeneration = 0;

  List<TokenUsageBucket> get dailyBuckets => _timeline.dailyBuckets;
  List<TokenUsageBucket> get visibleBuckets => _timeline.visibleBuckets;
  ModelTokenUsage get totalUsage => _timeline.totalUsage;
  ModelTokenUsage get visibleTotalUsage => _timeline.visibleTotalUsage;
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
      final records = await _messageRepository.getTokenUsageRecordsForChat(
        chatId,
      );
      if (_disposed || generation != _loadGeneration) return;
      _timeline.replaceRecords(records);
    } catch (error) {
      if (_disposed || generation != _loadGeneration) return;
      _error = AppFailure.from(error, code: 'chat_usage_load_failed');
    } finally {
      if (!_disposed && generation == _loadGeneration) {
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
    _messageSubscription.cancel();
    _chatSubscription.cancel();
    super.dispose();
  }
}
