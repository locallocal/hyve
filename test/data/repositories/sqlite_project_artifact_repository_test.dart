import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/data/repositories/file_project_storage_repository.dart';
import 'package:hyve/data/models/project_execution_records.dart';
import 'package:hyve/data/repositories/sqlite_agent_repository.dart';
import 'package:hyve/data/repositories/sqlite_project_artifact_repository.dart';
import 'package:hyve/data/repositories/sqlite_project_membership_repository.dart';
import 'package:hyve/data/repositories/sqlite_project_repository.dart';
import 'package:hyve/data/services/bot_api_key_cipher.dart';
import 'package:hyve/data/services/database_service.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/data/services/project_agent_storage_service.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database database;
  late Directory support;
  late ProjectAgentStorageService storageService;
  late FileProjectStorageRepository blobStorage;
  late SqliteAgentRepository agentRepository;
  late SqliteProjectRepository projectRepository;
  late SqliteProjectMembershipRepository membershipRepository;
  late SqliteProjectArtifactRepository artifactRepository;
  late ProjectMembership membership;
  var identity = 0;

  const user = ProjectArtifactActor(
    type: ProjectArtifactActorType.user,
    id: 'current-user',
    name: 'User',
  );
  const agent = ProjectArtifactActor(
    type: ProjectArtifactActorType.agent,
    id: 'agent-1',
    name: 'Researcher',
    sourceRunId: 'run-1',
  );

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DatabaseService.databaseVersion,
        onConfigure: DatabaseService.configure,
        onCreate: DatabaseService.createSchema,
      ),
    );
    support = await Directory.systemTemp.createTemp('hyve_phase_four_');
    final localDatabase = LocalDatabaseService(
      databaseProvider: () async => database,
    );
    storageService = ProjectAgentStorageService(
      supportDirectoryProvider: () async => support,
    );
    blobStorage = FileProjectStorageRepository(storage: storageService);
    agentRepository = SqliteAgentRepository(
      localDatabase: localDatabase,
      apiKeyCipher: const _Cipher(),
      storage: storageService,
    );
    projectRepository = SqliteProjectRepository(
      localDatabase: localDatabase,
      storage: storageService,
    );
    membershipRepository = SqliteProjectMembershipRepository(
      localDatabase: localDatabase,
    );
    artifactRepository = SqliteProjectArtifactRepository(
      localDatabase: localDatabase,
      storage: blobStorage,
      clock: () => DateTime(2026, 8, 22, 10),
      idFactory: (prefix) => '$prefix-${identity++}',
    );

    await agentRepository.addAgent(_agent());
    membership = ProjectMembership(
      projectId: 'project-1',
      agentId: 'agent-1',
      position: 0,
      joinedAt: DateTime(2026, 8, 22),
      updatedAt: DateTime(2026, 8, 22),
    );
    await projectRepository.addProjectWithMemberships(
      _project('project-1'),
      <ProjectMembership>[membership],
    );
    await projectRepository.addProject(_project('project-2'));
  });

  tearDown(() async {
    await agentRepository.dispose();
    await projectRepository.dispose();
    await membershipRepository.dispose();
    await database.close();
    await support.delete(recursive: true);
  });

  test('creates indexed immutable versions with auditable changes', () async {
    final created = await artifactRepository.create(
      projectId: 'project-1',
      relativePath: 'docs/plan.md',
      kind: ProjectArtifactKind.document,
      mimeType: 'text/markdown',
      bytes: Uint8List.fromList(utf8.encode('alpha launch plan')),
      actor: user,
    );

    final searchAlpha = await artifactRepository.search(
      projectId: 'project-1',
      actor: user,
      query: ProjectArtifactQuery(text: 'alpha'),
    );
    expect(searchAlpha, hasLength(1));
    expect(searchAlpha.single.snippet, contains('alpha'));

    final updated = await artifactRepository.writeVersion(
      projectId: 'project-1',
      artifactId: created.artifact.id,
      bytes: Uint8List.fromList(utf8.encode('beta launch plan')),
      actor: user,
      expectedCurrentVersionId: created.version.id,
    );

    expect(updated.version.versionNumber, 2);
    expect(updated.version.id, isNot(created.version.id));
    expect(
      utf8.decode(
        (await artifactRepository.read(
          projectId: 'project-1',
          artifactId: created.artifact.id,
          versionId: created.version.id,
          actor: user,
        )).bytes,
      ),
      'alpha launch plan',
    );
    expect(
      utf8.decode(
        (await artifactRepository.read(
          projectId: 'project-1',
          artifactId: created.artifact.id,
          actor: user,
        )).bytes,
      ),
      'beta launch plan',
    );
    expect(
      (await artifactRepository.versions(
        projectId: 'project-1',
        artifactId: created.artifact.id,
        actor: user,
      )).map((version) => version.versionNumber),
      <int>[2, 1],
    );
    expect(
      await artifactRepository.search(
        projectId: 'project-1',
        actor: user,
        query: ProjectArtifactQuery(text: 'alpha'),
      ),
      isEmpty,
    );
    expect(
      await artifactRepository.search(
        projectId: 'project-1',
        actor: user,
        query: ProjectArtifactQuery(text: 'beta'),
      ),
      hasLength(1),
    );

    final events = await database.query(
      'project_events',
      orderBy: 'sequence ASC',
    );
    expect(events, hasLength(2));
    expect(
      events.map((event) => event['event_type']),
      everyElement(ProjectEventType.projectArtifactChanged.name),
    );
    expect(
      events.map((event) => event['message_sequence']),
      everyElement(null),
    );
    expect(
      await File(
        path.join(
          support.path,
          'projects',
          'project-1',
          path.fromUri(created.version.relativeBlobPath),
        ),
      ).readAsString(),
      'alpha launch plan',
    );
  });

  test('rechecks live membership read and write permissions', () async {
    await expectLater(
      artifactRepository.create(
        projectId: 'project-1',
        relativePath: 'agent/blocked.md',
        kind: ProjectArtifactKind.document,
        mimeType: 'text/markdown',
        bytes: Uint8List.fromList(utf8.encode('blocked')),
        actor: agent,
      ),
      throwsA(_failure('artifact_write_forbidden')),
    );

    membership = membership.copyWith(
      projectStorageAccess: ProjectStorageAccess.readWrite,
      updatedAt: DateTime(2026, 8, 22, 10, 1),
    );
    await membershipRepository.save(membership);
    final created = await artifactRepository.create(
      projectId: 'project-1',
      relativePath: 'agent/report.md',
      kind: ProjectArtifactKind.document,
      mimeType: 'text/markdown',
      bytes: Uint8List.fromList(utf8.encode('first')),
      actor: agent,
    );

    membership = membership.copyWith(
      projectStorageAccess: ProjectStorageAccess.read,
      updatedAt: DateTime(2026, 8, 22, 10, 2),
    );
    await membershipRepository.save(membership);
    await expectLater(
      artifactRepository.writeVersion(
        projectId: 'project-1',
        artifactId: created.artifact.id,
        bytes: Uint8List.fromList(utf8.encode('second')),
        actor: agent,
        expectedCurrentVersionId: created.version.id,
      ),
      throwsA(_failure('artifact_write_forbidden')),
    );

    membership = membership.copyWith(
      projectStorageAccess: ProjectStorageAccess.none,
      updatedAt: DateTime(2026, 8, 22, 10, 3),
    );
    await membershipRepository.save(membership);
    await expectLater(
      artifactRepository.list(projectId: 'project-1', actor: agent),
      throwsA(_failure('artifact_read_forbidden')),
    );
  });

  test(
    'isolates project scope and cleans blobs after database conflict',
    () async {
      final created = await artifactRepository.create(
        projectId: 'project-1',
        relativePath: 'docs/unique.md',
        kind: ProjectArtifactKind.document,
        mimeType: 'text/markdown',
        bytes: Uint8List.fromList(utf8.encode('one')),
        actor: user,
      );

      expect(
        await artifactRepository.get(
          projectId: 'project-2',
          artifactId: created.artifact.id,
          actor: user,
        ),
        isNull,
      );
      await expectLater(
        artifactRepository.create(
          projectId: 'project-1',
          relativePath: '../escape.md',
          kind: ProjectArtifactKind.document,
          mimeType: 'text/markdown',
          bytes: Uint8List.fromList(utf8.encode('escape')),
          actor: user,
        ),
        throwsA(_failure('artifact_path_invalid')),
      );
      await expectLater(
        artifactRepository.create(
          projectId: 'project-1',
          relativePath: 'docs/unique.md',
          kind: ProjectArtifactKind.document,
          mimeType: 'text/markdown',
          bytes: Uint8List.fromList(utf8.encode('conflict')),
          actor: user,
        ),
        throwsA(_failure('artifact_path_conflict')),
      );

      expect(
        Directory(
          path.join(
            support.path,
            'projects',
            'project-1',
            'artifacts',
            'blobs',
            'artifact-2',
          ),
        ).existsSync(),
        isFalse,
      );
    },
  );

  test('rejects symlink imports and oversize writes', () async {
    final source = File(path.join(support.path, 'source.txt'));
    await source.writeAsString('source');
    final link = Link(path.join(support.path, 'source-link.txt'));
    await link.create(source.path);

    await expectLater(
      artifactRepository.import(
        projectId: 'project-1',
        sourcePath: link.path,
        relativePath: 'imports/source.txt',
        kind: ProjectArtifactKind.document,
        mimeType: 'text/plain',
        actor: user,
      ),
      throwsA(_failure('artifact_source_symlink_rejected')),
    );

    final boundedStorage = FileProjectStorageRepository(
      storage: storageService,
      maxBlobBytes: 3,
    );
    await expectLater(
      boundedStorage.writeBytes(
        projectId: 'project-1',
        artifactId: 'bounded-artifact',
        versionId: 'bounded-version',
        bytes: Uint8List.fromList(<int>[1, 2, 3, 4]),
        mimeType: 'application/octet-stream',
      ),
      throwsA(_failure('artifact_size_limit_exceeded')),
    );
  });

  test('prevents deletion after a fixed version is referenced', () async {
    final created = await artifactRepository.create(
      projectId: 'project-1',
      relativePath: 'docs/referenced.md',
      kind: ProjectArtifactKind.document,
      mimeType: 'text/markdown',
      bytes: Uint8List.fromList(utf8.encode('referenced')),
      actor: user,
    );
    final message = ProjectEvent(
      id: 'reference-message',
      projectId: 'project-1',
      sequence: 2,
      messageSequence: 1,
      eventType: ProjectEventType.userMessage,
      actorType: ProjectEventActorType.user,
      actorId: 'current-user',
      actorNameSnapshot: 'User',
      content: 'Use the referenced artifact',
      payload: ProjectMessagePayload(
        projectArtifactVersionIds: <String>[created.version.id],
      ),
      createdAt: DateTime(2026, 8, 22, 10, 1),
      updatedAt: DateTime(2026, 8, 22, 10, 1),
    );
    await database.insert(
      'project_events',
      ProjectEventRecord.fromDomain(message).values,
    );
    await database.insert('project_event_artifacts', <String, Object?>{
      'event_id': message.id,
      'artifact_id': created.artifact.id,
      'artifact_version_id': created.version.id,
      'relation': 'attachment',
      'position': 0,
    });
    final references = await artifactRepository.messageReferences(
      projectId: 'project-1',
      artifactId: created.artifact.id,
      versionId: created.version.id,
      actor: user,
    );
    expect(references, hasLength(1));
    expect(references.single.eventId, message.id);
    expect(references.single.messageSequence, 1);
    expect(references.single.content, 'Use the referenced artifact');

    await expectLater(
      artifactRepository.delete(
        projectId: 'project-1',
        artifactId: created.artifact.id,
        actor: user,
      ),
      throwsA(_failure('artifact_is_referenced')),
    );
  });

  test('recovers or commits project deletion staging after a crash', () async {
    const liveId = 'live-project-with-hyphen';
    const deletedId = 'deleted-project';
    await storageService.ensureProjectRoot(liveId);
    await storageService.ensureProjectRoot(deletedId);
    final liveMarker = File(
      path.join(support.path, 'projects', liveId, 'audit', 'marker'),
    );
    await liveMarker.writeAsString('keep');
    await storageService.stageProjectDeletion(liveId);
    await storageService.stageProjectDeletion(deletedId);

    await storageService.recoverPendingProjectDeletions(<String>{liveId});

    expect(liveMarker.existsSync(), isTrue);
    expect(
      Directory(path.join(support.path, 'projects', deletedId)).existsSync(),
      isFalse,
    );
    expect(
      Directory(path.join(support.path, '.pending_deletions')).existsSync(),
      isFalse,
    );
  });
}

Matcher _failure(String code) => isA<ProjectArtifactFailure>().having(
  (failure) => failure.code,
  'code',
  code,
);

Agent _agent() => Agent(
  id: 'agent-1',
  name: 'Researcher',
  avatar: '',
  provider: 'test',
  baseUrl: '',
  apiKey: 'secret',
  apiType: Bot.apiTypeOpenAI,
  model: 'model',
  systemPrompt: 'help',
  createdAt: DateTime(2026, 8, 22),
  updatedAt: DateTime(2026, 8, 22),
);

Project _project(String id) => Project(
  id: id,
  name: id,
  lastMessageAt: DateTime(2026, 8, 22),
  createdAt: DateTime(2026, 8, 22),
  updatedAt: DateTime(2026, 8, 22),
);

final class _Cipher implements BotApiKeyCipher {
  const _Cipher();

  @override
  bool isEncrypted(String value) => value.startsWith('encrypted:');

  @override
  Future<String> encrypt({
    required String botId,
    required String apiKey,
  }) async => apiKey.isEmpty ? '' : 'encrypted:$apiKey';

  @override
  Future<String> decrypt({
    required String botId,
    required String encrypted,
  }) async => encrypted.substring('encrypted:'.length);
}
