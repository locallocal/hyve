import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:stars/model/model.dart';

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

    final restored = MessageProcessInfo.fromRaw(jsonEncode(info.toMap()));

    expect(restored.hasData, isTrue);
    expect(restored.reasoningStatus, 'completed');
    expect(restored.skillActivations, hasLength(1));
    expect(restored.skillActivations.single.name, 'release-notes');
    expect(restored.skillActivations.single.contentDigest, 'abc123');
    expect(restored.skillActivations.single.trigger, 'manual');
    expect(restored.skillActivations.single.status, 'recorded');
  });

  test('legacy process info remains readable without Skill fields', () {
    final restored = MessageProcessInfo.fromRaw(
      jsonEncode(<String, Object?>{
        'reasoning_status': 'completed',
        'duration_ms': 42,
        'tool_calls': <Object?>[],
        'command_executions': <Object?>[],
        'file_edits': <Object?>[],
      }),
    );

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

    final restored = MessageProcessInfo.fromRaw(jsonEncode(info.toMap()));
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
}
