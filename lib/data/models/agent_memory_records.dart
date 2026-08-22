import 'dart:convert';

import 'package:hyve/domain/models/agent_memory.dart';

final class AgentMemoryRecord {
  const AgentMemoryRecord(this.values);

  factory AgentMemoryRecord.fromDomain(AgentMemory memory) {
    return AgentMemoryRecord(<String, Object?>{
      'schemaVersion': 1,
      'id': memory.id,
      'agentId': memory.agentId,
      'memoryKey': memory.memoryKey,
      'kind': memory.kind.name,
      'content': memory.content,
      'state': memory.state.name,
      'reuseScope': memory.reuseScope.name,
      'sensitivity': memory.sensitivity.name,
      'importance': memory.importance,
      'confidence': memory.confidence,
      'sourceProjectId': memory.sourceProjectId,
      'sourceEventIds': memory.sourceEventIds,
      'sourceMessageSequence': memory.sourceMessageSequence,
      'sourceDigest': memory.sourceDigest,
      'version': memory.version,
      'supersedesId': memory.supersedesId,
      'createdAt': memory.createdAt.toUtc().toIso8601String(),
      'updatedAt': memory.updatedAt.toUtc().toIso8601String(),
      'lastUsedAt': memory.lastUsedAt?.toUtc().toIso8601String(),
    });
  }

  final Map<String, Object?> values;

  String encode() => jsonEncode(values);

  AgentMemory toDomain() {
    _requireExactKeys(values, const <String>{
      'schemaVersion',
      'id',
      'agentId',
      'memoryKey',
      'kind',
      'content',
      'state',
      'reuseScope',
      'sensitivity',
      'importance',
      'confidence',
      'sourceProjectId',
      'sourceEventIds',
      'sourceMessageSequence',
      'sourceDigest',
      'version',
      'supersedesId',
      'createdAt',
      'updatedAt',
      'lastUsedAt',
    });
    if (_integer(values['schemaVersion'], 'schemaVersion') != 1) {
      throw const FormatException('Unsupported Agent memory schema version.');
    }
    return AgentMemory(
      id: _text(values['id'], 'id'),
      agentId: _text(values['agentId'], 'agentId'),
      memoryKey: _text(values['memoryKey'], 'memoryKey'),
      kind: _enumByName(
        AgentMemoryKind.values,
        _text(values['kind'], 'kind'),
        'kind',
      ),
      content: _text(values['content'], 'content'),
      state: _enumByName(
        AgentMemoryState.values,
        _text(values['state'], 'state'),
        'state',
      ),
      reuseScope: _enumByName(
        AgentMemoryReuseScope.values,
        _text(values['reuseScope'], 'reuseScope'),
        'reuseScope',
      ),
      sensitivity: _enumByName(
        AgentMemorySensitivity.values,
        _text(values['sensitivity'], 'sensitivity'),
        'sensitivity',
      ),
      importance: _number(values['importance'], 'importance'),
      confidence: _number(values['confidence'], 'confidence'),
      sourceProjectId: _text(values['sourceProjectId'], 'sourceProjectId'),
      sourceEventIds: _stringList(values['sourceEventIds'], 'sourceEventIds'),
      sourceMessageSequence: _nullableInteger(
        values['sourceMessageSequence'],
        'sourceMessageSequence',
      ),
      sourceDigest: _text(values['sourceDigest'], 'sourceDigest'),
      version: _integer(values['version'], 'version'),
      supersedesId: _text(values['supersedesId'], 'supersedesId'),
      createdAt: _date(values['createdAt'], 'createdAt'),
      updatedAt: _date(values['updatedAt'], 'updatedAt'),
      lastUsedAt: _nullableDate(values['lastUsedAt'], 'lastUsedAt'),
    );
  }

  static AgentMemoryRecord decode(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Agent memory record must be an object.');
    }
    return AgentMemoryRecord(decoded);
  }
}

final class AgentMemoryManifestRecord {
  const AgentMemoryManifestRecord({
    required this.agentId,
    required this.revision,
    required this.heads,
  });

  factory AgentMemoryManifestRecord.decode(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Agent memory manifest must be an object.');
    }
    _requireExactKeys(decoded, const <String>{
      'schemaVersion',
      'agentId',
      'revision',
      'heads',
    });
    if (_integer(decoded['schemaVersion'], 'schemaVersion') != 1) {
      throw const FormatException('Unsupported Agent memory manifest.');
    }
    final rawHeads = decoded['heads'];
    if (rawHeads is! Map<String, Object?>) {
      throw const FormatException('Agent memory heads must be an object.');
    }
    final heads = <String, AgentMemoryManifestHead>{};
    for (final entry in rawHeads.entries) {
      final value = entry.value;
      if (value is! Map<String, Object?>) {
        throw const FormatException('Agent memory head must be an object.');
      }
      heads[entry.key] = AgentMemoryManifestHead.fromJson(value);
    }
    return AgentMemoryManifestRecord(
      agentId: _text(decoded['agentId'], 'agentId'),
      revision: _integer(decoded['revision'], 'revision'),
      heads: Map<String, AgentMemoryManifestHead>.unmodifiable(heads),
    );
  }

  final String agentId;
  final int revision;
  final Map<String, AgentMemoryManifestHead> heads;

  String encode() => jsonEncode(<String, Object?>{
    'schemaVersion': 1,
    'agentId': agentId,
    'revision': revision,
    'heads': <String, Object?>{
      for (final entry in heads.entries) entry.key: entry.value.toJson(),
    },
  });
}

final class AgentMemoryManifestHead {
  const AgentMemoryManifestHead({
    required this.id,
    required this.version,
    required this.relativePath,
    required this.contentDigest,
  });

  factory AgentMemoryManifestHead.fromJson(Map<String, Object?> json) {
    _requireExactKeys(json, const <String>{
      'id',
      'version',
      'relativePath',
      'contentDigest',
    });
    return AgentMemoryManifestHead(
      id: _text(json['id'], 'id'),
      version: _integer(json['version'], 'version'),
      relativePath: _text(json['relativePath'], 'relativePath'),
      contentDigest: _text(json['contentDigest'], 'contentDigest'),
    );
  }

  final String id;
  final int version;
  final String relativePath;
  final String contentDigest;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'version': version,
    'relativePath': relativePath,
    'contentDigest': contentDigest,
  };
}

void _requireExactKeys(Map<String, Object?> json, Set<String> expected) {
  if (json.keys.toSet().difference(expected).isNotEmpty ||
      expected.difference(json.keys.toSet()).isNotEmpty) {
    throw const FormatException('Agent memory record shape is invalid.');
  }
}

String _text(Object? value, String field) {
  if (value is String) return value;
  throw FormatException('$field must be text.');
}

int _integer(Object? value, String field) {
  if (value is int) return value;
  throw FormatException('$field must be an integer.');
}

int? _nullableInteger(Object? value, String field) =>
    value == null ? null : _integer(value, field);

double _number(Object? value, String field) {
  if (value is num) return value.toDouble();
  throw FormatException('$field must be a number.');
}

DateTime _date(Object? value, String field) {
  final source = _text(value, field);
  return DateTime.tryParse(source)?.toLocal() ??
      (throw FormatException('$field must be an ISO-8601 date.'));
}

DateTime? _nullableDate(Object? value, String field) =>
    value == null ? null : _date(value, field);

List<String> _stringList(Object? value, String field) {
  if (value is! List<Object?> || value.any((item) => item is! String)) {
    throw FormatException('$field must be a string list.');
  }
  return List<String>.unmodifiable(value.cast<String>());
}

T _enumByName<T extends Enum>(List<T> values, String name, String field) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  throw FormatException('$field has an unknown enum value.');
}
