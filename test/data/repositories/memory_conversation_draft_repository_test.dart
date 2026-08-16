import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/data/repositories/memory_conversation_draft_repository.dart';
import 'package:hyve/domain/models/conversation_draft.dart';

void main() {
  test('evicts the least recently used conversation at capacity', () async {
    final repository = MemoryConversationDraftRepository(
      capacity: 2,
      pathValidator: (_) async => true,
    );

    await repository.write('first', const ConversationDraft(text: '1'));
    await repository.write('second', const ConversationDraft(text: '2'));
    await repository.read('first');
    await repository.write('third', const ConversationDraft(text: '3'));

    expect(await repository.read('first'), isNotNull);
    expect(await repository.read('second'), isNull);
    expect(await repository.read('third'), isNotNull);
  });

  test('filters stale attachments and supports deletion', () async {
    final repository = MemoryConversationDraftRepository(
      pathValidator: (path) async => !path.endsWith('.missing'),
    );
    await repository.write(
      'chat',
      const ConversationDraft(
        text: 'draft',
        imagePaths: ['valid.png', 'stale.missing'],
        filePaths: ['valid.txt', 'stale.missing'],
      ),
    );

    final draft = await repository.read('chat');
    expect(draft?.imagePaths, ['valid.png']);
    expect(draft?.filePaths, ['valid.txt']);

    await repository.delete('chat');
    expect(await repository.read('chat'), isNull);
  });
}
