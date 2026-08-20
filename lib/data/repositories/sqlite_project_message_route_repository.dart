import 'package:hyve/data/models/project_execution_records.dart';
import 'package:hyve/data/services/local_database_service.dart';
import 'package:hyve/domain/models/project_event.dart';
import 'package:hyve/domain/models/project_message_route.dart';
import 'package:hyve/domain/models/project_turn.dart';
import 'package:hyve/domain/repositories/project_message_route_repository.dart';
import 'package:hyve/domain/repositories/project_repository.dart';

final class SqliteProjectMessageRouteRepository
    implements ProjectMessageRouteRepository {
  const SqliteProjectMessageRouteRepository({
    required LocalDatabaseService localDatabase,
    ProjectRepository? projectRepository,
  }) : _localDatabase = localDatabase,
       _projectRepository = projectRepository;

  final LocalDatabaseService _localDatabase;
  final ProjectRepository? _projectRepository;

  @override
  Future<RoutedProjectMessage> append(
    ProjectMessageAppendRequest request,
  ) async {
    final rootMessageId =
        request.rootMessageId.isEmpty ? request.eventId : request.rootMessageId;
    final rootTurnId =
        request.rootTurnId.isEmpty ? request.turnId : request.rootTurnId;
    final provisionalEvent = ProjectEvent(
      id: request.eventId,
      projectId: request.projectId,
      turnId: request.turnId,
      runId: request.runId,
      sequence: 1,
      messageSequence: 1,
      eventType: request.eventType,
      actorType: request.actorType,
      actorId: request.actorId,
      actorNameSnapshot: request.actorNameSnapshot,
      actorAvatarSnapshot: request.actorAvatarSnapshot,
      visibility: ProjectEventVisibility.project,
      replyToEventId: request.replyToEventId,
      replyToMessageSequence: request.replyToMessageSequence,
      rootMessageId: rootMessageId,
      autonomousDepth: request.autonomousDepth,
      content: request.content,
      payload: request.payload,
      targetAgentIds: request.targetAgentIds,
      createdAt: request.createdAt,
      updatedAt: request.createdAt,
    );
    final provisionalTurn = ProjectTurn(
      id: request.turnId,
      projectId: request.projectId,
      rootEventId: rootMessageId,
      initiatorType: request.initiatorType,
      initiatorId: request.initiatorId,
      routingMode: request.routingMode,
      sourceMessageId: request.eventId,
      sourceMessageSequence: 1,
      recipientCount: 0,
      rootTurnId: rootTurnId,
      autonomousDepth: request.autonomousDepth,
      createdAt: request.createdAt,
    );
    final record = await _localDatabase.appendProjectMessage(
      ProjectEventRecord.fromDomain(provisionalEvent).values,
      ProjectTurnRecord.fromDomain(provisionalTurn).values,
      request.targetAgentIds,
      request.routingMode.name,
    );
    final routed = RoutedProjectMessage(
      event: ProjectEventRecord(
        record.eventValues,
      ).toDomain(targetAgentIds: record.targetAgentIds),
      turn: ProjectTurnRecord(record.turnValues).toDomain(),
      activeAgentIds: record.activeAgentIds,
    );
    try {
      await _projectRepository?.getProjects(forceRefresh: true);
    } on Object {
      // The route is already committed. A cache refresh must never make the
      // caller retry and append the same user message a second time.
    }
    return routed;
  }
}
