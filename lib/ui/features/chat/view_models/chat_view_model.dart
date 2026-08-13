import 'package:flutter/foundation.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/ai_provider_repository.dart';
import 'package:stars/domain/repositories/attachment_repository.dart';
import 'package:stars/domain/repositories/chat_repository.dart';
import 'package:stars/domain/repositories/conversation_history_repository.dart';
import 'package:stars/domain/repositories/message_repository.dart';
import 'package:stars/data/services/tools/conversation_history_tools.dart';
import 'package:stars/data/services/tools/mcp_inventory_tools.dart';
import 'package:stars/data/services/tools/skill_inventory_tools.dart';
import 'package:stars/domain/repositories/mcp_inventory_repository.dart';
import 'package:stars/domain/repositories/skill_inventory_repository.dart';
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
    McpInventoryRepository? mcpInventoryRepository,
    SkillInventoryRepository? skillInventoryRepository,
  }) : _messageRepository = messageRepository,
       _chatRepository = chatRepository,
       _aiProviderRepository = aiProviderRepository,
       _attachmentRepository = attachmentRepository,
       _composeChatTurn = composeChatTurn,
       _conversationHistoryRepository = conversationHistoryRepository,
       _mcpInventoryRepository = mcpInventoryRepository,
       _skillInventoryRepository = skillInventoryRepository,
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
  final McpInventoryRepository? _mcpInventoryRepository;
  final SkillInventoryRepository? _skillInventoryRepository;
  final ChatGenerationRegistry generationRegistry;
  final ChatGenerationViewModel generationViewModel;

  List<Message> _messages = const [];
  AppFailure? _historyError;
  bool _isLoading = false;
  bool _isLoadingEarlier = false;
  bool _hasEarlierMessages = false;
  MessageCursor? _earlierCursor;

  List<Message> get messages => _messages;
  List<Message>? get cachedMessages {
    final repository = _messageRepository;
    if (repository is PaginatedMessageRepository) {
      final page = repository.peekMessagePage(chatId);
      if (page == null) return null;
      _applyPageState(page);
      return page.messages;
    }
    return repository is CachedMessageRepository
        ? repository.peekMessages(chatId)
        : null;
  }

  AppFailure? get historyError => _historyError;
  bool get isLoading => _isLoading;
  bool get isLoadingEarlier => _isLoadingEarlier;
  bool get hasEarlierMessages => _hasEarlierMessages;

  Future<void> loadMessages() async {
    _isLoading = true;
    _historyError = null;
    notifyListeners();
    try {
      final repository = _messageRepository;
      if (repository is PaginatedMessageRepository) {
        final page = await repository.getMessagePage(chatId);
        _messages = page.messages;
        _applyPageState(page);
      } else {
        _messages = await repository.getMessages(chatId);
        _hasEarlierMessages = false;
        _earlierCursor = null;
      }
    } catch (error) {
      _historyError = AppFailure.from(
        error,
        code: 'message_history_load_failed',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Message>> loadEarlierMessages() async {
    if (_isLoadingEarlier || !_hasEarlierMessages) return _messages;
    final repository = _messageRepository;
    final cursor = _earlierCursor;
    if (repository is! PaginatedMessageRepository || cursor == null) {
      _hasEarlierMessages = false;
      return _messages;
    }
    _isLoadingEarlier = true;
    notifyListeners();
    try {
      final page = await repository.getMessagePage(chatId, before: cursor);
      final byId = <String, Message>{
        for (final message in page.messages) message.messageId: message,
        for (final message in _messages) message.messageId: message,
      };
      _messages = List<Message>.unmodifiable(
        byId.values.toList()..sort(_compareMessages),
      );
      _applyPageState(page);
      return _messages;
    } catch (error) {
      _historyError = AppFailure.from(error, code: 'message_page_load_failed');
      rethrow;
    } finally {
      _isLoadingEarlier = false;
      notifyListeners();
    }
  }

  void _applyPageState(MessagePage page) {
    _hasEarlierMessages = page.hasMore;
    _earlierCursor = page.nextCursor;
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
    final inventoryRepository = _skillInventoryRepository;
    final inventoryTools =
        inventoryRepository != null &&
                preparedTurn.requestedToolNames.any(
                  skillInventoryToolNames.contains,
                )
            ? SkillInventoryToolSession(
              repository: inventoryRepository,
              chatId: chatId,
            ).createTools()
            : const <ExecutableTool>[];
    final mcpInventoryRepository = _mcpInventoryRepository;
    final mcpInventoryTools =
        mcpInventoryRepository != null &&
                preparedTurn.requestedToolNames.any(
                  mcpInventoryToolNames.contains,
                )
            ? McpInventoryToolSession(
              repository: mcpInventoryRepository,
              chatId: chatId,
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
      runScopedTools: [
        ...historyTools,
        ...inventoryTools,
        ...mcpInventoryTools,
      ],
      contextAssemblyReport: preparedTurn.contextAssemblyReport,
    );
  }

  Future<String?> captureImage() => _attachmentRepository.captureImage();

  Future<String?> selectImage() => _attachmentRepository.selectImage();

  Future<String?> selectFile() => _attachmentRepository.selectFile();

  Future<List<String>> persistAssets(Iterable<String> sourcePaths) {
    final repository = _attachmentRepository;
    if (repository is! ConversationAssetRepository) {
      throw const AppFailure.storage('conversation_asset_store_unavailable');
    }
    return repository.persistAssets(chatId: chatId, sourcePaths: sourcePaths);
  }

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

  Future<bool> cancelMedia() {
    final repository = _aiProviderRepository;
    if (repository is! CancelableMediaRepository) return Future.value(false);
    return repository.cancelMedia(bot.id);
  }

  void notifyChatListChanged() => _chatRepository.invalidate();
}

int _compareMessages(Message left, Message right) {
  final timestamp = left.timestamp.compareTo(right.timestamp);
  if (timestamp != 0) return timestamp;
  return left.messageId.compareTo(right.messageId);
}
