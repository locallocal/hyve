import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/skill_inventory_repository.dart';

final class SqliteSkillInventoryRepository implements SkillInventoryRepository {
  const SqliteSkillInventoryRepository({
    required LocalDatabaseService localDatabase,
  }) : _localDatabase = localDatabase;

  static const int maxInstalledLimit = 100;

  final LocalDatabaseService _localDatabase;

  @override
  Future<InstalledSkillInventoryPage> listInstalled({
    String query = '',
    int limit = 50,
  }) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.length > 128) {
      throw ArgumentError.value(
        query,
        'query',
        'Must not exceed 128 characters.',
      );
    }
    if (limit < 1 || limit > maxInstalledLimit) {
      throw ArgumentError.value(limit, 'limit', 'Must be between 1 and 100.');
    }
    final records = await _localDatabase.queryInstalledSkillInventory(
      query: normalized,
      limit: limit + 1,
    );
    final truncated = records.length > limit;
    final visible = truncated ? records.take(limit) : records;
    return InstalledSkillInventoryPage(
      items: List<InstalledSkillInventoryItem>.unmodifiable(
        visible.map(_installedFromRecord),
      ),
      truncated: truncated,
    );
  }

  @override
  Future<List<ConversationSkillInventoryItem>> listForConversation(
    String chatId,
    String botId,
  ) async {
    if (chatId.trim().isEmpty) {
      throw ArgumentError.value(chatId, 'chatId', 'Must not be empty.');
    }
    if (botId.trim().isEmpty) {
      throw ArgumentError.value(botId, 'botId', 'Must not be empty.');
    }
    final records = await _localDatabase.queryConversationSkillInventory(
      chatId,
      botId,
    );
    return List<ConversationSkillInventoryItem>.unmodifiable(
      records.map(_conversationFromRecord),
    );
  }

  InstalledSkillInventoryItem _installedFromRecord(
    Map<String, Object?> record,
  ) => InstalledSkillInventoryItem(
    id: _text(record['id']),
    name: _text(record['name']),
    description: _text(record['description']),
    version: _text(record['version']),
    scope: _text(record['scope']),
    trustState: _text(record['trust_state']),
    validationStatus: _text(record['validation_status']),
    signatureStatus: _text(record['signature_status']),
    boundBotCount: _integer(record['bound_bot_count']),
    enabledBotCount: _integer(record['enabled_bot_count']),
    installedAt: _date(record['installed_at'])!,
    updatedAt: _date(record['updated_at'])!,
  );

  ConversationSkillInventoryItem _conversationFromRecord(
    Map<String, Object?> record,
  ) => ConversationSkillInventoryItem(
    id: _text(record['id']),
    name: _text(record['name']),
    version: _text(record['version']),
    scope: _text(record['scope']),
    installed: _integer(record['installed']) == 1,
    bundled: _integer(record['bundled']) == 1,
    available: _integer(record['available']) == 1,
    configuredEnabled: _integer(record['configured_enabled']) == 1,
    pinnedToConversation: _integer(record['pinned_to_conversation']) == 1,
    activationMode: _text(record['activation_mode']),
    priority: _integer(record['priority']),
    lastActivationStatus: _text(record['last_activation_status']),
    lastActivatedAt: _date(record['last_activated_at']),
  );

  String _text(Object? value) => value?.toString() ?? '';

  int _integer(Object? value) => value is num ? value.toInt() : 0;

  DateTime? _date(Object? value) {
    if (value is! num) return null;
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
}
