import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy model entry point is fully migrated', () {
    expect(File('lib/model/model.dart').existsSync(), isFalse);

    final domainBarrel =
        File('lib/domain/models/models.dart').readAsStringSync();
    expect(domainBarrel, isNot(contains("export '../../model/")));
  });

  test('domain models do not depend on Flutter, data, or UI layers', () {
    final modelFiles = Directory('lib/domain/models')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in modelFiles) {
      final source = file.readAsStringSync();
      expect(
        source,
        isNot(contains('package:flutter/')),
        reason: '${file.path} imports Flutter',
      );
      expect(
        source,
        isNot(contains('package:stars/data/')),
        reason: '${file.path} imports the data layer',
      );
      expect(
        source,
        isNot(contains('package:stars/ui/')),
        reason: '${file.path} imports the UI layer',
      );
    }
  });

  test('UI depends on data only through the composition root', () {
    final uiFiles = Directory('lib/ui')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in uiFiles) {
      if (file.path.endsWith(
        'lib/ui/core/dependency_injection/app_dependencies.dart',
      )) {
        continue;
      }
      expect(
        file.readAsStringSync(),
        isNot(contains('package:stars/data/')),
        reason: '${file.path} bypasses a domain contract',
      );
    }
  });

  test('views do not invoke platform action plugins directly', () {
    const pluginImports = <String>[
      'package:file_picker/',
      'package:gallery_saver_plus/',
      'package:share_plus/',
      'package:url_launcher/',
    ];
    final viewFiles = Directory('lib/ui')
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (file) =>
              file.path.endsWith('.dart') && file.path.contains('/views/'),
        );

    for (final file in viewFiles) {
      final source = file.readAsStringSync();
      for (final pluginImport in pluginImports) {
        expect(
          source,
          isNot(contains(pluginImport)),
          reason: '${file.path} invokes a platform plugin directly',
        );
      }
    }
  });

  test('production source files stay below the reviewability limit', () {
    final sourceFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (file) =>
              file.path.endsWith('.dart') && !file.path.contains('/generated/'),
        );

    for (final file in sourceFiles) {
      final lineCount = file.readAsLinesSync().length;
      expect(
        lineCount,
        lessThanOrEqualTo(1000),
        reason: '${file.path} has $lineCount lines; split by responsibility',
      );
    }
  });
}
