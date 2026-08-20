import 'dart:async';

import 'package:hyve/data/models/project_execution_records.dart';
import 'package:hyve/data/models/project_inbox_records.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/domain/models/agent_message_cursor.dart';
import 'package:hyve/domain/models/agent_message_receipt.dart';
import 'package:hyve/domain/repositories/project_agent_cursor_repository.dart';

final class SqliteProjectAgentCursorRepository
    implements ProjectAgentCursorRepository {
  SqliteProjectAgentCursorRepository({
    required LocalDatabaseService localDatabase,
  }) : _localDatabase = localDatabase;

  final LocalDatabaseService _localDatabase;
  final StreamController<ProjectAgentInboxKey> _changes =
      StreamController<ProjectAgentInboxKey>.broadcast();

  @override
  Stream<ProjectAgentInboxKey> get changes => _changes.stream;

  @override
  Future<AgentMessageCursor?> getCursor(
    String projectId,
    String agentId,
  ) async {
    final records = await _localDatabase.loadProjectAgentCursor(
      projectId,
      agentId,
    );
    return records.isEmpty
        ? null
        : AgentMessageCursorRecord(records.single).toDomain();
  }

  @override
  Future<List<AgentMessageCursor>> getForProject(String projectId) async =>
      (await _localDatabase.loadProjectAgentCursors(projectId))
          .map((record) => AgentMessageCursorRecord(record).toDomain())
          .toList(growable: false);

  @override
  Future<List<ProjectAgentInboxKey>> getBackloggedActiveInboxes() async =>
      (await _localDatabase.loadBackloggedActiveInboxes())
          .map(
            (record) => ProjectAgentInboxKey(
              projectId: record['project_id']! as String,
              agentId: record['agent_id']! as String,
            ),
          )
          .toList(growable: false);

  @override
  Future<AgentMessageClaim?> claimNext({
    required String projectId,
    required String agentId,
    required String leaseOwner,
    required DateTime now,
    Duration leaseDuration = const Duration(minutes: 4),
  }) async {
    final record = await _localDatabase.claimNextProjectMessage(
      projectId: projectId,
      agentId: agentId,
      leaseOwner: leaseOwner,
      now: now.millisecondsSinceEpoch,
      leaseExpiresAt: now.add(leaseDuration).millisecondsSinceEpoch,
    );
    if (record == null) return null;
    final eventId = record.eventValues['id']! as String;
    final targets = await _localDatabase.loadProjectEventTargets(eventId);
    _emit(projectId, agentId);
    return AgentMessageClaim(
      cursor: AgentMessageCursorRecord(record.cursorValues).toDomain(),
      event: ProjectEventRecord(record.eventValues).toDomain(
        targetAgentIds: targets.map((target) => target['agent_id']! as String),
      ),
    );
  }

  @override
  Future<void> setActiveRun({
    required String projectId,
    required String agentId,
    required String leaseOwner,
    required String runId,
    required DateTime now,
  }) async {
    await _localDatabase.setProjectAgentActiveRun(
      projectId: projectId,
      agentId: agentId,
      leaseOwner: leaseOwner,
      runId: runId,
      now: now.millisecondsSinceEpoch,
    );
    _emit(projectId, agentId);
  }

  @override
  Future<void> complete(
    AgentMessageReceipt receipt, {
    required String leaseOwner,
  }) async {
    await _localDatabase.completeProjectAgentMessage(
      AgentMessageReceiptRecord.fromDomain(receipt).values,
      leaseOwner,
    );
    _emit(receipt.projectId, receipt.agentId);
  }

  @override
  Future<void> release({
    required String projectId,
    required String agentId,
    required String leaseOwner,
    required DateTime now,
    String errorCode = '',
  }) async {
    await _localDatabase.releaseProjectAgentClaim(
      projectId: projectId,
      agentId: agentId,
      leaseOwner: leaseOwner,
      now: now.millisecondsSinceEpoch,
      errorCode: errorCode,
    );
    _emit(projectId, agentId);
  }

  @override
  Future<void> recoverInterrupted(DateTime now) => _localDatabase
      .recoverInterruptedProjectAgentClaims(now.millisecondsSinceEpoch);

  void _emit(String projectId, String agentId) {
    if (!_changes.isClosed) {
      _changes.add(
        ProjectAgentInboxKey(projectId: projectId, agentId: agentId),
      );
    }
  }

  Future<void> dispose() => _changes.close();
}
