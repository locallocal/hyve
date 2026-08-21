import 'package:hyve/domain/models/agent_run.dart';
import 'package:hyve/domain/models/project_event.dart';
import 'package:hyve/domain/models/project_turn.dart';

enum AgentDeliveryVisibility { project, targets }

final class AgentDeliveryRequest {
  AgentDeliveryRequest({
    required Iterable<String> targetAgentIds,
    required this.kind,
    required this.summary,
    required this.payload,
    Iterable<String> projectArtifactVersionIds = const <String>[],
    this.visibility = AgentDeliveryVisibility.project,
    this.requestPublicReply = false,
  }) : targetAgentIds = List<String>.unmodifiable(targetAgentIds),
       projectArtifactVersionIds = List<String>.unmodifiable(
         projectArtifactVersionIds,
       );

  final List<String> targetAgentIds;
  final AgentDeliveryKind kind;
  final String summary;
  final String payload;
  final List<String> projectArtifactVersionIds;
  final AgentDeliveryVisibility visibility;
  final bool requestPublicReply;
}

final class AgentDelivery {
  AgentDelivery({
    required this.eventId,
    required this.deliveryRunId,
    required this.sourceRunId,
    required this.sourceAgentId,
    required this.kind,
    required this.summary,
    required this.payload,
    required this.visibility,
    required this.requestPublicReply,
    required this.rootTurnId,
    required this.depth,
    required this.payloadDigest,
    required Iterable<String> targetAgentIds,
    Iterable<String> projectArtifactVersionIds = const <String>[],
  }) : targetAgentIds = List<String>.unmodifiable(targetAgentIds),
       projectArtifactVersionIds = List<String>.unmodifiable(
         projectArtifactVersionIds,
       );

  final String eventId;
  final String deliveryRunId;
  final String sourceRunId;
  final String sourceAgentId;
  final AgentDeliveryKind kind;
  final String summary;
  final String payload;
  final AgentDeliveryVisibility visibility;
  final bool requestPublicReply;
  final String rootTurnId;
  final int depth;
  final String payloadDigest;
  final List<String> targetAgentIds;
  final List<String> projectArtifactVersionIds;
}

final class AgentDeliveryAppendRequest {
  const AgentDeliveryAppendRequest({
    required this.event,
    required this.turn,
    required this.deliveryRun,
    required this.delivery,
    required this.maxDeliveriesPerTurn,
  });

  final ProjectEvent event;
  final ProjectTurn turn;
  final AgentRun deliveryRun;
  final AgentDelivery delivery;
  final int maxDeliveriesPerTurn;
}

final class AgentDeliveryRejectionRequest {
  const AgentDeliveryRejectionRequest({
    required this.event,
    required this.deliveryRun,
  });

  final ProjectEvent event;
  final AgentRun deliveryRun;
}

final class AgentDeliveryAppendResult {
  const AgentDeliveryAppendResult({
    required this.event,
    required this.turn,
    required this.deliveryRun,
    required this.delivery,
    required this.activeAgentIds,
    this.duplicate = false,
  });

  final ProjectEvent event;
  final ProjectTurn turn;
  final AgentRun deliveryRun;
  final AgentDelivery delivery;
  final List<String> activeAgentIds;
  final bool duplicate;
}

final class AgentDeliveryExecutionResult {
  const AgentDeliveryExecutionResult({
    required this.eventId,
    required this.turnId,
    required this.deliveryRunId,
    required this.messageSequence,
    this.duplicate = false,
  });

  final String eventId;
  final String turnId;
  final String deliveryRunId;
  final int messageSequence;
  final bool duplicate;
}

final class AgentDeliveryFailure implements Exception {
  const AgentDeliveryFailure(this.code);

  final String code;

  @override
  String toString() => 'AgentDeliveryFailure($code)';
}
