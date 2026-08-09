final class InstalledMcpServerInventoryItem {
  const InstalledMcpServerInventoryItem({
    required this.id,
    required this.name,
    required this.transportType,
    required this.remoteServerName,
    required this.remoteServerVersion,
    required this.connectionStatus,
    required this.lastErrorCode,
    required this.toolCount,
    this.lastConnectedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String transportType;
  final String remoteServerName;
  final String remoteServerVersion;
  final String connectionStatus;
  final String lastErrorCode;
  final int toolCount;
  final DateTime? lastConnectedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}

final class InstalledMcpServerInventoryPage {
  const InstalledMcpServerInventoryPage({
    required this.items,
    required this.truncated,
  });

  final List<InstalledMcpServerInventoryItem> items;
  final bool truncated;
}

final class ConversationMcpInventory {
  const ConversationMcpInventory({
    required this.conversationFound,
    required this.botId,
    required this.botName,
    required this.modelSupportsMcp,
    required this.servers,
  });

  final bool conversationFound;
  final String botId;
  final String botName;
  final bool? modelSupportsMcp;
  final List<ConversationMcpServerInventoryItem> servers;
}

final class ConversationMcpServerInventoryItem {
  const ConversationMcpServerInventoryItem({
    required this.id,
    required this.name,
    required this.installed,
    required this.transportType,
    required this.connectionStatus,
    required this.lastErrorCode,
    required this.availableToolCount,
    required this.tools,
  });

  final String id;
  final String name;
  final bool installed;
  final String transportType;
  final String connectionStatus;
  final String lastErrorCode;
  final int availableToolCount;
  final List<ConversationMcpToolInventoryItem> tools;
}

final class ConversationMcpToolInventoryItem {
  const ConversationMcpToolInventoryItem({
    required this.remoteName,
    required this.canonicalName,
    required this.title,
    required this.description,
    required this.available,
    required this.requiresApproval,
  });

  final String remoteName;
  final String canonicalName;
  final String title;
  final String description;
  final bool available;
  final bool requiresApproval;
}
