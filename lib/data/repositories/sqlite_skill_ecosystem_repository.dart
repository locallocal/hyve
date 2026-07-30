import 'dart:convert';

import 'package:stars/data/services/local_database_service.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/skill_ecosystem_repository.dart';

final class SqliteSkillEcosystemRepository implements SkillEcosystemRepository {
  const SqliteSkillEcosystemRepository({
    required LocalDatabaseService localDatabase,
  }) : _localDatabase = localDatabase;

  final LocalDatabaseService _localDatabase;

  @override
  Future<SkillOrganizationPolicy> getOrganizationPolicy() async {
    final rows = await _localDatabase.loadSkillOrganizationPolicy();
    if (rows.isEmpty) return SkillOrganizationPolicy.defaults;
    final row = rows.single;
    return SkillOrganizationPolicy(
      allowUnsignedSkills: _bool(row['allow_unsigned_skills'], true),
      allowUnknownPublishers: _bool(row['allow_unknown_publishers'], false),
      allowScriptExecution: _bool(row['allow_script_execution'], true),
      allowAutomaticUpdates: _bool(row['allow_automatic_updates'], false),
      allowedPublisherIds: _stringSet(row['allowed_publishers_json']),
      updatedAt: _date(row['updated_at']),
    );
  }

  @override
  Future<void> saveOrganizationPolicy(SkillOrganizationPolicy policy) {
    return _localDatabase.saveSkillOrganizationPolicy({
      'allow_unsigned_skills': policy.allowUnsignedSkills ? 1 : 0,
      'allow_unknown_publishers': policy.allowUnknownPublishers ? 1 : 0,
      'allow_script_execution': policy.allowScriptExecution ? 1 : 0,
      'allow_automatic_updates': policy.allowAutomaticUpdates ? 1 : 0,
      'allowed_publishers_json': jsonEncode(
        policy.allowedPublisherIds.toList()..sort(),
      ),
      'updated_at': (policy.updatedAt ?? DateTime.now()).millisecondsSinceEpoch,
    });
  }

  @override
  Future<List<SkillPublisher>> getPublishers() async {
    final rows = await _localDatabase.loadSkillPublishers();
    return List.unmodifiable(rows.map(_publisher));
  }

  @override
  Future<SkillPublisher?> getPublisher(String publisherId) async {
    final rows = await _localDatabase.loadSkillPublisher(publisherId);
    return rows.isEmpty ? null : _publisher(rows.single);
  }

  @override
  Future<void> savePublisher(SkillPublisher publisher) {
    return _localDatabase.upsertSkillPublisher({
      'id': publisher.id,
      'name': publisher.name,
      'key_id': publisher.keyId,
      'public_key': publisher.publicKey,
      'organization': publisher.organization,
      'trusted': publisher.trusted ? 1 : 0,
      'created_at': publisher.createdAt.millisecondsSinceEpoch,
      'updated_at': publisher.updatedAt.millisecondsSinceEpoch,
    });
  }

  @override
  Future<List<SkillCatalogSource>> getCatalogs() async {
    final rows = await _localDatabase.loadSkillCatalogs();
    return List.unmodifiable(
      rows.map(
        (row) => SkillCatalogSource(
          id: _text(row['id']),
          name: _text(row['name']),
          indexUri: Uri.parse(_text(row['index_uri'])),
          publisherId: _text(row['publisher_id']),
          enabled: _bool(row['enabled'], true),
          lastError: _text(row['last_error']),
          lastFetchedAt: _date(row['last_fetched_at']),
        ),
      ),
    );
  }

  @override
  Future<void> saveCatalog(SkillCatalogSource catalog) {
    return _localDatabase.upsertSkillCatalog({
      'id': catalog.id,
      'name': catalog.name,
      'index_uri': catalog.indexUri.toString(),
      'publisher_id': catalog.publisherId,
      'enabled': catalog.enabled ? 1 : 0,
      'last_error': catalog.lastError,
      'last_fetched_at': catalog.lastFetchedAt?.millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> setSkillUpdatePolicy(String skillId, SkillUpdatePolicy policy) =>
      _localDatabase.setSkillUpdatePolicy(skillId, policy.name);

  @override
  Future<SkillScriptGrant?> getScriptGrant(String skillId) async {
    final rows = await _localDatabase.loadSkillScriptGrant(skillId);
    if (rows.isEmpty) return null;
    final row = rows.single;
    return SkillScriptGrant(
      skillId: _text(row['skill_id']),
      contentDigest: _text(row['content_digest']),
      enabled: _bool(row['enabled'], false),
      approvedAt:
          _date(row['approved_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  @override
  Future<void> saveScriptGrant(SkillScriptGrant grant) {
    return _localDatabase.upsertSkillScriptGrant({
      'skill_id': grant.skillId,
      'content_digest': grant.contentDigest,
      'enabled': grant.enabled ? 1 : 0,
      'approved_at': grant.approvedAt.millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> deleteScriptGrant(String skillId) =>
      _localDatabase.deleteSkillScriptGrant(skillId);

  @override
  Future<void> appendComplianceEvent(SkillComplianceEvent event) {
    return _localDatabase.insertSkillComplianceEvent({
      'id': event.id,
      'event_type': event.type.name,
      'skill_id': event.skillId,
      'content_digest': event.contentDigest,
      'publisher_id': event.publisherId,
      'decision': event.decision,
      'reason': event.reason,
      'metadata_json': jsonEncode(event.metadata),
      'timestamp': event.timestamp.millisecondsSinceEpoch,
    });
  }

  @override
  Future<List<SkillComplianceEvent>> getComplianceEvents({
    String? skillId,
    int limit = 100,
  }) async {
    final boundedLimit = limit.clamp(1, 1000);
    final rows = await _localDatabase.loadSkillComplianceEvents(
      skillId: skillId,
      limit: boundedLimit,
    );
    return List.unmodifiable(
      rows.map(
        (row) => SkillComplianceEvent(
          id: _text(row['id']),
          type: _enumValue(
            SkillComplianceEventType.values,
            _text(row['event_type']),
            SkillComplianceEventType.scriptRejected,
          ),
          skillId: _text(row['skill_id']),
          contentDigest: _text(row['content_digest']),
          publisherId: _text(row['publisher_id']),
          decision: _text(row['decision']),
          reason: _text(row['reason']),
          metadata: _objectMap(row['metadata_json']),
          timestamp:
              _date(row['timestamp']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        ),
      ),
    );
  }

  SkillPublisher _publisher(Map<String, Object?> row) => SkillPublisher(
    id: _text(row['id']),
    name: _text(row['name']),
    keyId: _text(row['key_id']),
    publicKey: _text(row['public_key']),
    organization: _text(row['organization']),
    trusted: _bool(row['trusted'], true),
    createdAt:
        _date(row['created_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt:
        _date(row['updated_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
  );
}

String _text(Object? value) => value?.toString() ?? '';

bool _bool(Object? value, bool fallback) {
  if (value == null) return fallback;
  return value == 1 || value == true || value.toString() == '1';
}

DateTime? _date(Object? value) {
  final milliseconds = switch (value) {
    final int number => number,
    final num number => number.toInt(),
    _ => int.tryParse(value?.toString() ?? ''),
  };
  return milliseconds == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(milliseconds);
}

Set<String> _stringSet(Object? value) {
  try {
    final decoded = jsonDecode(_text(value));
    return decoded is List
        ? decoded.map((item) => item.toString()).toSet()
        : const {};
  } on FormatException {
    return const {};
  }
}

Map<String, Object?> _objectMap(Object? value) {
  try {
    final decoded = jsonDecode(_text(value));
    return decoded is Map
        ? decoded.map((key, item) => MapEntry(key.toString(), item))
        : const {};
  } on FormatException {
    return const {};
  }
}

T _enumValue<T extends Enum>(List<T> values, String name, T fallback) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}
