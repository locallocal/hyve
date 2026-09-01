import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/agent_memory_evolution_repository.dart';
import 'package:hyve/domain/repositories/agent_memory_repository.dart';
import 'package:hyve/domain/repositories/agent_repository.dart';
import 'package:hyve/ui/features/bots/view_models/agent_memory_view_model.dart';
import 'package:hyve/ui/features/bots/views/agent_memory_panel.dart';
import 'package:hyve/ui/features/bots/views/edit_bot.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../support/widget_test_support.dart';

void main() {
  testWidgets('agent details use AgentMemory for all memory actions', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 1100);
    addTearDown(tester.view.reset);

    final agentRepository = _AgentRepository(_agent);
    final memoryRepository = _AgentMemoryRepository(_memory);
    final agentViewModel = AgentMemoryViewModel(
      agentId: _agent.id,
      agentRepository: agentRepository,
      memoryRepository: memoryRepository,
      evolutionRepository: const _AgentMemoryEvolutionRepository(),
    );
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
    expect(contextSection, findsOneWidget);
    expect(tester.widget(contextSection), isA<ShadCard>());
    expect(
      find.byKey(const ValueKey<String>('desktop-bot-agent-memory-section')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('conversation-memory-section-title')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('agent-memory-auto-evolution-switch')),
      findsOneWidget,
    );
    expect(find.byType(SwitchListTile), findsNothing);
    expect(find.text('记忆'), findsOneWidget);
    expect(find.text('智能体记忆'), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('memory-view-summary')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey<String>('memory-manage')), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('memory-compact-now')),
      findsOneWidget,
    );

    final autoEvolutionSwitch = find.byKey(
      const ValueKey<String>('agent-memory-auto-evolution-switch'),
    );
    await tester.ensureVisible(autoEvolutionSwitch);
    await tester.tap(autoEvolutionSwitch);
    await tester.pumpAndSettle();
    expect(agentRepository.agent.memoryPolicy.autoEvolutionEnabled, isFalse);

    final summaryButton = find.byKey(
      const ValueKey<String>('memory-view-summary'),
    );
    await tester.ensureVisible(summaryButton);
    await tester.tap(summaryButton);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('agent-memory-summary-dialog')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('agent-memory-summary-content')),
      findsOneWidget,
    );
    expect(find.textContaining(_memory.content), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey<String>('agent-memory-summary-close')),
    );
    await tester.pumpAndSettle();

    final compactButton = find.byKey(
      const ValueKey<String>('memory-compact-now'),
    );
    await tester.ensureVisible(compactButton);
    await tester.tap(compactButton);
    await tester.pumpAndSettle();
    expect(memoryRepository.requestedAgentIds, everyElement(_agent.id));
    expect(memoryRepository.forgottenIds, isEmpty);

    final manageButton = find.byKey(const ValueKey<String>('memory-manage'));
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

  testWidgets('agent memory displays ten items per page', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 900);
    addTearDown(tester.view.reset);

    final memories = <AgentMemory>[
      for (var index = 1; index <= 21; index++)
        _memory.copyWith(
          id: 'memory-$index',
          content: 'Memory ${index.toString().padLeft(2, '0')}',
        ),
    ];
    final memoryRepository = _AgentMemoryRepository.fromMemories(memories);
    final viewModel = AgentMemoryViewModel(
      agentId: _agent.id,
      agentRepository: _AgentRepository(_agent),
      memoryRepository: memoryRepository,
      evolutionRepository: const _AgentMemoryEvolutionRepository(),
    );
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      shadHarness(
        brightness: Brightness.light,
        homeBuilder:
            (_) => Scaffold(
              body: SizedBox(
                width: 720,
                child: AgentMemoryPanel(viewModel: viewModel),
              ),
            ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('memory-manage')));
    await tester.pumpAndSettle();

    expect(find.text('Memory 01'), findsOneWidget);
    expect(find.text('Memory 11'), findsNothing);
    expect(find.text('1 / 3'), findsOneWidget);
    expect(
      tester
          .widget<ListView>(
            find.byKey(const ValueKey<String>('agent-memory-list-page-1')),
          )
          .semanticChildCount,
      10,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('agent-memory-next-page')),
    );
    await tester.pump();

    expect(find.text('Memory 01'), findsNothing);
    expect(find.text('Memory 11'), findsOneWidget);
    expect(find.text('Memory 21'), findsNothing);
    expect(find.text('2 / 3'), findsOneWidget);
    expect(
      tester
          .widget<ListView>(
            find.byKey(const ValueKey<String>('agent-memory-list-page-2')),
          )
          .semanticChildCount,
      10,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('agent-memory-next-page')),
    );
    await tester.pump();

    expect(find.text('Memory 21'), findsOneWidget);
    expect(find.text('3 / 3'), findsOneWidget);
    expect(
      tester
          .widget<ListView>(
            find.byKey(const ValueKey<String>('agent-memory-list-page-3')),
          )
          .semanticChildCount,
      1,
    );
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
  _AgentMemoryRepository(AgentMemory memory) : memories = <AgentMemory>[memory];

  _AgentMemoryRepository.fromMemories(Iterable<AgentMemory> memories)
    : memories = List<AgentMemory>.of(memories);

  final List<AgentMemory> memories;
  final List<String> requestedAgentIds = <String>[];
  final List<String> forgottenIds = <String>[];

  @override
  Stream<String> get changes => const Stream<String>.empty();

  @override
  Future<List<AgentMemory>> list(
    String agentId, {
    bool includeHistory = false,
  }) async {
    requestedAgentIds.add(agentId);
    return List<AgentMemory>.unmodifiable(memories);
  }

  @override
  Future<AgentMemoryMutationResult> forget({
    required String agentId,
    required String memoryId,
    int? expectedRevision,
  }) async {
    requestedAgentIds.add(agentId);
    forgottenIds.add(memoryId);
    final memory = memories.firstWhere((item) => item.id == memoryId);
    return AgentMemoryMutationResult(memory: memory, revision: 1);
  }

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
