import 'package:hyve/domain/models/conversation_history.dart';

abstract interface class ConversationHistoryRepository {
  Future<ConversationHistoryPage> search({
    required String chatId,
    required ConversationHistoryQuery query,
  });

  Future<ConversationHistoryPage> read({
    required String chatId,
    required List<String> references,
    required int surroundingTurns,
    String? cursor,
    String excludedRunId = '',
  });
}
