import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('pubspec uses one localization generator and no audited dead deps', () {
    final pubspec =
        loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
    final flutter = pubspec['flutter']! as YamlMap;
    final dependencies = pubspec['dependencies']! as YamlMap;

    expect(flutter.containsKey('generate'), isFalse);
    expect(pubspec['flutter_intl'], isA<YamlMap>());
    expect(pubspec['dev_dependencies'], contains('intl_utils'));
    for (final dependency in const [
      'cupertino_icons',
      'dart_openai',
      'google_generative_ai',
      'flex_color_scheme',
      'dot_curved_bottom_nav',
      'elegant_nav_bar',
      'sidebarx',
    ]) {
      expect(dependencies, isNot(contains(dependency)), reason: dependency);
    }
    expect(dependencies, contains('sqlite3'));
  });

  test('repository governance and cache guidance stay present', () {
    for (final path in const [
      'LICENSE',
      'SECURITY.md',
      'CONTRIBUTING.md',
      'CHANGELOG.md',
      'CODE_OF_CONDUCT.md',
      '.github/dependabot.yml',
    ]) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }

    final readme = File('README.md').readAsStringSync();
    expect(readme, contains('flutter clean'));
    expect(readme, contains('tool/check_format.dart'));
    expect(readme, contains('12 interface languages'));
  });
}
