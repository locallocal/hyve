import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/agent_message_receipt_repository.dart';
import 'package:hyve/domain/repositories/agent_run_repository.dart';
import 'package:hyve/domain/repositories/project_event_repository.dart';
import 'package:hyve/domain/repositories/project_turn_repository.dart';

final class ProjectTurnCoordinator {
  const ProjectTurnCoordinator({
    required ProjectTurnRepository turnRepository,
    required ProjectEventRepository eventRepository,
    required AgentMessageReceiptRepository receiptRepository,
    required AgentRunRepository runRepository,
  }) : _turnRepository = turnRepository,
       _eventRepository = eventRepository,
       _receiptRepository = receiptRepository,
       _runRepository = runRepository;

  final ProjectTurnRepository _turnRepository;
  final ProjectEventRepository _eventRepository;
  final AgentMessageReceiptRepository _receiptRepository;
  final AgentRunRepository _runRepository;

  Future<ProjectTurn?> refresh(String turnId) async {
    final turn = await _turnRepository.getTurn(turnId);
    if (turn == null || turn.isTerminal) return turn;
    final event = await _eventRepository.getEvent(turn.sourceMessageId);
    if (event == null) return turn;
    final targetIds = event.targetAgentIds.toSet();
    if (targetIds.isEmpty || turn.recipientCount == 0) {
      final completed = turn.copyWith(
        status: ProjectTurnStatus.completed,
        noParticipant: turn.routingMode == ProjectTurnRoutingMode.broadcast,
        completedAt: DateTime.now(),
      );
      await _turnRepository.save(completed);
      return completed;
    }

    final receipts = <AgentMessageReceipt>[
      for (final receipt in await _receiptRepository.getForTurn(turn.id))
        if (targetIds.contains(receipt.agentId)) receipt,
    ];
    if (receipts.length < turn.recipientCount) {
      final runs = await _runRepository.getForTurn(turn.id);
      final status =
          runs.any((run) => run.phase == AgentRunPhase.reply && !run.isTerminal)
              ? ProjectTurnStatus.replying
              : runs.any(
                (run) => run.phase == AgentRunPhase.decision && !run.isTerminal,
              )
              ? ProjectTurnStatus.deciding
              : ProjectTurnStatus.dispatching;
      final updated = turn.copyWith(status: status);
      await _turnRepository.save(updated);
      return updated;
    }

    final failures = receipts.where(
      (receipt) =>
          receipt.outcome == AgentMessageReceiptOutcome.failedSkipped ||
          receipt.outcome == AgentMessageReceiptOutcome.cancelled,
    );
    final failureCount = failures.length;
    final replied = receipts.any(
      (receipt) => receipt.outcome == AgentMessageReceiptOutcome.replied,
    );
    final status =
        failureCount == receipts.length
            ? ProjectTurnStatus.failed
            : failureCount > 0
            ? ProjectTurnStatus.partial
            : ProjectTurnStatus.completed;
    final completed = turn.copyWith(
      status: status,
      noParticipant:
          turn.routingMode == ProjectTurnRoutingMode.broadcast && !replied,
      completedAt: DateTime.now(),
    );
    await _turnRepository.save(completed);
    return completed;
  }
}
