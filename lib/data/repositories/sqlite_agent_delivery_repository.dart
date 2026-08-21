import 'dart:async';

import 'package:hyve/data/models/project_execution_records.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/domain/models/agent_delivery.dart';
import 'package:hyve/domain/repositories/agent_delivery_repository.dart';
import 'package:hyve/domain/repositories/project_repository.dart';

final class SqliteAgentDeliveryRepository implements AgentDeliveryRepository {
  SqliteAgentDeliveryRepository({
    required LocalDatabaseService localDatabase,
    ProjectRepository? projectRepository,
  }) : _localDatabase = localDatabase,
       _projectRepository = projectRepository;

  final LocalDatabaseService _localDatabase;
  final ProjectRepository? _projectRepository;
  final StreamController<String> _changes =
      StreamController<String>.broadcast();

  @override
  Stream<String> get changes => _changes.stream;

  @override
  Future<AgentDelivery?> getForEvent(String eventId) async {
    final record = await _localDatabase.loadAgentDelivery(eventId);
    if (record == null) return null;
    return AgentDeliveryRecord(record.deliveryValues).toDomain(
      deliveryRunId: record.deliveryValues['delivery_run_id']! as String,
      targetAgentIds: record.targetAgentIds,
      projectArtifactVersionIds: record.artifactVersionIds,
    );
  }

  @override
  Future<AgentDeliveryAppendResult> append(
    AgentDeliveryAppendRequest request,
  ) async {
    try {
      final record = await _localDatabase.appendAgentDelivery(
        ProjectEventRecord.fromDomain(request.event).values,
        ProjectTurnRecord.fromDomain(request.turn).values,
        AgentRunRecord.fromDomain(request.deliveryRun).values,
        AgentDeliveryRecord.fromDomain(request.delivery).values,
        request.delivery.targetAgentIds,
        request.delivery.projectArtifactVersionIds,
        maxDeliveriesPerTurn: request.maxDeliveriesPerTurn,
      );
      final event = ProjectEventRecord(
        record.eventValues,
      ).toDomain(targetAgentIds: record.targetAgentIds);
      final deliveryRun = AgentRunRecord(record.deliveryRunValues).toDomain();
      final delivery = AgentDeliveryRecord(record.deliveryValues).toDomain(
        deliveryRunId: deliveryRun.id,
        targetAgentIds: record.targetAgentIds,
        projectArtifactVersionIds: record.artifactVersionIds,
      );
      if (!record.duplicate) {
        if (!_changes.isClosed) _changes.add(event.projectId);
        try {
          await _projectRepository?.getProjects(forceRefresh: true);
        } on Object {
          // The atomic append is already durable. Cache refresh is best effort.
        }
      }
      return AgentDeliveryAppendResult(
        event: event,
        turn: ProjectTurnRecord(record.turnValues).toDomain(),
        deliveryRun: deliveryRun,
        delivery: delivery,
        activeAgentIds: List<String>.unmodifiable(record.activeAgentIds),
        duplicate: record.duplicate,
      );
    } on StateError catch (error) {
      throw AgentDeliveryFailure(error.message);
    }
  }

  @override
  Future<void> recordRejection(AgentDeliveryRejectionRequest request) async {
    await _localDatabase.appendAgentDeliveryRejection(
      ProjectEventRecord.fromDomain(request.event).values,
      AgentRunRecord.fromDomain(request.deliveryRun).values,
    );
    if (!_changes.isClosed) _changes.add(request.event.projectId);
    try {
      await _projectRepository?.getProjects(forceRefresh: true);
    } on Object {
      // The audit event is already durable. Cache refresh is best effort.
    }
  }

  Future<void> dispose() => _changes.close();
}
