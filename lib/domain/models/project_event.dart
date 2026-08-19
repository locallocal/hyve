enum ProjectEventType {
  userMessage,
  agentMessage,
  participationDecision,
  agentDelivery,
  membershipChanged,
  projectArtifactChanged,
  runStatusChanged,
  systemNotice,
}

enum ProjectEventActorType { user, agent, system }

enum ProjectEventVisibility { project, targets, audit }

enum ProjectEventTerminalState {
  draft,
  completed,
  cancelled,
  failed,
  timedOut,
  limitExceeded,
}

sealed class ProjectEventPayload {
  const ProjectEventPayload();
}

final class ProjectMessagePayload extends ProjectEventPayload {
  ProjectMessagePayload({
    this.reasoning = '',
    this.processInfoJson =
        '{"reasoning_status":"","duration_ms":null,'
            '"tool_calls":[],"command_executions":[],"file_edits":[],'
            '"skill_activations":[]}',
    Iterable<String> images = const <String>[],
    Iterable<String> files = const <String>[],
    this.audio = '',
    this.music = '',
    this.video = '',
  }) : images = List<String>.unmodifiable(images),
       files = List<String>.unmodifiable(files);

  final String reasoning;
  final String processInfoJson;
  final List<String> images;
  final List<String> files;
  final String audio;
  final String music;
  final String video;
}

enum ParticipationChoice { reply, pass }

final class ParticipationDecisionPayload extends ProjectEventPayload {
  const ParticipationDecisionPayload({
    required this.choice,
    required this.reasonCode,
    this.intendedContribution = '',
  });

  final ParticipationChoice choice;
  final String reasonCode;
  final String intendedContribution;
}

enum AgentDeliveryKind { information, task, question, result }

final class AgentDeliveryPayload extends ProjectEventPayload {
  const AgentDeliveryPayload({
    required this.kind,
    required this.summary,
    required this.payload,
    this.requestPublicReply = false,
  });

  final AgentDeliveryKind kind;
  final String summary;
  final String payload;
  final bool requestPublicReply;
}

final class MembershipChangedPayload extends ProjectEventPayload {
  const MembershipChangedPayload({
    required this.agentId,
    required this.currentStatus,
    this.previousStatus = '',
  });

  final String agentId;
  final String previousStatus;
  final String currentStatus;
}

final class ProjectArtifactChangedPayload extends ProjectEventPayload {
  const ProjectArtifactChangedPayload({
    required this.artifactId,
    required this.versionId,
    required this.changeKind,
  });

  final String artifactId;
  final String versionId;
  final String changeKind;
}

final class RunStatusChangedPayload extends ProjectEventPayload {
  const RunStatusChangedPayload({
    required this.runId,
    required this.phase,
    required this.status,
    this.errorCode = '',
  });

  final String runId;
  final String phase;
  final String status;
  final String errorCode;
}

final class SystemNoticePayload extends ProjectEventPayload {
  const SystemNoticePayload({required this.code, this.detail = ''});

  final String code;
  final String detail;
}

final class ProjectEvent {
  ProjectEvent({
    required this.id,
    required this.projectId,
    this.turnId = '',
    this.runId = '',
    required this.sequence,
    this.messageSequence,
    required this.eventType,
    required this.actorType,
    this.actorId = '',
    this.actorNameSnapshot = '',
    this.actorAvatarSnapshot = '',
    this.visibility = ProjectEventVisibility.project,
    this.replyToEventId = '',
    this.replyToMessageSequence,
    this.rootMessageId = '',
    this.autonomousDepth = 0,
    this.content = '',
    required this.payload,
    this.terminalState = ProjectEventTerminalState.completed,
    this.hasPartialContent = false,
    Iterable<String> targetAgentIds = const <String>[],
    required this.createdAt,
    required this.updatedAt,
  }) : targetAgentIds = List<String>.unmodifiable(targetAgentIds) {
    if (id.trim().isEmpty || projectId.trim().isEmpty) {
      throw ArgumentError('Project event id and projectId are required.');
    }
    if (sequence < 1 ||
        (messageSequence != null && messageSequence! < 1) ||
        autonomousDepth < 0) {
      throw ArgumentError('Project event sequences must be positive.');
    }
    if (terminalState == ProjectEventTerminalState.draft &&
        messageSequence != null) {
      throw ArgumentError('A draft event cannot enter the message sequence.');
    }
    if (!_payloadMatches(eventType, payload)) {
      throw ArgumentError('Project event payload does not match eventType.');
    }
  }

  final String id;
  final String projectId;
  final String turnId;
  final String runId;
  final int sequence;
  final int? messageSequence;
  final ProjectEventType eventType;
  final ProjectEventActorType actorType;
  final String actorId;
  final String actorNameSnapshot;
  final String actorAvatarSnapshot;
  final ProjectEventVisibility visibility;
  final String replyToEventId;
  final int? replyToMessageSequence;
  final String rootMessageId;
  final int autonomousDepth;
  final String content;
  final ProjectEventPayload payload;
  final ProjectEventTerminalState terminalState;
  final bool hasPartialContent;
  final List<String> targetAgentIds;
  final DateTime createdAt;
  final DateTime updatedAt;
}

bool _payloadMatches(ProjectEventType type, ProjectEventPayload payload) {
  return switch (type) {
    ProjectEventType.userMessage ||
    ProjectEventType.agentMessage => payload is ProjectMessagePayload,
    ProjectEventType.participationDecision =>
      payload is ParticipationDecisionPayload,
    ProjectEventType.agentDelivery => payload is AgentDeliveryPayload,
    ProjectEventType.membershipChanged => payload is MembershipChangedPayload,
    ProjectEventType.projectArtifactChanged =>
      payload is ProjectArtifactChangedPayload,
    ProjectEventType.runStatusChanged => payload is RunStatusChangedPayload,
    ProjectEventType.systemNotice => payload is SystemNoticePayload,
  };
}
