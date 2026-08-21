import 'dart:convert';
import 'dart:typed_data';

import 'package:hyve/data/repositories/sqlite_project_artifact_repository.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/project_artifact_repository.dart';

abstract final class ProjectArtifactToolNames {
  static const search = 'project.artifacts.search';
  static const list = 'project.artifacts.list';
  static const stat = 'project.artifacts.stat';
  static const read = 'project.artifacts.read';
  static const create = 'project.artifacts.create';
  static const writeVersion = 'project.artifacts.write_version';
  static const move = 'project.artifacts.move';
  static const delete = 'project.artifacts.delete';

  static const readOnly = <String>{search, list, stat, read};
  static const write = <String>{create, writeVersion};
  static const destructive = <String>{move, delete};
  static const all = <String>{...readOnly, ...write, ...destructive};
}

final class ProjectArtifactToolSet {
  ProjectArtifactToolSet({
    required ProjectArtifactRepository repository,
    required String projectId,
    required ProjectArtifactActor actor,
    required ProjectStorageAccess access,
  }) : tools = List<ExecutableTool>.unmodifiable(
         access == ProjectStorageAccess.none
             ? const <ExecutableTool>[]
             : <ExecutableTool>[
               _ProjectArtifactTool(
                 name: ProjectArtifactToolNames.search,
                 repository: repository,
                 projectId: projectId,
                 actor: actor,
               ),
               _ProjectArtifactTool(
                 name: ProjectArtifactToolNames.list,
                 repository: repository,
                 projectId: projectId,
                 actor: actor,
               ),
               _ProjectArtifactTool(
                 name: ProjectArtifactToolNames.stat,
                 repository: repository,
                 projectId: projectId,
                 actor: actor,
               ),
               _ProjectArtifactTool(
                 name: ProjectArtifactToolNames.read,
                 repository: repository,
                 projectId: projectId,
                 actor: actor,
               ),
               if (access ==
                   ProjectStorageAccess.readWrite) ...<ExecutableTool>[
                 _ProjectArtifactTool(
                   name: ProjectArtifactToolNames.create,
                   repository: repository,
                   projectId: projectId,
                   actor: actor,
                 ),
                 _ProjectArtifactTool(
                   name: ProjectArtifactToolNames.writeVersion,
                   repository: repository,
                   projectId: projectId,
                   actor: actor,
                 ),
                 _ProjectArtifactTool(
                   name: ProjectArtifactToolNames.move,
                   repository: repository,
                   projectId: projectId,
                   actor: actor,
                 ),
                 _ProjectArtifactTool(
                   name: ProjectArtifactToolNames.delete,
                   repository: repository,
                   projectId: projectId,
                   actor: actor,
                 ),
               ],
             ],
       );

  final List<ExecutableTool> tools;
}

final class _ProjectArtifactTool implements ExecutableTool {
  const _ProjectArtifactTool({
    required String name,
    required ProjectArtifactRepository repository,
    required String projectId,
    required ProjectArtifactActor actor,
  }) : _name = name,
       _repository = repository,
       _projectId = projectId,
       _actor = actor;

  final String _name;
  final ProjectArtifactRepository _repository;
  final String _projectId;
  final ProjectArtifactActor _actor;

  @override
  ToolDefinition get definition => ToolDefinition(
    name: _name,
    title: _title,
    description: _description,
    inputSchema: _inputSchema,
    outputSchema: const <String, Object?>{'type': 'object'},
    source: ToolSource.builtIn,
    riskLevel:
        ProjectArtifactToolNames.destructive.contains(_name)
            ? ToolRiskLevel.destructive
            : ProjectArtifactToolNames.write.contains(_name)
            ? ToolRiskLevel.write
            : ToolRiskLevel.readOnly,
    capabilities: <ToolCapability>{
      ProjectArtifactToolNames.readOnly.contains(_name)
          ? ToolCapability.localRead
          : ToolCapability.localWrite,
    },
  );

  String get _title => switch (_name) {
    ProjectArtifactToolNames.search => 'Search project artifacts',
    ProjectArtifactToolNames.list => 'List project artifacts',
    ProjectArtifactToolNames.stat => 'Inspect project artifact',
    ProjectArtifactToolNames.read => 'Read project artifact',
    ProjectArtifactToolNames.create => 'Create project artifact',
    ProjectArtifactToolNames.writeVersion => 'Write artifact version',
    ProjectArtifactToolNames.move => 'Move project artifact',
    ProjectArtifactToolNames.delete => 'Delete project artifact',
    _ => 'Project artifact',
  };

  String get _description => switch (_name) {
    ProjectArtifactToolNames.search =>
      'Search the current project artifact index by text and optional kind.',
    ProjectArtifactToolNames.list =>
      'List small metadata records for artifacts in the current project.',
    ProjectArtifactToolNames.stat =>
      'Read metadata and the immutable current version identity.',
    ProjectArtifactToolNames.read =>
      'Read one bounded chunk from a fixed or current artifact version.',
    ProjectArtifactToolNames.create =>
      'Create a new immutable project artifact from UTF-8 or base64 content.',
    ProjectArtifactToolNames.writeVersion =>
      'Create a new immutable version without deleting version history.',
    ProjectArtifactToolNames.move =>
      'Rename or move an artifact logical path. Requires approval.',
    ProjectArtifactToolNames.delete =>
      'Delete an unreferenced artifact and all versions. Requires approval.',
    _ => '',
  };

  Map<String, Object?> get _inputSchema => switch (_name) {
    ProjectArtifactToolNames.search => const <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'query': <String, Object?>{'type': 'string', 'maxLength': 512},
        'kind': <String, Object?>{
          'type': 'string',
          'enum': <String>[
            'attachment',
            'document',
            'code',
            'image',
            'audio',
            'video',
            'dataset',
            'archive',
            'generated',
            'other',
          ],
        },
        'limit': <String, Object?>{
          'type': 'integer',
          'minimum': 1,
          'maximum': 50,
          'default': 10,
        },
      },
      'required': <String>['query'],
      'additionalProperties': false,
    },
    ProjectArtifactToolNames.list => const <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'limit': <String, Object?>{
          'type': 'integer',
          'minimum': 1,
          'maximum': 50,
          'default': 20,
        },
      },
      'additionalProperties': false,
    },
    ProjectArtifactToolNames.stat => _artifactIdSchema,
    ProjectArtifactToolNames.read => const <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'artifactId': <String, Object?>{'type': 'string', 'minLength': 1},
        'versionId': <String, Object?>{'type': 'string'},
        'offset': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'default': 0,
        },
        'length': <String, Object?>{
          'type': 'integer',
          'minimum': 1,
          'maximum': 32768,
          'default': 8192,
        },
      },
      'required': <String>['artifactId'],
      'additionalProperties': false,
    },
    ProjectArtifactToolNames.create => _writeSchema(create: true),
    ProjectArtifactToolNames.writeVersion => _writeSchema(create: false),
    ProjectArtifactToolNames.move => const <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'artifactId': <String, Object?>{'type': 'string', 'minLength': 1},
        'relativePath': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 512,
        },
      },
      'required': <String>['artifactId', 'relativePath'],
      'additionalProperties': false,
    },
    ProjectArtifactToolNames.delete => _artifactIdSchema,
    _ => const <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
    },
  };

  static const _artifactIdSchema = <String, Object?>{
    'type': 'object',
    'properties': <String, Object?>{
      'artifactId': <String, Object?>{'type': 'string', 'minLength': 1},
    },
    'required': <String>['artifactId'],
    'additionalProperties': false,
  };

  static Map<String, Object?> _writeSchema({required bool create}) {
    return <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        if (create)
          'relativePath': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 512,
          }
        else
          'artifactId': <String, Object?>{'type': 'string', 'minLength': 1},
        if (create)
          'kind': <String, Object?>{
            'type': 'string',
            'enum': <String>[
              'attachment',
              'document',
              'code',
              'image',
              'audio',
              'video',
              'dataset',
              'archive',
              'generated',
              'other',
            ],
          },
        'mimeType': <String, Object?>{'type': 'string', 'maxLength': 255},
        'encoding': <String, Object?>{
          'type': 'string',
          'enum': <String>['utf8', 'base64'],
          'default': 'utf8',
        },
        'content': <String, Object?>{'type': 'string', 'maxLength': 1400000},
        if (!create)
          'expectedCurrentVersionId': <String, Object?>{'type': 'string'},
        if (create) 'metadata': <String, Object?>{'type': 'object'},
      },
      'required': <String>[create ? 'relativePath' : 'artifactId', 'content'],
      'additionalProperties': false,
    };
  }

  @override
  Future<ToolResult> execute(
    ToolCallRequest call,
    AgentCancellationToken cancellationToken,
  ) async {
    cancellationToken.throwIfCancelled();
    try {
      final structured = await _execute(call.arguments);
      cancellationToken.throwIfCancelled();
      return ToolResult(
        callId: call.callId,
        name: call.name,
        content: jsonEncode(structured),
        structuredContent: structured,
      );
    } on AgentRunCancelledException {
      rethrow;
    } on ProjectArtifactFailure catch (failure) {
      return ToolResult(
        callId: call.callId,
        name: call.name,
        content: 'The project artifact operation was rejected.',
        isError: true,
        errorCode: failure.code,
      );
    } on FormatException {
      return ToolResult(
        callId: call.callId,
        name: call.name,
        content: 'The encoded artifact content is invalid.',
        isError: true,
        errorCode: 'artifact_content_encoding_invalid',
      );
    }
  }

  Future<Map<String, Object?>> _execute(Map<String, Object?> arguments) async {
    switch (_name) {
      case ProjectArtifactToolNames.search:
        final rawKind = arguments['kind'] as String?;
        final entries = await _repository.search(
          projectId: _projectId,
          actor: _actor,
          query: ProjectArtifactQuery(
            text: arguments['query']! as String,
            kinds:
                rawKind == null
                    ? const <ProjectArtifactKind>[]
                    : <ProjectArtifactKind>[
                      ProjectArtifactKind.values.byName(rawKind),
                    ],
            limit: arguments['limit'] as int? ?? 10,
          ),
        );
        return _entries(entries);
      case ProjectArtifactToolNames.list:
        return _entries(
          await _repository.list(
            projectId: _projectId,
            actor: _actor,
            limit: arguments['limit'] as int? ?? 20,
          ),
        );
      case ProjectArtifactToolNames.stat:
        final entry = await _requiredEntry(arguments['artifactId']! as String);
        final history = await _repository.versions(
          projectId: _projectId,
          artifactId: entry.artifact.id,
          actor: _actor,
        );
        return <String, Object?>{
          'artifact': _entry(entry),
          'versionCount': history.length,
          'versions': history.take(20).map(_version).toList(growable: false),
        };
      case ProjectArtifactToolNames.read:
        final result = await _repository.read(
          projectId: _projectId,
          artifactId: arguments['artifactId']! as String,
          versionId: arguments['versionId'] as String? ?? '',
          actor: _actor,
          offset: arguments['offset'] as int? ?? 0,
          length: arguments['length'] as int? ?? 8192,
        );
        return <String, Object?>{
          'artifactId': result.artifact.id,
          'versionId': result.version.id,
          'offset': result.offset,
          'nextOffset': result.nextOffset,
          'endOfFile': result.endOfFile,
          'encoding': result.text == null ? 'base64' : 'utf8',
          'content': result.text ?? base64Encode(result.bytes),
        };
      case ProjectArtifactToolNames.create:
        final relativePath = arguments['relativePath']! as String;
        final mutation = await _repository.create(
          projectId: _projectId,
          relativePath: relativePath,
          kind:
              arguments['kind'] == null
                  ? projectArtifactKindForPath(relativePath)
                  : ProjectArtifactKind.values.byName(
                    arguments['kind']! as String,
                  ),
          mimeType:
              arguments['mimeType'] as String? ??
              projectArtifactMimeTypeForPath(relativePath),
          bytes: _contentBytes(arguments),
          actor: _actor,
          metadata: _metadata(arguments['metadata']),
        );
        return _mutation(mutation);
      case ProjectArtifactToolNames.writeVersion:
        final mutation = await _repository.writeVersion(
          projectId: _projectId,
          artifactId: arguments['artifactId']! as String,
          bytes: _contentBytes(arguments),
          actor: _actor,
          mimeType: arguments['mimeType'] as String? ?? '',
          expectedCurrentVersionId:
              arguments['expectedCurrentVersionId'] as String? ?? '',
        );
        return _mutation(mutation);
      case ProjectArtifactToolNames.move:
        final mutation = await _repository.move(
          projectId: _projectId,
          artifactId: arguments['artifactId']! as String,
          relativePath: arguments['relativePath']! as String,
          actor: _actor,
        );
        return _mutation(mutation);
      case ProjectArtifactToolNames.delete:
        final artifactId = arguments['artifactId']! as String;
        await _repository.delete(
          projectId: _projectId,
          artifactId: artifactId,
          actor: _actor,
        );
        return <String, Object?>{'artifactId': artifactId, 'deleted': true};
      default:
        throw const ProjectArtifactFailure('artifact_tool_unknown');
    }
  }

  Future<ProjectArtifactEntry> _requiredEntry(String artifactId) async {
    final entry = await _repository.get(
      projectId: _projectId,
      artifactId: artifactId,
      actor: _actor,
    );
    if (entry == null) {
      throw const ProjectArtifactFailure('artifact_not_found');
    }
    return entry;
  }

  static Uint8List _contentBytes(Map<String, Object?> arguments) {
    final content = arguments['content']! as String;
    return Uint8List.fromList(
      arguments['encoding'] == 'base64'
          ? base64Decode(content)
          : utf8.encode(content),
    );
  }

  static Map<String, Object?> _metadata(Object? raw) {
    if (raw == null) return const <String, Object?>{};
    return Map<String, Object?>.from(raw as Map<Object?, Object?>);
  }

  static Map<String, Object?> _entries(List<ProjectArtifactEntry> entries) {
    return <String, Object?>{
      'count': entries.length,
      'artifacts': entries.map(_entry).toList(growable: false),
    };
  }

  static Map<String, Object?> _entry(ProjectArtifactEntry entry) {
    return <String, Object?>{
      'id': entry.artifact.id,
      'name': entry.artifact.name,
      'relativePath': entry.artifact.relativePath,
      'kind': entry.artifact.kind.name,
      'mimeType': entry.artifact.mimeType,
      'searchStatus': entry.artifact.searchStatus.name,
      'currentVersion': _version(entry.currentVersion),
      'snippet': entry.snippet,
      'updatedAt': entry.artifact.updatedAt.toUtc().toIso8601String(),
    };
  }

  static Map<String, Object?> _version(ProjectArtifactVersion version) {
    return <String, Object?>{
      'id': version.id,
      'versionNumber': version.versionNumber,
      'contentDigest': version.contentDigest,
      'byteLength': version.byteLength,
      'mimeType': version.mimeType,
      'createdAt': version.createdAt.toUtc().toIso8601String(),
    };
  }

  static Map<String, Object?> _mutation(ProjectArtifactMutationResult result) {
    return <String, Object?>{
      'artifactId': result.artifact.id,
      'versionId': result.version.id,
      'versionNumber': result.version.versionNumber,
      'relativePath': result.artifact.relativePath,
      'contentDigest': result.version.contentDigest,
      'byteLength': result.version.byteLength,
      'auditEventId': result.auditEventId,
    };
  }
}
