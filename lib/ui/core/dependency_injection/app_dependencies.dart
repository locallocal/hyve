import 'package:stars/data/repositories/ai_provider_repository_impl.dart';
import 'package:stars/data/repositories/attachment_repository_impl.dart';
import 'package:stars/data/repositories/feedback_repository_impl.dart';
import 'package:stars/data/repositories/legal_document_repository_impl.dart';
import 'package:stars/data/repositories/file_skill_repository.dart';
import 'package:stars/data/repositories/sqlite_mcp_server_repository.dart';
import 'package:stars/data/repositories/skill_picker_repository_impl.dart';
import 'package:stars/data/repositories/sqlite_bot_repository.dart';
import 'package:stars/data/repositories/sqlite_bot_skill_binding_repository.dart';
import 'package:stars/data/repositories/sqlite_chat_repository.dart';
import 'package:stars/data/repositories/sqlite_conversation_skill_pin_repository.dart';
import 'package:stars/data/repositories/sqlite_conversation_memory_repository.dart';
import 'package:stars/data/repositories/sqlite_conversation_history_repository.dart';
import 'package:stars/data/repositories/sqlite_message_repository.dart';
import 'package:stars/data/repositories/sqlite_model_usage_repository.dart';
import 'package:stars/data/repositories/sqlite_profile_repository.dart';
import 'package:stars/data/repositories/sqlite_skill_run_repository.dart';
import 'package:stars/data/repositories/sqlite_skill_ecosystem_repository.dart';
import 'package:stars/data/services/feedback_service.dart';
import 'package:stars/data/services/attachment_picker_service.dart';
import 'package:stars/data/services/asset_text_service.dart';
import 'package:stars/data/services/bot_api_key_cipher.dart';
import 'package:stars/data/services/database_service.dart';
import 'package:stars/data/services/conversation_summary_storage.dart';
import 'package:stars/data/services/ai/provider_context_summarizer.dart';
import 'package:stars/data/services/local_database_service.dart';
import 'package:stars/data/services/mcp/mcp_catalog_service.dart';
import 'package:stars/data/services/mcp/mcp_client_service.dart';
import 'package:stars/data/services/mcp/mcp_endpoint_policy.dart';
import 'package:stars/data/services/mcp/mcp_http_transport.dart';
import 'package:stars/data/services/mcp/mcp_stdio_transport.dart';
import 'package:stars/data/services/mcp/secure_mcp_credential_store.dart';
import 'package:stars/data/services/skills/skill_package_storage_service.dart';
import 'package:stars/data/services/skills/skill_parser.dart';
import 'package:stars/data/services/skills/skill_picker_service.dart';
import 'package:stars/data/services/skills/linux_bubblewrap_skill_sandbox.dart';
import 'package:stars/data/services/skills/skill_catalog_endpoint_policy.dart';
import 'package:stars/data/services/skills/skill_catalog_service.dart';
import 'package:stars/data/services/skills/skill_organization_policy_bundle_service.dart';
import 'package:stars/data/services/skills/skill_script_catalog_service.dart';
import 'package:stars/data/services/skills/skill_script_manifest_parser.dart';
import 'package:stars/data/services/skills/skill_signature_service.dart';
import 'package:stars/data/services/tools/built_in_tools.dart';
import 'package:stars/data/services/tools/system_conversation_history_skill.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/models/legal_document.dart';
import 'package:stars/domain/repositories/ai_provider_repository.dart';
import 'package:stars/domain/repositories/attachment_repository.dart';
import 'package:stars/domain/repositories/bot_repository.dart';
import 'package:stars/domain/repositories/bot_skill_binding_repository.dart';
import 'package:stars/domain/repositories/chat_repository.dart';
import 'package:stars/domain/repositories/conversation_skill_pin_repository.dart';
import 'package:stars/domain/repositories/conversation_memory_repository.dart';
import 'package:stars/domain/repositories/conversation_history_repository.dart';
import 'package:stars/domain/repositories/feedback_repository.dart';
import 'package:stars/domain/repositories/legal_document_repository.dart';
import 'package:stars/domain/repositories/message_repository.dart';
import 'package:stars/domain/repositories/model_usage_repository.dart';
import 'package:stars/domain/repositories/mcp_credential_store.dart';
import 'package:stars/domain/repositories/mcp_server_repository.dart';
import 'package:stars/domain/repositories/profile_repository.dart';
import 'package:stars/domain/repositories/skill_repository.dart';
import 'package:stars/domain/repositories/skill_ecosystem_repository.dart';
import 'package:stars/domain/repositories/skill_run_repository.dart';
import 'package:stars/domain/use_cases/compose_chat_turn.dart';
import 'package:stars/domain/use_cases/create_chat.dart';
import 'package:stars/domain/use_cases/prepare_conversation_context.dart';
import 'package:stars/domain/use_cases/compact_conversation.dart';
import 'package:stars/ui/features/chat/view_models/chat_generation_view_model.dart';
import 'package:stars/ui/features/app/view_models/app_view_model.dart';
import 'package:stars/ui/features/app/view_models/main_shell_view_model.dart';
import 'package:stars/ui/features/app/view_models/startup_view_model.dart';
import 'package:stars/ui/features/bots/view_models/bot_list_view_model.dart';
import 'package:stars/ui/features/bots/view_models/bot_token_usage_view_model.dart';
import 'package:stars/ui/features/bots/view_models/bot_skill_view_model.dart';
import 'package:stars/ui/features/chat/view_models/chat_skill_view_model.dart';
import 'package:stars/ui/features/chat/view_models/chat_view_model.dart';
import 'package:stars/ui/features/chat/view_models/conversation_memory_view_model.dart';
import 'package:stars/ui/features/chat/view_models/chat_token_usage_view_model.dart';
import 'package:stars/ui/features/chats/view_models/chat_list_view_model.dart';
import 'package:stars/ui/features/chats/view_models/new_chat_view_model.dart';
import 'package:stars/ui/features/feedback/view_models/feedback_view_model.dart';
import 'package:stars/ui/features/mcp/view_models/mcp_servers_view_model.dart';
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
    required this.modelUsageRepository,
    required this.profileRepository,
    required this.feedbackRepository,
    required this.aiProviderRepository,
    required this.attachmentRepository,
    required this.legalDocumentRepository,
    required this.skillRepository,
    required this.skillPickerRepository,
    required this.botSkillBindingRepository,
    required this.conversationSkillPinRepository,
    required this.conversationMemoryRepository,
    required this.conversationHistoryRepository,
    required this.skillRunRepository,
    required this.mcpServerRepository,
    required this.mcpCredentialStore,
    required this.mcpCatalogService,
    required this.toolRegistry,
    required this.toolPolicy,
    required this.composeChatTurn,
    required this.compactConversation,
    required this.systemConversationHistorySkill,
    required this.createChat,
    required this.generationRegistry,
    this.skillEcosystemRepository,
    this.skillScriptCatalogService,
    this.skillCatalogService,
    this.skillOrganizationPolicyBundleService,
  });

  factory AppDependencies.production() {
    final databaseService = DatabaseService();
    final localDatabase = LocalDatabaseService(
      databaseProvider: () => databaseService.database,
    );
    final conversationSummaryStorage = ConversationSummaryStorage();
    conversationSummaryStorage.recoverPendingDeletions().ignore();
    final conversationMemoryRepository = SqliteConversationMemoryRepository(
      localDatabase: localDatabase,
      storage: conversationSummaryStorage,
    );
    final chatRepository = SqliteChatRepository(
      localDatabase: localDatabase,
      conversationMemoryRepository: conversationMemoryRepository,
      conversationSummaryStorage: conversationSummaryStorage,
    );
    final messageRepository = SqliteMessageRepository(
      localDatabase: localDatabase,
    );
    final conversationHistoryRepository = SqliteConversationHistoryRepository(
      messageRepository: messageRepository,
    );
    final modelUsageRepository = SqliteModelUsageRepository(
      localDatabase: localDatabase,
    );
    final botApiKeyCipher = SecureBotApiKeyCipher();
    final botRepository = SqliteBotRepository(
      localDatabase: localDatabase,
      chatRepository: chatRepository,
      apiKeyCipher: botApiKeyCipher,
    );
    final profileRepository = SqliteProfileRepository(
      localDatabase: localDatabase,
    );
    final feedbackRepository = FeedbackRepositoryImpl(
      service: const FeedbackService(),
    );
    const aiProviderRepository = AiProviderRepositoryImpl();
    final systemConversationHistorySkill = SystemConversationHistorySkill();
    final compactConversation = CompactConversation(
      messageRepository: messageRepository,
      memoryRepository: conversationMemoryRepository,
      summarizerFactory:
          (bot) => ProviderContextSummarizer(
            bot: bot,
            providerFactory: aiProviderRepository.create,
          ),
      usagePersister:
          (operationId, chatId, bot, usage) => modelUsageRepository.upsert(
            ModelTokenUsageRecord(
              messageId: operationId,
              chatId: chatId,
              botId: bot.id,
              timestamp: DateTime.now(),
              usage: usage,
              operationKind: 'context_compaction',
            ),
          ),
    );
    final attachmentRepository = AttachmentRepositoryImpl(
      service: AttachmentPickerService(),
    );
    const legalDocumentRepository = LegalDocumentRepositoryImpl(
      service: AssetTextService(),
    );
    final skillEcosystemRepository = SqliteSkillEcosystemRepository(
      localDatabase: localDatabase,
    );
    final skillStorageService = SkillPackageStorageService();
    final skillRepository = FileSkillRepository(
      localDatabase: localDatabase,
      storageService: skillStorageService,
      parser: const SkillParser(),
      ecosystemRepository: skillEcosystemRepository,
      signatureService: SkillSignatureService(
        ecosystemRepository: skillEcosystemRepository,
      ),
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
    final mcpServerRepository = SqliteMcpServerRepository(
      localDatabase: localDatabase,
    );
    final mcpCredentialStore = SecureMcpCredentialStore();
    final mcpClient = McpClientService(
      transports: [
        McpHttpTransport(endpointPolicy: McpEndpointPolicy()),
        McpStdioTransport(),
      ],
      credentialStore: mcpCredentialStore,
    );
    final composeChatTurn = ComposeChatTurn(
      skillRepository: skillRepository,
      bindingRepository: botSkillBindingRepository,
      mcpServerRepository: mcpServerRepository,
      prepareConversationContext: PrepareConversationContext(
        memoryRepository: conversationMemoryRepository,
        aiProviderRepository: aiProviderRepository,
        historySkillAvailable: () => systemConversationHistorySkill.isValid,
      ),
      compactConversation: compactConversation,
    );
    final toolRegistry = DynamicToolRegistry(createBuiltInTools());
    final mcpCatalogService = McpCatalogService(
      repository: mcpServerRepository,
      client: mcpClient,
      toolRegistry: toolRegistry,
    );
    final skillScriptCatalogService = SkillScriptCatalogService(
      skillRepository: skillRepository,
      ecosystemRepository: skillEcosystemRepository,
      manifestParser: const SkillScriptManifestParser(),
      sandbox: LinuxBubblewrapSkillSandbox(
        installationVerifier: skillStorageService.verifyImmutableInstallation,
      ),
      toolRegistry: toolRegistry,
    );
    final skillCatalogService = SkillCatalogService(
      ecosystemRepository: skillEcosystemRepository,
      skillRepository: skillRepository,
      endpointPolicy: SkillCatalogEndpointPolicy(),
    );
    final skillOrganizationPolicyBundleService =
        SkillOrganizationPolicyBundleService(
          ecosystemRepository: skillEcosystemRepository,
        );
    const toolPolicy = DefaultToolPolicy(
      allowDestructiveWithApproval: true,
      allowSkillScripts: true,
    );
    return AppDependencies(
      botRepository: botRepository,
      chatRepository: chatRepository,
      messageRepository: messageRepository,
      modelUsageRepository: modelUsageRepository,
      profileRepository: profileRepository,
      feedbackRepository: feedbackRepository,
      aiProviderRepository: aiProviderRepository,
      attachmentRepository: attachmentRepository,
      legalDocumentRepository: legalDocumentRepository,
      skillRepository: skillRepository,
      skillPickerRepository: skillPickerRepository,
      botSkillBindingRepository: botSkillBindingRepository,
      conversationSkillPinRepository: conversationSkillPinRepository,
      conversationMemoryRepository: conversationMemoryRepository,
      conversationHistoryRepository: conversationHistoryRepository,
      skillRunRepository: skillRunRepository,
      mcpServerRepository: mcpServerRepository,
      mcpCredentialStore: mcpCredentialStore,
      mcpCatalogService: mcpCatalogService,
      toolRegistry: toolRegistry,
      toolPolicy: toolPolicy,
      composeChatTurn: composeChatTurn,
      compactConversation: compactConversation,
      systemConversationHistorySkill: systemConversationHistorySkill,
      createChat: CreateChat(chatRepository: chatRepository),
      generationRegistry: ChatGenerationRegistry(
        messagePersister: messageRepository.upsertMessage,
        lastMessageUpdater: chatRepository.updateLastMessage,
        providerFactory: aiProviderRepository.create,
        messageIdFactory: messageRepository.createId,
        skillActivationPersister: skillRunRepository.saveActivations,
        terminalMessageObserver: (chatId, bot, message, report) async {
          final action = report?.compressionAction;
          if (action == ContextCompressionAction.backgroundReady ||
              action == ContextCompressionAction.synchronous ||
              action == ContextCompressionAction.fallbackTrim) {
            await compactConversation(bot: bot, chatId: chatId);
          }
        },
        toolInvocationPersister: (runId, chatId, botId, audit) async {
          final now = DateTime.now();
          await skillEcosystemRepository.appendComplianceEvent(
            SkillComplianceEvent(
              id:
                  '${now.microsecondsSinceEpoch}:tool:$runId:'
                  '${audit.callId}:${audit.status}',
              type: SkillComplianceEventType.toolInvoked,
              decision: audit.approvalStatus,
              reason: audit.errorCode,
              metadata: {
                'runId': runId,
                'chatId': chatId,
                'botId': botId,
                'callId': audit.callId,
                'tool': audit.name,
                'source': audit.source,
                'riskLevel': audit.riskLevel,
                'status': audit.status,
                'argumentsSummary': audit.argumentsSummary,
                'resultSummary': audit.resultSummary,
                'durationMs': audit.durationMs,
              },
              timestamp: now,
            ),
          );
        },
        toolRegistry: toolRegistry,
        toolPolicy: toolPolicy,
      ),
      skillEcosystemRepository: skillEcosystemRepository,
      skillScriptCatalogService: skillScriptCatalogService,
      skillCatalogService: skillCatalogService,
      skillOrganizationPolicyBundleService:
          skillOrganizationPolicyBundleService,
    );
  }

  final BotRepository botRepository;
  final ChatRepository chatRepository;
  final MessageRepository messageRepository;
  final ModelUsageRepository modelUsageRepository;
  final ProfileRepository profileRepository;
  final FeedbackRepository feedbackRepository;
  final AiProviderRepository aiProviderRepository;
  final AttachmentRepository attachmentRepository;
  final LegalDocumentRepository legalDocumentRepository;
  final SkillRepository skillRepository;
  final SkillPickerRepository skillPickerRepository;
  final BotSkillBindingRepository botSkillBindingRepository;
  final ConversationSkillPinRepository conversationSkillPinRepository;
  final ConversationMemoryRepository conversationMemoryRepository;
  final ConversationHistoryRepository conversationHistoryRepository;
  final SkillRunRepository skillRunRepository;
  final McpServerRepository mcpServerRepository;
  final McpCredentialStore mcpCredentialStore;
  final McpCatalogService mcpCatalogService;
  final ToolRegistry toolRegistry;
  final ToolPolicy toolPolicy;
  final ComposeChatTurn composeChatTurn;
  final CompactConversation compactConversation;
  final SystemConversationHistorySkill systemConversationHistorySkill;
  final CreateChat createChat;
  final ChatGenerationRegistry generationRegistry;
  final SkillEcosystemRepository? skillEcosystemRepository;
  final SkillScriptCatalogService? skillScriptCatalogService;
  final SkillCatalogService? skillCatalogService;
  final SkillOrganizationPolicyBundleService?
  skillOrganizationPolicyBundleService;

  StartupViewModel createStartupViewModel() => StartupViewModel(
    profileRepository: profileRepository,
    capabilityInitializer: () async {
      try {
        await systemConversationHistorySkill.validate();
      } on Object {
        // A damaged built-in Skill remains unavailable; chat still works with
        // summaries and recent turns.
      }
      try {
        await mcpCatalogService.hydrateFromCache();
      } on Object {
        // One optional capability source must not block the others.
      }
      try {
        await skillScriptCatalogService?.hydrateFromCache();
      } on Object {
        // Unsupported or malformed script packages fail closed.
      }
      try {
        await skillCatalogService?.refreshConfiguredCatalogs();
      } on Object {
        // Online catalogs are optional and must not block startup.
      }
    },
  );

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
    botSkillBindingRepository: botSkillBindingRepository,
    messageRepository: messageRepository,
    mcpServerRepository: mcpServerRepository,
  );

  BotTokenUsageViewModel createBotTokenUsageViewModel(String botId) =>
      BotTokenUsageViewModel(
        botId: botId,
        messageRepository: messageRepository,
        chatRepository: chatRepository,
      );

  BotSkillViewModel createBotSkillViewModel(Bot bot) {
    final provider = aiProviderRepository.create(bot);
    return BotSkillViewModel(
      botId: bot.id,
      skillRepository: skillRepository,
      bindingRepository: botSkillBindingRepository,
      skillToolProvider: provider,
      supportsAutoActivation:
          bot.configuredSupportsAutomaticSkillActivation ??
          provider.capabilities.supportsAutomaticSkillActivation,
    );
  }

  BotSkillViewModel createDraftBotSkillViewModel(String botId) =>
      BotSkillViewModel(
        botId: botId,
        skillRepository: skillRepository,
        bindingRepository: DraftBotSkillBindingRepository(),
        supportsAutoActivation: false,
      );

  SkillLibraryViewModel createSkillLibraryViewModel() => SkillLibraryViewModel(
    skillRepository: skillRepository,
    pickerRepository: skillPickerRepository,
    ecosystemRepository: skillEcosystemRepository,
    scriptCatalogService: skillScriptCatalogService,
    catalogService: skillCatalogService,
    bundledSkillLoader:
        () async => [await systemConversationHistorySkill.loadContent()],
  );

  McpServersViewModel createMcpServersViewModel() => McpServersViewModel(
    repository: mcpServerRepository,
    credentialStore: mcpCredentialStore,
    catalogService: mcpCatalogService,
  );

  ChatSkillViewModel createChatSkillViewModel(String chatId, Bot bot) =>
      ChatSkillViewModel(
        botId: bot.id,
        skillRepository: skillRepository,
        bindingRepository: botSkillBindingRepository,
        supportsAutoActivation:
            bot.configuredSupportsAutomaticSkillActivation ??
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
    conversationHistoryRepository: conversationHistoryRepository,
  );

  ChatTokenUsageViewModel createChatTokenUsageViewModel(String chatId) =>
      ChatTokenUsageViewModel(
        chatId: chatId,
        messageRepository: messageRepository,
        chatRepository: chatRepository,
      );

  ConversationMemoryViewModel createConversationMemoryViewModel(
    String chatId,
    Bot bot,
  ) => ConversationMemoryViewModel(
    chatId: chatId,
    bot: bot,
    repository: conversationMemoryRepository,
    compactConversation: compactConversation,
  );
}
