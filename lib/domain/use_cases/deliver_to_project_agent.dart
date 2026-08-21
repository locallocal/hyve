import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/agent_delivery_repository.dart';

typedef AgentDeliveryClock = DateTime Function();
typedef AgentDeliveryIdFactory = String Function(String prefix);
typedef AgentDeliveryWakeup =
    void Function(String projectId, Iterable<String> activeAgentIds);

final class DeliverToProjectAgent {
  DeliverToProjectAgent({
    required AgentDeliveryRepository repository,
    AgentDeliveryClock? clock,
    AgentDeliveryIdFactory? idFactory,
    AgentDeliveryWakeup? wakeup,
  }) : _repository = repository,
       _clock = clock ?? DateTime.now,
       _idFactory = idFactory ?? _defaultDeliveryIdFactory,
       _wakeup = wakeup;

  final AgentDeliveryRepository _repository;
  final AgentDeliveryClock _clock;
  final AgentDeliveryIdFactory _idFactory;
  final AgentDeliveryWakeup? _wakeup;

  Future<AgentDeliveryExecutionResult> call({
    required Project project,
    required Agent sourceAgent,
    required AgentRun sourceRun,
    required ProjectTurn sourceTurn,
    required ProjectEvent sourceEvent,
    required AgentDeliveryRequest request,
    ProjectRunCancellationToken? cancellationToken,
  }) async {
    _validateSource(
      project: project,
      sourceAgent: sourceAgent,
      sourceRun: sourceRun,
      sourceTurn: sourceTurn,
      sourceEvent: sourceEvent,
    );
    cancellationToken?.throwIfCancelled();

    final targetAgentIds = _uniqueNonEmpty(request.targetAgentIds);
    if (targetAgentIds.isEmpty) {
      throw const AgentDeliveryFailure('delivery_targets_required');
    }
    if (targetAgentIds.contains(sourceAgent.id)) {
      throw const AgentDeliveryFailure('delivery_to_self_not_allowed');
    }
    final summary = request.summary.trim();
    final payload = request.payload.trim();
    if (summary.isEmpty || payload.isEmpty) {
      throw const AgentDeliveryFailure('delivery_content_required');
    }
    if (summary.runes.length > 512 || payload.runes.length > 32768) {
      throw const AgentDeliveryFailure('delivery_content_too_large');
    }
    final artifactVersionIds = _uniqueNonEmpty(
      request.projectArtifactVersionIds,
    );
    final depth = sourceRun.deliveryDepth + 1;
    final now = _clock();
    final deliveryRunId = _idFactory('delivery-run');
    if (depth > project.responsePolicy.deliveryMaxDepth) {
      await _recordRejection(
        project: project,
        sourceAgent: sourceAgent,
        sourceRun: sourceRun,
        sourceTurn: sourceTurn,
        sourceEvent: sourceEvent,
        deliveryRunId: deliveryRunId,
        depth: depth,
        code: 'delivery_depth_limit_reached',
      );
      throw const AgentDeliveryFailure('delivery_depth_limit_reached');
    }

    final eventId = _idFactory('delivery-event');
    final turnId = _idFactory('delivery-turn');
    final rootMessageId =
        sourceEvent.rootMessageId.isEmpty
            ? sourceEvent.id
            : sourceEvent.rootMessageId;
    final digest = _deliveryDigest(
      sourceAgentId: sourceAgent.id,
      targetAgentIds: targetAgentIds,
      kind: request.kind,
      summary: summary,
      payload: payload,
      artifactVersionIds: artifactVersionIds,
      visibility: request.visibility,
      requestPublicReply: request.requestPublicReply,
    );
    final event = ProjectEvent(
      id: eventId,
      projectId: project.id,
      turnId: turnId,
      runId: deliveryRunId,
      sequence: 1,
      messageSequence: 1,
      eventType: ProjectEventType.agentDelivery,
      actorType: ProjectEventActorType.agent,
      actorId: sourceAgent.id,
      actorNameSnapshot: sourceAgent.name,
      actorAvatarSnapshot: sourceAgent.avatar,
      visibility: switch (request.visibility) {
        AgentDeliveryVisibility.project => ProjectEventVisibility.project,
        AgentDeliveryVisibility.targets => ProjectEventVisibility.targets,
      },
      replyToEventId: sourceEvent.id,
      replyToMessageSequence: sourceEvent.messageSequence,
      rootMessageId: rootMessageId,
      autonomousDepth: sourceEvent.autonomousDepth + 1,
      content: summary,
      payload: AgentDeliveryPayload(
        kind: request.kind,
        summary: summary,
        payload: payload,
        projectArtifactVersionIds: artifactVersionIds,
        requestPublicReply: request.requestPublicReply,
      ),
      targetAgentIds: targetAgentIds,
      createdAt: now,
      updatedAt: now,
    );
    final turn = ProjectTurn(
      id: turnId,
      projectId: project.id,
      rootEventId: rootMessageId,
      initiatorType: ProjectTurnInitiatorType.agent,
      initiatorId: sourceAgent.id,
      routingMode: ProjectTurnRoutingMode.delivery,
      sourceMessageId: eventId,
      sourceMessageSequence: 1,
      recipientCount: targetAgentIds.length,
      rootTurnId: sourceTurn.rootTurnId,
      autonomousDepth: event.autonomousDepth,
      status: ProjectTurnStatus.dispatching,
      createdAt: now,
    );
    final deliveryRun = AgentRun(
      id: deliveryRunId,
      projectId: project.id,
      turnId: sourceRun.turnId,
      agentId: sourceAgent.id,
      sourceMessageEventId: sourceEvent.id,
      sourceMessageSequence: sourceEvent.messageSequence!,
      contextThroughMessageSequence: sourceRun.contextThroughMessageSequence,
      parentRunId: sourceRun.id,
      rootRunId: sourceRun.rootRunId,
      deliveryDepth: depth,
      phase: AgentRunPhase.delivery,
      status: AgentRunStatus.completed,
      agentSnapshot: sourceRun.agentSnapshot,
      startedAt: now,
      completedAt: now,
      createdAt: now,
    );
    final result = await _appendWithRejectionAudit(
      project: project,
      sourceAgent: sourceAgent,
      sourceRun: sourceRun,
      sourceTurn: sourceTurn,
      sourceEvent: sourceEvent,
      deliveryRunId: deliveryRunId,
      depth: depth,
      appendRequest: AgentDeliveryAppendRequest(
        event: event,
        turn: turn,
        deliveryRun: deliveryRun,
        delivery: AgentDelivery(
          eventId: eventId,
          deliveryRunId: deliveryRunId,
          sourceRunId: sourceRun.id,
          sourceAgentId: sourceAgent.id,
          kind: request.kind,
          summary: summary,
          payload: payload,
          visibility: request.visibility,
          requestPublicReply: request.requestPublicReply,
          rootTurnId: sourceTurn.rootTurnId,
          depth: depth,
          payloadDigest: digest,
          targetAgentIds: targetAgentIds,
          projectArtifactVersionIds: artifactVersionIds,
        ),
        maxDeliveriesPerTurn:
            project.responsePolicy.deliveryMaxDeliveriesPerTurn,
      ),
    );
    if (!result.duplicate) {
      _wakeup?.call(project.id, result.activeAgentIds);
    }
    return AgentDeliveryExecutionResult(
      eventId: result.event.id,
      turnId: result.turn.id,
      deliveryRunId: result.deliveryRun.id,
      messageSequence: result.event.messageSequence!,
      duplicate: result.duplicate,
    );
  }

  Future<AgentDeliveryAppendResult> _appendWithRejectionAudit({
    required Project project,
    required Agent sourceAgent,
    required AgentRun sourceRun,
    required ProjectTurn sourceTurn,
    required ProjectEvent sourceEvent,
    required int depth,
    required String deliveryRunId,
    required AgentDeliveryAppendRequest appendRequest,
  }) async {
    try {
      return await _repository.append(appendRequest);
    } on AgentDeliveryFailure catch (failure) {
      const auditedCodes = <String>{
        'delivery_count_limit_reached',
        'delivery_source_not_active',
        'delivery_target_not_active',
        'delivery_source_cancelled',
        'delivery_artifact_version_not_found',
      };
      if (auditedCodes.contains(failure.code)) {
        await _recordRejection(
          project: project,
          sourceAgent: sourceAgent,
          sourceRun: sourceRun,
          sourceTurn: sourceTurn,
          sourceEvent: sourceEvent,
          deliveryRunId: deliveryRunId,
          depth: depth,
          code: failure.code,
        );
      }
      rethrow;
    }
  }

  Future<void> _recordRejection({
    required Project project,
    required Agent sourceAgent,
    required AgentRun sourceRun,
    required ProjectTurn sourceTurn,
    required ProjectEvent sourceEvent,
    required String deliveryRunId,
    required int depth,
    required String code,
  }) async {
    final now = _clock();
    final limited =
        code == 'delivery_depth_limit_reached' ||
        code == 'delivery_count_limit_reached';
    final run = AgentRun(
      id: deliveryRunId,
      projectId: project.id,
      turnId: sourceTurn.id,
      agentId: sourceAgent.id,
      sourceMessageEventId: sourceEvent.id,
      sourceMessageSequence: sourceEvent.messageSequence!,
      contextThroughMessageSequence: sourceRun.contextThroughMessageSequence,
      parentRunId: sourceRun.id,
      rootRunId: sourceRun.rootRunId,
      deliveryDepth: depth,
      phase: AgentRunPhase.delivery,
      status: limited ? AgentRunStatus.limitExceeded : AgentRunStatus.failed,
      agentSnapshot: sourceRun.agentSnapshot,
      startedAt: now,
      completedAt: now,
      errorCode: code,
      createdAt: now,
    );
    final event = ProjectEvent(
      id: _idFactory('delivery-notice'),
      projectId: project.id,
      turnId: sourceTurn.id,
      runId: deliveryRunId,
      sequence: 1,
      eventType: ProjectEventType.systemNotice,
      actorType: ProjectEventActorType.system,
      visibility: ProjectEventVisibility.project,
      replyToEventId: sourceEvent.id,
      replyToMessageSequence: sourceEvent.messageSequence,
      rootMessageId:
          sourceEvent.rootMessageId.isEmpty
              ? sourceEvent.id
              : sourceEvent.rootMessageId,
      autonomousDepth: sourceEvent.autonomousDepth,
      content: code,
      payload: SystemNoticePayload(
        code: code,
        detail: 'sourceAgentId=${sourceAgent.id}',
      ),
      terminalState:
          limited
              ? ProjectEventTerminalState.limitExceeded
              : ProjectEventTerminalState.failed,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.recordRejection(
      AgentDeliveryRejectionRequest(event: event, deliveryRun: run),
    );
  }

  void _validateSource({
    required Project project,
    required Agent sourceAgent,
    required AgentRun sourceRun,
    required ProjectTurn sourceTurn,
    required ProjectEvent sourceEvent,
  }) {
    if (sourceRun.projectId != project.id ||
        sourceRun.agentId != sourceAgent.id ||
        sourceTurn.projectId != project.id ||
        sourceRun.turnId != sourceTurn.id ||
        sourceEvent.projectId != project.id ||
        sourceEvent.messageSequence == null ||
        sourceRun.sourceMessageEventId != sourceEvent.id ||
        sourceRun.sourceMessageSequence != sourceEvent.messageSequence) {
      throw const AgentDeliveryFailure('delivery_source_mismatch');
    }
    if (sourceRun.isTerminal ||
        sourceTurn.status == ProjectTurnStatus.cancelled) {
      throw const AgentDeliveryFailure('delivery_source_cancelled');
    }
  }
}

List<String> _uniqueNonEmpty(Iterable<String> values) {
  final unique = <String>[];
  final seen = <String>{};
  for (final value in values) {
    final normalized = value.trim();
    if (normalized.isNotEmpty && seen.add(normalized)) unique.add(normalized);
  }
  return List<String>.unmodifiable(unique);
}

String _deliveryDigest({
  required String sourceAgentId,
  required List<String> targetAgentIds,
  required AgentDeliveryKind kind,
  required String summary,
  required String payload,
  required List<String> artifactVersionIds,
  required AgentDeliveryVisibility visibility,
  required bool requestPublicReply,
}) {
  final sortedTargets = List<String>.of(targetAgentIds)..sort();
  final sortedArtifacts = List<String>.of(artifactVersionIds)..sort();
  final canonical = jsonEncode(<String, Object?>{
    'sourceAgentId': sourceAgentId,
    'targetAgentIds': sortedTargets,
    'kind': kind.name,
    'summary': summary,
    'payload': payload,
    'projectArtifactVersionIds': sortedArtifacts,
    'visibility': visibility.name,
    'requestPublicReply': requestPublicReply,
  });
  return sha256.convert(utf8.encode(canonical)).toString();
}

int _deliveryIdentitySequence = 0;

String _defaultDeliveryIdFactory(String prefix) {
  _deliveryIdentitySequence = (_deliveryIdentitySequence + 1) & 0x7fffffff;
  return '$prefix:${DateTime.now().microsecondsSinceEpoch}:'
      '$_deliveryIdentitySequence';
}
