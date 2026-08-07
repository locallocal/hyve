import 'dart:convert';

import 'package:stars/domain/models/models.dart';

final class McpServerRecord {
  const McpServerRecord(this.values);

  factory McpServerRecord.fromDomain(McpServer server) {
    return McpServerRecord({
      'id': server.id,
      'name': server.name,
      'transport_type': server.transport.type.name,
      'transport_config_json': jsonEncode(_transportToMap(server.transport)),
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
    final transportType = _enumValue(
      McpTransportType.values,
      _string('transport_type'),
      field: 'transport_type',
    );
    final transportConfig = _decodeMap(
      _string('transport_config_json'),
      field: 'transport_config_json',
    );
    final lastConnectedAt = _nullableInteger(
      values['last_connected_at'],
      field: 'last_connected_at',
    );
    return McpServer(
      id: _string('id'),
      name: _string('name'),
      transport: _transportFromMap(transportType, transportConfig),
      remoteServerName: _string('remote_server_name'),
      remoteServerVersion: _string('remote_server_version'),
      capabilities: McpServerCapabilities.fromMap(
        _decodeMap(_string('capabilities_json'), field: 'capabilities_json'),
      ),
      status: _enumValue(
        McpConnectionStatus.values,
        _string('connection_status'),
        field: 'connection_status',
      ),
      lastErrorCode: _string('last_error_code'),
      lastConnectedAt:
          lastConnectedAt == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(lastConnectedAt),
      createdAt: DateTime.fromMillisecondsSinceEpoch(_integer('created_at')),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(_integer('updated_at')),
    );
  }

  String _string(String key) {
    final value = values[key];
    if (value is String) return value;
    throw FormatException('MCP record field "$key" must be a string.');
  }

  int _integer(String key) {
    final value = values[key];
    if (value is int) return value;
    throw FormatException('MCP record field "$key" must be an integer.');
  }
}

final class McpToolRecord {
  const McpToolRecord(this.values);

  factory McpToolRecord.fromDomain(McpToolDescriptor tool) {
    return McpToolRecord({
      'server_id': tool.serverId,
      'remote_name': tool.remoteName,
      'title': tool.title,
      'description': tool.description,
      'input_schema_json': jsonEncode(tool.inputSchema),
      'output_schema_json':
          tool.outputSchema == null ? null : jsonEncode(tool.outputSchema),
      'annotations_json': jsonEncode(tool.annotations.toMap()),
      'task_support': tool.taskSupport.name,
      'updated_at': tool.updatedAt.millisecondsSinceEpoch,
    });
  }

  final Map<String, Object?> values;

  McpToolDescriptor toDomain() {
    final outputSchemaSource = values['output_schema_json'];
    if (outputSchemaSource != null && outputSchemaSource is! String) {
      throw const FormatException(
        'MCP Tool output_schema_json must be a string or null.',
      );
    }
    return McpToolDescriptor(
      serverId: _requiredString(values, 'server_id'),
      remoteName: _requiredString(values, 'remote_name'),
      title: _requiredString(values, 'title'),
      description: _requiredString(values, 'description'),
      inputSchema: _decodeMap(
        _requiredString(values, 'input_schema_json'),
        field: 'input_schema_json',
      ),
      outputSchema:
          outputSchemaSource == null
              ? null
              : _decodeMap(
                outputSchemaSource as String,
                field: 'output_schema_json',
              ),
      annotations: McpToolAnnotations.fromMap(
        _decodeMap(
          _requiredString(values, 'annotations_json'),
          field: 'annotations_json',
        ),
      ),
      taskSupport: _enumValue(
        McpToolTaskSupport.values,
        _requiredString(values, 'task_support'),
        field: 'task_support',
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        _requiredInteger(values, 'updated_at'),
      ),
    );
  }
}

Map<String, Object?> _transportToMap(McpServerTransport transport) {
  return switch (transport) {
    McpStreamableHttpServerTransport(:final endpoint, :final authType) => {
      'endpoint': endpoint.toString(),
      'authType': authType.name,
    },
    McpStdioServerTransport(:final command, :final arguments) => {
      'command': command,
      'arguments': arguments,
    },
  };
}

McpServerTransport _transportFromMap(
  McpTransportType type,
  Map<String, Object?> values,
) {
  return switch (type) {
    McpTransportType.streamableHttp => McpStreamableHttpServerTransport(
      endpoint: Uri.parse(_requiredString(values, 'endpoint')),
      authType: _enumValue(
        McpAuthType.values,
        _requiredString(values, 'authType'),
        field: 'authType',
      ),
    ),
    McpTransportType.stdio => McpStdioServerTransport(
      command: _requiredString(values, 'command'),
      arguments: _decodeStringList(values['arguments'], field: 'arguments'),
    ),
  };
}

Map<String, Object?> _decodeMap(String source, {required String field}) {
  final Object? decoded;
  try {
    decoded = jsonDecode(source);
  } on FormatException {
    throw FormatException('MCP record field "$field" contains invalid JSON.');
  }
  if (decoded is! Map) {
    throw FormatException('MCP record field "$field" must contain an object.');
  }
  return decoded.map(
    (key, value) => MapEntry(key.toString(), value as Object?),
  );
}

List<String> _decodeStringList(Object? value, {required String field}) {
  if (value is! List || value.any((item) => item is! String)) {
    throw FormatException('MCP record field "$field" must be a string array.');
  }
  return List<String>.unmodifiable(value.cast<String>());
}

T _enumValue<T extends Enum>(
  List<T> values,
  String name, {
  required String field,
}) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  throw FormatException('MCP record field "$field" has an unknown value.');
}

String _requiredString(Map<String, Object?> values, String key) {
  final value = values[key];
  if (value is String) return value;
  throw FormatException('MCP record field "$key" must be a string.');
}

int _requiredInteger(Map<String, Object?> values, String key) {
  final value = values[key];
  if (value is int) return value;
  throw FormatException('MCP record field "$key" must be an integer.');
}

int? _nullableInteger(Object? value, {required String field}) {
  if (value == null || value is int) return value as int?;
  throw FormatException(
    'MCP record field "$field" must be an integer or null.',
  );
}
