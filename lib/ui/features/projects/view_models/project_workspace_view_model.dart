import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/attachment_repository.dart';
import 'package:hyve/domain/repositories/agent_delivery_repository.dart';
import 'package:hyve/domain/repositories/agent_message_receipt_repository.dart';
import 'package:hyve/domain/repositories/agent_repository.dart';
import 'package:hyve/domain/repositories/agent_run_repository.dart';
import 'package:hyve/domain/repositories/project_agent_cursor_repository.dart';
import 'package:hyve/domain/repositories/project_artifact_repository.dart';
import 'package:hyve/domain/repositories/project_event_repository.dart';
import 'package:hyve/domain/repositories/project_membership_repository.dart';
import 'package:hyve/domain/repositories/model_usage_repository.dart';
import 'package:hyve/domain/repositories/participation_decision_repository.dart';
import 'package:hyve/domain/repositories/project_repository.dart';
import 'package:hyve/domain/repositories/project_turn_repository.dart';
import 'package:hyve/domain/repositories/project_temporary_attachment_repository.dart';
import 'package:hyve/domain/use_cases/agent_inbox_coordinator.dart';
import 'package:hyve/domain/use_cases/route_project_message.dart';
import 'package:hyve/ui/core/view_models/disposable_change_notifier.dart';
import 'package:hyve/ui/features/projects/view_models/project_agent_activity.dart';
import 'package:hyve/ui/features/projects/view_models/project_artifacts_controller.dart';

final class ProjectAgentStatusSnapshot {
  const ProjectAgentStatusSnapshot({
    required this.agentId,
    required this.activity,
    required this.lastProcessedMessageSequence,
    required this.latestMessageSequence,
    required this.backlog,
    this.activeRunId = '',
    this.errorCode = '',
  });

  final String agentId;
  final ProjectAgentActivity activity;
  final int lastProcessedMessageSequence;
  final int latestMessageSequence;
  final int backlog;
  final String activeRunId;
  final String errorCode;
}

final class ProjectWorkspaceViewModel extends DisposableChangeNotifier
    implements ProjectArtifactsController {
  ProjectWorkspaceViewModel({
    required this.projectId,
    required RouteProjectMessage routeProjectMessage,
    required ProjectRepository projectRepository,
    required ProjectMembershipRepository membershipRepository,
    required ProjectEventRepository eventRepository,
    required ProjectTurnRepository turnRepository,
    required AgentRepository agentRepository,
    required ProjectAgentCursorRepository cursorRepository,
    required AgentRunRepository runRepository,
    required AgentDeliveryRepository deliveryRepository,
    required AgentMessageReceiptRepository receiptRepository,
    required ParticipationDecisionRepository decisionRepository,
    required ModelUsageRepository modelUsageRepository,
    required AgentInboxCoordinator inboxCoordinator,
    required ProjectArtifactRepository artifactRepository,
    required AttachmentRepository attachmentRepository,
    required ProjectTemporaryAttachmentRepository temporaryAttachmentRepository,
  }) : _routeProjectMessage = routeProjectMessage,
       _projectRepository = projectRepository,
       _membershipRepository = membershipRepository,
       _eventRepository = eventRepository,
       _turnRepository = turnRepository,
       _agentRepository = agentRepository,
       _cursorRepository = cursorRepository,
       _runRepository = runRepository,
       _deliveryRepository = deliveryRepository,
       _receiptRepository = receiptRepository,
       _decisionRepository = decisionRepository,
       _modelUsageRepository = modelUsageRepository,
       _artifactRepository = artifactRepository,
       _attachmentRepository = attachmentRepository,
       _temporaryAttachmentRepository = temporaryAttachmentRepository,
       _inboxCoordinator = inboxCoordinator {
    _cursorSubscription = _cursorRepository.changes.listen((key) {
      if (key.projectId == projectId) unawaited(refresh());
    });
    _membershipSubscription = _membershipRepository.changes.listen((id) {
      if (id == projectId) unawaited(refresh());
    });
    _eventSubscription = _eventRepository.changes.listen((id) {
      if (id == projectId) unawaited(refresh());
    });
    _agentSubscription = _agentRepository.changes.listen((_) {
      unawaited(refresh());
    });
    _projectSubscription = _projectRepository.changes.listen((projects) {
      if (projects.any((project) => project.id == projectId)) {
        unawaited(refresh());
      }
    });
    _deliverySubscription = _deliveryRepository.changes.listen((id) {
      if (id == projectId) unawaited(refresh());
    });
    _artifactSubscription = _artifactRepository.changes.listen((id) {
      if (id == projectId) unawaited(refreshArtifacts());
    });
  }

  final String projectId;
  final RouteProjectMessage _routeProjectMessage;
  final ProjectRepository _projectRepository;
  final ProjectMembershipRepository _membershipRepository;
  final ProjectEventRepository _eventRepository;
  final ProjectTurnRepository _turnRepository;
  final AgentRepository _agentRepository;
  final ProjectAgentCursorRepository _cursorRepository;
  final AgentRunRepository _runRepository;
  final AgentDeliveryRepository _deliveryRepository;
  final AgentMessageReceiptRepository _receiptRepository;
  final ParticipationDecisionRepository _decisionRepository;
  final ModelUsageRepository _modelUsageRepository;
  final ProjectArtifactRepository _artifactRepository;
  final AttachmentRepository _attachmentRepository;
  final ProjectTemporaryAttachmentRepository _temporaryAttachmentRepository;
  final AgentInboxCoordinator _inboxCoordinator;
  late final StreamSubscription<ProjectAgentInboxKey> _cursorSubscription;
  late final StreamSubscription<String> _membershipSubscription;
  late final StreamSubscription<String> _eventSubscription;
  late final StreamSubscription<List<Agent>> _agentSubscription;
  late final StreamSubscription<List<Project>> _projectSubscription;
  late final StreamSubscription<String> _deliverySubscription;
  late final StreamSubscription<String> _artifactSubscription;

  List<ProjectAgentStatusSnapshot> _agentStatuses = const [];
  Project? _project;
  List<Agent> _activeAgents = const [];
  List<ProjectEvent> _events = const [];
  Map<String, ProjectTurn> _turns = const {};
  Map<String, AgentDelivery> _deliveries = const {};
  Map<String, AgentRun> _runs = const {};
  Map<String, ParticipationDecision> _decisions = const {};
  List<ModelTokenUsageRecord> _usageRecords = const [];
  Map<String, String> _agentNames = const {};
  List<ProjectArtifactEntry> _artifacts = const [];
  String _artifactQuery = '';
  Set<ProjectArtifactKind> _artifactKinds = const <ProjectArtifactKind>{};
  bool _artifactBusy = false;
  bool _eventPageBusy = false;
  bool _hasEarlierEvents = false;
  bool _submitting = false;
  String _errorCode = '';

  List<ProjectAgentStatusSnapshot> get agentStatuses => _agentStatuses;
  Project? get project => _project;
  List<Agent> get activeAgents => _activeAgents;
  List<ProjectEvent> get events => _events;
  Map<String, ProjectTurn> get turns => _turns;
  Map<String, AgentDelivery> get deliveries => _deliveries;
  Map<String, AgentRun> get runs => _runs;
  Map<String, ParticipationDecision> get decisions => _decisions;
  List<ModelTokenUsageRecord> get usageRecords => _usageRecords;
  Map<String, String> get agentNames => _agentNames;
  @override
  List<ProjectArtifactEntry> get artifacts => _artifacts;
  String get artifactQuery => _artifactQuery;
  Set<ProjectArtifactKind> get artifactKinds => _artifactKinds;
  @override
  bool get artifactBusy => _artifactBusy;
  bool get eventPageBusy => _eventPageBusy;
  bool get hasEarlierEvents => _hasEarlierEvents;
  bool get submitting => _submitting;
  @override
  String get errorCode => _errorCode;

  Future<void> refresh() async {
    final project = await _projectRepository.getProject(projectId);
    if (project == null || isDisposed) return;
    final memberships = await _membershipRepository.getForProject(projectId);
    if (_artifacts.isEmpty && !_artifactBusy) {
      unawaited(refreshArtifacts());
    }
    final activeMemberships = memberships
        .where(
          (membership) => membership.status == ProjectMembershipStatus.active,
        )
        .toList(growable: false);
    final agentsById = <String, Agent>{
      for (final agent in await _agentRepository.getAgents()) agent.id: agent,
    };
    final latestEvents = await _eventRepository.getEvents(
      projectId,
      limit: 200,
    );
    final eventById = <String, ProjectEvent>{
      for (final event in _events) event.id: event,
      for (final event in latestEvents) event.id: event,
    };
    final events = eventById.values.toList(growable: false)
      ..sort((left, right) => left.sequence.compareTo(right.sequence));
    final turns = await _turnRepository.getForProject(projectId, limit: 200);
    final deliveryRecords = await Future.wait(<Future<AgentDelivery?>>[
      for (final event in events)
        if (event.eventType == ProjectEventType.agentDelivery)
          _deliveryRepository.getForEvent(event.id),
    ]);
    final turnRuns = await Future.wait(<Future<List<AgentRun>>>[
      for (final turn in turns) _runRepository.getForTurn(turn.id),
    ]);
    final turnDecisions = await Future.wait(
      <Future<List<ParticipationDecision>>>[
        for (final turn in turns) _decisionRepository.getForTurn(turn.id),
      ],
    );
    final turnReceipts = await Future.wait(<Future<List<AgentMessageReceipt>>>[
      for (final turn in turns) _receiptRepository.getForTurn(turn.id),
    ]);
    final latestDecisionByAgent = <String, ParticipationDecision>{};
    for (final values in turnDecisions) {
      for (final decision in values) {
        final current = latestDecisionByAgent[decision.agentId];
        if (current == null ||
            decision.messageSequence > current.messageSequence ||
            (decision.messageSequence == current.messageSequence &&
                decision.createdAt.isAfter(current.createdAt))) {
          latestDecisionByAgent[decision.agentId] = decision;
        }
      }
    }
    final latestReceiptByAgent = <String, AgentMessageReceipt>{};
    for (final values in turnReceipts) {
      for (final receipt in values) {
        final current = latestReceiptByAgent[receipt.agentId];
        if (current == null ||
            receipt.messageSequence > current.messageSequence ||
            (receipt.messageSequence == current.messageSequence &&
                receipt.completedAt.isAfter(current.completedAt))) {
          latestReceiptByAgent[receipt.agentId] = receipt;
        }
      }
    }
    final usageRecords = await _modelUsageRepository.getForProject(projectId);
    final cursors = await _cursorRepository.getForProject(projectId);
    final byAgent = <String, AgentMessageCursor>{
      for (final cursor in cursors) cursor.agentId: cursor,
    };
    final statuses = <ProjectAgentStatusSnapshot>[];
    for (final membership in memberships.where(
      (item) => item.status != ProjectMembershipStatus.removed,
    )) {
      final cursor = byAgent[membership.agentId];
      final run =
          cursor?.activeRunId == null
              ? null
              : await _runRepository.getRun(cursor!.activeRunId!);
      final last =
          cursor?.lastProcessedMessageSequence ??
          membership.joinMessageSequence;
      final latestReceipt = latestReceiptByAgent[membership.agentId];
      statuses.add(
        ProjectAgentStatusSnapshot(
          agentId: membership.agentId,
          activity: resolveProjectAgentActivity(
            membership,
            cursor,
            run,
            latestDecisionByAgent[membership.agentId],
            latestReceipt,
            project,
          ),
          lastProcessedMessageSequence: last,
          latestMessageSequence: project.lastMessageSequence,
          backlog:
              project.lastMessageSequence > last
                  ? project.lastMessageSequence - last
                  : 0,
          activeRunId: cursor?.activeRunId ?? '',
          errorCode:
              cursor?.lastError.isNotEmpty == true
                  ? cursor!.lastError
                  : latestReceipt?.outcome ==
                      AgentMessageReceiptOutcome.failedSkipped
                  ? latestReceipt?.errorCode ?? ''
                  : '',
        ),
      );
    }
    if (isDisposed) return;
    _project = project;
    _activeAgents = List<Agent>.unmodifiable([
      for (final membership in activeMemberships)
        if (agentsById[membership.agentId] case final agent?) agent,
    ]);
    _events = List<ProjectEvent>.unmodifiable(events);
    _hasEarlierEvents = _events.isNotEmpty && _events.first.sequence > 1;
    _turns = Map<String, ProjectTurn>.unmodifiable({
      for (final turn in turns) turn.id: turn,
    });
    _deliveries = Map<String, AgentDelivery>.unmodifiable({
      for (final delivery in deliveryRecords)
        if (delivery != null) delivery.eventId: delivery,
    });
    _runs = Map<String, AgentRun>.unmodifiable({
      for (final values in turnRuns)
        for (final run in values) run.id: run,
    });
    _decisions = Map<String, ParticipationDecision>.unmodifiable({
      for (final values in turnDecisions)
        for (final decision in values) decision.runId: decision,
    });
    _usageRecords = List<ModelTokenUsageRecord>.unmodifiable(usageRecords);
    _agentNames = Map<String, String>.unmodifiable({
      for (final entry in agentsById.entries) entry.key: entry.value.name,
    });
    _agentStatuses = List<ProjectAgentStatusSnapshot>.unmodifiable(statuses);
    notifyListeners();
  }

  Future<void> loadEarlierEvents() async {
    if (_eventPageBusy || !_hasEarlierEvents || _events.isEmpty) return;
    _eventPageBusy = true;
    notifyListeners();
    try {
      final older = await _eventRepository.getEvents(
        projectId,
        beforeSequence: _events.first.sequence,
        limit: 200,
      );
      if (isDisposed) return;
      _events = List<ProjectEvent>.unmodifiable(<ProjectEvent>[
        ...older,
        ..._events,
      ]);
      _hasEarlierEvents = _events.isNotEmpty && _events.first.sequence > 1;
    } on Object {
      _errorCode = 'project_events_load_failed';
    } finally {
      if (!isDisposed) {
        _eventPageBusy = false;
        notifyListeners();
      }
    }
  }

  ProjectArtifactActor get _userArtifactActor => const ProjectArtifactActor(
    type: ProjectArtifactActorType.user,
    id: 'current-user',
    name: 'User',
  );

  @override
  Future<void> refreshArtifacts({
    String? query,
    Set<ProjectArtifactKind>? kinds,
  }) async {
    if (_artifactBusy) return;
    _artifactQuery = query ?? _artifactQuery;
    _artifactKinds = kinds ?? _artifactKinds;
    _artifactBusy = true;
    _errorCode = '';
    notifyListeners();
    try {
      final entries = await _artifactRepository.search(
        projectId: projectId,
        actor: _userArtifactActor,
        query: ProjectArtifactQuery(
          text: _artifactQuery,
          kinds: _artifactKinds,
          limit: 100,
        ),
      );
      if (!isDisposed) _artifacts = entries;
    } on ProjectArtifactFailure catch (failure) {
      _errorCode = failure.code;
    } finally {
      if (!isDisposed) {
        _artifactBusy = false;
        notifyListeners();
      }
    }
  }

  Future<PendingAttachment?> pickMessageAttachment() async {
    final sourcePath = await _attachmentRepository.selectFile();
    if (sourcePath == null || sourcePath.trim().isEmpty) return null;
    return PendingAttachment(
      sourcePath: sourcePath,
      kind: _pendingAttachmentKind(sourcePath),
      displayName: path.basename(sourcePath),
    );
  }

  Future<ProjectArtifactEntry?> importPickedArtifact() async {
    final sourcePath = await _attachmentRepository.selectFile();
    if (sourcePath == null || sourcePath.trim().isEmpty) return null;
    return _importSource(sourcePath, folder: 'imports');
  }

  @override
  Future<List<ProjectArtifactEntry>> importPickedArtifacts() async {
    return importArtifactPaths(await _attachmentRepository.selectFiles());
  }

  @override
  Future<List<ProjectArtifactEntry>> importArtifactPaths(
    Iterable<String> sourcePaths,
  ) async {
    final imported = <ProjectArtifactEntry>[];
    for (final sourcePath in sourcePaths.where(
      (item) => item.trim().isNotEmpty,
    )) {
      final entry = await _importSource(sourcePath, folder: 'imports');
      if (entry != null) imported.add(entry);
    }
    return List<ProjectArtifactEntry>.unmodifiable(imported);
  }

  @override
  Future<ProjectArtifactEntry?> createTextArtifact({
    required String relativePath,
    required String content,
  }) async {
    try {
      final result = await _artifactRepository.create(
        projectId: projectId,
        relativePath: relativePath,
        kind: _projectArtifactKind(relativePath),
        mimeType: '',
        bytes: Uint8List.fromList(utf8.encode(content)),
        actor: _userArtifactActor,
      );
      await refreshArtifacts();
      return ProjectArtifactEntry(
        artifact: result.artifact,
        currentVersion: result.version,
      );
    } on ProjectArtifactFailure catch (failure) {
      _recordArtifactFailure(failure);
      return null;
    }
  }

  @override
  Future<ProjectArtifactReadResult?> previewArtifact(
    ProjectArtifactEntry entry, {
    String versionId = '',
  }) async {
    try {
      return await _artifactRepository.read(
        projectId: projectId,
        artifactId: entry.artifact.id,
        versionId: versionId,
        actor: _userArtifactActor,
        length: 32768,
      );
    } on ProjectArtifactFailure catch (failure) {
      _recordArtifactFailure(failure);
      return null;
    }
  }

  @override
  Future<List<ProjectArtifactVersion>> artifactVersions(
    ProjectArtifactEntry entry,
  ) async {
    try {
      return await _artifactRepository.versions(
        projectId: projectId,
        artifactId: entry.artifact.id,
        actor: _userArtifactActor,
      );
    } on ProjectArtifactFailure catch (failure) {
      _recordArtifactFailure(failure);
      return const <ProjectArtifactVersion>[];
    }
  }

  @override
  Future<List<ProjectArtifactMessageReference>> artifactMessageReferences(
    ProjectArtifactEntry entry, {
    String versionId = '',
  }) => _artifactRepository.messageReferences(
    projectId: projectId,
    artifactId: entry.artifact.id,
    versionId: versionId,
    actor: _userArtifactActor,
  );

  @override
  Future<ProjectArtifactEntry?> writeTextArtifactVersion({
    required ProjectArtifactEntry entry,
    required String content,
  }) async {
    try {
      final result = await _artifactRepository.writeVersion(
        projectId: projectId,
        artifactId: entry.artifact.id,
        bytes: Uint8List.fromList(utf8.encode(content)),
        actor: _userArtifactActor,
        expectedCurrentVersionId: entry.artifact.currentVersionId,
      );
      await refreshArtifacts();
      return ProjectArtifactEntry(
        artifact: result.artifact,
        currentVersion: result.version,
      );
    } on ProjectArtifactFailure catch (failure) {
      _recordArtifactFailure(failure);
      return null;
    }
  }

  @override
  Future<bool> moveArtifact(
    ProjectArtifactEntry entry,
    String relativePath,
  ) async {
    try {
      await _artifactRepository.move(
        projectId: projectId,
        artifactId: entry.artifact.id,
        relativePath: relativePath,
        actor: _userArtifactActor,
      );
      await refreshArtifacts();
      return true;
    } on ProjectArtifactFailure catch (failure) {
      _recordArtifactFailure(failure);
      return false;
    }
  }

  @override
  Future<bool> deleteArtifact(ProjectArtifactEntry entry) async {
    try {
      await _artifactRepository.delete(
        projectId: projectId,
        artifactId: entry.artifact.id,
        actor: _userArtifactActor,
      );
      await refreshArtifacts();
      return true;
    } on ProjectArtifactFailure catch (failure) {
      _recordArtifactFailure(failure);
      return false;
    }
  }

  Future<ProjectArtifactEntry?> _importSource(
    String sourcePath, {
    required String folder,
    String displayName = '',
  }) async {
    final name =
        displayName.trim().isEmpty
            ? path.basename(sourcePath)
            : path.basename(displayName.trim());
    if (name.isEmpty) {
      _recordArtifactFailure(
        const ProjectArtifactFailure('artifact_path_invalid'),
      );
      return null;
    }
    Future<ProjectArtifactMutationResult> importAt(String relativePath) {
      return _artifactRepository.import(
        projectId: projectId,
        sourcePath: sourcePath,
        relativePath: relativePath,
        kind: _projectArtifactKind(name),
        mimeType: '',
        actor: _userArtifactActor,
        metadata: <String, Object?>{
          'originalName': name,
          'source':
              folder == 'attachments' ? 'messageAttachment' : 'userImport',
        },
      );
    }

    try {
      ProjectArtifactMutationResult result;
      try {
        result = await importAt(path.posix.join(folder, name));
      } on ProjectArtifactFailure catch (failure) {
        if (failure.code != 'artifact_path_conflict') rethrow;
        final stem = path.basenameWithoutExtension(name);
        final extension = path.extension(name);
        result = await importAt(
          path.posix.join(
            folder,
            '${stem}_${DateTime.now().microsecondsSinceEpoch}$extension',
          ),
        );
      }
      await refreshArtifacts();
      return ProjectArtifactEntry(
        artifact: result.artifact,
        currentVersion: result.version,
      );
    } on ProjectArtifactFailure catch (failure) {
      _recordArtifactFailure(failure);
      return null;
    }
  }

  void _recordArtifactFailure(ProjectArtifactFailure failure) {
    _errorCode = failure.code;
    if (!isDisposed) notifyListeners();
  }

  Future<RoutedProjectMessage?> submit(ProjectMessageDraft draft) async {
    if (_submitting || draft.isEmpty) return null;
    _submitting = true;
    _errorCode = '';
    notifyListeners();
    try {
      final versionIds = <String>[...draft.projectArtifactVersionIds];
      final transientAttachments = <PendingAttachment>[];
      for (final attachment in draft.attachments) {
        if (!attachment.promoteToProjectArtifact) {
          transientAttachments.add(attachment);
          continue;
        }
        final imported = await _importSource(
          attachment.sourcePath,
          folder: 'attachments',
          displayName: attachment.displayName,
        );
        if (imported == null) return null;
        versionIds.add(imported.currentVersion.id);
      }
      var messageAttachments = transientAttachments;
      if (transientAttachments.isNotEmpty) {
        final persistedPaths = await _temporaryAttachmentRepository.persist(
          projectId: projectId,
          sourcePaths: transientAttachments.map((item) => item.sourcePath),
        );
        messageAttachments = <PendingAttachment>[
          for (var index = 0; index < persistedPaths.length; index++)
            PendingAttachment(
              sourcePath: persistedPaths[index],
              kind: transientAttachments[index].kind,
              displayName: transientAttachments[index].displayName,
            ),
        ];
      }
      return await _routeProjectMessage(
        projectId: projectId,
        draft: ProjectMessageDraft(
          text: draft.text,
          mentions: draft.mentions,
          attachments: messageAttachments,
          projectArtifactVersionIds: versionIds,
        ),
      );
    } on ProjectMessageRouteFailure catch (failure) {
      _errorCode = failure.code;
      return null;
    } on Object {
      _errorCode = 'attachment_persist_failed';
      return null;
    } finally {
      if (!isDisposed) {
        _submitting = false;
        notifyListeners();
      }
    }
  }

  bool cancelRun(String runId) => _inboxCoordinator.cancelRun(runId);

  Future<int> cancelTurn(String turnId) => _inboxCoordinator.cancelTurn(turnId);

  int cancelRootChain(String rootRunId) {
    var cancelled = 0;
    for (final run in _runs.values.where(
      (item) => item.rootRunId == rootRunId && !item.isTerminal,
    )) {
      if (_inboxCoordinator.cancelRun(run.id)) cancelled++;
    }
    return cancelled;
  }

  int cancelActiveRuns() {
    var cancelled = 0;
    for (final runId
        in _agentStatuses
            .map((status) => status.activeRunId)
            .where((runId) => runId.isNotEmpty)
            .toSet()) {
      if (_inboxCoordinator.cancelRun(runId)) cancelled++;
    }
    return cancelled;
  }

  @override
  void dispose() {
    _cursorSubscription.cancel();
    _membershipSubscription.cancel();
    _eventSubscription.cancel();
    _agentSubscription.cancel();
    _projectSubscription.cancel();
    _deliverySubscription.cancel();
    _artifactSubscription.cancel();
    super.dispose();
  }
}

PendingAttachmentKind _pendingAttachmentKind(String filePath) {
  return switch (path.extension(filePath).toLowerCase()) {
    '.png' ||
    '.jpg' ||
    '.jpeg' ||
    '.gif' ||
    '.webp' => PendingAttachmentKind.image,
    '.mp3' || '.wav' || '.m4a' => PendingAttachmentKind.audio,
    '.mp4' || '.mov' || '.webm' => PendingAttachmentKind.video,
    _ => PendingAttachmentKind.file,
  };
}

ProjectArtifactKind _projectArtifactKind(String filePath) {
  final extension = path.extension(filePath).toLowerCase();
  return switch (extension) {
    '.png' ||
    '.jpg' ||
    '.jpeg' ||
    '.gif' ||
    '.webp' ||
    '.svg' => ProjectArtifactKind.image,
    '.mp3' || '.wav' || '.m4a' => ProjectArtifactKind.audio,
    '.mp4' || '.mov' || '.webm' => ProjectArtifactKind.video,
    '.zip' || '.tar' || '.gz' || '.7z' => ProjectArtifactKind.archive,
    '.csv' || '.json' || '.parquet' => ProjectArtifactKind.dataset,
    '.dart' ||
    '.js' ||
    '.mjs' ||
    '.ts' ||
    '.tsx' ||
    '.py' ||
    '.java' ||
    '.kt' ||
    '.swift' ||
    '.go' ||
    '.rs' ||
    '.c' ||
    '.h' ||
    '.cpp' ||
    '.css' ||
    '.html' => ProjectArtifactKind.code,
    '.txt' ||
    '.md' ||
    '.markdown' ||
    '.pdf' ||
    '.yaml' ||
    '.yml' => ProjectArtifactKind.document,
    _ => ProjectArtifactKind.other,
  };
}
