import 'package:flutter_test/flutter_test.dart';
import 'package:stars/data/services/tools/system_conversation_history_skill.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'bundled conversation history Skill passes its content digest',
    () async {
      final skill = SystemConversationHistorySkill();

      await skill.validate();

      expect(skill.isValid, isTrue);
      expect(skill.promptVersion, 1);
      expect(skill.contentDigest, hasLength(64));
    },
  );
}
