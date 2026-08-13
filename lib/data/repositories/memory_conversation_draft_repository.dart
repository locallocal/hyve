import 'dart:collection';
import 'dart:io';

import 'package:stars/domain/models/conversation_draft.dart';
import 'package:stars/domain/repositories/conversation_draft_repository.dart';

typedef DraftPathValidator = Future<bool> Function(String path);

/// Process-local drafts with LRU eviction and stale attachment filtering.
final class MemoryConversationDraftRepository
    implements ConversationDraftRepository {
  MemoryConversationDraftRepository({
    this.capacity = 20,
    DraftPathValidator? pathValidator,
  }) : assert(capacity > 0),
       _pathValidator = pathValidator ?? _fileExists;

  final int capacity;
  final DraftPathValidator _pathValidator;
  final LinkedHashMap<String, ConversationDraft> _drafts = LinkedHashMap();

  @override
  Future<ConversationDraft?> read(String chatId) async {
    final stored = _drafts.remove(chatId);
    if (stored == null) return null;
    final validImages = await _validPaths(stored.imagePaths);
    final validFiles = await _validPaths(stored.filePaths);
    final validated = ConversationDraft(
      text: stored.text,
      imagePaths: validImages,
      filePaths: validFiles,
    );
    if (!validated.isEmpty) _drafts[chatId] = validated;
    return validated.isEmpty ? null : validated;
  }

  @override
  Future<void> write(String chatId, ConversationDraft draft) async {
    _drafts.remove(chatId);
    if (draft.isEmpty) return;
    _drafts[chatId] = ConversationDraft(
      text: draft.text,
      imagePaths: List<String>.unmodifiable(draft.imagePaths),
      filePaths: List<String>.unmodifiable(draft.filePaths),
    );
    while (_drafts.length > capacity) {
      _drafts.remove(_drafts.keys.first);
    }
  }

  @override
  Future<void> delete(String chatId) async {
    _drafts.remove(chatId);
  }

  Future<List<String>> _validPaths(List<String> paths) async {
    final valid = <String>[];
    for (final path in paths) {
      if (await _pathValidator(path)) valid.add(path);
    }
    return List<String>.unmodifiable(valid);
  }

  static Future<bool> _fileExists(String path) => File(path).exists();
}
