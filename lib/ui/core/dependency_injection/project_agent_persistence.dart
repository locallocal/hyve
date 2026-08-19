part of 'app_dependencies.dart';

final class ProjectAgentPersistence {
  const ProjectAgentPersistence({
    required this.agentRepository,
    required this.projectRepository,
    required this.membershipRepository,
    required this.eventRepository,
    required this.turnRepository,
    required this.runRepository,
    required this.createProject,
  });

  factory ProjectAgentPersistence.create({
    required LocalDatabaseService localDatabase,
    required BotApiKeyCipher apiKeyCipher,
    required ProjectAgentStorageService storage,
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
    return ProjectAgentPersistence(
      agentRepository: agentRepository,
      projectRepository: projectRepository,
      membershipRepository: membershipRepository,
      eventRepository: SqliteProjectEventRepository(
        localDatabase: localDatabase,
      ),
      turnRepository: SqliteProjectTurnRepository(localDatabase: localDatabase),
      runRepository: SqliteAgentRunRepository(localDatabase: localDatabase),
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
  final CreateProject createProject;
}
