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
  });

  static const empty = BotCardMetrics();

  final ModelTokenUsage tokenUsage;
  final List<String> mcpServerNames;
  final int skillCount;
  final int? contextWindowTokens;
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
    if (notify) notifyListeners();
  }

  Future<(String, BotCardMetrics)> _loadBotCardMetrics(
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
        contextWindowTokens:
            bot.configuredContextWindowTokens ?? modelInfo?.contextWindowTokens,
      ),
    );
  }

  Future<AiModelInfo?> _loadModelInfoForCard(Bot bot) async {
    if (bot.configuredContextWindowTokens != null) return null;
    try {
      return await _aiProviderRepository.getModelInfo(bot);
    } on Object {
      return null;
    }
  }

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
