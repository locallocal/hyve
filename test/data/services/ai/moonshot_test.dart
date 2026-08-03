import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:stars/data/services/ai/moonshot.dart';
import 'package:stars/domain/models/ai_models.dart';
import 'package:stars/domain/models/models.dart';

void main() {
  group('Moonshot documented model catalog', () {
    test('drives selected-model reasoning and input capabilities', () {
      final k3 = Moonshot(_bot(model: 'kimi-k3'));
      final k26 = Moonshot(_bot(model: 'kimi-k2.6'));
      final text = Moonshot(_bot(model: 'moonshot-v1-128k'));
      final vision = Moonshot(_bot(model: 'moonshot-v1-128k-vision-preview'));

      expect(k3.supportDeepThinking(), isTrue);
      expect(k3.supportWebSearch(), isTrue);
      expect(k3.getInputModalites(), [
        InputModality.text,
        InputModality.image,
        InputModality.video,
      ]);
      expect(k26.supportDeepThinking(), isTrue);
      expect(k26.supportWebSearch(), isTrue);
      expect(k26.getInputModalites(), contains(InputModality.video));
      expect(text.supportDeepThinking(), isFalse);
      expect(text.supportWebSearch(), isFalse);
      expect(text.getInputModalites(), [InputModality.text]);
      expect(vision.getInputModalites(), [
        InputModality.text,
        InputModality.image,
      ]);
    });

    test('merges the official list with the live models endpoint', () async {
      final client = MockClient(
        (request) async => http.Response(
          jsonEncode({
            'data': [
              {'id': 'kimi-k3'},
              {'id': 'custom-model'},
            ],
          }),
          200,
        ),
      );
      final provider = Moonshot(_bot(model: 'kimi-k3'), client: client);

      final models = await provider.fetchModels();
      final ids = models.map((model) => model.modelId).toList();

      expect(ids.take(5), [
        'kimi-k3',
        'kimi-k2.7-code',
        'kimi-k2.7-code-highspeed',
        'kimi-k2.6',
        'kimi-k2.5',
      ]);
      expect(ids, contains('moonshot-v1-128k-vision-preview'));
      expect(ids.last, 'custom-model');
      expect(models.first.contextWindowTokens, 1048576);
      expect(models.first.supportsDeepThinking, isTrue);
    });
  });

  group('Moonshot thinking configuration', () {
    test('sends the K2.6 thinking mode selected by the user', () async {
      final disabled = await _requestBodyFor(
        model: 'kimi-k2.6',
        deepThinking: false,
      );
      final enabled = await _requestBodyFor(
        model: 'kimi-k2.6',
        deepThinking: true,
      );

      expect(disabled['thinking'], {'type': 'disabled'});
      expect(enabled['thinking'], {'type': 'enabled'});
    });

    test('maps the thinking switch to K3 reasoning effort', () async {
      final low = await _requestBodyFor(model: 'kimi-k3', deepThinking: false);
      final max = await _requestBodyFor(model: 'kimi-k3', deepThinking: true);

      expect(low, isNot(contains('thinking')));
      expect(low['reasoning_effort'], 'low');
      expect(max, isNot(contains('thinking')));
      expect(max['reasoning_effort'], 'max');
    });
  });

  group('Moonshot built-in web search', () {
    test('declares the official web search tool alongside reasoning', () async {
      final body = await _requestBodyFor(
        model: 'kimi-k2.6',
        deepThinking: true,
        webSearch: true,
      );

      expect(body['thinking'], {'type': 'enabled'});
      expect(body['tools'], [
        {
          'type': 'builtin_function',
          'function': {'name': r'$web_search'},
        },
      ]);
    });

    test('echoes web search arguments until Kimi returns an answer', () async {
      final requestBodies = <Map<String, dynamic>>[];
      var requestCount = 0;
      final client = MockClient((request) async {
        requestBodies.add(
          Map<String, dynamic>.from(jsonDecode(request.body) as Map),
        );
        requestCount += 1;
        if (requestCount == 1) {
          return http.Response(
            '${_sse({
              'choices': [
                {
                  'delta': {
                    'reasoning_content': 'searching',
                    'tool_calls': [
                      {
                        'index': 0,
                        'id': 'search-1',
                        'type': 'function',
                        'function': {'name': r'$web_search', 'arguments': '{"query":'},
                      },
                    ],
                  },
                },
              ],
            })}'
            '${_sse({
              'choices': [
                {
                  'delta': {
                    'tool_calls': [
                      {
                        'index': 0,
                        'function': {'arguments': '"Moonshot"}'},
                      },
                    ],
                  },
                  'finish_reason': 'tool_calls',
                },
              ],
            })}'
            'data: [DONE]\n\n',
            200,
            headers: {'content-type': 'text/event-stream'},
          );
        }
        return http.Response(
          '${_sse({
            'choices': [
              {
                'delta': {'content': 'final answer'},
                'finish_reason': 'stop',
              },
            ],
          })}'
          'data: [DONE]\n\n',
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      });
      var response = '';
      var reasoning = '';
      var completed = false;
      final provider =
          Moonshot(_bot(model: 'kimi-k3'), client: client)
            ..setWebSearch(true)
            ..setDeepThinking(true)
            ..setCallbacks(
              onResponse: (value) => response += value,
              onReasoningResponse: (value) => reasoning += value,
              onComplete: () => completed = true,
            );

      await provider.generateText([
        ChatMessage(role: 'user', content: 'latest Moonshot news'),
      ]);

      expect(requestBodies, hasLength(2));
      expect(response, 'final answer');
      expect(reasoning, 'searching');
      expect(completed, isTrue);
      expect(requestBodies.every((body) => body.containsKey('tools')), isTrue);
      expect(requestBodies.first['reasoning_effort'], 'max');

      final followUpMessages = requestBodies.last['messages'] as List;
      final assistant = followUpMessages[followUpMessages.length - 2] as Map;
      final tool = followUpMessages.last as Map;
      expect(assistant['reasoning_content'], 'searching');
      expect((assistant['tool_calls'] as List).single, {
        'id': 'search-1',
        'type': 'function',
        'function': {
          'name': r'$web_search',
          'arguments': '{"query":"Moonshot"}',
        },
      });
      expect(tool, {
        'role': 'tool',
        'tool_call_id': 'search-1',
        'name': r'$web_search',
        'content': '{"query":"Moonshot"}',
      });
    });
  });
}

Future<Map<String, dynamic>> _requestBodyFor({
  required String model,
  required bool deepThinking,
  bool webSearch = false,
}) async {
  Map<String, dynamic>? requestBody;
  final client = MockClient((request) async {
    requestBody = Map<String, dynamic>.from(jsonDecode(request.body) as Map);
    return http.Response(
      'data: ${jsonEncode({
        'choices': [
          {
            'delta': {'content': 'done'},
          },
        ],
      })}\n\ndata: [DONE]\n\n',
      200,
      headers: {'content-type': 'text/event-stream'},
    );
  });
  final provider =
      Moonshot(_bot(model: model), client: client)
        ..setDeepThinking(deepThinking)
        ..setWebSearch(webSearch)
        ..setCallbacks(onResponse: (_) {});

  await provider.generateText([ChatMessage(role: 'user', content: 'hello')]);

  expect(requestBody, isNotNull);
  return requestBody!;
}

String _sse(Map<String, Object?> data) => 'data: ${jsonEncode(data)}\n\n';

Bot _bot({required String model}) => Bot(
  id: 'bot-moonshot-$model',
  name: model,
  avatar: '',
  provider: 'Moonshot',
  baseURL: 'https://api.moonshot.cn/v1/',
  apiKey: 'test-key',
  apiType: Bot.apiTypeMoonshot,
  model: model,
  systemPrompt: '',
  createTimestamp: DateTime.fromMillisecondsSinceEpoch(1),
  modifyTimestamp: DateTime.fromMillisecondsSinceEpoch(1),
);
