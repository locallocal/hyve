import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/ai_provider_repository.dart';
import 'package:stars/domain/repositories/mcp_server_repository.dart';

typedef BotFormMcpCatalog =
    ({
      List<McpServer> servers,
      Map<String, List<McpToolDescriptor>> toolsByServer,
    });

final class BotRuntimeCapabilities {
  const BotRuntimeCapabilities({
    required this.supportsMcp,
    required this.supportsAutomaticSkillActivation,
    required this.inputModalities,
    required this.outputModalities,
  });

  final bool supportsMcp;
  final bool supportsAutomaticSkillActivation;
  final List<InputModality> inputModalities;
  final List<OutputModality> outputModalities;
}

final class BotFormViewModel {
  const BotFormViewModel({
    required McpServerRepository mcpServerRepository,
    required AiProviderRepository aiProviderRepository,
  }) : _mcpServers = mcpServerRepository,
       _providers = aiProviderRepository;

  final McpServerRepository _mcpServers;
  final AiProviderRepository _providers;

  Future<BotFormMcpCatalog> loadMcpCatalog() async {
    final servers = await _mcpServers.getServers();
    final tools = await Future.wait(
      servers.map(
        (server) async => (server.id, await _mcpServers.getTools(server.id)),
      ),
    );
    return (
      servers: List<McpServer>.unmodifiable(servers),
      toolsByServer: Map<String, List<McpToolDescriptor>>.unmodifiable({
        for (final entry in tools)
          entry.$1: List<McpToolDescriptor>.unmodifiable(entry.$2),
      }),
    );
  }

  Future<AiModelInfo?> loadModelInfo(Bot bot) => _providers.getModelInfo(bot);

  BotRuntimeCapabilities resolveCapabilities(Bot bot) {
    final provider = _providers.create(bot);
    return BotRuntimeCapabilities(
      supportsMcp: bot.configuredSupportsMcp ?? provider.supportMcp(),
      supportsAutomaticSkillActivation:
          bot.configuredSupportsAutomaticSkillActivation ??
          provider.capabilities.supportsAutomaticSkillActivation,
      inputModalities:
          bot.configuredInputModalities ?? provider.getInputModalites(),
      outputModalities:
          bot.configuredOutputModalities ?? provider.getOutputModalites(),
    );
  }
}
