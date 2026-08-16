import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/data/services/skills/skill_catalog_endpoint_policy.dart';
import 'package:hyve/data/services/skills/skill_installation_service.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/skill_repository.dart';

void main() {
  late Directory temporaryDirectory;
  late _RecordingSkillRepository repository;
  late List<Uri> fetchedUris;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'hyve-skill-installation-service-',
    );
    repository = _RecordingSkillRepository();
    fetchedUris = [];
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  SkillInstallationService createService() => SkillInstallationService(
    skillRepository: repository,
    endpointPolicy: SkillCatalogEndpointPolicy(
      dnsLookup: (_) async => [InternetAddress('8.8.8.8')],
    ),
    fetcher: (uri, maxBytes, cancellationToken) async {
      cancellationToken.throwIfCancelled();
      fetchedUris.add(uri);
      expect(maxBytes, 20 * 1024 * 1024);
      return const [1, 2, 3];
    },
    temporaryDirectoryProvider: () async {
      final directory = Directory('${temporaryDirectory.path}/download');
      await directory.create(recursive: true);
      return directory;
    },
  );

  test(
    'downloads a GitHub repository archive and selects a nested Skill',
    () async {
      final service = createService();

      final installed = await service.install(
        const SkillInstallationRequest(
          sourceType: SkillInstallSourceType.github,
          source: 'https://github.com/acme/hyve-skills',
          ref: 'release/v1',
          subdirectory: 'skills/reviewer',
          archiveSha256:
              'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
        ),
        AgentCancellationToken(),
      );

      expect(
        fetchedUris.single.toString(),
        'https://codeload.github.com/acme/hyve-skills/zip/release/v1',
      );
      expect(repository.source?.kind, SkillImportKind.zipArchive);
      expect(
        repository.source?.sourceUri,
        'https://github.com/acme/hyve-skills',
      );
      expect(repository.source?.subdirectory, 'skills/reviewer');
      expect(
        repository.source?.expectedArchiveDigest,
        List.filled(64, 'a').join(),
      );
      expect(installed.id, 'user:installed');
      expect(
        Directory('${temporaryDirectory.path}/download').existsSync(),
        isFalse,
      );
    },
  );

  test('passes an HTTPS ZIP through the same repository pipeline', () async {
    final service = createService();

    await service.install(
      const SkillInstallationRequest(
        sourceType: SkillInstallSourceType.zipUrl,
        source: 'https://downloads.example.com/reviewer.zip',
      ),
      AgentCancellationToken(),
    );

    expect(fetchedUris.single.host, 'downloads.example.com');
    expect(repository.source?.kind, SkillImportKind.zipArchive);
    expect(
      repository.source?.sourceUri,
      'https://downloads.example.com/reviewer.zip',
    );
  });

  test('uses absolute local paths without bypassing SkillRepository', () async {
    final source = Directory('${temporaryDirectory.path}/local-skill');
    await source.create();
    final service = createService();

    await service.install(
      SkillInstallationRequest(
        sourceType: SkillInstallSourceType.localDirectory,
        source: source.path,
      ),
      AgentCancellationToken(),
    );

    expect(fetchedUris, isEmpty);
    expect(repository.source?.kind, SkillImportKind.directory);
    expect(repository.source?.path, source.path);
  });

  test('rejects ambiguous GitHub and relative local sources', () async {
    final service = createService();

    await expectLater(
      service.install(
        const SkillInstallationRequest(
          sourceType: SkillInstallSourceType.github,
          source: 'https://github.com/acme/repo/tree/main/skill',
        ),
        AgentCancellationToken(),
      ),
      throwsA(isA<SkillInstallException>()),
    );
    await expectLater(
      service.install(
        const SkillInstallationRequest(
          sourceType: SkillInstallSourceType.localZip,
          source: 'relative/skill.zip',
        ),
        AgentCancellationToken(),
      ),
      throwsA(isA<SkillInstallException>()),
    );
    expect(repository.source, isNull);
  });
}

final class _RecordingSkillRepository implements SkillRepository {
  SkillImportSource? source;

  @override
  Stream<List<SkillDescriptor>> get changes => const Stream.empty();

  @override
  Future<SkillDescriptor?> getById(String id) async => null;

  @override
  Future<List<SkillDescriptor>> getInstalled({
    bool forceRefresh = false,
  }) async => const [];

  @override
  Future<SkillDescriptor> install(SkillImportSource source) async {
    this.source = source;
    final now = DateTime(2026, 8, 9);
    return SkillDescriptor(
      id: 'user:installed',
      name: 'installed',
      description: 'Installed Skill.',
      version: '1.0.0',
      scope: SkillScope.user,
      sourceUri: source.sourceUri,
      rootPath: source.path,
      contentDigest: List.filled(64, 'b').join(),
      trustState: SkillTrustState.userReviewed,
      validationStatus: SkillValidationStatus.valid,
      compatibility: 'Hyve',
      installedAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<SkillContent> load(String skillId, {String? contentDigest}) =>
      throw UnimplementedError();

  @override
  Future<SkillResourceContent> readResource(
    String skillId,
    String relativePath, {
    String? contentDigest,
  }) => throw UnimplementedError();

  @override
  Future<void> uninstall(String skillId) => throw UnimplementedError();
}
