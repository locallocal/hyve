import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:hyve/data/repositories/attachment_repository_impl.dart';
import 'package:hyve/data/services/attachment_picker_service.dart';
import 'package:hyve/domain/models/models.dart';

void main() {
  late Directory root;
  late AttachmentRepositoryImpl repository;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('hyve-assets-');
    repository = AttachmentRepositoryImpl(
      service: AttachmentPickerService(),
      documentsDirectoryProvider: () async => root,
    );
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('same-basename assets are unique and preserve extensions', () async {
    final firstDirectory =
        await Directory(path.join(root.path, 'source-a')).create();
    final secondDirectory =
        await Directory(path.join(root.path, 'source-b')).create();
    final first = File(path.join(firstDirectory.path, 'photo.PNG'));
    final second = File(path.join(secondDirectory.path, 'photo.PNG'));
    await first.writeAsString('first');
    await second.writeAsString('second');

    final stored = await repository.persistAssets(
      chatId: 'chat_1',
      sourcePaths: [first.path, second.path],
    );

    expect(stored, hasLength(2));
    expect(stored.toSet(), hasLength(2));
    expect(stored.every((item) => path.extension(item) == '.png'), isTrue);
    expect(await File(stored.first).readAsString(), 'first');
    expect(await File(stored.last).readAsString(), 'second');
  });

  test('a missing source rolls back every staged asset', () async {
    final source = File(path.join(root.path, 'valid.txt'));
    await source.writeAsString('valid');

    await expectLater(
      repository.persistAssets(
        chatId: 'chat_2',
        sourcePaths: [source.path, path.join(root.path, 'missing.txt')],
      ),
      throwsA(isA<AppFailure>()),
    );

    final destination = Directory(path.join(root.path, 'chats', 'chat_2'));
    expect(
      await destination.list().where((entity) => entity is File).toList(),
      isEmpty,
    );
  });
}
