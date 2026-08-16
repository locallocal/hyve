import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/use_cases/bot_commands.dart';

void main() {
  test('BuildBot creates the current capability and MCP parameter shape', () {
    final createdAt = DateTime.utc(2026, 8, 14);
    final bot = const BuildBot()(
      BotDraft(
        id: 'bot',
        name: ' Name ',
        avatar: '',
        provider: ' Provider ',
        baseUrl: ' https://example.com ',
        apiKey: ' key ',
        apiType: Bot.apiTypeOpenAI,
        model: ' model ',
        systemPrompt: ' prompt ',
        supportsMcp: true,
        supportsAutomaticSkillActivation: true,
        supportsSkills: true,
        contextWindowTokens: 128000,
        inputModalities: [InputModality.text, InputModality.image],
        outputModalities: [OutputModality.text],
        mcpServerIds: {'server-b', 'server-a'},
        mcpTools: {},
        createdAt: createdAt,
        modifiedAt: createdAt,
      ),
    );

    expect(bot.name, 'Name');
    expect(bot.provider, 'Provider');
    expect(bot.baseURL, 'https://example.com');
    expect(bot.configuredSupportsMcp, isTrue);
    expect(bot.configuredSupportsAutomaticSkillActivation, isTrue);
    expect(bot.configuredContextWindowTokens, 128000);
    expect(bot.mcpServerIds, {'server-a', 'server-b'});
    expect(bot.configuredInputModalities, [
      InputModality.text,
      InputModality.image,
    ]);
  });

  test('BuildBot removes MCP selections when capability is disabled', () {
    final now = DateTime.utc(2026, 8, 14);
    final bot = const BuildBot()(
      BotDraft(
        id: 'bot',
        name: 'Bot',
        avatar: '',
        provider: 'Provider',
        baseUrl: 'https://example.com',
        apiKey: 'key',
        apiType: Bot.apiTypeOpenAI,
        model: 'model',
        systemPrompt: '',
        supportsMcp: false,
        supportsAutomaticSkillActivation: false,
        mcpServerIds: {'server'},
        mcpTools: {},
        createdAt: now,
        modifiedAt: now,
      ),
    );

    expect(bot.mcpServerIds, isEmpty);
    expect(bot.mcpTools, isEmpty);
  });
}
