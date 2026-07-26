import 'dart:async';

import 'package:stars/data/models/skill_records.dart';
import 'package:stars/data/services/local_database_service.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/bot_skill_binding_repository.dart';

final class SqliteBotSkillBindingRepository
    implements BotSkillBindingRepository {
  SqliteBotSkillBindingRepository({required LocalDatabaseService localDatabase})
    : _localDatabase = localDatabase;

  final LocalDatabaseService _localDatabase;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  Stream<void> get changes => _changes.stream;

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
  }

  @override
  Future<void> remove(String botId, String skillId) async {
    await _localDatabase.deleteBotSkillBinding(botId, skillId);
    _changes.add(null);
  }

  Future<void> dispose() => _changes.close();
}
