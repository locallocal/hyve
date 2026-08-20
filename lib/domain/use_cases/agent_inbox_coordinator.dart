import 'dart:async';

import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/agent_repository.dart';
import 'package:hyve/domain/repositories/agent_run_repository.dart';
import 'package:hyve/domain/repositories/participation_decision_repository.dart';
import 'package:hyve/domain/repositories/project_agent_cursor_repository.dart';
import 'package:hyve/domain/repositories/project_event_repository.dart';
import 'package:hyve/domain/repositories/project_membership_repository.dart';
import 'package:hyve/domain/repositories/project_repository.dart';
import 'package:hyve/domain/repositories/project_turn_repository.dart';
import 'package:hyve/domain/use_cases/execute_project_agent_reply.dart';
import 'package:hyve/domain/use_cases/project_turn_coordinator.dart';
import 'package:hyve/domain/use_cases/run_broadcast_participation.dart';

typedef AgentInboxClock = DateTime Function();
typedef AgentInboxLeaseOwnerFactory = String Function();

final class AgentInboxCoordinator {
  AgentInboxCoordinator({
    required ProjectAgentCursorRepository cursorRepository,
    required ProjectRepository projectRepository,
    required ProjectMembershipRepository membershipRepository,
    required ProjectEventRepository eventRepository,
    required ProjectTurnRepository turnRepository,
    required AgentRunRepository runRepository,
    required ParticipationDecisionRepository decisionRepository,
    required AgentRepository agentRepository,
    required RunBroadcastParticipation runBroadcastParticipation,
    required ExecuteProjectAgentReply executeReply,
    required ProjectTurnCoordinator turnCoordinator,
    AgentInboxClock? clock,
    AgentInboxLeaseOwnerFactory? leaseOwnerFactory,
  }) : _cursorRepository = cursorRepository,
       _projectRepository = projectRepository,
       _membershipRepository = membershipRepository,
       _eventRepository = eventRepository,
       _turnRepository = turnRepository,
       _runRepository = runRepository,
       _decisionRepository = decisionRepository,
       _agentRepository = agentRepository,
       _runBroadcastParticipation = runBroadcastParticipation,
       _executeReply = executeReply,
       _turnCoordinator = turnCoordinator,
       _clock = clock ?? DateTime.now,
       _leaseOwnerFactory =
           leaseOwnerFactory ?? _defaultInboxLeaseOwnerFactory {
    _membershipSubscription = _membershipRepository.changes.listen(
      (projectId) => unawaited(wakeProject(projectId)),
    );
  }

  final ProjectAgentCursorRepository _cursorRepository;
  final ProjectRepository _projectRepository;
  final ProjectMembershipRepository _membershipRepository;
  final ProjectEventRepository _eventRepository;
  final ProjectTurnRepository _turnRepository;
  final AgentRunRepository _runRepository;
  final ParticipationDecisionRepository _decisionRepository;
  final AgentRepository _agentRepository;
  final RunBroadcastParticipation _runBroadcastParticipation;
  final ExecuteProjectAgentReply _executeReply;
  final ProjectTurnCoordinator _turnCoordinator;
  final AgentInboxClock _clock;
  final AgentInboxLeaseOwnerFactory _leaseOwnerFactory;
  final Map<String, Future<void>> _workers = <String, Future<void>>{};
  final Map<String, ProjectRunCancellationToken> _runCancellations =
      <String, ProjectRunCancellationToken>{};
  final Map<String, _ProjectConcurrency> _projectConcurrency =
      <String, _ProjectConcurrency>{};
  final Set<String> _cancelledTurnIds = <String>{};
  late final StreamSubscription<String> _membershipSubscription;
  bool _disposed = false;

  Future<void> start() async {
    await _cursorRepository.recoverInterrupted(_clock());
    final backlogs = await _cursorRepository.getBackloggedActiveInboxes();
    await Future.wait(<Future<void>>[
      for (final key in backlogs) wakeAgent(key.projectId, key.agentId),
    ]);
  }

  Future<void> wakeProject(
    String projectId, [
    Iterable<String>? activeAgentIds,
  ]) async {
    if (_disposed) return;
    final ids =
        activeAgentIds ??
        (await _membershipRepository.getForProject(projectId))
            .where(
              (membership) =>
                  membership.status == ProjectMembershipStatus.active,
            )
            .map((membership) => membership.agentId);
    for (final agentId in ids.toSet()) {
      unawaited(wakeAgent(projectId, agentId));
    }
  }

  Future<void> wakeAgent(String projectId, String agentId) {
    if (_disposed) return Future<void>.value();
    final key = '$projectId\u0000$agentId';
    final existing = _workers[key];
    if (existing != null) return existing;
    final worker = _drain(projectId, agentId);
    _workers[key] = worker;
    return worker.whenComplete(() {
      if (identical(_workers[key], worker)) _workers.remove(key);
    });
  }

  Future<void> waitForIdle({String? projectId}) async {
    while (true) {
      final pending = <Future<void>>[
        for (final entry in _workers.entries)
          if (projectId == null || entry.key.startsWith('$projectId\u0000'))
            entry.value,
      ];
      if (pending.isEmpty) return;
      await Future.wait(pending);
    }
  }

  bool cancelRun(String runId) {
    final token = _runCancellations[runId];
    if (token == null) return false;
    token.cancel();
    return true;
  }

  Future<int> cancelTurn(String turnId) async {
    _cancelledTurnIds.add(turnId);
    var cancelled = 0;
    for (final run in await _runRepository.getForTurn(turnId)) {
      if (!run.isTerminal && cancelRun(run.id)) cancelled++;
    }
    final turn = await _turnRepository.getTurn(turnId);
    if (turn != null && !turn.isTerminal) {
      await _turnRepository.save(
        turn.copyWith(
          status: ProjectTurnStatus.cancelled,
          completedAt: _clock(),
        ),
      );
      await wakeProject(turn.projectId);
    }
    return cancelled;
  }

  Future<void> _drain(String projectId, String agentId) async {
    final leaseOwner = _leaseOwnerFactory();
    while (!_disposed) {
      final claim = await _cursorRepository.claimNext(
        projectId: projectId,
        agentId: agentId,
        leaseOwner: leaseOwner,
        now: _clock(),
      );
      if (claim == null) return;
      try {
        await _process(claim, leaseOwner);
      } on Object {
        await _complete(
          claim,
          leaseOwner,
          outcome: AgentMessageReceiptOutcome.failedSkipped,
          errorCode: 'inbox_message_failed',
        );
      }
    }
  }

  Future<void> _process(AgentMessageClaim claim, String leaseOwner) async {
    final event = claim.event;
    final messageSequence = event.messageSequence!;
    final project = await _projectRepository.getProject(event.projectId);
    final agent = await _agentRepository.getAgent(claim.cursor.agentId);
    final turn = await _turnRepository.getTurn(event.turnId);
    if (project == null || agent == null || turn == null) {
      await _complete(
        claim,
        leaseOwner,
        outcome: AgentMessageReceiptOutcome.failedSkipped,
        errorCode: 'inbox_source_missing',
      );
      return;
    }
    if (await _isTurnCancelled(turn.id)) {
      await _complete(
        claim,
        leaseOwner,
        outcome: AgentMessageReceiptOutcome.cancelled,
        errorCode: 'turn_cancelled',
      );
      return;
    }
    if (event.actorType == ProjectEventActorType.agent &&
        event.actorId == agent.id) {
      await _complete(
        claim,
        leaseOwner,
        outcome: AgentMessageReceiptOutcome.ownMessage,
      );
      return;
    }
    if (event.visibility == ProjectEventVisibility.audit ||
        (event.visibility == ProjectEventVisibility.targets &&
            !event.targetAgentIds.contains(agent.id))) {
      await _complete(
        claim,
        leaseOwner,
        outcome: AgentMessageReceiptOutcome.invisible,
      );
      return;
    }
    if ((turn.routingMode == ProjectTurnRoutingMode.targeted ||
            turn.routingMode == ProjectTurnRoutingMode.broadcast) &&
        !event.targetAgentIds.contains(agent.id)) {
      await _complete(
        claim,
        leaseOwner,
        outcome: AgentMessageReceiptOutcome.notTargeted,
      );
      return;
    }
    if (await _chainLimitReached(project, event)) {
      await _complete(
        claim,
        leaseOwner,
        outcome: AgentMessageReceiptOutcome.chainLimitReached,
      );
      return;
    }

    final visibleHistory = await _eventRepository.getVisibleMessagesThrough(
      project.id,
      agent.id,
      messageSequence,
    );
    var decisionRunId = '';
    if (turn.routingMode == ProjectTurnRoutingMode.broadcast) {
      final existingDecisions = await _decisionRepository.getForTurn(turn.id);
      ParticipationDecision? decision;
      for (final item in existingDecisions) {
        if (item.agentId == agent.id &&
            item.messageSequence == messageSequence) {
          decision = item;
          break;
        }
      }
      if (decision == null) {
        final concurrency = _concurrencyFor(project);
        final execution = await concurrency.decisions.run(
          () async =>
              await _isTurnCancelled(turn.id)
                  ? null
                  : _runBroadcastParticipation(
                    project: project,
                    agent: agent,
                    turn: turn,
                    sourceEvent: event,
                    visibleHistory: visibleHistory,
                    onRunStarted:
                        (run, token) =>
                            _activateRun(claim, leaseOwner, run, token),
                  ),
        );
        if (execution == null) {
          await _complete(
            claim,
            leaseOwner,
            outcome: AgentMessageReceiptOutcome.cancelled,
            errorCode: 'turn_cancelled',
          );
          return;
        }
        _runCancellations.remove(execution.run.id);
        decision = execution.decision;
        if (execution.run.status == AgentRunStatus.cancelled) {
          await _complete(
            claim,
            leaseOwner,
            outcome: AgentMessageReceiptOutcome.cancelled,
            decisionRunId: decision.runId,
            errorCode: 'decision_cancelled',
          );
          return;
        }
      }
      decisionRunId = decision.runId;
      if (decision.choice == ParticipationChoice.pass) {
        await _complete(
          claim,
          leaseOwner,
          outcome: AgentMessageReceiptOutcome.passed,
          decisionRunId: decisionRunId,
        );
        return;
      }
    }

    if (await _isTurnCancelled(turn.id)) {
      await _complete(
        claim,
        leaseOwner,
        outcome: AgentMessageReceiptOutcome.cancelled,
        decisionRunId: decisionRunId,
        errorCode: 'turn_cancelled',
      );
      return;
    }

    final existingReply = await _existingReply(
      turn: turn,
      agentId: agent.id,
      messageSequence: messageSequence,
    );
    if (existingReply != null) {
      await _complete(
        claim,
        leaseOwner,
        outcome: AgentMessageReceiptOutcome.replied,
        decisionRunId: decisionRunId,
        replyRunId: existingReply.$1.id,
        replyEventId: existingReply.$2.id,
      );
      return;
    }

    final concurrency = _concurrencyFor(project);
    final execution = await concurrency.replies.run(
      () async =>
          await _isTurnCancelled(turn.id)
              ? null
              : _executeReply(
                project: project,
                agent: agent,
                turn: turn,
                sourceEvent: event,
                visibleHistory: visibleHistory,
                onRunStarted:
                    (run, token) => _activateRun(claim, leaseOwner, run, token),
              ),
    );
    if (execution == null) {
      await _complete(
        claim,
        leaseOwner,
        outcome: AgentMessageReceiptOutcome.cancelled,
        decisionRunId: decisionRunId,
        errorCode: 'turn_cancelled',
      );
      return;
    }
    _runCancellations.remove(execution.run.id);
    final outcome = switch (execution.result.status) {
      ProjectAgentReplyStatus.completed => AgentMessageReceiptOutcome.replied,
      ProjectAgentReplyStatus.cancelled => AgentMessageReceiptOutcome.cancelled,
      _ => AgentMessageReceiptOutcome.failedSkipped,
    };
    await _complete(
      claim,
      leaseOwner,
      outcome: outcome,
      decisionRunId: decisionRunId,
      replyRunId: execution.run.id,
      replyEventId: execution.replyEvent?.id ?? '',
      errorCode: execution.result.errorCode,
    );
  }

  Future<void> _activateRun(
    AgentMessageClaim claim,
    String leaseOwner,
    AgentRun run,
    ProjectRunCancellationToken token,
  ) async {
    await _cursorRepository.setActiveRun(
      projectId: claim.cursor.projectId,
      agentId: claim.cursor.agentId,
      leaseOwner: leaseOwner,
      runId: run.id,
      now: _clock(),
    );
    _runCancellations[run.id] = token;
  }

  Future<bool> _isTurnCancelled(String turnId) async =>
      _cancelledTurnIds.contains(turnId) ||
      (await _turnRepository.getTurn(turnId))?.status ==
          ProjectTurnStatus.cancelled;

  Future<(AgentRun, ProjectEvent)?> _existingReply({
    required ProjectTurn turn,
    required String agentId,
    required int messageSequence,
  }) async {
    for (final run in await _runRepository.getForTurn(turn.id)) {
      if (run.agentId == agentId &&
          run.phase == AgentRunPhase.reply &&
          run.sourceMessageSequence == messageSequence &&
          run.status == AgentRunStatus.completed) {
        final event = await _eventRepository.getAgentReplyForRun(run.id);
        if (event != null) return (run, event);
      }
    }
    return null;
  }

  Future<bool> _chainLimitReached(Project project, ProjectEvent event) async {
    if (event.actorType != ProjectEventActorType.agent) return false;
    if (event.autonomousDepth >=
        project.responsePolicy.autonomousChainMaxDepth) {
      return true;
    }
    final rootId = event.rootMessageId.isEmpty ? event.id : event.rootMessageId;
    final count = await _eventRepository.countAgentMessagesForRoot(
      project.id,
      rootId,
    );
    return count >=
        project.responsePolicy.autonomousChainMaxAgentMessagesPerRoot;
  }

  Future<void> _complete(
    AgentMessageClaim claim,
    String leaseOwner, {
    required AgentMessageReceiptOutcome outcome,
    String decisionRunId = '',
    String replyRunId = '',
    String replyEventId = '',
    String errorCode = '',
  }) async {
    final now = _clock();
    final receipt = AgentMessageReceipt(
      projectId: claim.cursor.projectId,
      agentId: claim.cursor.agentId,
      messageSequence: claim.event.messageSequence!,
      messageEventId: claim.event.id,
      turnId: claim.event.turnId,
      outcome: outcome,
      decisionRunId: decisionRunId,
      replyRunId: replyRunId,
      replyEventId: replyEventId,
      startedAt: claim.cursor.updatedAt,
      completedAt: now,
      errorCode: errorCode,
    );
    await _cursorRepository.complete(receipt, leaseOwner: leaseOwner);
    await _turnCoordinator.refresh(claim.event.turnId);
  }

  _ProjectConcurrency _concurrencyFor(Project project) =>
      _projectConcurrency.putIfAbsent(
        project.id,
        () => _ProjectConcurrency(
          decisions: _AsyncPool(
            project.responsePolicy.broadcastDecision.concurrency,
          ),
          replies: _AsyncPool(project.responsePolicy.replyConcurrency),
        ),
      );

  Future<void> dispose() async {
    _disposed = true;
    for (final token in _runCancellations.values) {
      token.cancel();
    }
    await _membershipSubscription.cancel();
    await Future.wait(_workers.values);
  }
}

final class _ProjectConcurrency {
  const _ProjectConcurrency({required this.decisions, required this.replies});

  final _AsyncPool decisions;
  final _AsyncPool replies;
}

final class _AsyncPool {
  _AsyncPool(this.limit) : assert(limit > 0);

  final int limit;
  int _active = 0;
  final List<Completer<void>> _waiters = <Completer<void>>[];

  Future<T> run<T>(Future<T> Function() operation) async {
    if (_active >= limit) {
      final waiter = Completer<void>();
      _waiters.add(waiter);
      await waiter.future;
    }
    _active++;
    try {
      return await operation();
    } finally {
      _active--;
      if (_waiters.isNotEmpty) _waiters.removeAt(0).complete();
    }
  }
}

int _inboxLeaseSequence = 0;

String _defaultInboxLeaseOwnerFactory() {
  _inboxLeaseSequence = (_inboxLeaseSequence + 1) & 0x7fffffff;
  return 'inbox:${DateTime.now().microsecondsSinceEpoch}:'
      '$_inboxLeaseSequence';
}
