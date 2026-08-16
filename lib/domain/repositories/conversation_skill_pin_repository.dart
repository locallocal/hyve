import 'package:hyve/domain/models/models.dart';

abstract interface class ConversationSkillPinRepository {
  Stream<void> get changes;

  Future<List<ConversationSkillPin>> getForChat(String chatId);

  Future<void> save(ConversationSkillPin pin);

  Future<void> remove(String chatId, String skillId);

  Future<void> clear(String chatId);
}
