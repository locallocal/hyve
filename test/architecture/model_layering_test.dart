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
}
