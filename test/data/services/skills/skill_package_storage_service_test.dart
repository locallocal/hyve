import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stars/data/services/skills/skill_package_storage_service.dart';
import 'package:stars/domain/models/models.dart';

void main() {
  late Directory temporaryDirectory;
  late Directory supportDirectory;
  late SkillPackageStorageService service;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'stars-skill-storage-',
    );
    supportDirectory = Directory('${temporaryDirectory.path}/support');
    service = SkillPackageStorageService(
      applicationSupportDirectoryProvider: () async => supportDirectory,
    );
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test(
    'stages and commits a directory to a content-addressed bundle',
    () async {
      final source = Directory('${temporaryDirectory.path}/summarize');
      await source.create(recursive: true);
      await File('${source.path}/SKILL.md').writeAsString('''
---
name: summarize
description: Summarize supplied material.
---
Keep the summary concise.
''');
      await File('${source.path}/references/tone.md').create(recursive: true);

      final staged = await service.stage(
        SkillImportSource(kind: SkillImportKind.directory, path: source.path),
      );
      final stored = await service.commit(
        staged,
        scope: SkillScope.user.name,
        skillName: 'summarize',
      );

      expect(stored.contentDigest, hasLength(64));
      expect(
        stored.rootPath,
        contains('/skills/bundles/user/summarize/${stored.contentDigest}'),
      );
      expect(
        await service.readInstructions(stored.rootPath),
        'Keep the summary concise.',
      );
      expect(
        await service.listFiles(stored.rootPath),
        containsAll(<String>['SKILL.md', 'references/tone.md']),
      );
    },
  );

  test('rejects ZIP path traversal before writing outside staging', () async {
    final zipFile = File('${temporaryDirectory.path}/malicious.zip');
    final archive =
        Archive()
          ..addFile(ArchiveFile.string('../outside.txt', 'escaped'))
          ..addFile(
            ArchiveFile.string('safe-skill/SKILL.md', '''
---
name: safe-skill
description: A nominal package.
---
Do work.
'''),
          );
    await zipFile.writeAsBytes(ZipEncoder().encodeBytes(archive));

    expect(
      () => service.stage(
        SkillImportSource(kind: SkillImportKind.zipArchive, path: zipFile.path),
      ),
      throwsA(isA<SkillInstallException>()),
    );
    expect(
      File('${supportDirectory.path}/skills/outside.txt').existsSync(),
      isFalse,
    );
    expect(
      File('${temporaryDirectory.path}/outside.txt').existsSync(),
      isFalse,
    );
  });

  test('rejects symbolic links in directory imports', () async {
    if (Platform.isWindows) return;
    final source = Directory('${temporaryDirectory.path}/linked');
    await source.create(recursive: true);
    await File('${source.path}/SKILL.md').writeAsString('''
---
name: linked
description: Contains an unsafe link.
---
Do work.
''');
    final external = File('${temporaryDirectory.path}/secret.txt');
    await external.writeAsString('secret');
    await Link('${source.path}/reference.txt').create(external.path);

    expect(
      () => service.stage(
        SkillImportSource(kind: SkillImportKind.directory, path: source.path),
      ),
      throwsA(isA<SkillInstallException>()),
    );
  });
}
