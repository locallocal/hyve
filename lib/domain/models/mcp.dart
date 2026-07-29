import 'dart:convert';

import 'package:stars/domain/models/tool.dart';

enum McpAuthType { none, oauthAccessToken }

enum McpTransportType { streamableHttp, stdio }

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
      tools: map['tools'] == true,
      toolListChanged: map['toolListChanged'] == true,
    );
  }
}

final class McpServer {
  McpServer({
    required this.id,
    required this.name,
    required this.namespace,
    this.transportType = McpTransportType.streamableHttp,
    Uri? endpoint,
    this.command = '',
    List<String> arguments = const [],
    this.authType = McpAuthType.none,
    this.enabled = true,
    this.protocolVersion = '',
    this.remoteServerName = '',
    this.remoteServerVersion = '',
    this.capabilities = const McpServerCapabilities(),
    this.status = McpConnectionStatus.disconnected,
    this.lastErrorCode = '',
    this.lastConnectedAt,
    required this.createdAt,
    required this.updatedAt,
  }) : endpoint = endpoint ?? Uri(),
       arguments = List<String>.unmodifiable(arguments) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'MCP server id cannot be empty.');
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
    switch (transportType) {
      case McpTransportType.streamableHttp:
        if (!this.endpoint.hasScheme || this.endpoint.host.isEmpty) {
          throw ArgumentError.value(
            this.endpoint,
            'endpoint',
            'MCP endpoint must be an absolute URI.',
          );
        }
      case McpTransportType.stdio:
        if (command.trim().isEmpty) {
          throw ArgumentError.value(
            command,
            'command',
            'MCP stdio command cannot be empty.',
          );
        }
        if (authType != McpAuthType.none) {
          throw ArgumentError.value(
            authType,
            'authType',
            'MCP stdio servers do not use HTTP authentication.',
          );
        }
    }
  }

  final String id;
  final String name;
  final String namespace;
  final McpTransportType transportType;
  final Uri endpoint;
  final String command;
  final List<String> arguments;
  final McpAuthType authType;
  final bool enabled;
  final String protocolVersion;
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
    McpTransportType? transportType,
    Uri? endpoint,
    String? command,
    List<String>? arguments,
    McpAuthType? authType,
    bool? enabled,
    String? protocolVersion,
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
      transportType: transportType ?? this.transportType,
      endpoint: endpoint ?? this.endpoint,
      command: command ?? this.command,
      arguments: arguments ?? this.arguments,
      authType: authType ?? this.authType,
      enabled: enabled ?? this.enabled,
      protocolVersion: protocolVersion ?? this.protocolVersion,
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
      readOnlyHint: map['readOnlyHint'] == true,
      destructiveHint: map['destructiveHint'] != false,
      idempotentHint: map['idempotentHint'] == true,
      openWorldHint: map['openWorldHint'] != false,
    );
  }
}

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
    this.enabled = false,
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
  final bool enabled;
  final DateTime updatedAt;

  String get canonicalName =>
      McpToolDescriptor.canonicalNameFor(namespace, remoteName);

  bool get hasCompatibleSchema {
    const validator = JsonSchemaValidator();
    return inputSchema['type'] == 'object' &&
        validator.supports(inputSchema) &&
        (outputSchema == null || validator.supports(outputSchema!));
  }

  McpToolDescriptor copyWith({bool? enabled, DateTime? updatedAt}) {
    return McpToolDescriptor(
      serverId: serverId,
      namespace: namespace,
      remoteName: remoteName,
      title: title,
      description: description,
      inputSchema: inputSchema,
      outputSchema: outputSchema,
      annotations: annotations,
      enabled: enabled ?? this.enabled,
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

final class McpCredential {
  const McpCredential({
    this.accessToken = '',
    this.environment = const {},
    this.tokenType = 'Bearer',
    this.scope = '',
    this.expiresAt,
  });

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

final class McpInitializeResult {
  const McpInitializeResult({
    required this.protocolVersion,
    required this.serverName,
    required this.serverVersion,
    required this.capabilities,
    this.instructions = '',
  });

  final String protocolVersion;
  final String serverName;
  final String serverVersion;
  final McpServerCapabilities capabilities;
  final String instructions;
}

final class McpToolCallResult {
  const McpToolCallResult({
    required this.content,
    this.structuredContent,
    this.isError = false,
  });

  final String content;
  final Object? structuredContent;
  final bool isError;
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
