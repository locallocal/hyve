import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/chat_repository.dart';
import 'package:stars/domain/repositories/message_repository.dart';

enum TokenUsageGranularity { day, hour }

@immutable
class TokenUsageBucket {
  const TokenUsageBucket({required this.start, required this.usage});

  final DateTime start;
  final ModelTokenUsage usage;
}

class ChatTokenUsageViewModel extends ChangeNotifier {
  ChatTokenUsageViewModel({
    required this.chatId,
    required MessageRepository messageRepository,
    required ChatRepository chatRepository,
    DateTime Function()? now,
  }) : _messageRepository = messageRepository,
       _now = now ?? DateTime.now {
    _messageSubscription = messageRepository.changes.listen(
      (_) => _scheduleLoad(),
    );
    _chatSubscription = chatRepository.changes.listen((_) => _scheduleLoad());
  }

  final String chatId;
  final MessageRepository _messageRepository;
  final DateTime Function() _now;
  late final StreamSubscription<void> _messageSubscription;
  late final StreamSubscription<List<Chat>> _chatSubscription;

  List<ModelTokenUsageRecord> _records = const [];
  List<TokenUsageBucket> _dailyBuckets = const [];
  ModelTokenUsage _totalUsage = ModelTokenUsage.empty;
  DateTime? _selectedDay;
  Object? _error;
  bool _isLoading = false;
  bool _loadScheduled = false;
  bool _disposed = false;
  int _loadGeneration = 0;

  List<TokenUsageBucket> get dailyBuckets => _dailyBuckets;
  List<TokenUsageBucket> get visibleBuckets =>
      _selectedDay == null ? _dailyBuckets : _hourlyBuckets(_selectedDay!);
  ModelTokenUsage get totalUsage => _totalUsage;
  ModelTokenUsage get visibleTotalUsage =>
      _selectedDay == null
          ? _totalUsage
          : ModelTokenUsage.sum(
            _hourlyBuckets(_selectedDay!).map((bucket) => bucket.usage),
          );
  DateTime? get selectedDay => _selectedDay;
  TokenUsageGranularity get granularity =>
      _selectedDay == null
          ? TokenUsageGranularity.day
          : TokenUsageGranularity.hour;
  Object? get error => _error;
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
      _records = List<ModelTokenUsageRecord>.unmodifiable(records);
      _dailyBuckets = List<TokenUsageBucket>.unmodifiable(
        _buildDailyBuckets(_records),
      );
      _totalUsage = ModelTokenUsage.sum(_records.map((record) => record.usage));
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

  void selectDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    if (_selectedDay == normalized) return;
    _selectedDay = normalized;
    notifyListeners();
  }

  void showDaily() {
    if (_selectedDay == null) return;
    _selectedDay = null;
    notifyListeners();
  }

  void _scheduleLoad() {
    if (_disposed || _loadScheduled) return;
    _loadScheduled = true;
    scheduleMicrotask(() {
      _loadScheduled = false;
      if (!_disposed) unawaited(load());
    });
  }

  List<TokenUsageBucket> _buildDailyBuckets(
    List<ModelTokenUsageRecord> records,
  ) {
    final usageByDay = <DateTime, ModelTokenUsage>{};
    for (final record in records) {
      if (!record.usage.hasData) continue;
      final timestamp = record.timestamp;
      final day = DateTime(timestamp.year, timestamp.month, timestamp.day);
      usageByDay[day] =
          (usageByDay[day] ?? ModelTokenUsage.empty) + record.usage;
    }
    if (usageByDay.isEmpty) return const [];

    final days = usageByDay.keys.toList()..sort();
    final buckets = <TokenUsageBucket>[];
    var cursor = days.first;
    final last = days.last;
    while (!cursor.isAfter(last)) {
      buckets.add(
        TokenUsageBucket(
          start: cursor,
          usage: usageByDay[cursor] ?? ModelTokenUsage.empty,
        ),
      );
      cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
    }
    return buckets;
  }

  List<TokenUsageBucket> _hourlyBuckets(DateTime day) {
    final now = _now();
    final selectedDate = DateTime(day.year, day.month, day.day);
    final today = DateTime(now.year, now.month, now.day);
    final bucketCount =
        selectedDate.isBefore(today)
            ? 24
            : selectedDate == today
            ? now.hour + 1
            : 0;
    final usageByHour = <int, ModelTokenUsage>{};
    for (final record in _records) {
      final timestamp = record.timestamp;
      if (timestamp.year != day.year ||
          timestamp.month != day.month ||
          timestamp.day != day.day ||
          !record.usage.hasData) {
        continue;
      }
      usageByHour[timestamp.hour] =
          (usageByHour[timestamp.hour] ?? ModelTokenUsage.empty) + record.usage;
    }
    return List<TokenUsageBucket>.generate(bucketCount, (hour) {
      return TokenUsageBucket(
        start: DateTime(day.year, day.month, day.day, hour),
        usage: usageByHour[hour] ?? ModelTokenUsage.empty,
      );
    }, growable: false);
  }

  @override
  void dispose() {
    _disposed = true;
    _messageSubscription.cancel();
    _chatSubscription.cancel();
    super.dispose();
  }
}
