import 'dart:async';

import 'package:stars/data/models/skill_records.dart';
import 'package:stars/data/services/local_database_service.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/conversation_skill_pin_repository.dart';

final class SqliteConversationSkillPinRepository
    implements ConversationSkillPinRepository {
  SqliteConversationSkillPinRepository({
    required LocalDatabaseService localDatabase,
  }) : _localDatabase = localDatabase;

  final LocalDatabaseService _localDatabase;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<List<ConversationSkillPin>> getForChat(String chatId) async {
    final records = await _localDatabase.loadConversationSkillPins(chatId);
    return List<ConversationSkillPin>.unmodifiable(
      records.map((record) => ConversationSkillPinRecord(record).toDomain()),
    );
  }

  @override
  Future<void> save(ConversationSkillPin pin) async {
    await _localDatabase.upsertConversationSkillPin(
      ConversationSkillPinRecord.fromDomain(pin).values,
    );
    _changes.add(null);
  }

  @override
  Future<void> remove(String chatId, String skillId) async {
    await _localDatabase.deleteConversationSkillPin(chatId, skillId);
    _changes.add(null);
  }

  @override
  Future<void> clear(String chatId) async {
    await _localDatabase.clearConversationSkillPins(chatId);
    _changes.add(null);
  }

  Future<void> dispose() => _changes.close();
}
