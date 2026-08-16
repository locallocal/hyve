import 'dart:convert';

import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/skill_ecosystem_repository.dart';
import 'package:hyve/domain/repositories/skill_script_sandbox.dart';

final class SkillScriptTool implements ExecutableTool {
  SkillScriptTool({
    required SkillDescriptor skill,
    required SkillScriptToolManifest manifest,
    required SkillScriptSandbox sandbox,
    required Future<bool> Function() authorizationCheck,
    SkillEcosystemRepository? ecosystemRepository,
  }) : _skill = skill,
       _manifest = manifest,
       _sandbox = sandbox,
       _authorizationCheck = authorizationCheck,
       _ecosystemRepository = ecosystemRepository,
       definition = ToolDefinition(
         name: manifest.name,
         title: manifest.title,
         description: manifest.description,
         inputSchema: manifest.inputSchema,
         outputSchema: manifest.outputSchema,
         source: ToolSource.skillScript,
         riskLevel: manifest.riskLevel,
         capabilities: manifest.capabilities,
       );

  final SkillDescriptor _skill;
  final SkillScriptToolManifest _manifest;
  final SkillScriptSandbox _sandbox;
  final Future<bool> Function() _authorizationCheck;
  final SkillEcosystemRepository? _ecosystemRepository;

  @override
  final ToolDefinition definition;

  @override
  Future<ToolResult> execute(
    ToolCallRequest call,
    AgentCancellationToken cancellationToken,
  ) async {
    try {
      if (!await _authorizationCheck()) {
        await _audit(
          'deny',
          'skill_script_authorization_revoked',
          Duration.zero,
        );
        return _error(
          call,
          'Skill script authorization is no longer valid.',
          'skill_script_authorization_revoked',
        );
      }
      final result = await _sandbox.execute(
        SkillScriptExecutionRequest(
          skillRootPath: _skill.rootPath,
          contentDigest: _skill.contentDigest,
          entry: _manifest.entry,
          interpreter: _manifest.interpreter,
          arguments: call.arguments,
        ),
        cancellationToken,
      );
      if (result.timedOut) {
        await _audit('deny', 'skill_script_timeout', result.duration);
        return _error(call, 'Skill script timed out.', 'skill_script_timeout');
      }
      if (result.outputTruncated) {
        await _audit('deny', 'skill_script_output_limit', result.duration);
        return _error(
          call,
          'Skill script output exceeded the limit.',
          'skill_script_output_limit',
        );
      }
      if (result.exitCode != 0) {
        await _audit('deny', 'skill_script_failed', result.duration);
        return _error(
          call,
          _redact(result.stderr.trim()).isEmpty
              ? 'Skill script failed.'
              : _redact(result.stderr.trim()),
          'skill_script_failed',
        );
      }

      var safeOutput = '';
      Object? structured;
      if (_manifest.outputSchema != null) {
        try {
          structured = _redactValue(jsonDecode(result.stdout.trim()));
          safeOutput = jsonEncode(structured);
        } on FormatException {
          await _audit('deny', 'skill_script_invalid_output', result.duration);
          return _error(
            call,
            'Skill script did not return valid JSON.',
            'skill_script_invalid_output',
          );
        }
      } else {
        safeOutput = _redact(result.stdout.trim());
      }
      await _audit('allow', '', result.duration);
      return ToolResult(
        callId: call.callId,
        name: call.name,
        content: safeOutput,
        structuredContent: structured,
      );
    } on AgentRunCancelledException {
      rethrow;
    } on Object {
      try {
        await _ecosystemRepository?.deleteScriptGrant(_skill.id);
      } on Object {
        // The current call still fails closed if grant persistence is down.
      }
      await _audit('deny', 'skill_script_sandbox_error', Duration.zero);
      return _error(
        call,
        'Skill script could not run in the sandbox.',
        'skill_script_sandbox_error',
      );
    }
  }

  ToolResult _error(ToolCallRequest call, String content, String code) {
    return ToolResult(
      callId: call.callId,
      name: call.name,
      content: content,
      isError: true,
      errorCode: code,
    );
  }

  String _redact(String value) {
    var redacted = value.replaceAll(
      RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'),
      '',
    );
    for (final pattern in [
      RegExp(
        r'''(authorization|cookie|password|secret|token|api[_-]?key)(["']?\s*[:=]\s*["']?)[^"'\s,;}]+''',
        caseSensitive: false,
      ),
      RegExp(r'\bsk-[A-Za-z0-9_-]{12,}\b'),
    ]) {
      redacted = redacted.replaceAllMapped(
        pattern,
        (match) =>
            match.groupCount >= 2
                ? '${match.group(1)}${match.group(2)}[redacted]'
                : '[redacted]',
      );
    }
    return redacted;
  }

  Object? _redactValue(Object? value, {String key = ''}) {
    const sensitiveFragments = <String>[
      'authorization',
      'cookie',
      'password',
      'secret',
      'token',
      'api_key',
      'apikey',
    ];
    if (sensitiveFragments.any(key.toLowerCase().contains)) {
      return '[redacted]';
    }
    if (value is Map) {
      return value.map(
        (itemKey, itemValue) => MapEntry(
          itemKey.toString(),
          _redactValue(itemValue, key: itemKey.toString()),
        ),
      );
    }
    if (value is List) {
      return value.map((item) => _redactValue(item)).toList();
    }
    if (value is String) return _redact(value);
    return value;
  }

  Future<void> _audit(String decision, String reason, Duration duration) async {
    final repository = _ecosystemRepository;
    if (repository == null) return;
    final now = DateTime.now();
    try {
      await repository.appendComplianceEvent(
        SkillComplianceEvent(
          id: '${now.microsecondsSinceEpoch}:script:${_skill.id}',
          type:
              decision == 'allow'
                  ? SkillComplianceEventType.scriptExecuted
                  : SkillComplianceEventType.scriptRejected,
          skillId: _skill.id,
          contentDigest: _skill.contentDigest,
          publisherId: _skill.publisherId,
          decision: decision,
          reason: reason,
          metadata: {
            'tool': definition.name,
            'durationMs': duration.inMilliseconds,
          },
          timestamp: now,
        ),
      );
    } on Object {
      // The execution result remains authoritative if local audit I/O fails.
    }
  }
}
