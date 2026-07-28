import 'package:stars/data/repositories/ai_provider_repository_impl.dart';
import 'package:stars/data/repositories/attachment_repository_impl.dart';
import 'package:stars/data/repositories/feedback_repository_impl.dart';
import 'package:stars/data/repositories/legal_document_repository_impl.dart';
import 'package:stars/data/repositories/file_skill_repository.dart';
import 'package:stars/data/repositories/skill_picker_repository_impl.dart';
import 'package:stars/data/repositories/sqlite_bot_repository.dart';
import 'package:stars/data/repositories/sqlite_bot_skill_binding_repository.dart';
import 'package:stars/data/repositories/sqlite_chat_repository.dart';
import 'package:stars/data/repositories/sqlite_conversation_skill_pin_repository.dart';
import 'package:stars/data/repositories/sqlite_message_repository.dart';
import 'package:stars/data/repositories/sqlite_profile_repository.dart';
import 'package:stars/data/repositories/sqlite_skill_run_repository.dart';
import 'package:stars/data/services/feedback_service.dart';
import 'package:stars/data/services/attachment_picker_service.dart';
import 'package:stars/data/services/asset_text_service.dart';
import 'package:stars/data/services/database_service.dart';
import 'package:stars/data/services/local_database_service.dart';
import 'package:stars/data/services/skills/skill_package_storage_service.dart';
import 'package:stars/data/services/skills/skill_parser.dart';
import 'package:stars/data/services/skills/skill_picker_service.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/models/legal_document.dart';
import 'package:stars/domain/repositories/ai_provider_repository.dart';
import 'package:stars/domain/repositories/attachment_repository.dart';
import 'package:stars/domain/repositories/bot_repository.dart';
import 'package:stars/domain/repositories/bot_skill_binding_repository.dart';
import 'package:stars/domain/repositories/chat_repository.dart';
import 'package:stars/domain/repositories/conversation_skill_pin_repository.dart';
import 'package:stars/domain/repositories/feedback_repository.dart';
import 'package:stars/domain/repositories/legal_document_repository.dart';
import 'package:stars/domain/repositories/message_repository.dart';
import 'package:stars/domain/repositories/profile_repository.dart';
import 'package:stars/domain/repositories/skill_repository.dart';
import 'package:stars/domain/repositories/skill_run_repository.dart';
import 'package:stars/domain/use_cases/compose_chat_turn.dart';
import 'package:stars/domain/use_cases/create_chat.dart';
import 'package:stars/ui/features/chat/view_models/chat_generation_view_model.dart';
import 'package:stars/ui/features/app/view_models/app_view_model.dart';
import 'package:stars/ui/features/app/view_models/main_shell_view_model.dart';
import 'package:stars/ui/features/app/view_models/startup_view_model.dart';
import 'package:stars/ui/features/bots/view_models/bot_list_view_model.dart';
import 'package:stars/ui/features/bots/view_models/bot_token_usage_view_model.dart';
import 'package:stars/ui/features/bots/view_models/bot_skill_view_model.dart';
import 'package:stars/ui/features/chat/view_models/chat_skill_view_model.dart';
import 'package:stars/ui/features/chat/view_models/chat_view_model.dart';
import 'package:stars/ui/features/chat/view_models/chat_token_usage_view_model.dart';
import 'package:stars/ui/features/chats/view_models/chat_list_view_model.dart';
import 'package:stars/ui/features/chats/view_models/new_chat_view_model.dart';
import 'package:stars/ui/features/feedback/view_models/feedback_view_model.dart';
import 'package:stars/ui/features/profile/view_models/profile_view_model.dart';
import 'package:stars/ui/features/profile/view_models/legal_document_view_model.dart';
import 'package:stars/ui/features/skills/view_models/skill_library_view_model.dart';

/// Application composition root. Production implementations are assembled in
/// one place; views only receive repositories through their ViewModels.
class AppDependencies {
  AppDependencies({
    required this.botRepository,
    required this.chatRepository,
    required this.messageRepository,
    required this.profileRepository,
    required this.feedbackRepository,
    required this.aiProviderRepository,
    required this.attachmentRepository,
    required this.legalDocumentRepository,
    required this.skillRepository,
    required this.skillPickerRepository,
    required this.botSkillBindingRepository,
    required this.conversationSkillPinRepository,
    required this.skillRunRepository,
    required this.composeChatTurn,
    required this.createChat,
    required this.generationRegistry,
  });

  factory AppDependencies.production() {
    final databaseService = DatabaseService();
    final localDatabase = LocalDatabaseService(
      databaseProvider: () => databaseService.database,
    );
    final chatRepository = SqliteChatRepository(localDatabase: localDatabase);
    final messageRepository = SqliteMessageRepository(
      localDatabase: localDatabase,
    );
    final botRepository = SqliteBotRepository(
      localDatabase: localDatabase,
      chatRepository: chatRepository,
    );
    final profileRepository = SqliteProfileRepository(
      localDatabase: localDatabase,
    );
    final feedbackRepository = FeedbackRepositoryImpl(
      service: const FeedbackService(),
    );
    const aiProviderRepository = AiProviderRepositoryImpl();
    final attachmentRepository = AttachmentRepositoryImpl(
      service: AttachmentPickerService(),
    );
    const legalDocumentRepository = LegalDocumentRepositoryImpl(
      service: AssetTextService(),
    );
    final skillRepository = FileSkillRepository(
      localDatabase: localDatabase,
      storageService: SkillPackageStorageService(),
      parser: const SkillParser(),
    );
    const skillPickerRepository = SkillPickerRepositoryImpl(
      service: SkillPickerService(),
    );
    final botSkillBindingRepository = SqliteBotSkillBindingRepository(
      localDatabase: localDatabase,
    );
    final skillRunRepository = SqliteSkillRunRepository(
      localDatabase: localDatabase,
    );
    final conversationSkillPinRepository = SqliteConversationSkillPinRepository(
      localDatabase: localDatabase,
    );
    final composeChatTurn = ComposeChatTurn(
      skillRepository: skillRepository,
      bindingRepository: botSkillBindingRepository,
    );
    return AppDependencies(
      botRepository: botRepository,
      chatRepository: chatRepository,
      messageRepository: messageRepository,
      profileRepository: profileRepository,
      feedbackRepository: feedbackRepository,
      aiProviderRepository: aiProviderRepository,
      attachmentRepository: attachmentRepository,
      legalDocumentRepository: legalDocumentRepository,
      skillRepository: skillRepository,
      skillPickerRepository: skillPickerRepository,
      botSkillBindingRepository: botSkillBindingRepository,
      conversationSkillPinRepository: conversationSkillPinRepository,
      skillRunRepository: skillRunRepository,
      composeChatTurn: composeChatTurn,
      createChat: CreateChat(chatRepository: chatRepository),
      generationRegistry: ChatGenerationRegistry(
        messagePersister: messageRepository.upsertMessage,
        lastMessageUpdater: chatRepository.updateLastMessage,
        providerFactory: aiProviderRepository.create,
        messageIdFactory: messageRepository.createId,
        skillActivationPersister: skillRunRepository.saveActivations,
      ),
    );
  }

  final BotRepository botRepository;
  final ChatRepository chatRepository;
  final MessageRepository messageRepository;
  final ProfileRepository profileRepository;
  final FeedbackRepository feedbackRepository;
  final AiProviderRepository aiProviderRepository;
  final AttachmentRepository attachmentRepository;
  final LegalDocumentRepository legalDocumentRepository;
  final SkillRepository skillRepository;
  final SkillPickerRepository skillPickerRepository;
  final BotSkillBindingRepository botSkillBindingRepository;
  final ConversationSkillPinRepository conversationSkillPinRepository;
  final SkillRunRepository skillRunRepository;
  final ComposeChatTurn composeChatTurn;
  final CreateChat createChat;
  final ChatGenerationRegistry generationRegistry;

  StartupViewModel createStartupViewModel() =>
      StartupViewModel(profileRepository: profileRepository);

  AppViewModel createAppViewModel(Profile initialProfile) => AppViewModel(
    initialProfile: initialProfile,
    profileRepository: profileRepository,
  );

  MainShellViewModel createMainShellViewModel() =>
      MainShellViewModel(botRepository: botRepository);

  ChatListViewModel createChatListViewModel() => ChatListViewModel(
    chatRepository: chatRepository,
    botRepository: botRepository,
  );

  BotListViewModel createBotListViewModel() => BotListViewModel(
    botRepository: botRepository,
    createChat: createChat,
    aiProviderRepository: aiProviderRepository,
    attachmentRepository: attachmentRepository,
  );

  BotTokenUsageViewModel createBotTokenUsageViewModel(String botId) =>
      BotTokenUsageViewModel(
        botId: botId,
        messageRepository: messageRepository,
        chatRepository: chatRepository,
      );

  BotSkillViewModel createBotSkillViewModel(Bot bot) => BotSkillViewModel(
    botId: bot.id,
    skillRepository: skillRepository,
    bindingRepository: botSkillBindingRepository,
    skillToolProvider: aiProviderRepository.create(bot),
  );

  SkillLibraryViewModel createSkillLibraryViewModel() => SkillLibraryViewModel(
    skillRepository: skillRepository,
    pickerRepository: skillPickerRepository,
  );

  ChatSkillViewModel createChatSkillViewModel(String chatId, Bot bot) =>
      ChatSkillViewModel(
        chatId: chatId,
        botId: bot.id,
        skillRepository: skillRepository,
        bindingRepository: botSkillBindingRepository,
        pinRepository: conversationSkillPinRepository,
        supportsAutoActivation:
            aiProviderRepository
                .create(bot)
                .capabilities
                .supportsAutomaticSkillActivation,
      );

  ProfileViewModel createProfileViewModel() => ProfileViewModel(
    profileRepository: profileRepository,
    attachmentRepository: attachmentRepository,
  );

  LegalDocumentViewModel createLegalDocumentViewModel(LegalDocumentType type) =>
      LegalDocumentViewModel(type: type, repository: legalDocumentRepository);

  FeedbackViewModel createFeedbackViewModel() =>
      FeedbackViewModel(feedbackRepository: feedbackRepository);

  NewChatViewModel createNewChatViewModel() =>
      NewChatViewModel(botRepository: botRepository, createChat: createChat);

  ChatViewModel createChatViewModel(String chatId, Bot bot) => ChatViewModel(
    chatId: chatId,
    bot: bot,
    messageRepository: messageRepository,
    chatRepository: chatRepository,
    aiProviderRepository: aiProviderRepository,
    attachmentRepository: attachmentRepository,
    generationRegistry: generationRegistry,
    composeChatTurn: composeChatTurn,
  );

  ChatTokenUsageViewModel createChatTokenUsageViewModel(String chatId) =>
      ChatTokenUsageViewModel(
        chatId: chatId,
        messageRepository: messageRepository,
        chatRepository: chatRepository,
      );
}
