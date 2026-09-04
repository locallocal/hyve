import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/views/project_execution_panel.dart';

import '../../../../support/widget_test_support.dart';

void main() {
  testWidgets('embedded execution page can return to messages', (tester) async {
    var closeCount = 0;

    await tester.pumpWidget(
      shadHarness(
        brightness: Brightness.light,
        locale: const Locale('en'),
        homeBuilder:
            (_) => SizedBox(
              width: 700,
              height: 600,
              child: ProjectExecutionPanel(
                embedded: true,
                turns: const <String, ProjectTurn>{},
                runs: const <String, AgentRun>{},
                decisions: const <String, ParticipationDecision>{},
                usageRecords: const <ModelTokenUsageRecord>[],
                events: const <ProjectEvent>[],
                agentNames: const <String, String>{},
                onCancelRun: (_) {},
                onCancelTurn: (_) {},
                onCancelRootChain: (_) {},
                onClose: () => closeCount += 1,
              ),
            ),
      ),
    );
    await tester.pumpAndSettle();

    final close = find.byKey(const ValueKey<String>('project-execution-close'));
    expect(close, findsOneWidget);
    final backButton = tester.widget<ShadIconButton>(
      find.descendant(of: close, matching: find.byType(ShadIconButton)),
    );
    expect(backButton.variant, ShadButtonVariant.outline);
    await tester.tap(close);
    await tester.pump();

    expect(closeCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows run chain, usage, errors, context IDs, and cancellation', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final now = DateTime.utc(2026, 8, 22);
    final turn = _turn(now);
    final run = _run(now);
    String? cancelledRun;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        home: Scaffold(
          body: SizedBox(
            width: 900,
            height: 700,
            child: ProjectExecutionPanel(
              embedded: true,
              turns: <String, ProjectTurn>{turn.id: turn},
              runs: <String, AgentRun>{run.id: run},
              decisions: <String, ParticipationDecision>{
                run.id: ParticipationDecision(
                  runId: run.id,
                  agentId: run.agentId,
                  projectId: run.projectId,
                  turnId: run.turnId,
                  messageSequence: 1,
                  choice: ParticipationChoice.reply,
                  reasonCode: 'relevant',
                  createdAt: now,
                ),
              },
              usageRecords: <ModelTokenUsageRecord>[
                ModelTokenUsageRecord(
                  messageId: 'usage-1',
                  chatId: 'project-1',
                  botId: 'agent-1',
                  runId: run.id,
                  timestamp: now,
                  usage: const ModelTokenUsage(
                    inputTokens: 120,
                    outputTokens: 30,
                  ),
                ),
              ],
              events: const <ProjectEvent>[],
              agentNames: const <String, String>{'agent-1': 'Researcher'},
              onCancelRun: (id) => cancelledRun = id,
              onCancelTurn: (_) {},
              onCancelRootChain: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Runs: 1'), findsOneWidget);
    expect(find.textContaining('Token usage · 150'), findsOneWidget);
    await tester.tap(find.byKey(ValueKey<String>('project-turn-${turn.id}')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(ValueKey<String>('project-run-${run.id}')),
      findsOneWidget,
    );
    expect(find.textContaining('Input 120 · output 30'), findsOneWidget);

    await tester.tap(find.byKey(ValueKey<String>('project-run-${run.id}')));
    await tester.pumpAndSettle();
    expect(find.textContaining('summary-1'), findsOneWidget);
    expect(find.textContaining('memory-1'), findsOneWidget);

    await tester.tap(find.byTooltip('Cancel run'));
    await tester.pumpAndSettle();

    expect(cancelledRun, isNull);
    expect(find.text('Cancel this run?'), findsOneWidget);
    expect(
      find.text(
        'Only this run will stop. Other active runs in the turn will continue.',
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(ValueKey<String>('confirm-cancel-run-${run.id}')),
    );
    await tester.pumpAndSettle();

    expect(cancelledRun, run.id);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('uses consistent Shad cancellation actions and confirmations', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 8, 31);
    final turn = _turn(now);
    final run = _run(now);
    String? cancelledRun;
    String? cancelledTurn;
    String? cancelledRootChain;

    await tester.pumpWidget(
      shadHarness(
        brightness: Brightness.light,
        locale: const Locale('en'),
        homeBuilder:
            (_) => SizedBox(
              width: 420,
              height: 700,
              child: ProjectExecutionPanel(
                embedded: true,
                turns: <String, ProjectTurn>{turn.id: turn},
                runs: <String, AgentRun>{run.id: run},
                decisions: const <String, ParticipationDecision>{},
                usageRecords: const <ModelTokenUsageRecord>[],
                events: const <ProjectEvent>[],
                agentNames: const <String, String>{'agent-1': 'Researcher'},
                onCancelRun: (id) => cancelledRun = id,
                onCancelTurn: (id) => cancelledTurn = id,
                onCancelRootChain: (id) => cancelledRootChain = id,
              ),
            ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(ValueKey<String>('project-turn-${turn.id}')));
    await tester.pumpAndSettle();

    final cancelTurn = find.byKey(ValueKey<String>('cancel-turn-${turn.id}'));
    final cancelRootChain = find.byKey(
      ValueKey<String>('cancel-root-chain-${run.rootRunId}'),
    );
    final cancelRun = find.byKey(ValueKey<String>('cancel-run-${run.id}'));

    expect(cancelTurn, findsOneWidget);
    expect(cancelRootChain, findsOneWidget);
    expect(cancelRun, findsOneWidget);
    for (final action in <Finder>[cancelTurn, cancelRootChain]) {
      final button = tester.widget<ShadButton>(
        find.descendant(of: action, matching: find.byType(ShadButton)),
      );
      expect(button.variant, ShadButtonVariant.outline);
    }
    final runButton = tester.widget<ShadIconButton>(
      find.descendant(of: cancelRun, matching: find.byType(ShadIconButton)),
    );
    expect(runButton.variant, ShadButtonVariant.outline);

    await tester.tap(cancelTurn);
    await tester.pumpAndSettle();

    expect(cancelledTurn, isNull);
    expect(find.byType(ShadDialog), findsOneWidget);
    expect(find.text('Cancel this turn?'), findsOneWidget);
    final confirmTurn = find.byKey(
      ValueKey<String>('confirm-cancel-turn-${turn.id}'),
    );
    expect(
      tester.widget<ShadButton>(confirmTurn).variant,
      ShadButtonVariant.destructive,
    );
    await tester.tap(confirmTurn);
    await tester.pumpAndSettle();
    expect(cancelledTurn, turn.id);

    await tester.tap(cancelRootChain);
    await tester.pumpAndSettle();

    expect(cancelledRootChain, isNull);
    expect(find.text('Cancel this root message chain?'), findsOneWidget);
    await tester.tap(
      find.byKey(
        ValueKey<String>('confirm-cancel-root-chain-${run.rootRunId}'),
      ),
    );
    await tester.pumpAndSettle();
    expect(cancelledRootChain, run.rootRunId);

    await tester.tap(cancelRun);
    await tester.pumpAndSettle();

    expect(cancelledRun, isNull);
    expect(find.text('Cancel this run?'), findsOneWidget);
    await tester.tap(
      find.byKey(ValueKey<String>('confirm-cancel-run-${run.id}')),
    );
    await tester.pumpAndSettle();
    expect(cancelledRun, run.id);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses Chinese project copy when the locale is Chinese', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('zh', 'CN'),
        supportedLocales: <Locale>[Locale('zh', 'CN'), Locale('en')],
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: SizedBox(
            width: 500,
            height: 500,
            child: ProjectExecutionPanel(
              embedded: true,
              turns: <String, ProjectTurn>{},
              runs: <String, AgentRun>{},
              decisions: <String, ParticipationDecision>{},
              usageRecords: <ModelTokenUsageRecord>[],
              events: <ProjectEvent>[],
              agentNames: <String, String>{},
              onCancelRun: _ignore,
              onCancelTurn: _ignore,
              onCancelRootChain: _ignore,
            ),
          ),
        ),
      ),
    );

    expect(find.text('执行详情'), findsOneWidget);
    expect(find.text('暂无执行记录'), findsOneWidget);
  });

  testWidgets('localizes invalid and timed out participation decisions', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 8, 30);
    final turn = _turn(now);
    final invalidRun = _run(
      now,
      id: 'invalid-run',
      phase: AgentRunPhase.decision,
      status: AgentRunStatus.failed,
      errorCode: 'decision_invalid',
    );
    final timedOutRun = _run(
      now,
      id: 'timed-out-run',
      phase: AgentRunPhase.decision,
      status: AgentRunStatus.timedOut,
      errorCode: 'decision_timeout',
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh', 'CN'),
        supportedLocales: const <Locale>[Locale('zh', 'CN'), Locale('en')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: SizedBox(
            width: 900,
            height: 700,
            child: ProjectExecutionPanel(
              embedded: true,
              turns: <String, ProjectTurn>{turn.id: turn},
              runs: <String, AgentRun>{
                invalidRun.id: invalidRun,
                timedOutRun.id: timedOutRun,
              },
              decisions: <String, ParticipationDecision>{
                invalidRun.id: _decision(
                  invalidRun,
                  now,
                  reasonCode: 'decision_invalid',
                ),
                timedOutRun.id: _decision(
                  timedOutRun,
                  now,
                  reasonCode: 'decision_timeout',
                ),
              },
              usageRecords: const <ModelTokenUsageRecord>[],
              events: const <ProjectEvent>[],
              agentNames: const <String, String>{'agent-1': 'Researcher'},
              onCancelRun: _ignore,
              onCancelTurn: _ignore,
              onCancelRootChain: _ignore,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(ValueKey<String>('project-turn-${turn.id}')));
    await tester.pumpAndSettle();

    expect(find.textContaining('跳过 · 判断结果格式无效'), findsOneWidget);
    expect(find.textContaining('错误：判断结果格式无效'), findsOneWidget);
    expect(find.textContaining('跳过 · 判断超时'), findsOneWidget);
    expect(find.textContaining('错误：判断超时'), findsOneWidget);
    expect(find.textContaining('decision_invalid'), findsNothing);
    expect(find.textContaining('decision_timeout'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('paginates execution history and navigates between pages', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 8, 24);
    final turns = <String, ProjectTurn>{
      for (var index = 1; index <= 11; index += 1)
        'turn-$index': _turn(
          now.add(Duration(minutes: index)),
          id: 'turn-$index',
          sourceMessageSequence: index,
        ),
    };
    final turnsNotifier = ValueNotifier<Map<String, ProjectTurn>>(turns);
    addTearDown(turnsNotifier.dispose);

    await tester.pumpWidget(
      shadHarness(
        brightness: Brightness.light,
        locale: const Locale('en'),
        homeBuilder:
            (_) => SizedBox(
              width: 900,
              height: 700,
              child: ValueListenableBuilder<Map<String, ProjectTurn>>(
                valueListenable: turnsNotifier,
                builder:
                    (context, currentTurns, _) => ProjectExecutionPanel(
                      embedded: true,
                      turns: currentTurns,
                      runs: const <String, AgentRun>{},
                      decisions: const <String, ParticipationDecision>{},
                      usageRecords: const <ModelTokenUsageRecord>[],
                      events: const <ProjectEvent>[],
                      agentNames: const <String, String>{},
                      onCancelRun: _ignore,
                      onCancelTurn: _ignore,
                      onCancelRootChain: _ignore,
                    ),
              ),
            ),
      ),
    );

    expect(find.text('1 / 2'), findsOneWidget);
    expect(find.text('#11 · broadcast'), findsOneWidget);
    expect(find.text('#1 · broadcast'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey<String>('project-execution-next-page')),
    );
    await tester.pump();

    expect(find.text('2 / 2'), findsOneWidget);
    expect(find.text('#11 · broadcast'), findsNothing);
    expect(find.text('#1 · broadcast'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('project-execution-previous-page')),
    );
    await tester.pump();

    expect(find.text('1 / 2'), findsOneWidget);
    expect(find.text('#11 · broadcast'), findsOneWidget);
    expect(find.text('#1 · broadcast'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey<String>('project-execution-next-page')),
    );
    await tester.pump();

    turnsNotifier.value = <String, ProjectTurn>{'turn-11': turns['turn-11']!};
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('project-execution-page-indicator')),
      findsNothing,
    );
    expect(find.text('#11 · broadcast'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('separates Shad audit history from broadcast runs', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 8, 23);
    final turn = _turn(now);
    final run = _run(now);
    final audit = ProjectEvent(
      id: 'audit-1',
      projectId: 'project-1',
      sequence: 1,
      eventType: ProjectEventType.systemNotice,
      actorType: ProjectEventActorType.system,
      actorNameSnapshot: 'System',
      visibility: ProjectEventVisibility.audit,
      payload: const SystemNoticePayload(code: 'run_started'),
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      shadHarness(
        brightness: Brightness.light,
        homeBuilder:
            (_) => SizedBox(
              width: 900,
              height: 700,
              child: ProjectExecutionPanel(
                embedded: true,
                turns: <String, ProjectTurn>{turn.id: turn},
                runs: <String, AgentRun>{run.id: run},
                decisions: const <String, ParticipationDecision>{},
                usageRecords: const <ModelTokenUsageRecord>[],
                events: <ProjectEvent>[audit],
                agentNames: const <String, String>{'agent-1': 'Researcher'},
                onCancelRun: _ignore,
                onCancelTurn: _ignore,
                onCancelRootChain: _ignore,
              ),
            ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ShadAccordion<String>), findsWidgets);
    expect(find.byType(ExpansionTile), findsNothing);
    expect(find.byType(ListTile), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('project-execution-list')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('project-audit-events-list')),
      findsNothing,
    );
    expect(find.text('systemNotice'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey<String>('project-execution-audits-tab')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('project-execution-list')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('project-audit-events-list')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('project-audit-events-card')),
      findsOneWidget,
    );
    expect(find.text('systemNotice'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('project-execution-runs-tab')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(ValueKey<String>('project-turn-${turn.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey<String>('project-run-${run.id}')));
    await tester.pumpAndSettle();

    expect(find.textContaining('summary-1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports retained offstage layout in expanding Shad tabs', (
    tester,
  ) async {
    await tester.pumpWidget(
      shadHarness(
        brightness: Brightness.light,
        homeBuilder:
            (_) => SizedBox(
              width: 368,
              height: 700,
              child: ShadTabs<int>(
                value: 0,
                maintainState: true,
                tabs: <ShadTab<int>>[
                  const ShadTab<int>(
                    value: 0,
                    expandContent: true,
                    content: SizedBox.shrink(),
                    child: Text('Artifacts tab'),
                  ),
                  ShadTab<int>(
                    value: 1,
                    expandContent: true,
                    content: const ProjectExecutionPanel(
                      embedded: true,
                      turns: <String, ProjectTurn>{},
                      runs: <String, AgentRun>{},
                      decisions: <String, ParticipationDecision>{},
                      usageRecords: <ModelTokenUsageRecord>[],
                      events: <ProjectEvent>[],
                      agentNames: <String, String>{},
                      onCancelRun: _ignore,
                      onCancelTurn: _ignore,
                      onCancelRootChain: _ignore,
                    ),
                    child: const Text('Execution tab'),
                  ),
                ],
              ),
            ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Execution tab'));
    await tester.pumpAndSettle();

    expect(find.text('暂无执行记录'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _ignore(String _) {}

ProjectTurn _turn(
  DateTime now, {
  String id = 'turn-1',
  int sourceMessageSequence = 1,
}) => ProjectTurn(
  id: id,
  projectId: 'project-1',
  rootEventId: 'event-$sourceMessageSequence',
  initiatorType: ProjectTurnInitiatorType.user,
  routingMode: ProjectTurnRoutingMode.broadcast,
  sourceMessageId: 'event-$sourceMessageSequence',
  sourceMessageSequence: sourceMessageSequence,
  recipientCount: 1,
  rootTurnId: id,
  status: ProjectTurnStatus.replying,
  createdAt: now,
);

AgentRun _run(
  DateTime now, {
  String id = 'run-1',
  AgentRunPhase phase = AgentRunPhase.reply,
  AgentRunStatus status = AgentRunStatus.running,
  String errorCode = '',
}) => AgentRun(
  id: id,
  projectId: 'project-1',
  turnId: 'turn-1',
  agentId: 'agent-1',
  sourceMessageEventId: 'event-1',
  sourceMessageSequence: 1,
  contextThroughMessageSequence: 1,
  rootRunId: id,
  phase: phase,
  status: status,
  agentSnapshot: const AgentRunSnapshot(
    agentName: 'Researcher',
    provider: 'test',
    model: 'model',
    systemPromptDigest: 'prompt',
    capabilityDigest: 'capability',
  ),
  contextReport: AgentRunContextReport(
    conversationSummarySegmentIds: const <String>['summary-1'],
    agentMemoryIds: const <String>['memory-1'],
    toolNames: const <String>['project.artifact.search'],
  ),
  errorCode: errorCode,
  startedAt: now,
  createdAt: now,
);

ParticipationDecision _decision(
  AgentRun run,
  DateTime now, {
  required String reasonCode,
}) => ParticipationDecision(
  runId: run.id,
  agentId: run.agentId,
  projectId: run.projectId,
  turnId: run.turnId,
  messageSequence: run.sourceMessageSequence,
  choice: ParticipationChoice.pass,
  reasonCode: reasonCode,
  createdAt: now,
);
