import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/data/services/tools/system_shell_skill.dart';
import 'package:hyve/domain/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled shell Skill passes its content digest', () async {
    final skill = SystemShellSkill();

    final content = await skill.loadContent();

    expect(skill.isValid, isTrue);
    expect(skill.promptVersion, 1);
    expect(skill.contentDigest, hasLength(64));
    expect(content.descriptor.id, shellCommandSkillId);
    expect(content.descriptor.scope, SkillScope.bundled);
    expect(content.descriptor.trustState, SkillTrustState.bundledTrusted);
    expect(content.descriptor.requestedToolNames, shellCommandToolNames);
    expect(content.instructions, contains('Every command requires'));
    expect(content.files, ['SKILL.md']);
  });
}
