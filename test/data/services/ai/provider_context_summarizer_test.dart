import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/data/services/ai/provider_context_summarizer.dart';
import 'package:hyve/domain/models/ai_models.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/ai_provider_repository.dart';
import 'package:hyve/domain/repositories/context_summarizer.dart';
import 'package:hyve/domain/services/hyve_system_prompt.dart';

void main() {
  test('prepends Hyve context to the summarization request', () async {
    final provider = _SummaryProvider();
    final summarizer = ProviderContextSummarizer(
      bot: _bot,
      providerFactory: (_) => provider,
      hyveSystemPromptProvider: _testHyveSystemPrompt,
    );

    await summarizer.summarize(
      ContextSummaryRequest(
        chatId: 'chat-1',
        summaryId: 'summary-1',
        sourceMessages: [
          Message(
            messageId: 'message-1',
            chatId: 'chat-1',
            botId: _bot.id,
            senderId: 'user-1',
            content: 'Keep this short.',
            timestamp: DateTime(2026),
          ),
        ],
        targetTokens: 500,
      ),
    );

    expect(provider.messages, hasLength(2));
    expect(provider.messages.first.role, 'system');
    expect(
      provider.messages.first.content,
      startsWith('<hyve_application_context>'),
    );
    expect(
      provider.messages.first.content,
      contains('You compress conversation data.'),
    );
    expect(provider.messages.last.role, 'user');
  });
}

final class _SummaryProvider extends AiProvider {
  _SummaryProvider() : super(_bot);

  List<ChatMessage> messages = const [];

  @override
  Future<void> generateText(List<ChatMessage> messages) async {
    this.messages = List.unmodifiable(messages);
    onResponse('''
{"schema_version":1,"narrative_summary":"","facts":[],"preferences":[],"decisions":[],"open_tasks":[],"unresolved_questions":[],"artifact_references":[]}
''');
  }
}

final _bot = Bot(
  id: 'bot-1',
  name: 'Bot',
  avatar: '',
  provider: 'test',
  baseURL: '',
  apiKey: '',
  apiType: Bot.apiTypeOpenAI,
  model: 'test-model',
  systemPrompt: '',
  createTimestamp: DateTime(2026),
  modifyTimestamp: DateTime(2026),
);

String _testHyveSystemPrompt() => buildHyveSystemPrompt(
  operatingSystem: 'TestOS',
  operatingSystemVersion: '1.2.3',
);
