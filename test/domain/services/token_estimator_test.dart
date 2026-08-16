import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/domain/models/ai_models.dart';
import 'package:hyve/domain/models/conversation_memory.dart';
import 'package:hyve/domain/services/token_estimator.dart';

void main() {
  const profile = ModelContextProfile(contextWindowTokens: 32768);
  const estimator = ConservativeTokenEstimator(messageOverheadTokens: 8);

  test('counts CJK conservatively and rounds latin text upward', () async {
    expect(await estimator.estimateText(profile, '你好'), 2);
    expect(await estimator.estimateText(profile, 'abcd'), 2);
  });

  test('includes message and attachment protocol overhead', () async {
    final tokens = await estimator.estimateMessages(profile, [
      ChatMessage(
        role: 'user',
        content: 'hello',
        images: const ['image'],
        files: const ['file'],
      ),
    ]);

    expect(tokens, greaterThanOrEqualTo(330));
  });
}
