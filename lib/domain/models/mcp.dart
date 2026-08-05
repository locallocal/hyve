import 'dart:convert';

import 'package:stars/domain/models/tool.dart';

enum McpAuthType { none, oauthAccessToken }

enum McpTransportType { streamableHttp, stdio }

sealed class McpServerTransport {
  const McpServerTransport();

  McpTransportType get type;
}

final class McpStreamableHttpServerTransport extends McpServerTransport {
  McpStreamableHttpServerTransport({
    required this.endpoint,
    this.authType = McpAuthType.none,
  }) {
    if (!endpoint.hasScheme || endpoint.host.isEmpty) {
      throw ArgumentError.value(
        endpoint,
        'endpoint',
        'MCP endpoint must be an absolute URI.',
      );
    }
  }

  final Uri endpoint;
  final McpAuthType authType;

  @override
  McpTransportType get type => McpTransportType.streamableHttp;

  @override
  bool operator ==(Object other) =>
      other is McpStreamableHttpServerTransport &&
      endpoint == other.endpoint &&
      authType == other.authType;

  @override
  int get hashCode => Object.hash(endpoint, authType);
}

final class McpStdioServerTransport extends McpServerTransport {
  McpStdioServerTransport({
    required this.command,
    List<String> arguments = const [],
  }) : arguments = List<String>.unmodifiable(arguments) {
    if (command.trim().isEmpty) {
      throw ArgumentError.value(
        command,
        'command',
        'MCP stdio command cannot be empty.',
      );
    }
  }

  final String command;
  final List<String> arguments;

  @override
  McpTransportType get type => McpTransportType.stdio;

  @override
  bool operator ==(Object other) =>
      other is McpStdioServerTransport &&
      command == other.command &&
      _listsEqual(arguments, other.arguments);

  @override
  int get hashCode => Object.hash(command, Object.hashAll(arguments));
}

enum McpConnectionStatus {
  disconnected,
  connecting,
  connected,
  authorizationRequired,
  error,
}

final class McpServerCapabilities {
  const McpServerCapabilities({
    this.tools = false,
    this.toolListChanged = false,
  });

  final bool tools;
  final bool toolListChanged;

  Map<String, Object?> toMap() => {
    'tools': tools,
    'toolListChanged': toolListChanged,
  };

  factory McpServerCapabilities.fromMap(Map<String, Object?> map) {
    return McpServerCapabilities(
      tools: _requiredBoolean(map, 'tools'),
      toolListChanged: _requiredBoolean(map, 'toolListChanged'),
    );
  }
}

final class McpServer {
  McpServer({
    required this.id,
    required this.name,
    required this.namespace,
    required this.transport,
    this.remoteServerName = '',
    this.remoteServerVersion = '',
    this.capabilities = const McpServerCapabilities(),
    this.status = McpConnectionStatus.disconnected,
    this.lastErrorCode = '',
    this.lastConnectedAt,
    required this.createdAt,
    required this.updatedAt,
  }) {
    if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9_.:-]{0,127}$').hasMatch(id)) {
      throw ArgumentError.value(id, 'id', 'MCP server id is invalid.');
    }
    if (name.trim().isEmpty) {
      throw ArgumentError.value(
        name,
        'name',
        'MCP server name cannot be empty.',
      );
    }
    if (!RegExp(r'^[a-z][a-z0-9_-]{0,31}$').hasMatch(namespace)) {
      throw ArgumentError.value(
        namespace,
        'namespace',
        'Use 1-32 lowercase letters, digits, underscores, or hyphens.',
      );
    }
  }

  final String id;
  final String name;
  final String namespace;
  final McpServerTransport transport;
  final String remoteServerName;
  final String remoteServerVersion;
  final McpServerCapabilities capabilities;
  final McpConnectionStatus status;
  final String lastErrorCode;
  final DateTime? lastConnectedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  McpServer copyWith({
    String? name,
    String? namespace,
    McpServerTransport? transport,
    String? remoteServerName,
    String? remoteServerVersion,
    McpServerCapabilities? capabilities,
    McpConnectionStatus? status,
    String? lastErrorCode,
    bool clearLastError = false,
    DateTime? lastConnectedAt,
    bool clearLastConnectedAt = false,
    DateTime? updatedAt,
  }) {
    return McpServer(
      id: id,
      name: name ?? this.name,
      namespace: namespace ?? this.namespace,
      transport: transport ?? this.transport,
      remoteServerName: remoteServerName ?? this.remoteServerName,
      remoteServerVersion: remoteServerVersion ?? this.remoteServerVersion,
      capabilities: capabilities ?? this.capabilities,
      status: status ?? this.status,
      lastErrorCode: clearLastError ? '' : lastErrorCode ?? this.lastErrorCode,
      lastConnectedAt:
          clearLastConnectedAt ? null : lastConnectedAt ?? this.lastConnectedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

final class McpToolAnnotations {
  const McpToolAnnotations({
    this.readOnlyHint = false,
    this.destructiveHint = true,
    this.idempotentHint = false,
    this.openWorldHint = true,
  });

  /// MCP annotations are untrusted hints and never bypass the local policy.
  final bool readOnlyHint;
  final bool destructiveHint;
  final bool idempotentHint;
  final bool openWorldHint;

  Map<String, Object?> toMap() => {
    'readOnlyHint': readOnlyHint,
    'destructiveHint': destructiveHint,
    'idempotentHint': idempotentHint,
    'openWorldHint': openWorldHint,
  };

  factory McpToolAnnotations.fromMap(Map<String, Object?> map) {
    return McpToolAnnotations(
      readOnlyHint: _optionalBoolean(map, 'readOnlyHint', false),
      destructiveHint: _optionalBoolean(map, 'destructiveHint', true),
      idempotentHint: _optionalBoolean(map, 'idempotentHint', false),
      openWorldHint: _optionalBoolean(map, 'openWorldHint', true),
    );
  }
}

enum McpToolTaskSupport { forbidden, optional, required }

final class McpToolDescriptor {
  McpToolDescriptor({
    required this.serverId,
    required this.namespace,
    required this.remoteName,
    required this.title,
    required this.description,
    required Map<String, Object?> inputSchema,
    Map<String, Object?>? outputSchema,
    this.annotations = const McpToolAnnotations(),
    this.taskSupport = McpToolTaskSupport.forbidden,
    required this.updatedAt,
  }) : inputSchema = Map<String, Object?>.unmodifiable(inputSchema),
       outputSchema =
           outputSchema == null
               ? null
               : Map<String, Object?>.unmodifiable(outputSchema) {
    if (serverId.trim().isEmpty || remoteName.trim().isEmpty) {
      throw ArgumentError('MCP server and remote tool names cannot be empty.');
    }
  }

  final String serverId;
  final String namespace;
  final String remoteName;
  final String title;
  final String description;
  final Map<String, Object?> inputSchema;
  final Map<String, Object?>? outputSchema;
  final McpToolAnnotations annotations;
  final McpToolTaskSupport taskSupport;
  final DateTime updatedAt;

  String get canonicalName =>
      McpToolDescriptor.canonicalNameFor(namespace, remoteName);

  bool get isSupportedByClient {
    const validator = JsonSchemaValidator();
    return taskSupport != McpToolTaskSupport.required &&
        inputSchema['type'] == 'object' &&
        validator.supports(inputSchema) &&
        (outputSchema == null || validator.supports(outputSchema!));
  }

  McpToolDescriptor copyWith({DateTime? updatedAt}) {
    return McpToolDescriptor(
      serverId: serverId,
      namespace: namespace,
      remoteName: remoteName,
      title: title,
      description: description,
      inputSchema: inputSchema,
      outputSchema: outputSchema,
      annotations: annotations,
      taskSupport: taskSupport,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String canonicalNameFor(String namespace, String remoteName) {
    final trimmed = remoteName.trim();
    if (RegExp(r'^[A-Za-z0-9_-]{1,96}$').hasMatch(trimmed)) {
      return 'mcp.$namespace.$trimmed';
    }
    final slug = trimmed
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    final safeSlug = slug.isEmpty ? 'tool' : slug;
    final slugEnd = safeSlug.length > 64 ? 64 : safeSlug.length;
    return 'mcp.$namespace.${safeSlug.substring(0, slugEnd)}'
        '_${_stableHash(trimmed)}';
  }
}

final class McpToolConfiguration {
  McpToolConfiguration({
    required this.serverId,
    required this.remoteName,
    this.requiresApproval = true,
  }) {
    if (serverId.trim().isEmpty || remoteName.trim().isEmpty) {
      throw ArgumentError(
        'MCP Tool configuration requires a server and remote Tool name.',
      );
    }
  }

  factory McpToolConfiguration.fromMap(Map<String, Object?> values) {
    final serverId = values['server_id'];
    final remoteName = values['remote_name'];
    final requiresApproval = values['requires_approval'];
    if (serverId is! String ||
        remoteName is! String ||
        requiresApproval is! bool) {
      throw const FormatException('Invalid MCP Tool configuration.');
    }
    return McpToolConfiguration(
      serverId: serverId,
      remoteName: remoteName,
      requiresApproval: requiresApproval,
    );
  }

  final String serverId;
  final String remoteName;
  final bool requiresApproval;

  String get key => keyFor(serverId, remoteName);

  static String keyFor(String serverId, String remoteName) =>
      '$serverId\u0000$remoteName';

  Map<String, Object?> toMap() => {
    'server_id': serverId,
    'remote_name': remoteName,
    'requires_approval': requiresApproval,
  };

  McpToolConfiguration copyWith({bool? requiresApproval}) =>
      McpToolConfiguration(
        serverId: serverId,
        remoteName: remoteName,
        requiresApproval: requiresApproval ?? this.requiresApproval,
      );

  @override
  bool operator ==(Object other) =>
      other is McpToolConfiguration &&
      serverId == other.serverId &&
      remoteName == other.remoteName &&
      requiresApproval == other.requiresApproval;

  @override
  int get hashCode => Object.hash(serverId, remoteName, requiresApproval);
}

final class McpCredential {
  McpCredential({
    this.accessToken = '',
    Map<String, String> environment = const {},
    this.tokenType = 'Bearer',
    this.scope = '',
    this.expiresAt,
  }) : environment = Map<String, String>.unmodifiable(environment);

  final String accessToken;
  final Map<String, String> environment;
  final String tokenType;
  final String scope;
  final DateTime? expiresAt;

  bool get isExpired {
    final expiry = expiresAt;
    return expiry != null &&
        !expiry.isAfter(DateTime.now().add(const Duration(seconds: 30)));
  }

  @override
  String toString() => 'McpCredential(<redacted>)';
}

final class McpServerCatalog {
  McpServerCatalog({
    required this.serverName,
    required this.serverVersion,
    required this.capabilities,
    required List<McpToolDescriptor> tools,
    this.instructions = '',
  }) : tools = List<McpToolDescriptor>.unmodifiable(tools);

  final String serverName;
  final String serverVersion;
  final McpServerCapabilities capabilities;
  final List<McpToolDescriptor> tools;
  final String instructions;
}

final class McpToolCallResult {
  const McpToolCallResult({
    required this.content,
    this.structuredContent,
    this.isError = false,
  });

  final String content;
  final Map<String, Object?>? structuredContent;
  final bool isError;
}

bool _listsEqual<T>(List<T> left, List<T> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

bool _requiredBoolean(Map<String, Object?> values, String key) {
  final value = values[key];
  if (value is bool) return value;
  throw FormatException('MCP field "$key" must be a boolean.');
}

bool _optionalBoolean(
  Map<String, Object?> values,
  String key,
  bool defaultValue,
) {
  if (!values.containsKey(key)) return defaultValue;
  return _requiredBoolean(values, key);
}

final class McpException implements Exception {
  const McpException(
    this.code, {
    this.message = '',
    this.statusCode,
    this.authorizationMetadataUri,
  });

  final String code;
  final String message;
  final int? statusCode;
  final Uri? authorizationMetadataUri;

  @override
  String toString() => message.isEmpty ? code : '$code: $message';
}

String _stableHash(String value) {
  var hash = 0x811c9dc5;
  for (final byte in utf8.encode(value)) {
    hash ^= byte;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}
