import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/project_message_route_repository.dart';
import 'package:hyve/domain/use_cases/route_project_message.dart';

void main() {
  test('optimistic and persisted messages reuse stable identities', () async {
    final repository = _RecordingRouteRepository();
    final now = DateTime.utc(2026, 8, 31, 12);
    var sequence = 0;
    final route = RouteProjectMessage(
      repository: repository,
      clock: () => now,
      idFactory: (prefix) => '$prefix-${++sequence}',
    );
    final optimisticRoute = route.prepareUserMessage(
      projectId: 'project-1',
      currentUserName: 'User',
      draft: ProjectMessageDraft(
        text: '@Agent review this',
        mentions: const <MentionSpan>[
          MentionSpan(
            agentId: 'agent-1',
            start: 0,
            length: 6,
            displayTextSnapshot: '@Agent',
          ),
        ],
        attachments: const <PendingAttachment>[
          PendingAttachment(
            sourcePath: '/picker/image.png',
            kind: PendingAttachmentKind.image,
          ),
        ],
      ),
    );

    final optimistic = optimisticRoute.optimisticEvent(sequence: 42);
    expect(optimistic.id, 'event-1');
    expect(optimistic.turnId, 'turn-2');
    expect(optimistic.sequence, 42);
    expect(optimistic.messageSequence, isNull);
    expect(optimistic.terminalState, ProjectEventTerminalState.draft);
    expect(optimistic.targetAgentIds, <String>['agent-1']);
    expect((optimistic.payload as ProjectMessagePayload).images, <String>[
      '/picker/image.png',
    ]);

    final persistedRoute = route.prepareUserMessage(
      projectId: 'project-1',
      currentUserName: 'User',
      identity: optimisticRoute.identity,
      draft: ProjectMessageDraft(
        text: '@Agent review this',
        mentions: const <MentionSpan>[
          MentionSpan(
            agentId: 'agent-1',
            start: 0,
            length: 6,
            displayTextSnapshot: '@Agent',
          ),
        ],
        attachments: const <PendingAttachment>[
          PendingAttachment(
            sourcePath: '/project/tmp/image.png',
            kind: PendingAttachmentKind.image,
          ),
        ],
      ),
    );
    final routed = await route.commit(persistedRoute);

    expect(repository.request, same(persistedRoute.request));
    expect(routed.event.id, optimistic.id);
    expect(routed.event.turnId, optimistic.turnId);
    expect(routed.event.createdAt, optimistic.createdAt);
    expect(routed.event.terminalState, ProjectEventTerminalState.completed);
    expect((routed.event.payload as ProjectMessagePayload).images, <String>[
      '/project/tmp/image.png',
    ]);
    expect(sequence, 2, reason: 'reusing an identity must not allocate again');
  });
}

final class _RecordingRouteRepository implements ProjectMessageRouteRepository {
  ProjectMessageAppendRequest? request;

  @override
  Future<RoutedProjectMessage> append(
    ProjectMessageAppendRequest request,
  ) async {
    this.request = request;
    final event = ProjectEvent(
      id: request.eventId,
      projectId: request.projectId,
      turnId: request.turnId,
      sequence: 7,
      messageSequence: 4,
      eventType: request.eventType,
      actorType: request.actorType,
      actorId: request.actorId,
      actorNameSnapshot: request.actorNameSnapshot,
      actorAvatarSnapshot: request.actorAvatarSnapshot,
      content: request.content,
      payload: request.payload,
      targetAgentIds: request.targetAgentIds,
      createdAt: request.createdAt,
      updatedAt: request.createdAt,
    );
    return RoutedProjectMessage(
      event: event,
      turn: ProjectTurn(
        id: request.turnId,
        projectId: request.projectId,
        rootEventId: request.eventId,
        initiatorType: request.initiatorType,
        initiatorId: request.initiatorId,
        routingMode: request.routingMode,
        sourceMessageId: request.eventId,
        sourceMessageSequence: 4,
        recipientCount: 1,
        rootTurnId: request.turnId,
        createdAt: request.createdAt,
      ),
      activeAgentIds: const <String>['agent-1'],
    );
  }
}
