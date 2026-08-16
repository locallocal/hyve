import 'dart:async';

import 'package:hyve/data/models/skill_records.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/bot_skill_binding_repository.dart';

final class SqliteBotSkillBindingRepository
    implements BotScopedSkillBindingMetricsRepository {
  SqliteBotSkillBindingRepository({required LocalDatabaseService localDatabase})
    : _localDatabase = localDatabase;

  final LocalDatabaseService _localDatabase;
  final StreamController<void> _changes = StreamController<void>.broadcast();
  final StreamController<Set<String>> _botMetricChanges =
      StreamController<Set<String>>.broadcast();

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Stream<Set<String>> get botMetricChanges => _botMetricChanges.stream;

  @override
  Future<List<BotSkillBinding>> getForBot(String botId) async {
    final records = await _localDatabase.loadBotSkillBindings(botId);
    return List<BotSkillBinding>.unmodifiable(
      records.map((record) => BotSkillBindingRecord(record).toDomain()),
    );
  }

  @override
  Future<void> save(BotSkillBinding binding) async {
    await _localDatabase.upsertBotSkillBinding(
      BotSkillBindingRecord.fromDomain(binding).values,
    );
    _changes.add(null);
    _botMetricChanges.add({binding.botId});
  }

  @override
  Future<void> remove(String botId, String skillId) async {
    await _localDatabase.deleteBotSkillBinding(botId, skillId);
    _changes.add(null);
    _botMetricChanges.add({botId});
  }

  @override
  Future<Map<String, int>> getBindingCountsForBots(
    Iterable<String> botIds,
  ) async {
    final ids = botIds.toSet();
    final records = await _localDatabase.loadBotSkillBindingCounts(ids);
    return Map<String, int>.unmodifiable({
      for (final id in ids) id: 0,
      for (final record in records)
        record['bot_id']?.toString() ?? '': _readCount(record['binding_count']),
    });
  }

  Future<void> dispose() async {
    await _changes.close();
    await _botMetricChanges.close();
  }
}

int _readCount(Object? value) => switch (value) {
  final int count => count,
  final num count => count.toInt(),
  _ => int.tryParse(value?.toString() ?? '') ?? 0,
};
