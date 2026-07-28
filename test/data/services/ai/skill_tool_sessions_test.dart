import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:stars/data/services/ai/anthropic.dart';
import 'package:stars/data/services/ai/openai.dart';
import 'package:stars/domain/models/ai_models.dart';
import 'package:stars/domain/models/models.dart';

void main() {
  test('OpenAI uses structured Skill tools and returns tool results', () async {
    final requests = <Map<String, Object?>>[];
    var requestIndex = 0;
    final client = MockClient((request) async {
      requests.add(
        (jsonDecode(request.body) as Map<Object?, Object?>).map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      );
      requestIndex += 1;
      if (requestIndex == 1) {
        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {
                  'content': null,
                  'tool_calls': [
                    {
                      'id': 'call-1',
                      'type': 'function',
                      'function': {
                        'name': 'activate_skill',
                        'arguments': '{"name":"release-notes"}',
                      },
                    },
                  ],
                },
              },
            ],
            'usage': {
              'prompt_tokens': 10,
              'completion_tokens': 2,
              'total_tokens': 12,
            },
          }),
          200,
        );
      }
      return http.Response(
        jsonEncode({
          'choices': [
            {
              'message': {'content': 'done'},
            },
          ],
        }),
        200,
      );
    });
    final provider = OpenAI(_bot, skillToolClient: client);
    final session = provider.openSkillToolSession(_request);
    addTearDown(session.close);

    final first = await session.start();
    expect(first.calls.single.name, 'activate_skill');
    expect(first.calls.single.arguments, {'name': 'release-notes'});
    expect(first.tokenUsage.effectiveTotalTokens, 12);

    final second = await session.continueWith(const [
      SkillToolResult(
        callId: 'call-1',
        name: 'activate_skill',
        content: 'activated',
      ),
    ]);
    expect(second.isComplete, isTrue);
    expect(requests, hasLength(2));
    expect(requests.first['parallel_tool_calls'], isFalse);
    expect(requests.first['tools'], hasLength(2));
    final secondMessages = requests.last['messages']! as List<Object?>;
    final toolMessage = secondMessages.last as Map<Object?, Object?>;
    expect(toolMessage['role'], 'tool');
    expect(toolMessage['tool_call_id'], 'call-1');
  });

  test('Anthropic parses tool_use blocks and reports usage', () async {
    final client = MockClient(
      (request) async => http.Response(
        jsonEncode({
          'content': [
            {
              'type': 'tool_use',
              'id': 'tool-1',
              'name': 'activate_skill',
              'input': {'name': 'release-notes'},
            },
          ],
          'usage': {'input_tokens': 14, 'output_tokens': 3},
        }),
        200,
      ),
    );
    final provider = Anthropic(_bot, skillToolClient: client);
    final session = provider.openSkillToolSession(_request);
    addTearDown(session.close);

    final turn = await session.start();

    expect(turn.calls.single.callId, 'tool-1');
    expect(turn.calls.single.arguments['name'], 'release-notes');
    expect(turn.tokenUsage.inputTokens, 14);
    expect(turn.tokenUsage.outputTokens, 3);
    expect(turn.tokenUsage.effectiveTotalTokens, 17);
  });
}

final _bot = Bot(
  id: 'bot-1',
  name: 'Bot',
  avatar: '',
  provider: 'test',
  baseURL: 'https://example.test/v1/',
  apiKey: 'secret',
  apiType: Bot.apiTypeOpenAI,
  model: 'test-model',
  systemPrompt: '',
  createTimestamp: DateTime(2026),
  modifyTimestamp: DateTime(2026),
);

final _request = SkillToolSessionRequest(
  messages: [ChatMessage(role: 'user', content: 'Write release notes')],
  catalog: const [
    SkillCatalogEntry(
      id: 'user:release-notes',
      name: 'release-notes',
      description: 'Prepare release notes.',
      contentDigest: 'digest',
      priority: 0,
    ),
  ],
);
