import 'package:flutter_test/flutter_test.dart';
import 'package:stars/data/services/tools/system_conversation_history_skill.dart';
import 'package:stars/domain/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'bundled conversation history Skill passes its content digest',
    () async {
      final skill = SystemConversationHistorySkill();

      final content = await skill.loadContent();

      expect(skill.isValid, isTrue);
      expect(skill.promptVersion, 1);
      expect(skill.contentDigest, hasLength(64));
      expect(content.descriptor.id, conversationHistorySkillId);
      expect(content.descriptor.scope, SkillScope.bundled);
      expect(content.descriptor.trustState, SkillTrustState.bundledTrusted);
      expect(
        content.descriptor.requestedToolNames,
        conversationHistoryToolNames,
      );
      expect(content.instructions, contains('Query conversation history'));
      expect(content.files, ['SKILL.md']);
    },
  );
}
