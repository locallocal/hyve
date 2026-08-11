import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/ai_provider_repository.dart';
import 'package:stars/domain/repositories/attachment_repository.dart';
import 'package:stars/domain/repositories/bot_repository.dart';
import 'package:stars/domain/repositories/chat_repository.dart';
import 'package:stars/domain/use_cases/create_chat.dart';
import 'package:stars/ui/features/bots/view_models/bot_list_view_model.dart';

void main() {
  group('BotListViewModel search', () {
    test('matches partial bot names, providers, and model names', () async {
      final viewModel = await _loadedViewModel();
      addTearDown(viewModel.dispose);

      viewModel.search('research');
      expect(_ids(viewModel), ['research']);

      viewModel.search('ANTHROPIC');
      expect(_ids(viewModel), ['writer']);

      viewModel.search('2.5-pro');
      expect(_ids(viewModel), ['vision']);
    });

    test(
      'supports cross-field terms and separator-insensitive models',
      () async {
        final viewModel = await _loadedViewModel();
        addTearDown(viewModel.dispose);

        viewModel.search('research open gpt4o');
        expect(_ids(viewModel), ['research']);

        viewModel.search('writer anth claude35');
        expect(_ids(viewModel), ['writer']);

        viewModel.search('google 25/pro');
        expect(_ids(viewModel), ['vision']);

        viewModel.search('missing model');
        expect(viewModel.filteredBots, isEmpty);

        viewModel.search('   ');
        expect(_ids(viewModel), ['research', 'writer', 'vision']);
      },
    );
  });

  test('loads and caches missing model metadata for card metrics', () async {
    final providerRepository = _ModelInfoAiProviderRepository();
    final botRepository = _UpdatingBotRepository([
      _bot(
        id: 'research',
        name: 'Research Assistant',
        provider: 'OpenAI',
        model: 'gpt-test',
      ),
    ]);
    addTearDown(botRepository.dispose);
    final viewModel = BotListViewModel(
      botRepository: botRepository,
      createChat: CreateChat(chatRepository: _UnusedChatRepository()),
      aiProviderRepository: providerRepository,
      attachmentRepository: _UnusedAttachmentRepository(),
    );
    addTearDown(viewModel.dispose);

    await viewModel.load();
    await pumpEventQueue();

    expect(providerRepository.lookupCount, 1);
    expect(viewModel.metricsFor('research').contextWindowTokens, 128000);
    expect(viewModel.metricsFor('research').inputModalities, [
      InputModality.text,
      InputModality.image,
      InputModality.audio,
    ]);
    expect(viewModel.metricsFor('research').outputModalities, [
      OutputModality.text,
    ]);
    expect(botRepository.bots.single.configuredContextWindowTokens, 128000);
    expect(botRepository.bots.single.configuredInputModalities, [
      InputModality.text,
      InputModality.image,
      InputModality.audio,
    ]);
    expect(botRepository.bots.single.configuredOutputModalities, [
      OutputModality.text,
    ]);
    expect(botRepository.bots.single.modifyTimestamp, DateTime(2026, 8, 7));

    final reloadedViewModel = BotListViewModel(
      botRepository: botRepository,
      createChat: CreateChat(chatRepository: _UnusedChatRepository()),
      aiProviderRepository: providerRepository,
      attachmentRepository: _UnusedAttachmentRepository(),
    );
    addTearDown(reloadedViewModel.dispose);

    await reloadedViewModel.load();

    expect(providerRepository.lookupCount, 1);
    expect(
      reloadedViewModel.metricsFor('research').contextWindowTokens,
      128000,
    );
  });
}

List<String> _ids(BotListViewModel viewModel) =>
    viewModel.filteredBots.map((bot) => bot.id).toList(growable: false);

Future<BotListViewModel> _loadedViewModel() async {
  final viewModel = BotListViewModel(
    botRepository: _FakeBotRepository([
      _bot(
        id: 'research',
        name: 'Research Assistant',
        provider: 'OpenAI',
        model: 'gpt-4o',
      ),
      _bot(
        id: 'writer',
        name: 'Release Writer',
        provider: 'Anthropic',
        model: 'claude-3.5-sonnet',
      ),
      _bot(
        id: 'vision',
        name: 'Vision Analyst',
        provider: 'Google',
        model: 'gemini-2.5-pro',
      ),
    ]),
    createChat: CreateChat(chatRepository: _UnusedChatRepository()),
    aiProviderRepository: _UnusedAiProviderRepository(),
    attachmentRepository: _UnusedAttachmentRepository(),
  );
  await viewModel.load();
  return viewModel;
}

Bot _bot({
  required String id,
  required String name,
  required String provider,
  required String model,
}) => Bot(
  id: id,
  name: name,
  avatar: '',
  provider: provider,
  baseURL: '',
  apiKey: '',
  apiType: Bot.apiTypeOpenAI,
  model: model,
  systemPrompt: '',
  createTimestamp: DateTime(2026, 8, 7),
  modifyTimestamp: DateTime(2026, 8, 7),
);

final class _FakeBotRepository implements BotRepository {
  const _FakeBotRepository(this.bots);

  final List<Bot> bots;

  @override
  Stream<List<Bot>> get changes => const Stream.empty();

  @override
  Future<List<Bot>> getBots({bool forceRefresh = false}) async => bots;

  @override
  Future<Bot?> getBot(String id) async =>
      bots.where((bot) => bot.id == id).firstOrNull;

  @override
  Future<void> addBot(Bot bot) =>
      throw UnsupportedError('Not used in search tests.');

  @override
  Future<void> updateBot(Bot bot) =>
      throw UnsupportedError('Not used in search tests.');

  @override
  Future<void> deleteBot(String id) =>
      throw UnsupportedError('Not used in search tests.');
}

final class _UpdatingBotRepository implements BotRepository {
  _UpdatingBotRepository(List<Bot> bots) : bots = List<Bot>.of(bots);

  final List<Bot> bots;
  final StreamController<List<Bot>> _changes =
      StreamController<List<Bot>>.broadcast();

  @override
  Stream<List<Bot>> get changes => _changes.stream;

  @override
  Future<List<Bot>> getBots({bool forceRefresh = false}) async =>
      List<Bot>.unmodifiable(bots);

  @override
  Future<Bot?> getBot(String id) async =>
      bots.where((bot) => bot.id == id).firstOrNull;

  @override
  Future<void> updateBot(Bot bot) async {
    final index = bots.indexWhere((item) => item.id == bot.id);
    if (index == -1) throw StateError('Unknown Bot: ${bot.id}');
    bots[index] = bot;
    _changes.add(List<Bot>.unmodifiable(bots));
  }

  Future<void> dispose() => _changes.close();

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Only Bot reads and updates are used.');
}

final class _UnusedChatRepository implements ChatRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Chat repository is not used in search tests.');
}

final class _UnusedAiProviderRepository implements AiProviderRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError(
        'AI provider repository is not used in search tests.',
      );
}

final class _ModelInfoAiProviderRepository implements AiProviderRepository {
  int lookupCount = 0;

  @override
  Future<AiModelInfo?> getModelInfo(Bot bot) async {
    lookupCount += 1;
    return AiModelInfo(
      modelId: bot.model,
      providerId: 'openai',
      inputModalities: const [
        InputModality.text,
        InputModality.image,
        InputModality.audio,
      ],
      outputModalities: const [OutputModality.text],
      contextWindowTokens: 128000,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Only model info lookup is used by this test.');
}

final class _UnusedAttachmentRepository implements AttachmentRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError(
        'Attachment repository is not used in search tests.',
      );
}
