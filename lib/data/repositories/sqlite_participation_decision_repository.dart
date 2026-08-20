import 'package:hyve/data/models/project_execution_records.dart';
import 'package:hyve/data/models/project_inbox_records.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/domain/models/participation_decision.dart';
import 'package:hyve/domain/models/project_event.dart';
import 'package:hyve/domain/repositories/participation_decision_repository.dart';

final class SqliteParticipationDecisionRepository
    implements ParticipationDecisionRepository {
  const SqliteParticipationDecisionRepository({
    required LocalDatabaseService localDatabase,
  }) : _localDatabase = localDatabase;

  final LocalDatabaseService _localDatabase;

  @override
  Future<ParticipationDecision?> getForRun(String runId) async {
    final records = await _localDatabase.loadParticipationDecision(runId);
    return records.isEmpty
        ? null
        : ParticipationDecisionRecord(records.single).toDomain();
  }

  @override
  Future<List<ParticipationDecision>> getForTurn(String turnId) async =>
      (await _localDatabase.loadParticipationDecisionsForTurn(turnId))
          .map((record) => ParticipationDecisionRecord(record).toDomain())
          .toList(growable: false);

  @override
  Future<void> save(ParticipationDecision decision) {
    final event = ProjectEvent(
      id: 'participation-decision:${decision.runId}',
      projectId: decision.projectId,
      turnId: decision.turnId,
      runId: decision.runId,
      sequence: 1,
      eventType: ProjectEventType.participationDecision,
      actorType: ProjectEventActorType.agent,
      actorId: decision.agentId,
      visibility: ProjectEventVisibility.audit,
      payload: ParticipationDecisionPayload(
        choice: decision.choice,
        reasonCode: decision.reasonCode,
        intendedContribution: decision.intendedContribution,
      ),
      createdAt: decision.createdAt,
      updatedAt: decision.createdAt,
    );
    return _localDatabase.saveParticipationDecision(
      ParticipationDecisionRecord.fromDomain(decision).values,
      ProjectEventRecord.fromDomain(event).values,
    );
  }
}
