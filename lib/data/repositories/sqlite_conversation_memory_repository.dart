import 'dart:async';
import 'dart:convert';

import 'package:stars/data/services/conversation_summary_storage.dart';
import 'package:stars/data/services/local_database_service.dart';
import 'package:stars/domain/models/conversation_memory.dart';
import 'package:stars/domain/repositories/conversation_memory_repository.dart';

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
    final rows = await _localDatabase.loadConversationMemoryState(chatId);
    if (rows.isEmpty) {
      return ConversationMemoryState(chatId: chatId, updatedAt: DateTime.now());
    }
    return _stateFromRow(rows.first);
  }

  @override
  Future<ConversationSummaryDocument?> getActiveSummary(String chatId) async {
    final rows = await _localDatabase.loadActiveConversationSummary(chatId);
    if (rows.isEmpty) return null;
    final metadata = _summaryFromRow(rows.first);
    try {
      final markdown = await _storage.read(metadata);
      return ConversationSummaryDocument(
        metadata: metadata,
        markdown: markdown,
      );
    } on ConversationSummaryStorageException catch (error) {
      await _localDatabase.invalidateConversationSummary(
        chatId,
        metadata.id,
        error.message,
      );
      _emit(chatId);
      return null;
    }
  }

  @override
  Future<List<ConversationMemoryItem>> getItems(String chatId) async {
    final rows = await _localDatabase.loadConversationMemoryItems(chatId);
    return List.unmodifiable(rows.map(_itemFromRow));
  }

  @override
  Future<bool> commitCompaction({
    required String chatId,
    required int expectedRevision,
    required ConversationSummaryDocument summary,
    required List<ConversationMemoryItem> items,
  }) async {
    if (summary.metadata.chatId != chatId ||
        summary.metadata.baseRevision != expectedRevision) {
      throw ArgumentError('Summary metadata does not match the CAS request.');
    }
    final stored = await _storage.write(
      chatId: chatId,
      summaryId: summary.metadata.id,
      markdown: summary.markdown,
    );
    final metadata = summary.metadata.copyWith(
      contentDigest: stored.contentDigest,
      contentBytes: stored.contentBytes,
    );
    try {
      final committed = await _localDatabase.commitConversationCompaction(
        chatId: chatId,
        expectedRevision: expectedRevision,
        summary: _summaryToRow(metadata),
        items: items.map(_itemToRow),
      );
      if (!committed) {
        await _storage.deleteSummary(chatId, summary.metadata.id);
        return false;
      }
      _emit(chatId);
      return true;
    } catch (_) {
      await _storage.deleteSummary(chatId, summary.metadata.id);
      rethrow;
    }
  }

  @override
  Future<void> saveUserItem(ConversationMemoryItem item) async {
    await _localDatabase.upsertConversationMemoryItem(
      _itemToRow(
        item.copyWith(
          origin: ConversationMemoryOrigin.user,
          updatedAt: DateTime.now(),
        ),
      ),
    );
    _emit(item.chatId);
  }

  @override
  Future<void> forgetItem(String chatId, String itemId) async {
    await _localDatabase.updateConversationMemoryItemState(
      chatId,
      itemId,
      ConversationMemoryItemState.forgotten.name,
    );
    _emit(chatId);
  }

  @override
  Future<void> restoreItem(String chatId, String itemId) async {
    await _localDatabase.updateConversationMemoryItemState(
      chatId,
      itemId,
      ConversationMemoryItemState.active.name,
    );
    _emit(chatId);
  }

  @override
  Future<void> setAutoMemoryEnabled(String chatId, bool enabled) async {
    await _localDatabase.setConversationAutoMemoryEnabled(chatId, enabled);
    _emit(chatId);
  }

  @override
  Future<void> setCompactionStatus(
    String chatId,
    ConversationCompactionStatus status, {
    String lastError = '',
  }) async {
    await _localDatabase.setConversationCompactionStatus(
      chatId,
      status.name,
      lastError,
    );
    _emit(chatId);
  }

  @override
  Future<void> clearAutomaticMemory(String chatId) async {
    await _storage.clearSummaries(chatId);
    await _localDatabase.clearAutomaticConversationMemory(chatId);
    _emit(chatId);
  }

  @override
  Future<void> clearForChat(String chatId) async {
    await _storage.clearSummaries(chatId);
    await _localDatabase.deleteConversationMemory(chatId);
    _emit(chatId);
  }

  @override
  Future<void> deleteForChat(String chatId) async {
    await _storage.deleteChatDirectory(chatId);
    await _localDatabase.deleteConversationMemory(chatId);
    _emit(chatId);
  }

  void _emit(String chatId) {
    if (!_changes.isClosed) _changes.add(chatId);
  }
}

ConversationMemoryState _stateFromRow(Map<String, Object?> row) {
  final lastCompactedAt = _nullableInt(row['last_compacted_at']);
  return ConversationMemoryState(
    chatId: row['chat_id']?.toString() ?? '',
    revision: _int(row['revision']),
    activeSummaryId: row['active_summary_id']?.toString() ?? '',
    coveredThroughMessageId:
        row['covered_through_message_id']?.toString() ?? '',
    autoMemoryEnabled: _int(row['auto_memory_enabled']) != 0,
    compactionStatus: _enumByName(
      ConversationCompactionStatus.values,
      row['compaction_status']?.toString(),
      ConversationCompactionStatus.idle,
    ),
    lastError: row['last_error']?.toString() ?? '',
    lastCompactedAt:
        lastCompactedAt == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(lastCompactedAt),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(_int(row['updated_at'])),
  );
}

ConversationSummaryMetadata _summaryFromRow(Map<String, Object?> row) {
  return ConversationSummaryMetadata(
    id: row['id']?.toString() ?? '',
    chatId: row['chat_id']?.toString() ?? '',
    status: _enumByName(
      ConversationSummaryStatus.values,
      row['status']?.toString(),
      ConversationSummaryStatus.invalid,
    ),
    fileName: row['file_name']?.toString() ?? '',
    markdownSchemaVersion: _int(row['markdown_schema_version']),
    contentDigest: row['content_digest']?.toString() ?? '',
    contentBytes: _int(row['content_bytes']),
    sourceStartMessageId: row['source_start_message_id']?.toString() ?? '',
    sourceEndMessageId: row['source_end_message_id']?.toString() ?? '',
    sourceMessageIds: _stringList(row['source_message_ids']),
    sourceDigest: row['source_digest']?.toString() ?? '',
    estimatedTokenCount: _int(row['estimated_token_count']),
    provider: row['provider']?.toString() ?? '',
    model: row['model']?.toString() ?? '',
    promptVersion: _int(row['prompt_version']),
    baseRevision: _int(row['base_revision']),
    createdAt: DateTime.fromMillisecondsSinceEpoch(_int(row['created_at'])),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(_int(row['updated_at'])),
  );
}

Map<String, Object?> _summaryToRow(ConversationSummaryMetadata metadata) => {
  'id': metadata.id,
  'chat_id': metadata.chatId,
  'status': metadata.status.name,
  'file_name': metadata.fileName,
  'markdown_schema_version': metadata.markdownSchemaVersion,
  'content_digest': metadata.contentDigest,
  'content_bytes': metadata.contentBytes,
  'source_start_message_id': metadata.sourceStartMessageId,
  'source_end_message_id': metadata.sourceEndMessageId,
  'source_message_ids': jsonEncode(metadata.sourceMessageIds),
  'source_digest': metadata.sourceDigest,
  'estimated_token_count': metadata.estimatedTokenCount,
  'provider': metadata.provider,
  'model': metadata.model,
  'prompt_version': metadata.promptVersion,
  'base_revision': metadata.baseRevision,
  'created_at': metadata.createdAt.millisecondsSinceEpoch,
  'updated_at': metadata.updatedAt.millisecondsSinceEpoch,
};

ConversationMemoryItem _itemFromRow(Map<String, Object?> row) {
  final expiresAt = _nullableInt(row['expires_at']);
  return ConversationMemoryItem(
    id: row['id']?.toString() ?? '',
    chatId: row['chat_id']?.toString() ?? '',
    memoryKey: row['memory_key']?.toString() ?? '',
    kind: _enumByName(
      ConversationMemoryKind.values,
      row['kind']?.toString(),
      ConversationMemoryKind.fact,
    ),
    content: row['content']?.toString() ?? '',
    state: _enumByName(
      ConversationMemoryItemState.values,
      row['state']?.toString(),
      ConversationMemoryItemState.active,
    ),
    origin: _enumByName(
      ConversationMemoryOrigin.values,
      row['origin']?.toString(),
      ConversationMemoryOrigin.auto,
    ),
    importance: _double(row['importance']),
    confidence: _double(row['confidence']),
    sourceMessageIds: _stringList(row['source_message_ids']),
    sourceDigest: row['source_digest']?.toString() ?? '',
    expiresAt:
        expiresAt == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(expiresAt),
    createdAt: DateTime.fromMillisecondsSinceEpoch(_int(row['created_at'])),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(_int(row['updated_at'])),
  );
}

Map<String, Object?> _itemToRow(ConversationMemoryItem item) => {
  'id': item.id,
  'chat_id': item.chatId,
  'memory_key': item.memoryKey,
  'kind': item.kind.name,
  'content': item.content,
  'state': item.state.name,
  'origin': item.origin.name,
  'importance': item.importance,
  'confidence': item.confidence,
  'source_message_ids': jsonEncode(item.sourceMessageIds),
  'source_digest': item.sourceDigest,
  'expires_at': item.expiresAt?.millisecondsSinceEpoch,
  'created_at': item.createdAt.millisecondsSinceEpoch,
  'updated_at': item.updatedAt.millisecondsSinceEpoch,
};

int _int(Object? value) => switch (value) {
  final int number => number,
  final num number => number.toInt(),
  _ => int.tryParse(value?.toString() ?? '') ?? 0,
};

int? _nullableInt(Object? value) => value == null ? null : _int(value);

double _double(Object? value) => switch (value) {
  final num number => number.toDouble(),
  _ => double.tryParse(value?.toString() ?? '') ?? 0.5,
};

List<String> _stringList(Object? value) {
  try {
    final decoded = jsonDecode(value?.toString() ?? '[]');
    return decoded is List
        ? decoded.map((item) => item.toString()).toList(growable: false)
        : const [];
  } on FormatException {
    return const [];
  }
}

T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}
