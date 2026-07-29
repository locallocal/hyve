import 'dart:convert';

import 'package:stars/domain/models/models.dart';

final class McpServerRecord {
  const McpServerRecord(this.values);

  factory McpServerRecord.fromDomain(McpServer server) {
    return McpServerRecord({
      'id': server.id,
      'name': server.name,
      'namespace': server.namespace,
      'transport_type': server.transportType.name,
      'endpoint_uri': server.endpoint.toString(),
      'command': server.command,
      'arguments_json': jsonEncode(server.arguments),
      'auth_type': server.authType.name,
      'enabled': server.enabled ? 1 : 0,
      'protocol_version': server.protocolVersion,
      'remote_server_name': server.remoteServerName,
      'remote_server_version': server.remoteServerVersion,
      'capabilities_json': jsonEncode(server.capabilities.toMap()),
      'connection_status': server.status.name,
      'last_error_code': server.lastErrorCode,
      'last_connected_at': server.lastConnectedAt?.millisecondsSinceEpoch,
      'created_at': server.createdAt.millisecondsSinceEpoch,
      'updated_at': server.updatedAt.millisecondsSinceEpoch,
    });
  }

  final Map<String, Object?> values;

  McpServer toDomain() {
    final lastConnectedAt = _nullableInteger(values['last_connected_at']);
    return McpServer(
      id: _text('id'),
      name: _text('name'),
      namespace: _text('namespace'),
      transportType: _enumValue(
        McpTransportType.values,
        _text('transport_type'),
        McpTransportType.streamableHttp,
      ),
      endpoint: Uri.parse(_text('endpoint_uri')),
      command: _text('command'),
      arguments: _decodeStringList(_text('arguments_json')),
      authType: _enumValue(
        McpAuthType.values,
        _text('auth_type'),
        McpAuthType.none,
      ),
      enabled: _integer(values['enabled']) == 1,
      protocolVersion: _text('protocol_version'),
      remoteServerName: _text('remote_server_name'),
      remoteServerVersion: _text('remote_server_version'),
      capabilities: McpServerCapabilities.fromMap(
        _decodeMap(_text('capabilities_json')),
      ),
      status: _enumValue(
        McpConnectionStatus.values,
        _text('connection_status'),
        McpConnectionStatus.disconnected,
      ),
      lastErrorCode: _text('last_error_code'),
      lastConnectedAt:
          lastConnectedAt == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(lastConnectedAt),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        _integer(values['created_at']),
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        _integer(values['updated_at']),
      ),
    );
  }

  String _text(String key) => values[key]?.toString() ?? '';
}

final class McpToolRecord {
  const McpToolRecord(this.values);

  factory McpToolRecord.fromDomain(McpToolDescriptor tool) {
    return McpToolRecord({
      'server_id': tool.serverId,
      'remote_name': tool.remoteName,
      'namespace': tool.namespace,
      'canonical_name': tool.canonicalName,
      'title': tool.title,
      'description': tool.description,
      'input_schema_json': jsonEncode(tool.inputSchema),
      'output_schema_json':
          tool.outputSchema == null ? null : jsonEncode(tool.outputSchema),
      'annotations_json': jsonEncode(tool.annotations.toMap()),
      'enabled': tool.enabled ? 1 : 0,
      'updated_at': tool.updatedAt.millisecondsSinceEpoch,
    });
  }

  final Map<String, Object?> values;

  McpToolDescriptor toDomain() {
    final outputSchemaSource = values['output_schema_json']?.toString();
    return McpToolDescriptor(
      serverId: values['server_id']?.toString() ?? '',
      namespace: values['namespace']?.toString() ?? '',
      remoteName: values['remote_name']?.toString() ?? '',
      title: values['title']?.toString() ?? '',
      description: values['description']?.toString() ?? '',
      inputSchema: _decodeMap(values['input_schema_json']?.toString() ?? ''),
      outputSchema:
          outputSchemaSource == null || outputSchemaSource.isEmpty
              ? null
              : _decodeMap(outputSchemaSource),
      annotations: McpToolAnnotations.fromMap(
        _decodeMap(values['annotations_json']?.toString() ?? ''),
      ),
      enabled: _integer(values['enabled']) == 1,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        _integer(values['updated_at']),
      ),
    );
  }
}

Map<String, Object?> _decodeMap(String source) {
  try {
    final decoded = jsonDecode(source);
    if (decoded is Map) {
      return decoded.map(
        (key, value) => MapEntry(key.toString(), value as Object?),
      );
    }
  } on FormatException {
    return const {};
  }
  return const {};
}

List<String> _decodeStringList(String source) {
  try {
    final decoded = jsonDecode(source);
    if (decoded is List) {
      return decoded.map((value) => value.toString()).toList(growable: false);
    }
  } on FormatException {
    // Invalid persisted values fail closed to an empty argument list.
  }
  return const [];
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
