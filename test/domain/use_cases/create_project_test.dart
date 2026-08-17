import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/chat_repository.dart';
import 'package:hyve/domain/use_cases/create_chat.dart';
import 'package:hyve/domain/use_cases/create_project.dart';

void main() {
  test('creates a project with distinct ordered agents', () async {
    final repository = _ChatRepository();
    final createProject = CreateProject(
      createChat: CreateChat(
        chatRepository: repository,
        clock: () => DateTime(2026, 8, 18),
      ),
    );
    final researcher = _bot('researcher');
    final writer = _bot('writer');

    final project = await createProject(
      name: '  Launch plan  ',
      bots: [researcher, writer, researcher],
    );

    expect(project.name, 'Launch plan');
    expect(project.bots.map((bot) => bot.id), ['researcher', 'writer']);
    expect(project.botIds, ['researcher', 'writer']);
    expect(repository.added, [project.chat]);
  });

  test('rejects a project without an agent before persistence', () async {
    final repository = _ChatRepository();
    final createProject = CreateProject(
      createChat: CreateChat(chatRepository: repository),
    );

    await expectLater(
      createProject(name: 'Empty', bots: const <Bot>[]),
      throwsArgumentError,
    );
    expect(repository.added, isEmpty);
  });

  test('rejects an empty project name before persistence', () async {
    final repository = _ChatRepository();
    final createProject = CreateProject(
      createChat: CreateChat(chatRepository: repository),
    );

    await expectLater(
      createProject(name: '   ', bots: [_bot('researcher')]),
      throwsArgumentError,
    );
    expect(repository.added, isEmpty);
  });
}

Bot _bot(String id) => Bot(
  id: id,
  name: id,
  avatar: '',
  provider: 'test',
  baseURL: '',
  apiKey: '',
  apiType: Bot.apiTypeOpenAI,
  model: 'model',
  systemPrompt: '',
  createTimestamp: DateTime(2026),
  modifyTimestamp: DateTime(2026),
);

final class _ChatRepository implements ChatRepository {
  final List<Chat> added = <Chat>[];

  @override
  Stream<List<Chat>> get changes => const Stream<List<Chat>>.empty();

  @override
  Future<void> addChat(Chat chat) async => added.add(chat);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
