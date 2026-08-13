import 'package:stars/domain/models/conversation_draft.dart';

/// A bounded, conversation-scoped draft store.
abstract interface class ConversationDraftRepository {
  Future<ConversationDraft?> read(String chatId);

  Future<void> write(String chatId, ConversationDraft draft);

  Future<void> delete(String chatId);
}
