import 'package:hyve/domain/models/project_agent_execution.dart';

abstract interface class ProjectAgentExecutionGateway {
  Future<BroadcastParticipationResult> decide(
    BroadcastParticipationRequest request,
  );

  Future<ProjectAgentReplyResult> reply(ProjectAgentReplyRequest request);
}
