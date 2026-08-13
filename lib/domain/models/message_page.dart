import 'package:stars/domain/models/message.dart';

final class MessageCursor {
  const MessageCursor({required this.timestamp, required this.messageId});

  final DateTime timestamp;
  final String messageId;
}

final class MessagePage {
  const MessagePage({
    required this.messages,
    required this.hasMore,
    this.nextCursor,
  });

  final List<Message> messages;
  final bool hasMore;
  final MessageCursor? nextCursor;
}
