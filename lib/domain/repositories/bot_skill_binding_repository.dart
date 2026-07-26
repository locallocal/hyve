import 'package:stars/domain/models/models.dart';

abstract interface class BotSkillBindingRepository {
  Stream<void> get changes;

  Future<List<BotSkillBinding>> getForBot(String botId);

  Future<void> save(BotSkillBinding binding);

  Future<void> remove(String botId, String skillId);
}
