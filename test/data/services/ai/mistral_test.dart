import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stars/data/services/ai/mistral.dart';
import 'package:stars/domain/models/ai_models.dart';
import 'package:stars/domain/models/models.dart';

void main() {
  test('Mistral streams thinking chunks separately from answer text', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    late Map<String, dynamic> requestBody;
    final handled = server.first.then((request) async {
      requestBody = Map<String, dynamic>.from(
        jsonDecode(await utf8.decoder.bind(request).join()) as Map,
      );
      request.response.headers.contentType = ContentType(
        'text',
        'event-stream',
        charset: 'utf-8',
      );
      request.response.write(
        'data: ${jsonEncode({
          'choices': [
            {
              'delta': {
                'content': [
                  {
                    'type': 'thinking',
                    'thinking': [
                      {'type': 'text', 'text': 'reason'},
                    ],
                  },
                  {'type': 'text', 'text': 'answer'},
                ],
              },
            },
          ],
        })}\n\n',
      );
      request.response.write('data: [DONE]\n\n');
      await request.response.close();
    });

    final bot = Bot(
      id: 'mistral-test',
      name: 'Mistral',
      avatar: '',
      provider: 'Mistral',
      baseURL: 'http://${server.address.host}:${server.port}/',
      apiKey: 'test-key',
      apiType: Bot.apiTypeMistral,
      model: 'mistral-medium-3-5',
      systemPrompt: '',
      createTimestamp: DateTime.fromMillisecondsSinceEpoch(1),
      modifyTimestamp: DateTime.fromMillisecondsSinceEpoch(1),
    );
    final provider = Mistral(bot)..setDeepThinking(true);
    var answer = '';
    var reasoning = '';
    provider.setCallbacks(
      onResponse: (text) => answer += text,
      onReasoningResponse: (text) => reasoning += text,
    );

    await provider.generateText([ChatMessage(role: 'user', content: 'hello')]);
    await handled;

    expect(requestBody['reasoning_effort'], 'high');
    expect(reasoning, 'reason');
    expect(answer, 'answer');
  });
}
