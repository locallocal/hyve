import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/data/services/tools/project_artifact_tools.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/project_artifact_repository.dart';

void main() {
  const actor = ProjectArtifactActor(
    type: ProjectArtifactActorType.agent,
    id: 'agent-1',
    name: 'Agent',
    sourceRunId: 'run-1',
  );

  test('exposes tools strictly from the membership storage access', () {
    final repository = _FakeArtifactRepository();

    expect(
      ProjectArtifactToolSet(
        repository: repository,
        projectId: 'project-1',
        actor: actor,
        access: ProjectStorageAccess.none,
      ).tools,
      isEmpty,
    );

    final readTools =
        ProjectArtifactToolSet(
          repository: repository,
          projectId: 'project-1',
          actor: actor,
          access: ProjectStorageAccess.read,
        ).tools;
    expect(
      readTools.map((tool) => tool.definition.name).toSet(),
      ProjectArtifactToolNames.readOnly,
    );
    expect(
      readTools.map((tool) => tool.definition.riskLevel),
      everyElement(ToolRiskLevel.readOnly),
    );

    final writeTools =
        ProjectArtifactToolSet(
          repository: repository,
          projectId: 'project-1',
          actor: actor,
          access: ProjectStorageAccess.readWrite,
        ).tools;
    expect(
      writeTools.map((tool) => tool.definition.name).toSet(),
      ProjectArtifactToolNames.all,
    );
    expect(
      writeTools
          .where(
            (tool) => ProjectArtifactToolNames.destructive.contains(
              tool.definition.name,
            ),
          )
          .map((tool) => tool.definition.riskLevel),
      everyElement(ToolRiskLevel.destructive),
    );
  });

  test(
    'create uses trusted scope and returns stable audit identities',
    () async {
      final repository = _FakeArtifactRepository();
      final tool = ProjectArtifactToolSet(
        repository: repository,
        projectId: 'project-1',
        actor: actor,
        access: ProjectStorageAccess.readWrite,
      ).tools.singleWhere(
        (tool) => tool.definition.name == ProjectArtifactToolNames.create,
      );

      final result = await tool.execute(
        ToolCallRequest(
          callId: 'call-1',
          name: ProjectArtifactToolNames.create,
          arguments: const <String, Object?>{
            'relativePath': 'reports/result.md',
            'kind': 'document',
            'content': 'verified result',
            'metadata': <String, Object?>{'label': 'final'},
          },
        ),
        AgentCancellationToken(),
      );

      expect(result.isError, isFalse);
      expect(repository.lastProjectId, 'project-1');
      expect(repository.lastActor?.id, 'agent-1');
      expect(repository.lastPath, 'reports/result.md');
      expect(String.fromCharCodes(repository.lastBytes), 'verified result');
      expect(
        result.structuredContent,
        containsPair('artifactId', 'artifact-1'),
      );
      expect(result.structuredContent, containsPair('versionId', 'version-1'));
      expect(result.structuredContent, containsPair('auditEventId', 'event-1'));
    },
  );

  test(
    'read is bounded and maps repository rejection to stable errors',
    () async {
      final repository = _FakeArtifactRepository();
      final tool = ProjectArtifactToolSet(
        repository: repository,
        projectId: 'project-1',
        actor: actor,
        access: ProjectStorageAccess.read,
      ).tools.singleWhere(
        (tool) => tool.definition.name == ProjectArtifactToolNames.read,
      );

      final result = await tool.execute(
        ToolCallRequest(
          callId: 'call-2',
          name: ProjectArtifactToolNames.read,
          arguments: const <String, Object?>{
            'artifactId': 'artifact-1',
            'versionId': 'version-1',
            'offset': 4,
            'length': 16,
          },
        ),
        AgentCancellationToken(),
      );

      expect(result.structuredContent, containsPair('content', 'chunk'));
      expect(repository.lastOffset, 4);
      expect(repository.lastLength, 16);

      repository.failure = const ProjectArtifactFailure(
        'artifact_read_forbidden',
      );
      final denied = await tool.execute(
        ToolCallRequest(
          callId: 'call-3',
          name: ProjectArtifactToolNames.read,
          arguments: const <String, Object?>{'artifactId': 'artifact-1'},
        ),
        AgentCancellationToken(),
      );
      expect(denied.isError, isTrue);
      expect(denied.errorCode, 'artifact_read_forbidden');
    },
  );
}

final class _FakeArtifactRepository implements ProjectArtifactRepository {
  String lastProjectId = '';
  String lastPath = '';
  ProjectArtifactActor? lastActor;
  Uint8List lastBytes = Uint8List(0);
  int lastOffset = 0;
  int lastLength = 0;
  ProjectArtifactFailure? failure;

  final ProjectArtifact artifact = ProjectArtifact(
    id: 'artifact-1',
    projectId: 'project-1',
    name: 'result.md',
    relativePath: 'reports/result.md',
    kind: ProjectArtifactKind.document,
    mimeType: 'text/markdown',
    currentVersionId: 'version-1',
    searchStatus: ProjectArtifactSearchStatus.indexed,
    createdByType: ProjectArtifactActorType.agent,
    createdById: 'agent-1',
    sourceRunId: 'run-1',
    createdAt: DateTime(2026, 8, 22),
    updatedAt: DateTime(2026, 8, 22),
  );

  final ProjectArtifactVersion version = ProjectArtifactVersion(
    id: 'version-1',
    artifactId: 'artifact-1',
    versionNumber: 1,
    relativeBlobPath: 'artifacts/blobs/artifact-1/version-1/content',
    contentDigest:
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    byteLength: 15,
    mimeType: 'text/markdown',
    createdByType: ProjectArtifactActorType.agent,
    createdById: 'agent-1',
    sourceRunId: 'run-1',
    createdAt: DateTime(2026, 8, 22),
  );

  @override
  Stream<String> get changes => const Stream<String>.empty();

  @override
  Future<ProjectArtifactMutationResult> create({
    required String projectId,
    required String relativePath,
    required ProjectArtifactKind kind,
    required String mimeType,
    required Uint8List bytes,
    required ProjectArtifactActor actor,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) async {
    lastProjectId = projectId;
    lastPath = relativePath;
    lastActor = actor;
    lastBytes = bytes;
    return ProjectArtifactMutationResult(
      artifact: artifact,
      version: version,
      auditEventId: 'event-1',
    );
  }

  @override
  Future<ProjectArtifactReadResult> read({
    required String projectId,
    required String artifactId,
    String versionId = '',
    required ProjectArtifactActor actor,
    int offset = 0,
    int length = 8192,
  }) async {
    final rejection = failure;
    if (rejection != null) throw rejection;
    lastProjectId = projectId;
    lastActor = actor;
    lastOffset = offset;
    lastLength = length;
    return ProjectArtifactReadResult(
      artifact: artifact,
      version: version,
      bytes: Uint8List.fromList('chunk'.codeUnits),
      offset: offset,
      nextOffset: offset + 5,
      endOfFile: true,
      text: 'chunk',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
