import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:stars/data/models/local_records.dart';
import 'package:stars/data/repositories/sqlite_bot_repository.dart';
import 'package:stars/data/repositories/sqlite_bot_skill_binding_repository.dart';
import 'package:stars/data/repositories/sqlite_chat_repository.dart';
import 'package:stars/data/repositories/sqlite_profile_repository.dart';
import 'package:stars/data/repositories/sqlite_message_repository.dart';
import 'package:stars/data/repositories/sqlite_skill_run_repository.dart';
import 'package:stars/data/services/local_database_service.dart';
import 'package:stars/data/services/database_service.dart';
import 'package:stars/domain/models/models.dart';

void main() {
  sqfliteFfiInit();

  late Database database;
  late LocalDatabaseService localDatabase;
  late SqliteChatRepository chatRepository;
  late SqliteBotRepository botRepository;
  late SqliteBotSkillBindingRepository bindingRepository;
  late SqliteSkillRunRepository skillRunRepository;

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DatabaseService.databaseVersion,
        onCreate: DatabaseService.createSchema,
      ),
    );
    localDatabase = LocalDatabaseService(
      databaseProvider: () async => database,
    );
    chatRepository = SqliteChatRepository(localDatabase: localDatabase);
    botRepository = SqliteBotRepository(
      localDatabase: localDatabase,
      chatRepository: chatRepository,
    );
    bindingRepository = SqliteBotSkillBindingRepository(
      localDatabase: localDatabase,
    );
    skillRunRepository = SqliteSkillRunRepository(localDatabase: localDatabase);
  });

  tearDown(() async {
    await bindingRepository.dispose();
    await botRepository.dispose();
    await chatRepository.dispose();
    await database.close();
  });

  test('empty bot results are cached until an explicit refresh', () async {
    expect(await botRepository.getBots(), isEmpty);
    await database.insert('bots', BotRecord.fromDomain(_bot()).values);

    expect(await botRepository.getBots(), isEmpty);
    expect(await botRepository.getBots(forceRefresh: true), hasLength(1));
  });

  test('bot update persists every field with millisecond timestamps', () async {
    final original = _bot();
    await botRepository.addBot(original);
    final modifiedAt = DateTime.fromMillisecondsSinceEpoch(1770000000123);
    final updated = Bot(
      id: original.id,
      name: 'Updated',
      avatar: '/avatar.png',
      provider: 'Custom',
      baseURL: 'https://updated.test',
      apiKey: 'new-secret',
      apiType: Bot.apiTypeAnthropic,
      model: 'updated-model',
      systemPrompt: 'updated prompt',
      parameters: const {'temperature': 0.2},
      createTimestamp: original.createTimestamp,
      modifyTimestamp: modifiedAt,
    );

    await botRepository.updateBot(updated);

    final rows = await database.query(
      'bots',
      where: 'id = ?',
      whereArgs: [original.id],
    );
    final persisted = BotRecord(rows.single).toDomain();
    expect(persisted.apiType, Bot.apiTypeAnthropic);
    expect(persisted.parameters, {'temperature': 0.2});
    expect(persisted.modifyTimestamp, modifiedAt);
  });

  test(
    'profile repository creates one default and publishes updates',
    () async {
      final repository = SqliteProfileRepository(localDatabase: localDatabase);
      addTearDown(repository.dispose);
      final changes = <Profile>[];
      final subscription = repository.changes.listen(changes.add);
      addTearDown(subscription.cancel);

      final profile = await repository.getProfile();
      expect(profile.showExecutionStatus, isTrue);
      final updated = Profile(
        name: 'Earthwind',
        avatar: profile.avatar,
        fontSize: 18,
        themeMode: 2,
        language: 'en_US',
        showExecutionStatus: false,
        createTimestamp: profile.createTimestamp,
        modifyTimestamp: DateTime(2026, 7, 21),
      );
      await repository.updateProfile(updated);
      await Future<void>.delayed(Duration.zero);

      final rows = await database.query('profile');
      expect(rows, hasLength(1));
      expect(rows.single['show_execution_status'], 0);
      expect(await repository.getProfile(), same(updated));
      expect(changes, [updated]);
    },
  );

  test('message repository aggregates persisted token usage by bot', () async {
    final repository = SqliteMessageRepository(localDatabase: localDatabase);
    final timestamp = DateTime(2026, 7, 25);
    await repository.upsertMessages([
      Message(
        messageId: 'assistant-1',
        turnId: 'turn-1',
        chatId: 'chat-1',
        botId: 'bot-1',
        senderId: 'bot-1',
        content: 'First',
        tokenUsage: const ModelTokenUsage(
          model: 'model-a',
          inputTokens: 100,
          outputTokens: 40,
          totalTokens: 140,
        ),
        timestamp: timestamp,
      ),
      Message(
        messageId: 'assistant-2',
        turnId: 'turn-2',
        chatId: 'chat-2',
        botId: 'bot-1',
        senderId: 'bot-1',
        content: 'Second',
        tokenUsage: const ModelTokenUsage(
          model: 'model-b',
          inputTokens: 80,
          outputTokens: 20,
          totalTokens: 100,
        ),
        timestamp: timestamp,
      ),
      Message(
        messageId: 'other-bot',
        turnId: 'turn-3',
        chatId: 'chat-3',
        botId: 'bot-2',
        senderId: 'bot-2',
        content: 'Other',
        tokenUsage: const ModelTokenUsage(
          inputTokens: 1000,
          outputTokens: 1000,
          totalTokens: 2000,
        ),
        timestamp: timestamp,
      ),
    ]);
    await database.update(
      'token_usage_records',
      {'total_token_count': 0},
      where: 'message_id = ?',
      whereArgs: ['assistant-1'],
    );

    final usage = await repository.getTokenUsageForBot('bot-1');
    expect(usage.inputTokens, 180);
    expect(usage.outputTokens, 60);
    expect(usage.effectiveTotalTokens, 240);

    final usageByChat = await repository.getTokenUsageByChatForBot('bot-1');
    expect(usageByChat.keys, ['chat-1', 'chat-2']);
    expect(usageByChat['chat-1']?.effectiveTotalTokens, 140);
    expect(usageByChat['chat-2']?.effectiveTotalTokens, 100);
    final usageRecords = await repository.getTokenUsageRecordsForBot('bot-1');
    expect(usageRecords.map((record) => record.chatId), ['chat-1', 'chat-2']);

    final persisted = await repository.getMessages('chat-1');
    expect(persisted.single.tokenUsage.model, 'model-a');
    expect(persisted.single.tokenUsage.effectiveTotalTokens, 140);
  });

  test('clearing chat content retains persisted token usage', () async {
    final repository = SqliteMessageRepository(localDatabase: localDatabase);
    await repository.upsertMessage(
      Message(
        messageId: 'assistant-clear',
        turnId: 'turn-clear',
        chatId: 'chat-clear',
        botId: 'bot-1',
        senderId: 'bot-1',
        content: 'Response to clear',
        tokenUsage: const ModelTokenUsage(
          model: 'model-a',
          inputTokens: 90,
          outputTokens: 30,
          totalTokens: 120,
        ),
        timestamp: DateTime(2026, 7, 25, 10),
      ),
    );

    await chatRepository.clearHistory('chat-clear');

    expect(await repository.getMessages('chat-clear'), isEmpty);
    final records = await repository.getTokenUsageRecordsForChat('chat-clear');
    expect(records, hasLength(1));
    expect(records.single.usage.effectiveTotalTokens, 120);
    expect(
      (await repository.getTokenUsageForBot('bot-1')).effectiveTotalTokens,
      120,
    );

    await localDatabase.deleteChat('chat-clear');

    expect(await repository.getTokenUsageRecordsForChat('chat-clear'), isEmpty);
    expect(
      (await repository.getTokenUsageForBot('bot-1')).effectiveTotalTokens,
      0,
    );
  });

  test('Skill bindings round-trip and are removed with their bot', () async {
    final bot = _bot();
    await botRepository.addBot(bot);
    final timestamp = DateTime(2026, 7, 26, 10);
    final binding = BotSkillBinding(
      botId: bot.id,
      skillId: 'user:release-notes',
      activationMode: SkillActivationMode.always,
      priority: 12,
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    await bindingRepository.save(binding);

    final restored = await bindingRepository.getForBot(bot.id);
    expect(restored, hasLength(1));
    expect(restored.single.skillId, binding.skillId);
    expect(restored.single.activationMode, SkillActivationMode.always);
    expect(restored.single.priority, 12);

    await botRepository.deleteBot(bot.id);

    expect(await bindingRepository.getForBot(bot.id), isEmpty);
  });

  test('Skill activation audit records round-trip by run', () async {
    final startedAt = DateTime(2026, 7, 26, 10);
    final completedAt = startedAt.add(const Duration(milliseconds: 8));
    await skillRunRepository.saveActivations([
      SkillActivationRecord(
        id: 'run-1:user:release-notes',
        runId: 'run-1',
        chatId: 'chat-1',
        messageId: 'message-1',
        skillId: 'user:release-notes',
        skillName: 'release-notes',
        contentDigest: 'abc123',
        trigger: SkillActivationTrigger.manual,
        status: SkillActivationStatus.activated,
        startedAt: startedAt,
        completedAt: completedAt,
        durationMs: 8,
      ),
    ]);

    final restored = await skillRunRepository.getForRun('run-1');

    expect(restored, hasLength(1));
    expect(restored.single.skillName, 'release-notes');
    expect(restored.single.contentDigest, 'abc123');
    expect(restored.single.trigger, SkillActivationTrigger.manual);
    expect(restored.single.status, SkillActivationStatus.activated);
    expect(restored.single.durationMs, 8);
    expect(restored.single.completedAt, completedAt);
  });
}

Bot _bot() => Bot(
  id: 'bot-1',
  name: 'Assistant',
  avatar: '',
  provider: 'OpenAI',
  baseURL: 'https://example.test',
  apiKey: 'secret',
  apiType: Bot.apiTypeOpenAI,
  model: 'model',
  systemPrompt: '',
  parameters: const {'temperature': 0.7},
  createTimestamp: DateTime(2026),
  modifyTimestamp: DateTime(2026),
);
