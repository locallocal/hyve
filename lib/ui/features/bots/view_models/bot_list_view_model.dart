import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/ai_provider_repository.dart';
import 'package:stars/domain/repositories/attachment_repository.dart';
import 'package:stars/domain/repositories/bot_repository.dart';
import 'package:stars/domain/repositories/bot_skill_binding_repository.dart';
import 'package:stars/domain/repositories/mcp_server_repository.dart';
import 'package:stars/domain/repositories/message_repository.dart';
import 'package:stars/domain/use_cases/create_chat.dart';

@immutable
class BotCardMetrics {
  const BotCardMetrics({
    this.tokenUsage = ModelTokenUsage.empty,
    this.mcpServerNames = const [],
    this.skillCount = 0,
    this.contextWindowTokens,
    this.inputModalities = const [InputModality.text],
    this.outputModalities = const [OutputModality.text],
  });

  static const empty = BotCardMetrics();

  final ModelTokenUsage tokenUsage;
  final List<String> mcpServerNames;
  final int skillCount;
  final int? contextWindowTokens;
  final List<InputModality> inputModalities;
  final List<OutputModality> outputModalities;
}

class BotListViewModel extends ChangeNotifier {
  static final RegExp _searchWhitespace = RegExp(r'\s+');
  static final RegExp _searchSeparators = RegExp(r'[\s\-_.:/]+');

  BotListViewModel({
    required BotRepository botRepository,
    required CreateChat createChat,
    required AiProviderRepository aiProviderRepository,
    required AttachmentRepository attachmentRepository,
    BotSkillBindingRepository? botSkillBindingRepository,
    MessageRepository? messageRepository,
    McpServerRepository? mcpServerRepository,
  }) : _botRepository = botRepository,
       _createChat = createChat,
       _aiProviderRepository = aiProviderRepository,
       _attachmentRepository = attachmentRepository,
       _botSkillBindingRepository = botSkillBindingRepository,
       _messageRepository = messageRepository,
       _mcpServerRepository = mcpServerRepository {
    _botSubscription = _botRepository.changes.listen(_handleBotsChanged);
    _messageSubscription = messageRepository?.changes.listen(
      (_) => _scheduleMetricsLoad(),
    );
    _bindingSubscription = botSkillBindingRepository?.changes.listen(
      (_) => _scheduleMetricsLoad(),
    );
    _mcpSubscription = mcpServerRepository?.changes.listen((servers) {
      _mcpServers = List<McpServer>.unmodifiable(servers);
      _scheduleMetricsLoad();
    });
  }

  final BotRepository _botRepository;
  final CreateChat _createChat;
  final AiProviderRepository _aiProviderRepository;
  final AttachmentRepository _attachmentRepository;
  final BotSkillBindingRepository? _botSkillBindingRepository;
  final MessageRepository? _messageRepository;
  final McpServerRepository? _mcpServerRepository;
  late final StreamSubscription<List<Bot>> _botSubscription;
  late final StreamSubscription<void>? _messageSubscription;
  late final StreamSubscription<void>? _bindingSubscription;
  late final StreamSubscription<List<McpServer>>? _mcpSubscription;

  List<Bot> _bots = const [];
  List<Bot> _filteredBots = const [];
  List<McpServer>? _mcpServers;
  Map<String, BotCardMetrics> _cardMetrics = const {};
  String _query = '';
  Object? _error;
  bool _isLoading = false;
  bool _metricsLoadScheduled = false;
  bool _isPersistingModelMetadata = false;
  bool _reloadMetricsAfterModelMetadataPersistence = false;
  bool _disposed = false;
  int _loadGeneration = 0;
  int _metricsLoadGeneration = 0;

  List<Bot> get bots => _bots;
  List<Bot> get filteredBots => _filteredBots;
  String get query => _query;
  Object? get error => _error;
  bool get isLoading => _isLoading;
  BotCardMetrics metricsFor(String botId) =>
      _cardMetrics[botId] ?? BotCardMetrics.empty;

  Future<void> load() async {
    final generation = ++_loadGeneration;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final bots = await _botRepository.getBots();
      if (_disposed || generation != _loadGeneration) return;
      _applyBots(bots, notify: false);
      await _loadCardMetrics(bots, notify: false);
    } catch (error) {
      if (_disposed || generation != _loadGeneration) return;
      _error = error;
    } finally {
      if (!_disposed && generation == _loadGeneration) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void search(String query) {
    _query = query;
    _applyFilter();
    notifyListeners();
  }

  Future<Chat> startChat(Bot bot) => _createChat(bot);

  Future<List<AiModelInfo>> listModels(Bot bot) =>
      _aiProviderRepository.listModels(bot);

  Future<AiModelInfo?> getModelInfo(Bot bot) =>
      _aiProviderRepository.getModelInfo(bot);

  Future<String?> pickAvatar() => _attachmentRepository.selectImage();

  Future<void> addBot(
    Bot bot, {
    List<BotSkillBinding> skillBindings = const [],
  }) async {
    await _botRepository.addBot(bot);
    if (skillBindings.isEmpty) return;

    final bindingRepository = _botSkillBindingRepository;
    if (bindingRepository == null) {
      throw StateError('No Bot Skill binding repository was configured.');
    }
    for (final binding in skillBindings) {
      await bindingRepository.save(binding);
    }
  }

  Future<void> updateBot(Bot bot) => _botRepository.updateBot(bot);

  Future<void> deleteBot(String id) => _botRepository.deleteBot(id);

  void _handleBotsChanged(List<Bot> bots) {
    if (_disposed) return;
    _applyBots(bots);
    if (_isPersistingModelMetadata) {
      _reloadMetricsAfterModelMetadataPersistence = true;
      return;
    }
    _scheduleMetricsLoad();
  }

  void _applyBots(List<Bot> bots, {bool notify = true}) {
    _bots = List<Bot>.unmodifiable(bots);
    _applyFilter();
    if (notify) notifyListeners();
  }

  void _applyFilter() {
    final terms = _query
        .trim()
        .toLowerCase()
        .split(_searchWhitespace)
        .where((term) => term.isNotEmpty)
        .toList(growable: false);
    _filteredBots =
        terms.isEmpty
            ? _bots
            : List<Bot>.unmodifiable(
              _bots.where((bot) => _matchesSearch(bot, terms)),
            );
  }

  bool _matchesSearch(Bot bot, List<String> terms) {
    final fields = [bot.name, bot.provider, bot.model]
        .map((value) => value.trim().toLowerCase())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    final compactFields = fields
        .map((value) => value.replaceAll(_searchSeparators, ''))
        .toList(growable: false);
    return terms.every((term) {
      if (fields.any((field) => field.contains(term))) return true;
      final compactTerm = term.replaceAll(_searchSeparators, '');
      return compactTerm.isNotEmpty &&
          compactFields.any((field) => field.contains(compactTerm));
    });
  }

  Future<void> _loadCardMetrics(List<Bot> bots, {bool notify = true}) async {
    final generation = ++_metricsLoadGeneration;
    var mcpServers = _mcpServers;
    final mcpRepository = _mcpServerRepository;
    if (mcpServers == null && mcpRepository != null) {
      mcpServers = List<McpServer>.unmodifiable(
        await mcpRepository.getServers(),
      );
      _mcpServers = mcpServers;
    }
    final serversById = {
      for (final server in mcpServers ?? const <McpServer>[]) server.id: server,
    };
    final entries = await Future.wait(
      bots.map((bot) => _loadBotCardMetrics(bot, serversById)),
    );
    if (_disposed || generation != _metricsLoadGeneration) return;
    _cardMetrics = Map<String, BotCardMetrics>.unmodifiable({
      for (final entry in entries) entry.$1: entry.$2,
    });
    await _persistModelMetadata(
      entries.map((entry) => entry.$3).whereType<Bot>(),
    );
    if (notify) notifyListeners();
  }

  Future<(String, BotCardMetrics, Bot?)> _loadBotCardMetrics(
    Bot bot,
    Map<String, McpServer> serversById,
  ) async {
    final usageFuture =
        _messageRepository?.getTokenUsageForBot(bot.id) ??
        Future<ModelTokenUsage>.value(ModelTokenUsage.empty);
    final bindingsFuture =
        _botSkillBindingRepository?.getForBot(bot.id) ??
        Future<List<BotSkillBinding>>.value(const []);
    final modelInfoFuture = _loadModelInfoForCard(bot);
    final (usage, bindings, modelInfo) =
        await (usageFuture, bindingsFuture, modelInfoFuture).wait;
    final contextWindowTokens =
        bot.configuredContextWindowTokens ?? modelInfo?.contextWindowTokens;
    final providerModalities = _providerModalities(bot);
    final inputModalities = _resolveInputModalities(
      bot.configuredInputModalities,
      modelInfo?.inputModalities,
      providerModalities.$1,
    );
    final outputModalities = _resolveOutputModalities(
      bot.configuredOutputModalities,
      modelInfo?.outputModalities,
      providerModalities.$2,
    );
    final metadataBackfill =
        _hasMissingModelMetadata(bot, modelInfo)
            ? _withModelMetadata(bot, modelInfo!)
            : null;
    final serverNames =
        bot.mcpServerIds
            .map((id) => serversById[id]?.name.trim())
            .whereType<String>()
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort(
            (left, right) => left.toLowerCase().compareTo(right.toLowerCase()),
          );
    return (
      bot.id,
      BotCardMetrics(
        tokenUsage: usage,
        mcpServerNames: List<String>.unmodifiable(serverNames),
        skillCount: bindings.length,
        contextWindowTokens: contextWindowTokens,
        inputModalities: inputModalities,
        outputModalities: outputModalities,
      ),
      metadataBackfill,
    );
  }

  bool _hasMissingModelMetadata(Bot bot, AiModelInfo? modelInfo) {
    if (modelInfo == null) return false;
    return (bot.configuredContextWindowTokens == null &&
            modelInfo.contextWindowTokens != null) ||
        (bot.configuredInputModalities == null &&
            modelInfo.inputModalities.isNotEmpty) ||
        (bot.configuredOutputModalities == null &&
            modelInfo.outputModalities.isNotEmpty);
  }

  Bot _withModelMetadata(Bot bot, AiModelInfo modelInfo) {
    return Bot(
      id: bot.id,
      name: bot.name,
      avatar: bot.avatar,
      provider: bot.provider,
      baseURL: bot.baseURL,
      apiKey: bot.apiKey,
      apiType: bot.apiType,
      model: bot.model,
      systemPrompt: bot.systemPrompt,
      parameters: {
        ...?bot.parameters,
        if (bot.configuredContextWindowTokens == null &&
            modelInfo.contextWindowTokens != null)
          Bot.parameterContextWindowTokens: modelInfo.contextWindowTokens,
        if (bot.configuredInputModalities == null &&
            modelInfo.inputModalities.isNotEmpty)
          Bot.parameterInputModalities: [
            for (final modality in modelInfo.inputModalities) modality.value,
          ],
        if (bot.configuredOutputModalities == null &&
            modelInfo.outputModalities.isNotEmpty)
          Bot.parameterOutputModalities: [
            for (final modality in modelInfo.outputModalities) modality.value,
          ],
      },
      createTimestamp: bot.createTimestamp,
      modifyTimestamp: bot.modifyTimestamp,
    );
  }

  Future<void> _persistModelMetadata(Iterable<Bot> bots) async {
    final backfills = bots.toList(growable: false);
    if (backfills.isEmpty || _disposed) return;
    _isPersistingModelMetadata = true;
    try {
      for (final bot in backfills) {
        if (_disposed) return;
        try {
          await _botRepository.updateBot(bot);
        } on Object {
          // The card can still use the fetched value for this session.
        }
      }
    } finally {
      _isPersistingModelMetadata = false;
      if (_reloadMetricsAfterModelMetadataPersistence && !_disposed) {
        _reloadMetricsAfterModelMetadataPersistence = false;
        _scheduleMetricsLoad();
      }
    }
  }

  Future<AiModelInfo?> _loadModelInfoForCard(Bot bot) async {
    if (bot.configuredContextWindowTokens != null &&
        bot.configuredInputModalities != null &&
        bot.configuredOutputModalities != null) {
      return null;
    }
    try {
      return await _aiProviderRepository.getModelInfo(bot);
    } on Object {
      return null;
    }
  }

  (List<InputModality>, List<OutputModality>) _providerModalities(Bot bot) {
    try {
      final provider = _aiProviderRepository.create(bot);
      return (provider.getInputModalites(), provider.getOutputModalites());
    } on Object {
      return const ([InputModality.text], [OutputModality.text]);
    }
  }

  List<InputModality> _resolveInputModalities(
    List<InputModality>? configured,
    List<InputModality>? fetched,
    List<InputModality> fallback,
  ) => List<InputModality>.unmodifiable(
    configured?.isNotEmpty == true
        ? configured!
        : fetched?.isNotEmpty == true
        ? fetched!
        : fallback.isNotEmpty
        ? fallback
        : const [InputModality.text],
  );

  List<OutputModality> _resolveOutputModalities(
    List<OutputModality>? configured,
    List<OutputModality>? fetched,
    List<OutputModality> fallback,
  ) => List<OutputModality>.unmodifiable(
    configured?.isNotEmpty == true
        ? configured!
        : fetched?.isNotEmpty == true
        ? fetched!
        : fallback.isNotEmpty
        ? fallback
        : const [OutputModality.text],
  );

  void _scheduleMetricsLoad() {
    if (_disposed || _metricsLoadScheduled) return;
    _metricsLoadScheduled = true;
    scheduleMicrotask(() async {
      _metricsLoadScheduled = false;
      if (_disposed) return;
      try {
        await _loadCardMetrics(_bots);
      } catch (error) {
        if (_disposed) return;
        _error = error;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _botSubscription.cancel();
    _messageSubscription?.cancel();
    _bindingSubscription?.cancel();
    _mcpSubscription?.cancel();
    super.dispose();
  }
}
