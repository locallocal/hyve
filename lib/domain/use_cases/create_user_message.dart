import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/message_repository.dart';

final class CreateUserMessage {
  const CreateUserMessage({required MessageRepository messageRepository})
    : _messages = messageRepository;

  final MessageRepository _messages;

  Message call({
    required String chatId,
    required String botId,
    required String senderId,
    required String content,
    List<String> imagePaths = const [],
    List<String> filePaths = const [],
    String imageDetail = '',
    String fileDetail = '',
  }) => Message(
    messageId: _messages.createId('message'),
    turnId: _messages.createId('turn'),
    chatId: chatId,
    botId: botId,
    senderId: senderId,
    content: content,
    images: imagePaths,
    files: filePaths,
    processInfo: MessageProcessInfo(
      fileEdits: [
        for (final path in imagePaths)
          MessageFileEdit(
            path: path,
            type: 'image',
            status: 'attached',
            detail: imageDetail,
          ),
        for (final path in filePaths)
          MessageFileEdit(
            path: path,
            type: 'file',
            status: 'attached',
            detail: fileDetail,
          ),
      ],
    ),
    timestamp: DateTime.now(),
  );
}
