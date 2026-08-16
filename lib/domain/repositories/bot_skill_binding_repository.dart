import 'package:hyve/domain/models/models.dart';

abstract interface class BotSkillBindingRepository {
  Stream<void> get changes;

  Future<List<BotSkillBinding>> getForBot(String botId);

  Future<void> save(BotSkillBinding binding);

  Future<void> remove(String botId, String skillId);
}

abstract interface class BotScopedSkillBindingMetricsRepository
    implements BotSkillBindingRepository {
  Stream<Set<String>> get botMetricChanges;

  Future<Map<String, int>> getBindingCountsForBots(Iterable<String> botIds);
}
