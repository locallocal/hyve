final class InstalledSkillInventoryItem {
  const InstalledSkillInventoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    required this.scope,
    required this.trustState,
    required this.validationStatus,
    required this.signatureStatus,
    required this.boundBotCount,
    required this.enabledBotCount,
    required this.installedAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final String version;
  final String scope;
  final String trustState;
  final String validationStatus;
  final String signatureStatus;
  final int boundBotCount;
  final int enabledBotCount;
  final DateTime installedAt;
  final DateTime updatedAt;
}

final class InstalledSkillInventoryPage {
  const InstalledSkillInventoryPage({
    required this.items,
    required this.truncated,
  });

  final List<InstalledSkillInventoryItem> items;
  final bool truncated;
}

final class ConversationSkillInventoryItem {
  const ConversationSkillInventoryItem({
    required this.id,
    required this.name,
    required this.version,
    required this.scope,
    required this.installed,
    required this.bundled,
    required this.available,
    required this.configuredEnabled,
    required this.pinnedToConversation,
    required this.activationMode,
    required this.priority,
    required this.lastActivationStatus,
    this.lastActivatedAt,
  });

  final String id;
  final String name;
  final String version;
  final String scope;
  final bool installed;
  final bool bundled;
  final bool available;
  final bool configuredEnabled;
  final bool pinnedToConversation;
  final String activationMode;
  final int priority;
  final String lastActivationStatus;
  final DateTime? lastActivatedAt;
}
