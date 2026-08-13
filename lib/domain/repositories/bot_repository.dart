import 'package:stars/domain/models/models.dart';

abstract interface class BotRepository {
  Stream<List<Bot>> get changes;

  Future<List<Bot>> getBots({bool forceRefresh = false});

  Future<Bot?> getBot(String id);

  Future<void> addBot(Bot bot);

  Future<void> updateBot(Bot bot);

  Future<void> deleteBot(String id);
}

/// Optional aggregate capability implemented by repositories that can persist
/// a Bot and its Skill bindings in one database transaction.
abstract interface class BotAggregateRepository implements BotRepository {
  Future<void> addBotWithSkillBindings(
    Bot bot,
    Iterable<BotSkillBinding> bindings,
  );
}
