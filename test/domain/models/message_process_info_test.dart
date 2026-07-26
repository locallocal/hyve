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
}
