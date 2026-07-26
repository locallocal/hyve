import 'package:flutter/foundation.dart';
import 'package:stars/domain/models/models.dart';

enum TokenUsageGranularity { day, hour }

@immutable
class TokenUsageBucket {
  const TokenUsageBucket({required this.start, required this.usage});

  final DateTime start;
  final ModelTokenUsage usage;
}

/// Shared daily/hourly projection for persisted token-usage records.
///
/// Feature view models own notification and loading concerns while this class
/// keeps the conversation and bot-detail timelines behaviorally identical.
class TokenUsageTimelineState {
  TokenUsageTimelineState({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  List<ModelTokenUsageRecord> _records = const [];
  List<TokenUsageBucket> _dailyBuckets = const [];
  ModelTokenUsage _totalUsage = ModelTokenUsage.empty;
  DateTime? _selectedDay;

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

  void replaceRecords(Iterable<ModelTokenUsageRecord> records) {
    _records = List<ModelTokenUsageRecord>.unmodifiable(records);
    _dailyBuckets = List<TokenUsageBucket>.unmodifiable(
      _buildDailyBuckets(_records),
    );
    _totalUsage = ModelTokenUsage.sum(_records.map((record) => record.usage));
    if (_selectedDay != null &&
        !_dailyBuckets.any((bucket) => bucket.start == _selectedDay)) {
      _selectedDay = null;
    }
  }

  bool selectDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    if (_selectedDay == normalized) return false;
    _selectedDay = normalized;
    return true;
  }

  bool showDaily() {
    if (_selectedDay == null) return false;
    _selectedDay = null;
    return true;
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
}
