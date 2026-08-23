import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:hyve/data/services/conversation_summary_storage.dart';
import 'package:hyve/domain/models/conversation_memory.dart';

void main() {
  late Directory root;
  late ConversationSummaryStorage storage;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('hyve_summary_storage_');
    storage = ConversationSummaryStorage(
      documentsDirectoryProvider: () async => root,
    );
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('writes immutable UTF-8 Markdown under the chat directory', () async {
    final stored = await storage.write(
      chatId: 'chat_1',
      summaryId: 'summary_1',
      markdown: '# 项目摘要\r\n\r\n- 目标',
    );
    final metadata = _metadata(
      digest: stored.contentDigest,
      bytes: stored.contentBytes,
    );

    final markdown = await storage.read(metadata);

    expect(markdown, '# 项目摘要\n\n- 目标');
    expect(
      File(
        path.join(root.path, 'chats', 'chat_1', 'summaries', 'summary_1.md'),
      ).exists(),
      completion(isTrue),
    );
    expect(
      () => storage.write(
        chatId: 'chat_1',
        summaryId: 'summary_1',
        markdown: 'replacement',
      ),
      throwsA(isA<ConversationSummaryStorageException>()),
    );
  });

  test('rejects traversal IDs and digest mismatches', () async {
    expect(
      () => storage.write(
        chatId: '../other',
        summaryId: 'summary_1',
        markdown: 'text',
      ),
      throwsArgumentError,
    );
    final stored = await storage.write(
      chatId: 'chat_1',
      summaryId: 'summary_1',
      markdown: 'text',
    );
    await File(
      path.join(root.path, 'chats', 'chat_1', 'summaries', 'summary_1.md'),
    ).writeAsString('tampered');

    expect(
      () => storage.read(
        _metadata(digest: stored.contentDigest, bytes: stored.contentBytes),
      ),
      throwsA(isA<ConversationSummaryStorageException>()),
    );
  });

  test('stages chat deletion for rollback and commit', () async {
    await storage.write(
      chatId: 'chat_1',
      summaryId: 'summary_1',
      markdown: 'summary',
    );
    final summaryFile = File(
      path.join(root.path, 'chats', 'chat_1', 'summaries', 'summary_1.md'),
    );

    final rollback = await storage.stageForChatDeletion('chat_1');
    expect(await summaryFile.exists(), isFalse);
    await rollback!.rollback();
    expect(await summaryFile.exists(), isTrue);

    final deletion = await storage.stageForChatDeletion('chat_1');
    expect(
      await Directory(path.join(root.path, 'chats', 'chat_1')).exists(),
      isFalse,
    );
    await deletion!.commit();
    expect(
      await Directory(path.join(root.path, 'chats', 'chat_1')).exists(),
      isFalse,
    );
  });
}

ConversationSummaryMetadata _metadata({
  required String digest,
  required int bytes,
}) => ConversationSummaryMetadata(
  id: 'summary_1',
  chatId: 'chat_1',
  fileName: 'summary_1.md',
  contentDigest: digest,
  contentBytes: bytes,
  sourceStartMessageId: 'message_1',
  sourceEndMessageId: 'message_2',
  sourceDigest: 'source-digest',
  baseRevision: 0,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);
