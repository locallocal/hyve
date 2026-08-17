import 'dart:convert';

import 'package:hyve/data/models/mcp_records.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/mcp_inventory_repository.dart';

final class SqliteMcpInventoryRepository implements McpInventoryRepository {
  const SqliteMcpInventoryRepository({
    required LocalDatabaseService localDatabase,
  }) : _localDatabase = localDatabase;

  static const int maxInstalledLimit = 100;

  final LocalDatabaseService _localDatabase;

  @override
  Future<InstalledMcpServerInventoryPage> listInstalled({
    String query = '',
    int limit = 50,
  }) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.length > 128) {
      throw ArgumentError.value(
        query,
        'query',
        'Must not exceed 128 characters.',
      );
    }
    if (limit < 1 || limit > maxInstalledLimit) {
      throw ArgumentError.value(limit, 'limit', 'Must be between 1 and 100.');
    }
    final records = await _localDatabase.queryInstalledMcpInventory(
      query: normalized,
      limit: limit + 1,
    );
    final truncated = records.length > limit;
    final visible = truncated ? records.take(limit) : records;
    return InstalledMcpServerInventoryPage(
      items: List<InstalledMcpServerInventoryItem>.unmodifiable(
        visible.map(_installedFromRecord),
      ),
      truncated: truncated,
    );
  }

  @override
  Future<ConversationMcpInventory> listForConversation(
    String chatId,
    String botId,
  ) async {
    if (chatId.trim().isEmpty) {
      throw ArgumentError.value(chatId, 'chatId', 'Must not be empty.');
    }
    if (botId.trim().isEmpty) {
      throw ArgumentError.value(botId, 'botId', 'Must not be empty.');
    }
    final identities = await _localDatabase.queryConversationMcpIdentity(
      chatId,
      botId,
    );
    if (identities.isEmpty) {
      return const ConversationMcpInventory(
        conversationFound: false,
        botId: '',
        botName: '',
        modelSupportsMcp: null,
        servers: [],
      );
    }
    final identity = identities.single;
    final parameters = _parameters(identity['bot_parameters']);
    final modelSupportsMcp = _optionalBool(
      parameters,
      Bot.parameterSupportsMcp,
    );
    final configuredServerIds = _serverIds(parameters);
    final configurations = _toolConfigurations(parameters);
    final allServerIds =
        <String>{
            ...configuredServerIds,
            ...configurations.map((configuration) => configuration.serverId),
          }.toList()
          ..sort();

    final serverRecords = await _localDatabase.loadMcpServers();
    final serversById = {
      for (final record in serverRecords)
        _requiredString(record, 'id'): McpServerRecord(record).toDomain(),
    };
    final toolRecords = await _localDatabase.loadAllMcpTools();
    final toolsByKey = <String, McpToolDescriptor>{};
    final availableToolCounts = <String, int>{};
    for (final record in toolRecords) {
      final tool = McpToolRecord(record).toDomain();
      toolsByKey[McpToolConfiguration.keyFor(tool.serverId, tool.remoteName)] =
          tool;
      availableToolCounts.update(
        tool.serverId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    final configurationsByServer = <String, List<McpToolConfiguration>>{};
    for (final configuration in configurations) {
      configurationsByServer
          .putIfAbsent(configuration.serverId, () => [])
          .add(configuration);
    }
    final servers = <ConversationMcpServerInventoryItem>[];
    for (final serverId in allServerIds) {
      final server = serversById[serverId];
      final configuredTools = configurationsByServer[serverId] ?? const [];
      final tools = <ConversationMcpToolInventoryItem>[];
      for (final configuration in configuredTools) {
        final descriptor = toolsByKey[configuration.key];
        tools.add(
          ConversationMcpToolInventoryItem(
            remoteName: configuration.remoteName,
            canonicalName: McpToolDescriptor.canonicalNameFor(
              configuration.serverId,
              configuration.remoteName,
            ),
            title: descriptor?.title ?? '',
            description: descriptor?.description ?? '',
            available: descriptor != null,
            requiresApproval: configuration.requiresApproval,
          ),
        );
      }
      tools.sort((left, right) => left.remoteName.compareTo(right.remoteName));
      servers.add(
        ConversationMcpServerInventoryItem(
          id: serverId,
          name: server?.name ?? '',
          installed: server != null,
          transportType:
              server == null ? '' : _transportName(server.transport.type.name),
          connectionStatus: server?.status.name ?? '',
          lastErrorCode: server?.lastErrorCode ?? '',
          availableToolCount: availableToolCounts[serverId] ?? 0,
          tools: List<ConversationMcpToolInventoryItem>.unmodifiable(tools),
        ),
      );
    }
    return ConversationMcpInventory(
      conversationFound: true,
      botId: _requiredString(identity, 'bot_id'),
      botName: _requiredString(identity, 'bot_name'),
      modelSupportsMcp: modelSupportsMcp,
      servers: List<ConversationMcpServerInventoryItem>.unmodifiable(servers),
    );
  }

  InstalledMcpServerInventoryItem _installedFromRecord(
    Map<String, Object?> record,
  ) => InstalledMcpServerInventoryItem(
    id: _requiredString(record, 'id'),
    name: _requiredString(record, 'name'),
    transportType: _transportName(_requiredString(record, 'transport_type')),
    remoteServerName: _requiredString(record, 'remote_server_name'),
    remoteServerVersion: _requiredString(record, 'remote_server_version'),
    connectionStatus: _requiredString(record, 'connection_status'),
    lastErrorCode: _requiredString(record, 'last_error_code'),
    toolCount: _integer(record['tool_count']),
    lastConnectedAt: _date(record['last_connected_at']),
    createdAt: _date(record['created_at'])!,
    updatedAt: _date(record['updated_at'])!,
  );

  Map<String, Object?> _parameters(Object? raw) {
    if (raw == null || raw == '') return const {};
    if (raw is! String) {
      throw const FormatException('Bot parameters must be stored as JSON.');
    }
    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Bot parameters must contain an object.');
    }
    return decoded.map(
      (key, value) => MapEntry(key.toString(), value as Object?),
    );
  }

  Set<String> _serverIds(Map<String, Object?> parameters) {
    final raw = parameters[Bot.parameterMcpServers];
    if (raw == null) return const {};
    if (raw is! List || raw.any((id) => id is! String || id.trim().isEmpty)) {
      throw const FormatException('Bot MCP servers must be a string array.');
    }
    return Set<String>.unmodifiable(raw.cast<String>());
  }

  List<McpToolConfiguration> _toolConfigurations(
    Map<String, Object?> parameters,
  ) {
    final raw = parameters[Bot.parameterMcpTools];
    if (raw == null) return const [];
    if (raw is! List) {
      throw const FormatException('Bot MCP tools must be an array.');
    }
    return List<McpToolConfiguration>.unmodifiable(
      raw.map((item) {
        if (item is! Map) {
          throw const FormatException('Bot MCP Tool must be an object.');
        }
        return McpToolConfiguration.fromMap(
          item.map((key, value) => MapEntry(key.toString(), value as Object?)),
        );
      }),
    );
  }

  bool? _optionalBool(Map<String, Object?> values, String key) {
    final value = values[key];
    if (value == null || value is bool) return value as bool?;
    throw FormatException('Bot parameter "$key" must be a boolean.');
  }

  String _transportName(String storedName) => switch (storedName) {
    'streamableHttp' => 'streamable_http',
    'stdio' => 'stdio',
    _ => throw FormatException('Unknown MCP transport "$storedName".'),
  };

  String _requiredString(Map<String, Object?> values, String key) {
    final value = values[key];
    if (value is String) return value;
    throw FormatException('MCP inventory field "$key" must be a string.');
  }

  int _integer(Object? value) => value is num ? value.toInt() : 0;

  DateTime? _date(Object? value) {
    if (value == null) return null;
    if (value is! num) {
      throw const FormatException('MCP inventory timestamp is invalid.');
    }
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
}
