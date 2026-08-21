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
    required this.routeRepository,
    required this.routeProjectMessage,
    required this.inboxCoordinator,
    required this.createProject,
  });

  factory ProjectAgentPersistence.create({
    required LocalDatabaseService localDatabase,
    required BotApiKeyCipher apiKeyCipher,
    required ProjectAgentStorageService storage,
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
    final eventRepository = SqliteProjectEventRepository(
      localDatabase: localDatabase,
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
        modelUsageRepository: modelUsageRepository,
      ),
      turnCoordinator: turnCoordinator,
    );
    inboxCoordinator.start().ignore();
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
      routeRepository: routeRepository,
      routeProjectMessage: routeProjectMessage,
      inboxCoordinator: inboxCoordinator,
      createProject: CreateProject(
        projectRepository: projectRepository,
        membershipRepository: membershipRepository,
      ),
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
  final ProjectMessageRouteRepository routeRepository;
  final RouteProjectMessage routeProjectMessage;
  final AgentInboxCoordinator inboxCoordinator;
  final CreateProject createProject;

  ProjectWorkspaceViewModel createWorkspaceViewModel(String projectId) =>
      ProjectWorkspaceViewModel(
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
        inboxCoordinator: inboxCoordinator,
      );
}

extension ProjectAgentAppDependencyFactories on AppDependencies {
  ChatListViewModel createChatListViewModel() => ChatListViewModel(
    chatRepository: chatRepository,
    botRepository: botRepository,
    projectRepository: projectRepository,
    membershipRepository: projectMembershipRepository,
    agentRepository: agentRepository,
  );
}
