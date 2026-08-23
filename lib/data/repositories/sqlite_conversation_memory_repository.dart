import 'dart:async';

import 'package:hyve/data/services/conversation_summary_storage.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/domain/models/conversation_memory.dart';
import 'package:hyve/domain/repositories/conversation_memory_repository.dart';

final class SqliteConversationMemoryRepository
    implements ConversationMemoryRepository {
  SqliteConversationMemoryRepository({
    required LocalDatabaseService localDatabase,
    required ConversationSummaryStorage storage,
  }) : _localDatabase = localDatabase,
       _storage = storage;

  final LocalDatabaseService _localDatabase;
  final ConversationSummaryStorage _storage;
  final StreamController<String> _changes = StreamController.broadcast();

  @override
  Stream<String> get changes => _changes.stream;

  @override
  Future<ConversationMemoryState> getState(String chatId) async {
    final rows = await _localDatabase.loadConversationSummaryStateV19(chatId);
    if (rows.isEmpty) {
      return ConversationMemoryState(
        chatId: chatId,
        autoMemoryEnabled: false,
        updatedAt: DateTime.now(),
      );
    }
    final row = rows.single;
    final lastCompactedAt = _nullableInt(row['last_compacted_at']);
    return ConversationMemoryState(
      chatId: chatId,
      revision: _int(row['revision']),
      activeSummaryId: _text(
        row['active_summary_set_id'],
        'active_summary_set_id',
      ),
      coveredThroughMessageId:
          _int(row['covered_through_message_sequence']).toString(),
      autoMemoryEnabled: false,
      compactionStatus: _enumByName(
        ConversationCompactionStatus.values,
        _text(row['compaction_status'], 'compaction_status'),
        'compaction_status',
      ),
      lastError: _text(row['last_error'], 'last_error'),
      lastCompactedAt:
          lastCompactedAt == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(lastCompactedAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(_int(row['updated_at'])),
    );
  }

  @override
  Future<ConversationSummaryDocument?> getActiveSummary(String chatId) async {
    // Project summaries are read through ConversationSummaryRepository. This
    // compatibility adapter deliberately exposes no Project Memory body.
    return null;
  }

  @override
  Future<List<ConversationMemoryItem>> getItems(String chatId) async {
    return const <ConversationMemoryItem>[];
  }

  @override
  Future<bool> commitCompaction({
    required String chatId,
    required int expectedRevision,
    required ConversationSummaryDocument summary,
    required List<ConversationMemoryItem> items,
  }) async {
    // Legacy chat compaction cannot write the Project summary schema because
    // it has no stable messageSequence. The Project use case owns this path.
    return false;
  }

  @override
  Future<void> saveUserItem(ConversationMemoryItem item) async {
    throw UnsupportedError(
      'Project Memory items do not exist. Save AgentMemory or an Artifact.',
    );
  }

  @override
  Future<void> forgetItem(String chatId, String itemId) async {
    throw UnsupportedError(
      'Project Memory items do not exist. Forget through AgentMemory.',
    );
  }

  @override
  Future<void> restoreItem(String chatId, String itemId) async {
    throw UnsupportedError('Project Memory items cannot be restored.');
  }

  @override
  Future<void> setAutoMemoryEnabled(String chatId, bool enabled) async {
    _emit(chatId);
  }

  @override
  Future<void> setCompactionStatus(
    String chatId,
    ConversationCompactionStatus status, {
    String lastError = '',
  }) async {
    await _localDatabase.setConversationSummaryCompactionStatusV19(
      chatId,
      status.name,
      lastError,
    );
    _emit(chatId);
  }

  @override
  Future<void> clearAutomaticMemory(String chatId) async {
    await _storage.clearSummaries(chatId);
    await _localDatabase.deleteConversationSummariesV19(chatId);
    _emit(chatId);
  }

  @override
  Future<void> deleteForChat(String chatId) async {
    await _storage.deleteChatDirectory(chatId);
    await _localDatabase.deleteConversationSummariesV19(chatId);
    _emit(chatId);
  }

  void _emit(String chatId) {
    if (!_changes.isClosed) _changes.add(chatId);
  }
}

int _int(Object? value) => switch (value) {
  final int number => number,
  _ => throw const FormatException('Memory record integer is invalid.'),
};

int? _nullableInt(Object? value) => value == null ? null : _int(value);

T _enumByName<T extends Enum>(List<T> values, String name, String field) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  throw FormatException('Memory record field "$field" has an unknown value.');
}

String _text(Object? value, String field) {
  if (value is String) return value;
  throw FormatException('Memory record field "$field" must be a string.');
}
