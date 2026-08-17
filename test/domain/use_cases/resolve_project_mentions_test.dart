import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/use_cases/resolve_project_mentions.dart';

void main() {
  const resolve = ResolveProjectMentions();
  final researcher = _bot('researcher', 'Research Agent');
  final reviewer = _bot('reviewer', '代码审查');

  test('resolves multiple project agents in textual mention order', () {
    final result = resolve(
      text: '@代码审查 review it, then @Research Agent investigate this',
      projectBots: [researcher, reviewer],
    );

    expect(result.bots, [reviewer, researcher]);
  });

  test('ignores unmentioned agents and partial names', () {
    final result = resolve(
      text: '@Research is not a complete mention',
      projectBots: [researcher, reviewer],
    );

    expect(result.hasTargets, isFalse);
  });

  test('deduplicates repeated mentions', () {
    final result = resolve(
      text: '@代码审查 please review. @代码审查 check again.',
      projectBots: [researcher, reviewer],
    );

    expect(result.bots, [reviewer]);
  });

  test('prefers the longest agent name at the same mention position', () {
    final agent = _bot('agent', 'Agent');
    final agentPro = _bot('agent-pro', 'Agent Pro');

    final result = resolve(
      text: '@Agent Pro inspect this',
      projectBots: [agent, agentPro],
    );

    expect(result.bots, [agentPro]);
  });
}

Bot _bot(String id, String name) => Bot(
  id: id,
  name: name,
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
