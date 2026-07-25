import 'package:stars/domain/models/models.dart';

abstract interface class MessageRepository {
  Stream<void> get changes;

  String createId(String prefix);

  Future<List<Message>> getMessages(String chatId);

  Future<List<ModelTokenUsageRecord>> getTokenUsageRecordsForChat(
    String chatId,
  );

  Future<ModelTokenUsage> getTokenUsageForBot(String botId);

  Future<Message> upsertMessage(Message message);

  Future<List<Message>> upsertMessages(Iterable<Message> messages);

  Future<void> deleteMessages(String chatId);
}
