import 'package:hyve/domain/models/participation_decision.dart';

abstract interface class ParticipationDecisionRepository {
  Future<ParticipationDecision?> getForRun(String runId);

  Future<List<ParticipationDecision>> getForTurn(String turnId);

  Future<void> save(ParticipationDecision decision);
}
