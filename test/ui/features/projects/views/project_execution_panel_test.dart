import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/views/project_execution_panel.dart';

import '../../../../support/widget_test_support.dart';

void main() {
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
    expect(cancelledRun, run.id);
    expect(tester.takeException(), isNull);
    semantics.dispose();
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

  testWidgets('renders execution details without a Material ancestor', (
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
    expect(find.text('systemNotice'), findsOneWidget);

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

ProjectTurn _turn(DateTime now) => ProjectTurn(
  id: 'turn-1',
  projectId: 'project-1',
  rootEventId: 'event-1',
  initiatorType: ProjectTurnInitiatorType.user,
  routingMode: ProjectTurnRoutingMode.broadcast,
  sourceMessageId: 'event-1',
  sourceMessageSequence: 1,
  recipientCount: 1,
  rootTurnId: 'turn-1',
  status: ProjectTurnStatus.replying,
  createdAt: now,
);

AgentRun _run(DateTime now) => AgentRun(
  id: 'run-1',
  projectId: 'project-1',
  turnId: 'turn-1',
  agentId: 'agent-1',
  sourceMessageEventId: 'event-1',
  sourceMessageSequence: 1,
  contextThroughMessageSequence: 1,
  rootRunId: 'run-1',
  phase: AgentRunPhase.reply,
  status: AgentRunStatus.running,
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
  startedAt: now,
  createdAt: now,
);
