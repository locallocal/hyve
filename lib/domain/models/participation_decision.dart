import 'package:hyve/domain/models/project_event.dart';

final class ParticipationDecision {
  const ParticipationDecision({
    required this.runId,
    required this.agentId,
    required this.projectId,
    required this.turnId,
    required this.messageSequence,
    required this.choice,
    required this.reasonCode,
    this.intendedContribution = '',
    required this.createdAt,
  }) : assert(messageSequence > 0);

  final String runId;
  final String agentId;
  final String projectId;
  final String turnId;
  final int messageSequence;
  final ParticipationChoice choice;
  final String reasonCode;
  final String intendedContribution;
  final DateTime createdAt;
}
