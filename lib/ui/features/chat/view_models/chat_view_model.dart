import 'package:flutter/foundation.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/ai_provider_repository.dart';
import 'package:stars/domain/repositories/attachment_repository.dart';
import 'package:stars/domain/repositories/chat_repository.dart';
import 'package:stars/domain/repositories/conversation_history_repository.dart';
import 'package:stars/domain/repositories/message_repository.dart';
import 'package:stars/data/services/tools/conversation_history_tools.dart';
import 'package:stars/domain/use_cases/compose_chat_turn.dart';
import 'package:stars/ui/features/chat/view_models/chat_generation_view_model.dart';

class ChatViewModel extends ChangeNotifier {
  ChatViewModel({
    required this.chatId,
    required this.bot,
    required MessageRepository messageRepository,
    required ChatRepository chatRepository,
    required AiProviderRepository aiProviderRepository,
    required AttachmentRepository attachmentRepository,
    required ChatGenerationRegistry generationRegistry,
    required ComposeChatTurn composeChatTurn,
    ConversationHistoryRepository? conversationHistoryRepository,
  }) : _messageRepository = messageRepository,
       _chatRepository = chatRepository,
       _aiProviderRepository = aiProviderRepository,
       _attachmentRepository = attachmentRepository,
       _composeChatTurn = composeChatTurn,
       _conversationHistoryRepository = conversationHistoryRepository,
       generationRegistry = generationRegistry,
       generationViewModel = generationRegistry.viewModelFor(chatId, bot);

  final String chatId;
  final Bot bot;
  final MessageRepository _messageRepository;
  final ChatRepository _chatRepository;
  final AiProviderRepository _aiProviderRepository;
  final AttachmentRepository _attachmentRepository;
  final ComposeChatTurn _composeChatTurn;
  final ConversationHistoryRepository? _conversationHistoryRepository;
  final ChatGenerationRegistry generationRegistry;
  final ChatGenerationViewModel generationViewModel;

  List<Message> _messages = const [];
  Object? _historyError;
  bool _isLoading = false;

  List<Message> get messages => _messages;
  Object? get historyError => _historyError;
  bool get isLoading => _isLoading;

  Future<void> loadMessages() async {
    _isLoading = true;
    _historyError = null;
    notifyListeners();
    try {
      _messages = await _messageRepository.getMessages(chatId);
    } catch (error) {
      _historyError = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String createId(String prefix) => _messageRepository.createId(prefix);

  Future<Message> upsertMessage(Message message) =>
      _messageRepository.upsertMessage(message);

  Future<void> updateLastMessage(String content) =>
      _chatRepository.updateLastMessage(chatId, content);

  Future<void> clearHistory() => _chatRepository.clearHistory(chatId);

  Future<PreparedChatTurn> prepareTextTurn({
    required List<Message> history,
    required Message userMessage,
    required String currentUserId,
  }) => _composeChatTurn(
    bot: bot,
    history: history,
    userMessage: userMessage,
    currentUserId: currentUserId,
    skillToolProvider: _aiProviderRepository.create(bot),
  );

  Future<PreparedTextGeneration> prepareTextGeneration({
    required List<Message> history,
    required Message userMessage,
    required String currentUserId,
  }) async {
    final preparedTurn = await prepareTextTurn(
      history: history,
      userMessage: userMessage,
      currentUserId: currentUserId,
    );
    final historyRepository = _conversationHistoryRepository;
    final historyTools =
        preparedTurn.contextAssemblyReport.historyLookupAvailable &&
                historyRepository != null
            ? ConversationHistoryToolSession(
              repository: historyRepository,
              chatId: chatId,
              runId: userMessage.runId,
              resultTokenBudget:
                  preparedTurn.contextAssemblyReport.historyLookupReserveTokens,
              initiallyAllowedReferences: preparedTurn.historySummaryReferences,
            ).createTools()
            : const <ExecutableTool>[];
    return PreparedTextGeneration(
      userMessage: userMessage,
      messages: preparedTurn.messages,
      activatedSkills: preparedTurn.activatedSkills,
      activationAttempts: preparedTurn.activationAttempts,
      skillToolCalls: preparedTurn.skillToolCalls,
      preflightTokenUsage: preparedTurn.preflightTokenUsage,
      requestedToolNames: preparedTurn.requestedToolNames,
      approvalExemptToolNames: preparedTurn.approvalExemptToolNames,
      runScopedTools: historyTools,
      contextAssemblyReport: preparedTurn.contextAssemblyReport,
    );
  }

  Future<String?> captureImage() => _attachmentRepository.captureImage();

  Future<String?> selectImage() => _attachmentRepository.selectImage();

  Future<String?> selectFile() => _attachmentRepository.selectFile();

  Future<List<String>> generateImage({
    required String prompt,
    required String size,
    required String outputDirectory,
    required List<String> referenceImages,
    required String style,
  }) => _aiProviderRepository.generateImage(
    bot: bot,
    prompt: prompt,
    size: size,
    outputDirectory: outputDirectory,
    referenceImages: referenceImages,
    style: style,
  );

  Future<String> generateSpeech({
    required String prompt,
    required String voiceType,
    required String outputDirectory,
  }) => _aiProviderRepository.generateSpeech(
    bot: bot,
    prompt: prompt,
    voiceType: voiceType,
    outputDirectory: outputDirectory,
  );

  Future<String> generateMusic({
    required String prompt,
    required String outputDirectory,
    required String referenceMusic,
  }) => _aiProviderRepository.generateMusic(
    bot: bot,
    prompt: prompt,
    outputDirectory: outputDirectory,
    referenceMusic: referenceMusic,
  );

  Future<String> generateVideo({
    required String prompt,
    required String ratio,
    required String outputDirectory,
    required List<String> referenceImages,
  }) => _aiProviderRepository.generateVideo(
    bot: bot,
    prompt: prompt,
    ratio: ratio,
    outputDirectory: outputDirectory,
    referenceImages: referenceImages,
  );

  void notifyChatListChanged() => _chatRepository.invalidate();
}
