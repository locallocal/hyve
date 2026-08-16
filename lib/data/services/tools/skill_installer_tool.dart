import 'package:hyve/data/services/skills/skill_installation_service.dart';
import 'package:hyve/domain/models/models.dart';

final class SkillInstallerTool implements ExecutableTool {
  SkillInstallerTool({required SkillInstallationGateway installation})
    : _installation = installation;

  final SkillInstallationGateway _installation;

  @override
  final ToolDefinition definition = ToolDefinition(
    name: installSkillToolName,
    title: 'Install Skill',
    description:
        'Install one Hyve Skill from GitHub, an HTTPS ZIP URL, a local ZIP, '
        'or a local directory through the validated Skill installation pipeline.',
    inputSchema: const {
      'type': 'object',
      'properties': {
        'source_type': {
          'type': 'string',
          'enum': ['github', 'zip_url', 'local_zip', 'local_directory'],
        },
        'source': {'type': 'string', 'minLength': 1, 'maxLength': 4096},
        'ref': {'type': 'string', 'maxLength': 255},
        'subdirectory': {'type': 'string', 'maxLength': 1024},
        'archive_sha256': {'type': 'string', 'pattern': '^[A-Fa-f0-9]{64}\$'},
      },
      'required': ['source_type', 'source'],
      'additionalProperties': false,
    },
    outputSchema: const {
      'type': 'object',
      'properties': {
        'skill_id': {'type': 'string'},
        'name': {'type': 'string'},
        'version': {'type': 'string'},
        'description': {'type': 'string'},
        'source_uri': {'type': 'string'},
        'content_digest': {'type': 'string'},
        'trust_state': {'type': 'string'},
        'signature_status': {'type': 'string'},
        'validation_status': {'type': 'string'},
      },
      'required': [
        'skill_id',
        'name',
        'version',
        'description',
        'source_uri',
        'content_digest',
        'trust_state',
        'signature_status',
        'validation_status',
      ],
      'additionalProperties': false,
    },
    source: ToolSource.builtIn,
    riskLevel: ToolRiskLevel.destructive,
    capabilities: const {
      ToolCapability.localRead,
      ToolCapability.localWrite,
      ToolCapability.network,
      ToolCapability.externalRead,
    },
  );

  @override
  Future<ToolResult> execute(
    ToolCallRequest call,
    AgentCancellationToken cancellationToken,
  ) async {
    final sourceType = switch (call.arguments['source_type']) {
      'github' => SkillInstallSourceType.github,
      'zip_url' => SkillInstallSourceType.zipUrl,
      'local_zip' => SkillInstallSourceType.localZip,
      'local_directory' => SkillInstallSourceType.localDirectory,
      _ => null,
    };
    if (sourceType == null) {
      return _error(call, 'Skill 安装来源类型无效。', 'invalid_skill_source');
    }
    try {
      final installed = await _installation.install(
        SkillInstallationRequest(
          sourceType: sourceType,
          source: call.arguments['source']?.toString() ?? '',
          ref: call.arguments['ref']?.toString() ?? '',
          subdirectory: call.arguments['subdirectory']?.toString() ?? '',
          archiveSha256: call.arguments['archive_sha256']?.toString() ?? '',
        ),
        cancellationToken,
      );
      final structured = <String, Object?>{
        'skill_id': installed.id,
        'name': installed.name,
        'version': installed.version,
        'description': installed.description,
        'source_uri': installed.sourceUri,
        'content_digest': installed.contentDigest,
        'trust_state': installed.trustState.name,
        'signature_status': installed.signatureStatus.name,
        'validation_status': installed.validationStatus.name,
      };
      return ToolResult(
        callId: call.callId,
        name: call.name,
        content:
            'Installed Skill ${installed.name} ${installed.version} '
            '(${installed.id}).',
        structuredContent: structured,
      );
    } on AgentRunCancelledException {
      rethrow;
    } on SkillInstallException catch (error) {
      return _error(call, error.message, 'skill_install_rejected');
    } on Object {
      return _error(call, 'Skill 安装失败。', 'skill_install_failed');
    }
  }

  ToolResult _error(ToolCallRequest call, String message, String code) =>
      ToolResult(
        callId: call.callId,
        name: call.name,
        content: message,
        isError: true,
        errorCode: code,
      );
}
