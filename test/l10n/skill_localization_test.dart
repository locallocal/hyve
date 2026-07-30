import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stars/generated/l10n.dart';

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
    'details',
    'skillDetails',
    'uninstall',
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
    'addSkill',
    'removeSkill',
    'noBotSkillsAdded',
    'noBotSkillsAddedDescription',
    'allSkillsAdded',
    'skillEnabled',
    'skillDisabled',
    'manualActivation',
    'alwaysActivation',
    'manualActivationDescription',
    'alwaysActivationDescription',
    'autoActivation',
    'autoActivationDescription',
    'autoActivationUnavailable',
    'testSkillDescription',
    'skillDescriptionTestInput',
    'skillDescriptionShouldActivate',
    'runSkillDescriptionTest',
    'skillDescriptionTestResult',
    'pinnedSkill',
    'pinSelectedSkills',
    'clearPinnedSkills',
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

  test('generated desktop Skill card copy loads for every locale', () async {
    const locales = <({Locale locale, String fileName})>[
      (locale: Locale('en', 'US'), fileName: 'intl_en.arb'),
      (locale: Locale('zh', 'CN'), fileName: 'intl_zh_CN.arb'),
      (locale: Locale('zh', 'TW'), fileName: 'intl_zh_TW.arb'),
      (locale: Locale('ja', 'JP'), fileName: 'intl_ja_JP.arb'),
      (locale: Locale('fr', 'FR'), fileName: 'intl_fr_FR.arb'),
      (locale: Locale('de', 'DE'), fileName: 'intl_de_DE.arb'),
      (locale: Locale('ko', 'KR'), fileName: 'intl_ko_KR.arb'),
      (locale: Locale('ru', 'RU'), fileName: 'intl_ru_RU.arb'),
      (locale: Locale('es', 'ES'), fileName: 'intl_es_ES.arb'),
      (locale: Locale('hi', 'IN'), fileName: 'intl_hi_IN.arb'),
      (locale: Locale('pt', 'BR'), fileName: 'intl_pt_BR.arb'),
      (locale: Locale('it', 'IT'), fileName: 'intl_it_it.arb'),
    ];

    for (final entry in locales) {
      final messages =
          jsonDecode(File('lib/l10n/${entry.fileName}').readAsStringSync())
              as Map<String, dynamic>;
      await S.load(entry.locale);
      final generated = <String, String>{
        'details': S.current.details,
        'uninstall': S.current.uninstall,
        'skillUserScope': S.current.skillUserScope,
        'skillScriptsDisabled': S.current.skillScriptsDisabled,
        'skillReferencesAvailable': S.current.skillReferencesAvailable,
        'skillAssetsAvailable': S.current.skillAssetsAvailable,
        'skillValidationWarnings': S.current.skillValidationWarnings,
      };

      for (final message in generated.entries) {
        expect(
          message.value,
          messages[message.key],
          reason: '${entry.locale}.${message.key}',
        );
      }
    }
  });
}
