part of 'compose_chat_turn.dart';

extension _ComposeChatTurnMcp on ComposeChatTurn {
  Future<_ResolvedMcpTools> _resolveMcpTools({
    required Bot bot,
    required AiProvider? provider,
  }) async {
    final repository = _mcpServerRepository;
    if (repository == null ||
        provider?.supportMcp() != true ||
        bot.mcpTools.isEmpty) {
      return const _ResolvedMcpTools();
    }

    final requestedNames = <String>{};
    final approvalExemptNames = <String>{};
    final configurations =
        bot.mcpTools.toList()
          ..sort((left, right) => left.key.compareTo(right.key));
    final byServer = <String, List<McpToolConfiguration>>{};
    for (final configuration in configurations) {
      byServer.putIfAbsent(configuration.serverId, () => []).add(configuration);
    }
    for (final entry in byServer.entries) {
      final serverId = entry.key;
      final server = await repository.getServer(serverId);
      if (server == null || server.status != McpConnectionStatus.connected) {
        continue;
      }
      final tools = await repository.getTools(serverId);
      final configurationsByName = {
        for (final configuration in entry.value)
          configuration.remoteName: configuration,
      };
      for (final tool in tools) {
        final configuration = configurationsByName[tool.remoteName];
        if (configuration == null || !tool.isSupportedByClient) continue;
        requestedNames.add(tool.canonicalName);
        if (!configuration.requiresApproval) {
          approvalExemptNames.add(tool.canonicalName);
        }
      }
    }
    return _ResolvedMcpTools(
      requestedNames: requestedNames,
      approvalExemptNames: approvalExemptNames,
    );
  }
}

final class _ResolvedMcpTools {
  const _ResolvedMcpTools({
    this.requestedNames = const {},
    this.approvalExemptNames = const {},
  });

  final Set<String> requestedNames;
  final Set<String> approvalExemptNames;
}
