import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/domain/models/models.dart';

void main() {
  test('resolves distinct available bots in persisted project order', () {
    final researcher = _bot('researcher');
    final reviewer = _bot('reviewer');
    final project = ProjectWorkspace(
      chat: _chat([researcher.id, reviewer.id]),
      bots: [reviewer, researcher, reviewer],
    );

    expect(project.bots.map((bot) => bot.id), ['researcher', 'reviewer']);
    expect(project.firstBot, same(researcher));
    expect(() => project.bots.clear(), throwsUnsupportedError);
  });

  test('removes a member from both the aggregate and persisted ids', () {
    final researcher = _bot('researcher');
    final reviewer = _bot('reviewer');
    final project = ProjectWorkspace(
      chat: _chat([researcher.id, reviewer.id]),
      bots: [researcher, reviewer],
    );
    final updated = project.removeBot(researcher.id);

    expect(updated.botIds, [reviewer.id]);
    expect(updated.bots, [reviewer]);
    expect(updated.firstBot, same(reviewer));
  });

  test('keeps a project summary when its final member is removed', () {
    final researcher = _bot('researcher');
    final project = ProjectWorkspace(
      chat: _chat([researcher.id]),
      bots: [researcher],
    );

    final updated = project.removeBot(researcher.id);

    expect(updated.botIds, isEmpty);
    expect(updated.bots, isEmpty);
    expect(updated.firstBot, isNull);
  });

  test('rejects an incomplete project member set', () {
    expect(
      () => ProjectWorkspace(
        chat: _chat(['researcher', 'reviewer']),
        bots: [_bot('researcher')],
      ),
      throwsStateError,
    );
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

Chat _chat(List<String> botIds) => Chat(
  id: 'project',
  name: 'ProjectWorkspace',
  botIds: botIds,
  lastMessageTimestamp: DateTime(2026),
  createTimestamp: DateTime(2026),
  modifyTimestamp: DateTime(2026),
);
