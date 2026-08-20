import 'package:hyve/domain/models/agent_message_cursor.dart';
import 'package:hyve/domain/models/agent_message_receipt.dart';
import 'package:hyve/domain/models/project_event.dart';

final class ProjectAgentInboxKey {
  const ProjectAgentInboxKey({required this.projectId, required this.agentId});

  final String projectId;
  final String agentId;
}

final class AgentMessageClaim {
  const AgentMessageClaim({required this.cursor, required this.event});

  final AgentMessageCursor cursor;
  final ProjectEvent event;
}

abstract interface class ProjectAgentCursorRepository {
  Stream<ProjectAgentInboxKey> get changes;

  Future<AgentMessageCursor?> getCursor(String projectId, String agentId);

  Future<List<AgentMessageCursor>> getForProject(String projectId);

  Future<List<ProjectAgentInboxKey>> getBackloggedActiveInboxes();

  Future<AgentMessageClaim?> claimNext({
    required String projectId,
    required String agentId,
    required String leaseOwner,
    required DateTime now,
    Duration leaseDuration = const Duration(minutes: 4),
  });

  Future<void> setActiveRun({
    required String projectId,
    required String agentId,
    required String leaseOwner,
    required String runId,
    required DateTime now,
  });

  /// Writes the receipt and advances the contiguous cursor in one transaction.
  Future<void> complete(
    AgentMessageReceipt receipt, {
    required String leaseOwner,
  });

  Future<void> release({
    required String projectId,
    required String agentId,
    required String leaseOwner,
    required DateTime now,
    String errorCode = '',
  });

  Future<void> recoverInterrupted(DateTime now);
}
