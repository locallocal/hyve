import 'package:stars/domain/models/models.dart';

abstract interface class SkillInventoryRepository {
  Future<InstalledSkillInventoryPage> listInstalled({
    String query = '',
    int limit = 50,
  });

  Future<List<ConversationSkillInventoryItem>> listForConversation(
    String chatId,
  );
}
