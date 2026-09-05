import 'package:flutter/widgets.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/generated/l10n.dart';
import 'package:hyve/ui/features/projects/view_models/project_agent_activity.dart';

/// Typed access to Project workspace copy backed by the app ARB catalogs.
///
/// Keeping the feature-facing API here lets Project widgets remain concise
/// while every supported locale still uses the generated localization source.
final class ProjectLocalizations {
  const ProjectLocalizations._(this._strings, this.isChinese);

  factory ProjectLocalizations.of(BuildContext context) =>
      ProjectLocalizations._(
        S.of(context),
        Localizations.localeOf(context).languageCode == 'zh',
      );

  final S _strings;

  /// Used only to choose the ideographic separator for joined identifiers.
  final bool isChinese;

  String get workspace => _strings.projectWorkspace;
  String get artifacts => _strings.projectArtifacts;
  String get artifactsDescription => _strings.projectArtifactsDescription;
  String get members => _strings.projectMembers;
  String get backToMessages => _strings.projectBackToMessages;
  String get execution => _strings.projectExecutionDetails;
  String get executionDescription => _strings.projectExecutionDescription;
  String get close => _strings.projectClose;
  String get cancel => _strings.cancel;
  String get create => _strings.projectCreate;
  String get save => _strings.save;
  String get delete => _strings.delete;
  String get search => _strings.projectSearch;
  String get retry => _strings.retry;
  String get unknown => _strings.projectUnknown;
  String get user => _strings.projectUser;
  String get agent => _strings.projectAgent;
  String get system => _strings.projectSystem;
  String get noAgentsNotice => _strings.projectNoAgentsNotice;
  String get noAgentsTitle => _strings.projectNoAgentsTitle;
  String get emptyTimelineTitle => _strings.projectEmptyTimelineTitle;
  String get emptyTimeline => _strings.projectEmptyTimeline;
  String get loadingWorkspace => _strings.projectLoadingWorkspace;
  String get loadEarlierEvents => _strings.projectLoadEarlierEvents;
  String get jumpToLatest => _strings.projectJumpToLatest;
  String get broadcastHint => _strings.projectBroadcastHint;
  String attachment(int index) => _strings.projectAttachment(index);
  String get addAttachment => _strings.projectAddAttachment;
  String get saveAsProjectArtifact => _strings.projectSaveAsArtifact;
  String get savedAsProjectArtifact => _strings.projectSavedAsArtifact;
  String get dropFilesToImport => _strings.projectDropFilesToImport;
  String get releaseToImport => _strings.projectReleaseToImport;
  String versionProvenance(int version, String actorId, String runId) {
    final actor = actorId.isEmpty ? _strings.projectSystemLowercase : actorId;
    final run = runId.isEmpty ? '' : _strings.projectRunSuffix(runId);
    return _strings.projectVersionProvenance(version, actor, run);
  }

  String referencingMessages(int count) =>
      _strings.projectReferencingMessages(count);
  String get send => _strings.send;
  String get sending => _strings.projectSending;
  String activity(ProjectAgentActivity activity) => switch (activity) {
    ProjectAgentActivity.idle => _strings.projectActivityCaughtUp,
    ProjectAgentActivity.deciding => _strings.projectActivityDeciding,
    ProjectAgentActivity.willReply => _strings.projectActivityWillReply,
    ProjectAgentActivity.skipped => _strings.projectActivitySkipped,
    ProjectAgentActivity.replying => _strings.projectActivityReplying,
    ProjectAgentActivity.catchingUp => _strings.projectActivityCatchingUp,
    ProjectAgentActivity.paused => _strings.projectActivityPaused,
    ProjectAgentActivity.failed => _strings.projectActivityFailed,
  };
  String processed(int processed, int latest) =>
      _strings.projectProcessed(processed, latest);
  String backlog(int count) => _strings.projectBacklog(count);
  String get noParticipant => _strings.projectNoParticipant;
  String replyingTo(int sequence) => _strings.projectReplyingTo(sequence);
  String get requestedPublicReply => _strings.projectRequestedPublicReply;
  String artifactVersions(Iterable<String> ids) =>
      _strings.projectArtifactVersions(ids.join(isChinese ? '，' : ', '));
  String get auditDetails => _strings.projectAuditDetails;
  String eventId(String id) => _strings.projectEventId(id);
  String messageId(String id) => _strings.projectMessageId(id);
  String turnId(String id, String status) => _strings.projectTurnId(id, status);
  String sourceRun(String id) => _strings.projectSourceRun(id);
  String deliveryRun(String id, String status) =>
      _strings.projectDeliveryRun(id, status);
  String rootRun(String id) => _strings.projectRootRun(id);
  String deliveryDepth(int depth) => _strings.projectDeliveryDepth(depth);
  String targetRuns(String value) => _strings.projectTargetRuns(value);
  String routeError(String code) => switch (code) {
    'project_message_target_not_active' =>
      _strings.projectMentionedAgentInactive,
    _ => _strings.projectMessageSendFailed(code),
  };

  String get newTextArtifact => _strings.projectNewTextArtifact;
  String get relativePath => _strings.projectRelativePath;
  String get content => _strings.projectContent;
  String get moveOrRename => _strings.projectMoveOrRename;
  String get deleteArtifact => _strings.projectDeleteArtifactTitle;
  String deleteArtifactDescription(String path) =>
      _strings.projectDeleteArtifactDescription(path);
  String get searchArtifacts => _strings.projectSearchArtifacts;
  String get allTypes => _strings.projectAllTypes;
  String get importFiles => _strings.projectImportFiles;
  String get createText => _strings.projectCreateText;
  String get noArtifacts => _strings.projectNoArtifacts;
  String get artifactRoot => _strings.projectArtifactRoot;
  String get backToParentFolder => _strings.projectBackToParentFolder;
  String folderArtifactCount(int count) =>
      _strings.projectFolderArtifactCount(count);
  String get previewAndHistory => _strings.projectPreviewAndHistory;
  String get openInSystemApp => _strings.projectOpenInSystemApp;
  String get unableToOpenArtifact => _strings.projectUnableToOpenArtifact;
  String get writeNewVersion => _strings.projectWriteNewVersion;
  String get createVersion => _strings.projectCreateVersion;
  String source(String value) => _strings.projectSource(value);
  String get unableToReadVersion => _strings.projectUnableToReadVersion;
  String unsupportedPreview(String mime, String digest) =>
      _strings.projectUnsupportedPreview(mime, digest);
  String get previewTruncated => _strings.projectPreviewTruncated;
  String actorSource(ProjectArtifact artifact) => switch (artifact
      .createdByType) {
    ProjectArtifactActorType.user => user,
    ProjectArtifactActorType.agent =>
      artifact.createdById.isEmpty
          ? agent
          : _strings.projectAgentNamed(artifact.createdById),
    ProjectArtifactActorType.system => system,
  };
  String artifactKind(ProjectArtifactKind kind) => switch (kind) {
    ProjectArtifactKind.attachment => _strings.projectArtifactKindAttachment,
    ProjectArtifactKind.document => _strings.projectArtifactKindDocument,
    ProjectArtifactKind.code => _strings.projectArtifactKindCode,
    ProjectArtifactKind.image => _strings.projectArtifactKindImage,
    ProjectArtifactKind.audio => _strings.projectArtifactKindAudio,
    ProjectArtifactKind.video => _strings.projectArtifactKindVideo,
    ProjectArtifactKind.dataset => _strings.projectArtifactKindDataset,
    ProjectArtifactKind.archive => _strings.projectArtifactKindArchive,
    ProjectArtifactKind.generated => _strings.projectArtifactKindGenerated,
    ProjectArtifactKind.other => _strings.projectArtifactKindOther,
  };
  String artifactError(String code) => switch (code) {
    'artifact_path_invalid' => _strings.projectArtifactPathInvalid,
    'artifact_path_conflict' => _strings.projectArtifactPathConflict,
    'artifact_size_limit_exceeded' => _strings.projectArtifactSizeExceeded,
    'artifact_is_referenced' => _strings.projectArtifactIsReferenced,
    'artifact_version_conflict' => _strings.projectArtifactVersionConflict,
    'artifact_source_symlink_rejected' =>
      _strings.projectArtifactSymlinkRejected,
    'artifact_open_failed' => unableToOpenArtifact,
    _ => _strings.projectArtifactOperationFailed(code),
  };

  String get searchAgents => _strings.projectSearchAgents;
  String get addAgent => _strings.projectAddAgent;
  String get addAgentDescription => _strings.projectAddAgentDescription;
  String get searchAvailableAgents => _strings.projectSearchAvailableAgents;
  String get membersDescription => _strings.projectMembersDescription;
  String get noMembers => _strings.projectNoMembers;
  String get noAvailableAgents => _strings.projectNoAvailableAgents;
  String get noMatchingAgents => _strings.projectNoMatchingAgents;
  String get deletedAgent => _strings.projectDeletedAgent;
  String get pause => _strings.projectPause;
  String get resume => _strings.projectResume;
  String get remove => _strings.projectRemove;
  String reorderMember(String name) => _strings.projectReorderMember(name);
  String get storageAccess => _strings.projectStorageAccess;
  String get updatingStorageAccess => _strings.projectUpdatingStorageAccess;
  String storageAccessName(ProjectStorageAccess access) => switch (access) {
    ProjectStorageAccess.none => _strings.projectStorageAccessNone,
    ProjectStorageAccess.read => _strings.projectStorageAccessRead,
    ProjectStorageAccess.readWrite => _strings.projectStorageAccessReadWrite,
  };
  String removeMemberTitle(String name) =>
      _strings.projectRemoveMemberTitle(name);
  String removeMemberDescription(bool hasActiveRun) =>
      hasActiveRun
          ? _strings.projectRemoveActiveMemberDescription
          : _strings.projectRemoveMemberDescription;
  String memberError(String code) => _strings.projectMemberUpdateFailed(code);

  String get totalRuns => _strings.projectRuns;
  String get decisions => _strings.projectDecisions;
  String get passed => _strings.projectPassed;
  String get tokenUsage => _strings.tokenUsage;
  String tokens(int input, int output) =>
      _strings.projectTokenBreakdown(input, output);
  String get noExecutions => _strings.projectNoExecutions;
  String get executionRuns => _strings.projectExecutionRuns;
  String messageSequence(int sequence) =>
      _strings.projectMessageSequence(sequence);
  String runCount(int count) => _strings.projectRunCount(count);
  String recipientCount(int count) => _strings.projectRecipientCount(count);
  String routingMode(ProjectTurnRoutingMode mode) => switch (mode) {
    ProjectTurnRoutingMode.targeted => _strings.projectRoutingTargeted,
    ProjectTurnRoutingMode.broadcast => _strings.projectRoutingBroadcast,
    ProjectTurnRoutingMode.delivery => _strings.projectRoutingDelivery,
  };
  String turnStatus(ProjectTurnStatus status) => switch (status) {
    ProjectTurnStatus.created => _strings.projectTurnCreated,
    ProjectTurnStatus.dispatching => _strings.projectTurnDispatching,
    ProjectTurnStatus.deciding => _strings.projectTurnDeciding,
    ProjectTurnStatus.replying => _strings.projectTurnReplying,
    ProjectTurnStatus.delivering => _strings.projectTurnDelivering,
    ProjectTurnStatus.completed => _strings.projectTurnCompleted,
    ProjectTurnStatus.partial => _strings.projectTurnPartial,
    ProjectTurnStatus.failed => _strings.projectTurnFailed,
    ProjectTurnStatus.cancelled => _strings.projectTurnCancelled,
  };
  String runPhase(AgentRunPhase phase) => switch (phase) {
    AgentRunPhase.decision => _strings.projectRunPhaseDecision,
    AgentRunPhase.reply => _strings.projectRunPhaseReply,
    AgentRunPhase.delivery => _strings.projectRunPhaseDelivery,
  };
  String agentRunStatus(AgentRunStatus status) => switch (status) {
    AgentRunStatus.queued => _strings.projectRunQueued,
    AgentRunStatus.deciding => _strings.projectRunDeciding,
    AgentRunStatus.passed => _strings.projectRunPassed,
    AgentRunStatus.preparing => _strings.projectRunPreparing,
    AgentRunStatus.running => _strings.projectRunRunning,
    AgentRunStatus.delivering => _strings.projectRunDelivering,
    AgentRunStatus.completed => _strings.projectRunCompleted,
    AgentRunStatus.cancelled => _strings.projectRunCancelled,
    AgentRunStatus.failed => _strings.projectRunFailed,
    AgentRunStatus.timedOut => _strings.projectRunTimedOut,
    AgentRunStatus.limitExceeded => _strings.projectRunLimitExceeded,
    AgentRunStatus.interrupted => _strings.projectRunInterrupted,
  };
  String get runIdentifierLabel => _strings.projectRunIdentifierLabel;
  String get cancelRun => _strings.projectCancelRun;
  String get cancelRunTitle => _strings.projectCancelRunTitle;
  String get cancelRunDescription => _strings.projectCancelRunDescription;
  String get cancelTurn => _strings.projectCancelTurn;
  String get cancelTurnTitle => _strings.projectCancelTurnTitle;
  String get cancelTurnDescription => _strings.projectCancelTurnDescription;
  String get cancelRootChain => _strings.projectCancelRootChain;
  String get cancelRootChainTitle => _strings.projectCancelRootChainTitle;
  String get cancelRootChainDescription =>
      _strings.projectCancelRootChainDescription;
  String get contextReport => _strings.projectContextReport;
  String get auditEvents => _strings.projectAuditEvents;
  String get noAuditEvents => _strings.projectNoAuditEvents;
  String auditEventType(ProjectEventType type) => switch (type) {
    ProjectEventType.userMessage => _strings.projectEventUserMessage,
    ProjectEventType.agentMessage => _strings.projectEventAgentMessage,
    ProjectEventType.participationDecision =>
      _strings.projectEventParticipationDecision,
    ProjectEventType.agentDelivery => _strings.projectEventAgentDelivery,
    ProjectEventType.membershipChanged =>
      _strings.projectEventMembershipChanged,
    ProjectEventType.projectArtifactChanged =>
      _strings.projectEventArtifactChanged,
    ProjectEventType.runStatusChanged => _strings.projectEventRunStatusChanged,
    ProjectEventType.systemNotice => _strings.projectEventSystemNotice,
  };
  String auditSequence(int sequence) => _strings.projectEventSequence(sequence);
  String auditActor(ProjectEventActorType type, String snapshot) {
    if (snapshot.trim().isNotEmpty) return snapshot.trim();
    return switch (type) {
      ProjectEventActorType.user => user,
      ProjectEventActorType.agent => agent,
      ProjectEventActorType.system => system,
    };
  }

  String membershipChange(String agentId, String previous, String current) =>
      previous.isEmpty
          ? _strings.projectMembershipCurrent(agentId, current)
          : _strings.projectMembershipChanged(agentId, previous, current);
  String artifactChange(String changeKind, String artifactId) =>
      _strings.projectArtifactChange(changeKind, artifactId);
  String auditRunChange(String phase, String status, String errorCode) =>
      <String>[
        '$phase · $status',
        if (errorCode.isNotEmpty) errorCode,
      ].join(' · ');
  String auditDelivery(String kind, String summary) =>
      summary.trim().isEmpty ? kind : '$kind · ${summary.trim()}';
  String auditSystemNotice(String code, String detail) =>
      detail.trim().isEmpty ? code : '$code · ${detail.trim()}';
  String get summarySegments => _strings.projectSummarySegments;
  String get memories => _strings.projectAgentMemories;
  String get artifactVersionIds => _strings.projectArtifactVersionIds;
  String get skills => _strings.projectSkills;
  String get tools => _strings.projectTools;
  String get memoryRevision => _strings.projectMemoryRevision;
  String get coveredThroughMessage => _strings.projectCoveredThroughMessage;
  String get active => _strings.projectActive;
  String get pausedStatus => _strings.projectPausedStatus;
  String participationDecision(ParticipationDecision decision) =>
      '${participationChoice(decision.choice)} · '
      '${participationReason(decision.reasonCode)}';
  String participationChoice(ParticipationChoice choice) => switch (choice) {
    ParticipationChoice.reply => _strings.projectParticipationReply,
    ParticipationChoice.pass => _strings.projectParticipationPass,
  };
  String participationReason(String code) => switch (code) {
    'decision_invalid' => _strings.projectDecisionInvalid,
    'decision_timeout' => _strings.projectDecisionTimeout,
    'decision_failed' => _strings.projectDecisionFailed,
    'decision_cancelled' => _strings.projectDecisionCancelled,
    _ => code,
  };
  String duration(String value) => _strings.projectDuration(value);
  String errorCode(String value) =>
      _strings.projectError(participationReason(value));
}
