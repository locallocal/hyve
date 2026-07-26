import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const skillKeys = <String>{
    'skillLibrary',
    'skillLibraryDescription',
    'searchSkills',
    'noMatchingSkills',
    'importSkillFolder',
    'importSkillZip',
    'importingSkill',
    'noSkillsInstalled',
    'noSkillsInstalledDescription',
    'skillImportSucceeded',
    'skillImportFailed',
    'skillDetails',
    'uninstallSkill',
    'confirmUninstallSkill',
    'skillVersion',
    'skillSource',
    'skillDigest',
    'skillCompatibility',
    'skillFiles',
    'skillValidationWarnings',
    'skillScriptsDisabled',
    'skillReferencesAvailable',
    'skillAssetsAvailable',
    'botSkills',
    'botSkillsDescription',
    'manualActivation',
    'alwaysActivation',
    'manualActivationDescription',
    'alwaysActivationDescription',
    'messageSkills',
    'alwaysOn',
    'skillNotExecutable',
    'skillSafetyDescription',
    'skillUserScope',
  };

  test('every supported locale defines the complete Skill feature copy', () {
    final arbFiles =
        Directory('lib/l10n')
            .listSync()
            .whereType<File>()
            .where((file) => RegExp(r'intl_.+\.arb$').hasMatch(file.path))
            .toList()
          ..sort((left, right) => left.path.compareTo(right.path));

    expect(arbFiles, hasLength(12));
    for (final file in arbFiles) {
      final messages =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final missing = skillKeys.difference(messages.keys.toSet());
      expect(
        missing,
        isEmpty,
        reason: '${file.path} is missing Skill translations',
      );
      expect(
        messages['skillImportFailed'],
        contains('{error}'),
        reason: '${file.path} must preserve the error placeholder',
      );
      expect(
        messages['confirmUninstallSkill'],
        contains('{name}'),
        reason: '${file.path} must preserve the name placeholder',
      );
      if (!file.path.endsWith('intl_en.arb')) {
        expect(
          messages['skillLibrary'],
          isNot('Skills'),
          reason: '${file.path} must not fall back to English',
        );
      }
    }
  });

  test('Chinese locales consistently use 技能 for visible Skill labels', () {
    for (final locale in ['zh_CN', 'zh_TW']) {
      final messages =
          jsonDecode(File('lib/l10n/intl_$locale.arb').readAsStringSync())
              as Map<String, dynamic>;

      expect(messages['skillLibrary'], '技能');
      expect(messages['botSkills'], '技能');
      expect(messages['messageSkills'], '技能');
      for (final key in skillKeys) {
        final value = messages[key] as String;
        expect(
          value,
          isNot(contains(RegExp(r'\bSkills?\b'))),
          reason: '$locale.$key should use Chinese terminology',
        );
      }
    }
  });
}
