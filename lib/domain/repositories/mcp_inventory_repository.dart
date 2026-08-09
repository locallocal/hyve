import 'package:stars/domain/models/models.dart';

abstract interface class McpInventoryRepository {
  Future<InstalledMcpServerInventoryPage> listInstalled({
    String query = '',
    int limit = 50,
  });

  Future<ConversationMcpInventory> listForConversation(String chatId);
}
