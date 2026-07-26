import 'package:stars/domain/models/models.dart';

abstract interface class SkillRunRepository {
  Future<void> saveActivations(Iterable<SkillActivationRecord> records);

  Future<List<SkillActivationRecord>> getForRun(String runId);
}
