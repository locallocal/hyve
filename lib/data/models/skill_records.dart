import 'dart:convert';

import 'package:stars/domain/models/models.dart';

final class SkillRecord {
  const SkillRecord(this.values);

  factory SkillRecord.fromDomain(SkillDescriptor skill) {
    return SkillRecord({
      'id': skill.id,
      'name': skill.name,
      'description': skill.description,
      'version': skill.version,
      'scope': skill.scope.name,
      'source_uri': skill.sourceUri,
      'root_path': skill.rootPath,
      'content_digest': skill.contentDigest,
      'trust_state': skill.trustState.name,
      'validation_status': skill.validationStatus.name,
      'compatibility': skill.compatibility,
      'requested_tools_json': jsonEncode(
        skill.requestedToolNames.toList()..sort(),
      ),
      'diagnostics_json': jsonEncode(
        skill.diagnostics.map((item) => item.toMap()).toList(),
      ),
      'has_scripts': skill.hasScripts ? 1 : 0,
      'has_references': skill.hasReferences ? 1 : 0,
      'has_assets': skill.hasAssets ? 1 : 0,
      'installed_at': skill.installedAt.millisecondsSinceEpoch,
      'updated_at': skill.updatedAt.millisecondsSinceEpoch,
    });
  }

  final Map<String, Object?> values;

  SkillDescriptor toDomain() {
    return SkillDescriptor(
      id: _text('id'),
      name: _text('name'),
      description: _text('description'),
      version: _text('version'),
      scope: _enumValue(SkillScope.values, _text('scope'), SkillScope.user),
      sourceUri: _text('source_uri'),
      rootPath: _text('root_path'),
      contentDigest: _text('content_digest'),
      trustState: _enumValue(
        SkillTrustState.values,
        _text('trust_state'),
        SkillTrustState.untrusted,
      ),
      validationStatus: _enumValue(
        SkillValidationStatus.values,
        _text('validation_status'),
        SkillValidationStatus.invalid,
      ),
      compatibility: _text('compatibility'),
      requestedToolNames: _decodeStringSet(_text('requested_tools_json')),
      diagnostics: _decodeDiagnostics(_text('diagnostics_json')),
      hasScripts: _integer('has_scripts') == 1,
      hasReferences: _integer('has_references') == 1,
      hasAssets: _integer('has_assets') == 1,
      installedAt: DateTime.fromMillisecondsSinceEpoch(
        _integer('installed_at'),
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(_integer('updated_at')),
    );
  }

  String _text(String key) => values[key]?.toString() ?? '';

  int _integer(String key) {
    final value = values[key];
    return switch (value) {
      final int number => number,
      final num number => number.toInt(),
      _ => int.tryParse(value?.toString() ?? '') ?? 0,
    };
  }
}

final class BotSkillBindingRecord {
  const BotSkillBindingRecord(this.values);

  factory BotSkillBindingRecord.fromDomain(BotSkillBinding binding) {
    return BotSkillBindingRecord({
      'bot_id': binding.botId,
      'skill_id': binding.skillId,
      'enabled': binding.enabled ? 1 : 0,
      'activation_mode': binding.activationMode.name,
      'priority': binding.priority,
      'created_at': binding.createdAt.millisecondsSinceEpoch,
      'updated_at': binding.updatedAt.millisecondsSinceEpoch,
    });
  }

  final Map<String, Object?> values;

  BotSkillBinding toDomain() {
    return BotSkillBinding(
      botId: values['bot_id']?.toString() ?? '',
      skillId: values['skill_id']?.toString() ?? '',
      enabled: _integer(values['enabled']) == 1,
      activationMode: _enumValue(
        SkillActivationMode.values,
        values['activation_mode']?.toString() ?? '',
        SkillActivationMode.manual,
      ),
      priority: _integer(values['priority']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        _integer(values['created_at']),
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        _integer(values['updated_at']),
      ),
    );
  }
}

final class SkillActivationDbRecord {
  const SkillActivationDbRecord(this.values);

  factory SkillActivationDbRecord.fromDomain(SkillActivationRecord record) {
    return SkillActivationDbRecord({
      'id': record.id,
      'run_id': record.runId,
      'chat_id': record.chatId,
      'message_id': record.messageId,
      'skill_id': record.skillId,
      'skill_name': record.skillName,
      'content_digest': record.contentDigest,
      'trigger_type': record.trigger.name,
      'status': record.status.name,
      'duration_ms': record.durationMs,
      'error_code': record.errorCode,
      'started_at': record.startedAt.millisecondsSinceEpoch,
      'completed_at': record.completedAt?.millisecondsSinceEpoch,
    });
  }

  final Map<String, Object?> values;

  SkillActivationRecord toDomain() {
    final completedAt = _nullableInteger(values['completed_at']);
    return SkillActivationRecord(
      id: values['id']?.toString() ?? '',
      runId: values['run_id']?.toString() ?? '',
      chatId: values['chat_id']?.toString() ?? '',
      messageId: values['message_id']?.toString() ?? '',
      skillId: values['skill_id']?.toString() ?? '',
      skillName: values['skill_name']?.toString() ?? '',
      contentDigest: values['content_digest']?.toString() ?? '',
      trigger: _enumValue(
        SkillActivationTrigger.values,
        values['trigger_type']?.toString() ?? '',
        SkillActivationTrigger.manual,
      ),
      status: _enumValue(
        SkillActivationStatus.values,
        values['status']?.toString() ?? '',
        SkillActivationStatus.failed,
      ),
      durationMs: _nullableInteger(values['duration_ms']),
      errorCode: values['error_code']?.toString() ?? '',
      startedAt: DateTime.fromMillisecondsSinceEpoch(
        _integer(values['started_at']),
      ),
      completedAt:
          completedAt == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(completedAt),
    );
  }
}

final class ConversationSkillPinRecord {
  const ConversationSkillPinRecord(this.values);

  factory ConversationSkillPinRecord.fromDomain(ConversationSkillPin pin) {
    return ConversationSkillPinRecord({
      'chat_id': pin.chatId,
      'skill_id': pin.skillId,
      'created_at': pin.createdAt.millisecondsSinceEpoch,
    });
  }

  final Map<String, Object?> values;

  ConversationSkillPin toDomain() {
    return ConversationSkillPin(
      chatId: values['chat_id']?.toString() ?? '',
      skillId: values['skill_id']?.toString() ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        _integer(values['created_at']),
      ),
    );
  }
}

T _enumValue<T extends Enum>(List<T> values, String name, T fallback) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}

int _integer(Object? value) => _nullableInteger(value) ?? 0;

int? _nullableInteger(Object? value) {
  return switch (value) {
    null => null,
    final int number => number,
    final num number => number.toInt(),
    _ => int.tryParse(value.toString()),
  };
}

Set<String> _decodeStringSet(String source) {
  try {
    final decoded = jsonDecode(source);
    if (decoded is List) {
      return decoded.whereType<String>().toSet();
    }
  } on FormatException {
    return const {};
  }
  return const {};
}

List<SkillDiagnostic> _decodeDiagnostics(String source) {
  try {
    final decoded = jsonDecode(source);
    if (decoded is List) {
      return decoded
          .whereType<Map<Object?, Object?>>()
          .map(
            (item) => SkillDiagnostic.fromMap(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList(growable: false);
    }
  } on FormatException {
    return const [];
  }
  return const [];
}
