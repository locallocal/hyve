part of 'app_dependencies.dart';

final class ProjectAgentPersistence {
  const ProjectAgentPersistence({
    required this.agentRepository,
    required this.projectRepository,
    required this.membershipRepository,
    required this.eventRepository,
    required this.turnRepository,
    required this.runRepository,
    required this.cursorRepository,
    required this.receiptRepository,
    required this.decisionRepository,
    required this.deliveryRepository,
    required this.artifactRepository,
    required this.conversationSummaryRepository,
    required this.agentMemoryRepository,
    required this.agentMemoryEvolutionRepository,
    required this.compactConversationMessages,
    required this.modelUsageRepository,
    required this.manageProjectMembers,
    required this.attachmentRepository,
    required this.temporaryAttachmentRepository,
    required this.routeRepository,
    required this.routeProjectMessage,
    required this.inboxCoordinator,
    required this.createProject,
    required this.workspaceCache,
  });

  factory ProjectAgentPersistence.create({
    required LocalDatabaseService localDatabase,
    required BotApiKeyCipher apiKeyCipher,
    required ProjectAgentStorageService storage,
    required AttachmentRepository attachmentRepository,
    required AiProviderRepository providers,
    required ModelUsageRepository modelUsageRepository,
  }) {
    final agentRepository = SqliteAgentRepository(
      localDatabase: localDatabase,
      apiKeyCipher: apiKeyCipher,
      storage: storage,
    );
    final projectRepository = SqliteProjectRepository(
      localDatabase: localDatabase,
      storage: storage,
    );
    final membershipRepository = SqliteProjectMembershipRepository(
      localDatabase: localDatabase,
    );
    final artifactRepository = SqliteProjectArtifactRepository(
      localDatabase: localDatabase,
      storage: FileProjectStorageRepository(storage: storage),
    );
    final temporaryAttachmentRepository =
        FileProjectTemporaryAttachmentRepository(storage: storage);
    final eventRepository = SqliteProjectEventRepository(
      localDatabase: localDatabase,
    );
    final fileAgentMemoryRepository = FileAgentMemoryRepository(
      storage: storage,
    );
    final externalAgentMemoryProvider =
        HttpExternalAgentMemoryRepositoryProvider();
    final agentMemoryRepository = AgentMemoryRepositoryRouter(
      agentRepository: agentRepository,
      factory: AgentMemoryRepositoryFactory(
        fileRepository: fileAgentMemoryRepository,
        externalProvider: externalAgentMemoryProvider.call,
      ),
    );
    final agentMemoryEvolutionRepository = SqliteAgentMemoryEvolutionRepository(
      localDatabase: localDatabase,
    );
    final conversationSummaryRepository = SqliteConversationSummaryRepository(
      localDatabase: localDatabase,
      storage: ProjectConversationSummaryStorage(storage: storage),
      eventRepository: eventRepository,
    );
    final compactConversationMessages = CompactConversationMessages(
      projectRepository: projectRepository,
      eventRepository: eventRepository,
      summaryRepository: conversationSummaryRepository,
      summarizerFactory:
          (agent) => ProviderProjectContextSummarizer(
            agent: agent,
            providers: providers,
          ),
      usagePersister:
          (operationId, projectId, agent, usage) => modelUsageRepository.upsert(
            ModelTokenUsageRecord(
              messageId: operationId,
              chatId: projectId,
              botId: agent.id,
              timestamp: DateTime.now(),
              usage: usage,
              operationKind: 'conversation_summary',
            ),
          ),
    );
    final evolveAgentMemory = EvolveAgentMemory(
      memoryRepository: agentMemoryRepository,
      extractor: ProviderAgentMemoryCandidateExtractor(providers: providers),
      evolutionRepository: agentMemoryEvolutionRepository,
    );
    final turnRepository = SqliteProjectTurnRepository(
      localDatabase: localDatabase,
    );
    final runRepository = SqliteAgentRunRepository(
      localDatabase: localDatabase,
    );
    final cursorRepository = SqliteProjectAgentCursorRepository(
      localDatabase: localDatabase,
    );
    final receiptRepository = SqliteAgentMessageReceiptRepository(
      localDatabase: localDatabase,
    );
    final decisionRepository = SqliteParticipationDecisionRepository(
      localDatabase: localDatabase,
    );
    final deliveryRepository = SqliteAgentDeliveryRepository(
      localDatabase: localDatabase,
      projectRepository: projectRepository,
    );
    final routeRepository = SqliteProjectMessageRouteRepository(
      localDatabase: localDatabase,
      projectRepository: projectRepository,
    );
    final gateway = ProviderProjectAgentExecutionGateway(providers: providers);
    late final AgentInboxCoordinator inboxCoordinator;
    final routeProjectMessage = RouteProjectMessage(
      repository: routeRepository,
      wakeup:
          (projectId, agentIds) =>
              inboxCoordinator.wakeProject(projectId, agentIds).ignore(),
    );
    final turnCoordinator = ProjectTurnCoordinator(
      turnRepository: turnRepository,
      eventRepository: eventRepository,
      receiptRepository: receiptRepository,
      runRepository: runRepository,
    );
    final deliverToProjectAgent = DeliverToProjectAgent(
      repository: deliveryRepository,
      wakeup:
          (projectId, agentIds) =>
              inboxCoordinator.wakeProject(projectId, agentIds).ignore(),
    );
    inboxCoordinator = AgentInboxCoordinator(
      cursorRepository: cursorRepository,
      projectRepository: projectRepository,
      membershipRepository: membershipRepository,
      eventRepository: eventRepository,
      turnRepository: turnRepository,
      runRepository: runRepository,
      decisionRepository: decisionRepository,
      agentRepository: agentRepository,
      runBroadcastParticipation: RunBroadcastParticipation(
        runRepository: runRepository,
        decisionRepository: decisionRepository,
        gateway: gateway,
        modelUsageRepository: modelUsageRepository,
      ),
      executeReply: ExecuteProjectAgentReply(
        runRepository: runRepository,
        gateway: gateway,
        routeProjectMessage: routeProjectMessage,
        deliverToProjectAgent: deliverToProjectAgent,
        contextAssembler: AssembleAgentRunContext(
          summaryRepository: conversationSummaryRepository,
          memoryRepository: agentMemoryRepository,
          projectRepository: projectRepository,
        ),
        evolveAgentMemory: ({
          required agent,
          required projectId,
          required observedEvents,
          required contextThroughMessageSequence,
          required agentResponse,
        }) async {
          await evolveAgentMemory(
            agent: agent,
            projectId: projectId,
            observedEvents: observedEvents,
            contextThroughMessageSequence: contextThroughMessageSequence,
            agentResponse: agentResponse,
          );
        },
        scopedToolProvider: ({
          required project,
          required agent,
          required run,
        }) async {
          final membership = await membershipRepository.getMembership(
            project.id,
            agent.id,
          );
          if (membership == null ||
              membership.status != ProjectMembershipStatus.active) {
            return const <ExecutableTool>[];
          }
          final artifactTools =
              ProjectArtifactToolSet(
                repository: artifactRepository,
                projectId: project.id,
                actor: ProjectArtifactActor(
                  type: ProjectArtifactActorType.agent,
                  id: agent.id,
                  name: agent.name,
                  avatar: agent.avatar,
                  sourceRunId: run.id,
                ),
                access: membership.projectStorageAccess,
              ).tools;
          final sourceEvent = await eventRepository.getEvent(
            run.sourceMessageEventId,
          );
          final memoryTools =
              AgentMemoryToolSet(
                repository: agentMemoryRepository,
                agent: agent,
                projectId: project.id,
                sourceEventId: run.sourceMessageEventId,
                sourceMessageSequence: run.sourceMessageSequence,
                sourceDigest:
                    sourceEvent == null
                        ? ''
                        : const ConversationSummarySourceDigest()(
                          <ProjectEvent>[sourceEvent],
                        ),
              ).tools;
          return <ExecutableTool>[...artifactTools, ...memoryTools];
        },
        modelUsageRepository: modelUsageRepository,
      ),
      turnCoordinator: turnCoordinator,
    );
    inboxCoordinator.start().ignore();
    final manageProjectMembers = ManageProjectMembers(
      projectRepository: projectRepository,
      agentRepository: agentRepository,
      membershipRepository: membershipRepository,
      cursorRepository: cursorRepository,
      wakeup:
          (projectId, agentIds) =>
              inboxCoordinator.wakeProject(projectId, agentIds),
      cancelRun: inboxCoordinator.cancelRun,
    );
    return ProjectAgentPersistence(
      agentRepository: agentRepository,
      projectRepository: projectRepository,
      membershipRepository: membershipRepository,
      eventRepository: eventRepository,
      turnRepository: turnRepository,
      runRepository: runRepository,
      cursorRepository: cursorRepository,
      receiptRepository: receiptRepository,
      decisionRepository: decisionRepository,
      deliveryRepository: deliveryRepository,
      artifactRepository: artifactRepository,
      conversationSummaryRepository: conversationSummaryRepository,
      agentMemoryRepository: agentMemoryRepository,
      agentMemoryEvolutionRepository: agentMemoryEvolutionRepository,
      compactConversationMessages: compactConversationMessages,
      modelUsageRepository: modelUsageRepository,
      manageProjectMembers: manageProjectMembers,
      attachmentRepository: attachmentRepository,
      temporaryAttachmentRepository: temporaryAttachmentRepository,
      routeRepository: routeRepository,
      routeProjectMessage: routeProjectMessage,
      inboxCoordinator: inboxCoordinator,
      createProject: CreateProject(
        projectRepository: projectRepository,
        membershipRepository: membershipRepository,
      ),
      workspaceCache: ProjectWorkspaceCache(),
    );
  }

  final AgentRepository agentRepository;
  final ProjectRepository projectRepository;
  final ProjectMembershipRepository membershipRepository;
  final ProjectEventRepository eventRepository;
  final ProjectTurnRepository turnRepository;
  final AgentRunRepository runRepository;
  final ProjectAgentCursorRepository cursorRepository;
  final AgentMessageReceiptRepository receiptRepository;
  final ParticipationDecisionRepository decisionRepository;
  final AgentDeliveryRepository deliveryRepository;
  final ProjectArtifactRepository artifactRepository;
  final ConversationSummaryRepository conversationSummaryRepository;
  final AgentMemoryRepository agentMemoryRepository;
  final AgentMemoryEvolutionRepository agentMemoryEvolutionRepository;
  final CompactConversationMessages compactConversationMessages;
  final ModelUsageRepository modelUsageRepository;
  final ManageProjectMembers manageProjectMembers;
  final AttachmentRepository attachmentRepository;
  final ProjectTemporaryAttachmentRepository temporaryAttachmentRepository;
  final ProjectMessageRouteRepository routeRepository;
  final RouteProjectMessage routeProjectMessage;
  final AgentInboxCoordinator inboxCoordinator;
  final CreateProject createProject;
  final ProjectWorkspaceCache workspaceCache;

  ProjectWorkspaceViewModel createWorkspaceViewModel(
    String projectId, {
    required ProfileRepository profileRepository,
    required MessageActionRepository messageActionRepository,
  }) => ProjectWorkspaceViewModel(
    projectId: projectId,
    routeProjectMessage: routeProjectMessage,
    projectRepository: projectRepository,
    membershipRepository: membershipRepository,
    eventRepository: eventRepository,
    turnRepository: turnRepository,
    agentRepository: agentRepository,
    cursorRepository: cursorRepository,
    runRepository: runRepository,
    deliveryRepository: deliveryRepository,
    receiptRepository: receiptRepository,
    decisionRepository: decisionRepository,
    modelUsageRepository: modelUsageRepository,
    inboxCoordinator: inboxCoordinator,
    artifactRepository: artifactRepository,
    messageActionRepository: messageActionRepository,
    attachmentRepository: attachmentRepository,
    temporaryAttachmentRepository: temporaryAttachmentRepository,
    profileRepository: profileRepository,
    workspaceCache: workspaceCache,
  );

  ProjectMembersViewModel createMembersViewModel(String projectId) =>
      ProjectMembersViewModel(
        projectId: projectId,
        agentRepository: agentRepository,
        membershipRepository: membershipRepository,
        cursorRepository: cursorRepository,
        manageMembers: manageProjectMembers,
      );
}

extension ProjectAgentAppDependencyFactories on AppDependencies {
  AgentMemoryRepository get agentMemoryRepository =>
      projectAgents.agentMemoryRepository;
  ConversationSummaryRepository get projectConversationSummaryRepository =>
      projectAgents.conversationSummaryRepository;
  AgentMemoryEvolutionRepository get agentMemoryEvolutionRepository =>
      projectAgents.agentMemoryEvolutionRepository;
  CompactConversationMessages get compactProjectConversationMessages =>
      projectAgents.compactConversationMessages;

  AgentMemoryViewModel createAgentMemoryViewModel(String agentId) =>
      AgentMemoryViewModel(
        agentId: agentId,
        agentRepository: agentRepository,
        memoryRepository: agentMemoryRepository,
        evolutionRepository: agentMemoryEvolutionRepository,
      );

  ChatListViewModel createChatListViewModel() => ChatListViewModel(
    chatRepository: chatRepository,
    botRepository: botRepository,
    projectRepository: projectRepository,
    membershipRepository: projectMembershipRepository,
    agentRepository: agentRepository,
  );
}
