import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:stars/data/models/local_records.dart';
import 'package:stars/domain/models/models.dart';

void main() {
  test('Skill activations survive process info serialization', () {
    const info = MessageProcessInfo(
      reasoningStatus: 'completed',
      skillActivations: [
        MessageSkillActivation(
          name: 'release-notes',
          contentDigest: 'abc123',
          trigger: 'manual',
        ),
      ],
    );

    final restored =
        MessageProcessInfoRecord.fromRaw(
          jsonEncode(MessageProcessInfoRecord.fromDomain(info).values),
        ).toDomain();

    expect(restored.hasData, isTrue);
    expect(restored.reasoningStatus, 'completed');
    expect(restored.skillActivations, hasLength(1));
    expect(restored.skillActivations.single.name, 'release-notes');
    expect(restored.skillActivations.single.contentDigest, 'abc123');
    expect(restored.skillActivations.single.trigger, 'manual');
    expect(restored.skillActivations.single.status, 'recorded');
  });

  test('legacy process info remains readable without Skill fields', () {
    final restored =
        MessageProcessInfoRecord.fromRaw(
          jsonEncode(<String, Object?>{
            'reasoning_status': 'completed',
            'duration_ms': 42,
            'tool_calls': <Object?>[],
            'command_executions': <Object?>[],
            'file_edits': <Object?>[],
          }),
        ).toDomain();

    expect(restored.reasoningStatus, 'completed');
    expect(restored.durationMs, 42);
    expect(restored.skillActivations, isEmpty);
  });

  test('structured tool invocation survives process info serialization', () {
    const info = MessageProcessInfo(
      toolCalls: [
        MessageToolCall(
          callId: 'call-1',
          name: 'save_note',
          status: 'succeeded',
          source: 'builtIn',
          riskLevel: 'write',
          argumentsSummary: '{"title":"Release"}',
          resultSummary: 'saved',
          approvalStatus: 'allowOnce',
          durationMs: 12,
        ),
      ],
    );

    final restored =
        MessageProcessInfoRecord.fromRaw(
          jsonEncode(MessageProcessInfoRecord.fromDomain(info).values),
        ).toDomain();
    final call = restored.toolCalls.single;

    expect(call.callId, 'call-1');
    expect(call.name, 'save_note');
    expect(call.source, 'builtIn');
    expect(call.riskLevel, 'write');
    expect(call.argumentsSummary, '{"title":"Release"}');
    expect(call.resultSummary, 'saved');
    expect(call.approvalStatus, 'allowOnce');
    expect(call.durationMs, 12);
  });

  test('local records preserve core domain model fields', () {
    final timestamp = DateTime.fromMillisecondsSinceEpoch(1770000000123);
    final bot = Bot(
      id: 'bot-1',
      name: 'Assistant',
      avatar: '/avatar.png',
      provider: 'Provider',
      baseURL: 'https://example.test',
      apiKey: 'secret',
      apiType: Bot.apiTypeOpenAI,
      model: 'model-a',
      systemPrompt: 'Be helpful.',
      parameters: const {'temperature': 0.3},
      createTimestamp: timestamp,
      modifyTimestamp: timestamp,
    );
    final chat = Chat(
      id: 'chat-1',
      botId: bot.id,
      lastMessage: 'Hello',
      lastMessageTimestamp: timestamp,
      createTimestamp: timestamp,
      modifyTimestamp: timestamp,
    );
    final profile = Profile(
      name: 'Earthwind',
      avatar: '/profile.png',
      fontSize: 18,
      themeMode: 2,
      language: 'zh_CN',
      showExecutionStatus: false,
      createTimestamp: timestamp,
      modifyTimestamp: timestamp,
    );

    final restoredBot = BotRecord.fromDomain(bot).toDomain();
    final restoredChat = ChatRecord.fromDomain(chat).toDomain();
    final restoredProfile = ProfileRecord.fromDomain(profile).toDomain();

    expect(restoredBot.parameters, {'temperature': 0.3});
    expect(restoredBot.modifyTimestamp, timestamp);
    expect(restoredChat.lastMessage, 'Hello');
    expect(restoredChat.lastMessageTimestamp, timestamp);
    expect(restoredProfile.fontSize, 18);
    expect(restoredProfile.showExecutionStatus, isFalse);
  });
}
