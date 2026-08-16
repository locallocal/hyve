import 'package:hyve/domain/models/models.dart';

/// Domain-facing capability used to refresh and inspect MCP catalogs.
abstract interface class McpCatalogController {
  McpStdioProcessInfo? getStdioProcessInfo(String serverId);

  Future<void> hydrateFromCache();

  Future<McpServer> refreshServer(String serverId);

  Future<void> disconnect(McpServer server);
}

/// Domain-facing capability for online Skill catalogs.
abstract interface class SkillCatalogController {
  Future<List<OnlineSkillCatalogEntry>> refresh(SkillCatalogSource catalog);

  Future<SkillDescriptor> install(OnlineSkillCatalogEntry entry);

  Future<List<OnlineSkillCatalogEntry>> availableUpdates();

  Future<void> applyAutomaticUpdates();

  Future<void> refreshConfiguredCatalogs();
}

/// Domain-facing capability for executable scripts provided by Skills.
abstract interface class SkillScriptCatalogController {
  Future<SkillSandboxStatus> sandboxStatus();

  Future<bool> hasToolManifest(SkillDescriptor skill);

  Future<bool> isEnabled(SkillDescriptor skill);

  Future<void> setEnabled(SkillDescriptor skill, bool enabled);

  Future<void> hydrateFromCache();
}
