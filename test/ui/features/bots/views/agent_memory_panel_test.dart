import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/agent_memory_evolution_repository.dart';
import 'package:hyve/domain/repositories/agent_memory_repository.dart';
import 'package:hyve/domain/repositories/agent_repository.dart';
import 'package:hyve/domain/repositories/context_summarizer.dart';
import 'package:hyve/domain/repositories/conversation_memory_repository.dart';
import 'package:hyve/domain/repositories/message_repository.dart';
import 'package:hyve/domain/use_cases/compact_conversation.dart';
import 'package:hyve/ui/features/bots/view_models/agent_memory_view_model.dart';
import 'package:hyve/ui/features/bots/views/edit_bot.dart';
import 'package:hyve/ui/features/chat/view_models/conversation_memory_view_model.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../support/widget_test_support.dart';

void main() {
  testWidgets('agent details host context and long-term memory Shad sections', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 1100);
    addTearDown(tester.view.reset);

    final conversationRepository = _ConversationMemoryRepository();
    final conversationViewModel = ConversationMemoryViewModel(
      chatId: 'project-1',
      bot: _bot,
      repository: conversationRepository,
      compactConversation: CompactConversation(
        messageRepository: _MessageRepository(),
        memoryRepository: conversationRepository,
        summarizerFactory: (_) => const _ContextSummarizer(),
      ),
    );
    final agentRepository = _AgentRepository(_agent);
    final agentViewModel = AgentMemoryViewModel(
      agentId: _agent.id,
      agentRepository: agentRepository,
      memoryRepository: _AgentMemoryRepository(_memory),
      evolutionRepository: const _AgentMemoryEvolutionRepository(),
    );
    addTearDown(conversationViewModel.dispose);
    addTearDown(agentViewModel.dispose);

    await tester.pumpWidget(
      shadHarness(
        brightness: Brightness.light,
        homeBuilder:
            (context) => Scaffold(
              body: EditBotPage(
                bot: _bot,
                embedded: true,
                readOnly: true,
                conversationMemoryViewModel: conversationViewModel,
                agentMemoryViewModel: agentViewModel,
                onBotUpdated: (_) async {},
                onBotDeleted: () async {},
              ),
            ),
      ),
    );
    await tester.pumpAndSettle();

    final contextSection = find.byKey(
      const ValueKey<String>('desktop-bot-context-memory-section'),
    );
    final agentSection = find.byKey(
      const ValueKey<String>('desktop-bot-agent-memory-section'),
    );
    expect(contextSection, findsOneWidget);
    expect(agentSection, findsOneWidget);
    expect(tester.widget(contextSection), isA<ShadCard>());
    expect(tester.widget(agentSection), isA<ShadCard>());
    expect(
      find.byKey(const ValueKey<String>('conversation-memory-section-title')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('agent-memory-auto-evolution-switch')),
      findsOneWidget,
    );
    expect(find.byType(SwitchListTile), findsNothing);
    expect(find.text('上下文与记忆'), findsOneWidget);
    expect(find.text('智能体记忆'), findsOneWidget);

    final autoEvolutionSwitch = find.byKey(
      const ValueKey<String>('agent-memory-auto-evolution-switch'),
    );
    await tester.ensureVisible(autoEvolutionSwitch);
    await tester.tap(autoEvolutionSwitch);
    await tester.pumpAndSettle();
    expect(agentRepository.agent.memoryPolicy.autoEvolutionEnabled, isFalse);

    final manageButton = find.byKey(
      const ValueKey<String>('manage-agent-memory'),
    );
    await tester.ensureVisible(manageButton);
    await tester.tap(manageButton);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('agent-memory-manager-dialog')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('agent-memory-item-memory-1')),
      findsOneWidget,
    );
    expect(find.byType(ShadDialog), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(ListTile), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

final _bot = Bot(
  id: 'agent-1',
  name: 'Researcher',
  avatar: '',
  provider: 'OpenAI',
  baseURL: 'https://example.invalid',
  apiKey: '',
  apiType: Bot.apiTypeOpenAI,
  model: 'gpt-test',
  systemPrompt: 'Research carefully.',
  createTimestamp: DateTime(2026),
  modifyTimestamp: DateTime(2026),
);

final _agent = Agent(
  id: _bot.id,
  name: _bot.name,
  avatar: _bot.avatar,
  provider: _bot.provider,
  baseUrl: _bot.baseURL,
  apiKey: _bot.apiKey,
  apiType: _bot.apiType,
  model: _bot.model,
  systemPrompt: _bot.systemPrompt,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

final _memory = AgentMemory(
  id: 'memory-1',
  agentId: _agent.id,
  memoryKey: 'preference.output',
  kind: AgentMemoryKind.userPreference,
  content: 'Prefer concise research summaries.',
  state: AgentMemoryState.active,
  reuseScope: AgentMemoryReuseScope.crossProject,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

final class _AgentRepository implements AgentRepository {
  _AgentRepository(this.agent);

  Agent agent;

  @override
  Stream<List<Agent>> get changes => const Stream<List<Agent>>.empty();

  @override
  Future<Agent?> getAgent(String id) async => agent;

  @override
  Future<void> updateAgent(Agent updated) async => agent = updated;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _AgentMemoryRepository implements AgentMemoryRepository {
  const _AgentMemoryRepository(this.memory);

  final AgentMemory memory;

  @override
  Stream<String> get changes => const Stream<String>.empty();

  @override
  Future<List<AgentMemory>> list(
    String agentId, {
    bool includeHistory = false,
  }) async => <AgentMemory>[memory];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _AgentMemoryEvolutionRepository
    implements AgentMemoryEvolutionRepository {
  const _AgentMemoryEvolutionRepository();

  @override
  Future<List<AgentMemoryEvolutionRun>> getForAgent(
    String agentId, {
    int limit = 50,
  }) async => const <AgentMemoryEvolutionRun>[];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _ConversationMemoryRepository
    implements ConversationMemoryRepository {
  @override
  Stream<String> get changes => const Stream<String>.empty();

  @override
  Future<ConversationSummaryDocument?> getActiveSummary(String chatId) async =>
      null;

  @override
  Future<List<ConversationMemoryItem>> getItems(String chatId) async =>
      const <ConversationMemoryItem>[];

  @override
  Future<ConversationMemoryState> getState(String chatId) async =>
      ConversationMemoryState(chatId: chatId, updatedAt: DateTime(2026));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _MessageRepository implements MessageRepository {
  @override
  Stream<void> get changes => const Stream<void>.empty();

  @override
  Future<List<Message>> getMessages(String chatId) async => const <Message>[];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _ContextSummarizer implements ContextSummarizer {
  const _ContextSummarizer();

  @override
  Future<ContextSummaryResult> summarize(ContextSummaryRequest request) =>
      throw UnsupportedError('Compaction is not used by this test.');
}
