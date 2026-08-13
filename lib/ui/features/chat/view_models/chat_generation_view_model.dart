import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:stars/domain/models/ai_models.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/ai_provider_repository.dart';
import 'package:stars/domain/use_cases/agent_run_coordinator.dart';

part 'chat_generation_events.dart';
part 'chat_generation_persistence.dart';
part 'chat_generation_registry.dart';

enum ChatRunLifecycle {
  idle,
  submitting,
  connecting,
  active,
  stopping,
  completed,
  cancelled,
  failed,
  emptyResponse;

  bool get isRunning =>
      this == submitting ||
      this == connecting ||
      this == active ||
      this == stopping;

  bool get isTerminal =>
      this == completed ||
      this == cancelled ||
      this == failed ||
      this == emptyResponse;
}

@immutable
class ChatGenerationSnapshot {
  const ChatGenerationSnapshot({
    required this.chatId,
    this.runId,
    this.turnId,
    this.lifecycle = ChatRunLifecycle.idle,
    this.streamingResponse = '',
    this.reasoningResponse = '',
    this.toolCalls = const [],
    this.commandExecutions = const [],
    this.skillActivations = const [],
    this.pendingToolApproval,
    this.tokenUsage = ModelTokenUsage.empty,
    this.supportsCancellation = false,
    this.userPersisted = false,
    this.submittedUserMessage,
    this.error,
    this.terminalMessage,
  });

  final String chatId;
  final String? runId;
  final String? turnId;
  final ChatRunLifecycle lifecycle;
  final String streamingResponse;
  final String reasoningResponse;
  final List<MessageToolCall> toolCalls;
  final List<MessageCommandExecution> commandExecutions;
  final List<MessageSkillActivation> skillActivations;
  final ToolApprovalRequest? pendingToolApproval;
  final ModelTokenUsage tokenUsage;
  final bool supportsCancellation;
  final bool userPersisted;
  final Message? submittedUserMessage;
  final String? error;
  final Message? terminalMessage;

  bool get isRunning => lifecycle.isRunning;
  bool get contentStreaming => streamingResponse.isNotEmpty;
  bool get reasoningActive =>
      isRunning && (reasoningResponse.isNotEmpty || contentStreaming);
  bool get toolingActive =>
      isRunning &&
      (toolCalls.isNotEmpty ||
          commandExecutions.isNotEmpty ||
          skillActivations.isNotEmpty);
  bool get canCancel =>
      supportsCancellation &&
      lifecycle.isRunning &&
      lifecycle != ChatRunLifecycle.stopping;

  ChatGenerationSnapshot copyWith({
    String? runId,
    bool clearRunId = false,
    String? turnId,
    bool clearTurnId = false,
    ChatRunLifecycle? lifecycle,
    String? streamingResponse,
    String? reasoningResponse,
    List<MessageToolCall>? toolCalls,
    List<MessageCommandExecution>? commandExecutions,
    List<MessageSkillActivation>? skillActivations,
    ToolApprovalRequest? pendingToolApproval,
    bool clearPendingToolApproval = false,
    ModelTokenUsage? tokenUsage,
    bool? supportsCancellation,
    bool? userPersisted,
    Message? submittedUserMessage,
    bool clearSubmittedUserMessage = false,
    String? error,
    bool clearError = false,
    Message? terminalMessage,
    bool clearTerminalMessage = false,
  }) {
    return ChatGenerationSnapshot(
      chatId: chatId,
      runId: clearRunId ? null : runId ?? this.runId,
      turnId: clearTurnId ? null : turnId ?? this.turnId,
      lifecycle: lifecycle ?? this.lifecycle,
      streamingResponse: streamingResponse ?? this.streamingResponse,
      reasoningResponse: reasoningResponse ?? this.reasoningResponse,
      toolCalls: toolCalls ?? this.toolCalls,
      commandExecutions: commandExecutions ?? this.commandExecutions,
      skillActivations: skillActivations ?? this.skillActivations,
      pendingToolApproval:
          clearPendingToolApproval
              ? null
              : pendingToolApproval ?? this.pendingToolApproval,
      tokenUsage: tokenUsage ?? this.tokenUsage,
      supportsCancellation: supportsCancellation ?? this.supportsCancellation,
      userPersisted: userPersisted ?? this.userPersisted,
      submittedUserMessage:
          clearSubmittedUserMessage
              ? null
              : submittedUserMessage ?? this.submittedUserMessage,
      error: clearError ? null : error ?? this.error,
      terminalMessage:
          clearTerminalMessage ? null : terminalMessage ?? this.terminalMessage,
    );
  }
}

typedef MessagePersister = Future<Message> Function(Message message);
typedef LastMessageUpdater =
    Future<void> Function(String chatId, String content);
typedef ProviderFactory = AiProvider Function(Bot bot);
typedef MessageIdFactory = String Function(String prefix);
typedef SkillActivationPersister =
    Future<void> Function(Iterable<SkillActivationRecord> records);
typedef ToolInvocationPersister =
    Future<void> Function(
      String runId,
      String chatId,
      String botId,
      MessageToolCall audit,
    );
typedef TerminalMessageObserver =
    Future<void> Function(
      String chatId,
      Bot bot,
      Message message,
      ContextAssemblyReport? report,
    );
typedef TextGenerationPreparer =
    Future<PreparedTextGeneration> Function(Message identifiedUserMessage);

@immutable
class PreparedTextGeneration {
  const PreparedTextGeneration({
    required this.userMessage,
    required this.messages,
    this.activatedSkills = const [],
    this.activationAttempts = const [],
    this.skillToolCalls = const [],
    this.preflightTokenUsage = ModelTokenUsage.empty,
    this.requestedToolNames = const {},
    this.approvalExemptToolNames = const {},
    this.runScopedTools = const [],
    this.contextAssemblyReport,
  });

  final Message userMessage;
  final List<ChatMessage> messages;
  final List<ActivatedSkill> activatedSkills;
  final List<SkillActivationAttempt> activationAttempts;
  final List<MessageToolCall> skillToolCalls;
  final ModelTokenUsage preflightTokenUsage;
  final Set<String> requestedToolNames;
  final Set<String> approvalExemptToolNames;
  final List<ExecutableTool> runScopedTools;
  final ContextAssemblyReport? contextAssemblyReport;
}

int _identitySequence = 0;

String _defaultMessageIdFactory(String prefix) {
  _identitySequence = (_identitySequence + 1) & 0x7fffffff;
  return '$prefix:${DateTime.now().microsecondsSinceEpoch}:'
      '$_identitySequence';
}

/// Owns one chat's text generation independently from any [StatefulWidget].
///
/// A fresh AI provider session is created for every run. Its callbacks capture
/// the run id, so a late token from an older request cannot be reduced into a
/// newer run even if the user stops and sends again quickly.
class ChatGenerationViewModel extends ChangeNotifier
    implements ToolApprovalHandler {
  static const Duration defaultPartialPersistenceInterval = Duration(
    milliseconds: 250,
  );

  ChatGenerationViewModel({
    required this.chatId,
    required Bot bot,
    required MessagePersister messagePersister,
    required LastMessageUpdater lastMessageUpdater,
    required ProviderFactory providerFactory,
    MessageIdFactory messageIdFactory = _defaultMessageIdFactory,
    SkillActivationPersister? skillActivationPersister,
    ToolInvocationPersister? toolInvocationPersister,
    TerminalMessageObserver? terminalMessageObserver,
    ToolRegistry? toolRegistry,
    ToolPolicy toolPolicy = const DefaultToolPolicy(),
    AgentRunLimits agentRunLimits = const AgentRunLimits(),
    Duration partialPersistenceInterval = defaultPartialPersistenceInterval,
  }) : _bot = bot,
       _providerFactory = providerFactory,
       _messagePersister = messagePersister,
       _lastMessageUpdater = lastMessageUpdater,
       _messageIdFactory = messageIdFactory,
       _skillActivationPersister = skillActivationPersister,
       _toolInvocationPersister = toolInvocationPersister,
       _terminalMessageObserver = terminalMessageObserver,
       _toolRegistry = toolRegistry ?? StaticToolRegistry(const []),
       _toolPolicy = toolPolicy,
       _agentRunLimits = agentRunLimits,
       _partialPersistenceInterval = partialPersistenceInterval,
       _capabilityProvider = providerFactory(bot),
       _snapshot = ChatGenerationSnapshot(chatId: chatId);

  final String chatId;
  final ProviderFactory _providerFactory;
  final MessagePersister _messagePersister;
  final LastMessageUpdater _lastMessageUpdater;
  final MessageIdFactory _messageIdFactory;
  final SkillActivationPersister? _skillActivationPersister;
  final ToolInvocationPersister? _toolInvocationPersister;
  final TerminalMessageObserver? _terminalMessageObserver;
  final ToolRegistry _toolRegistry;
  final ToolPolicy _toolPolicy;
  final AgentRunLimits _agentRunLimits;
  final Duration _partialPersistenceInterval;

  Bot _bot;
  Bot? _pendingBot;
  AiProvider _capabilityProvider;
  AiProvider? _runProvider;
  ChatGenerationSnapshot _snapshot;
  Completer<ChatRunLifecycle>? _terminalCompleter;
  DateTime? _startedAt;
  ModelTokenUsage _preflightTokenUsage = ModelTokenUsage.empty;
  final Set<String> _finalizingRuns = <String>{};
  final Set<String> _preparingRuns = <String>{};
  final Set<String> _preflightCancellationRuns = <String>{};
  AgentCancellationToken? _agentCancellationToken;
  Completer<ToolApprovalDecision>? _toolApprovalCompleter;
  ModelTokenUsage _agentTokenUsage = ModelTokenUsage.empty;
  ContextAssemblyReport? _contextAssemblyReport;
  Timer? _partialPersistenceTimer;
  Future<void> _partialPersistenceQueue = Future<void>.value();

  ChatGenerationSnapshot get snapshot => _snapshot;
  ContextAssemblyReport? get contextAssemblyReport => _contextAssemblyReport;
  AiProvider get capabilityProvider => _capabilityProvider;
  bool get hasBlockingRun => _snapshot.lifecycle.isRunning;

  void updateBot(Bot bot) {
    if (_bot == bot) return;
    if (hasBlockingRun) {
      _pendingBot = bot;
      return;
    }
    _replaceCapabilityProvider(bot);
  }

  Future<bool> startText({
    required Message userMessage,
    required List<ChatMessage> messages,
    List<ActivatedSkill> activatedSkills = const [],
    List<SkillActivationAttempt> activationAttempts = const [],
    List<MessageToolCall> skillToolCalls = const [],
    ModelTokenUsage preflightTokenUsage = ModelTokenUsage.empty,
    Set<String> requestedToolNames = const {},
    Set<String> approvalExemptToolNames = const {},
  }) => startTextWithPreparation(
    userMessage: userMessage,
    prepare:
        (identifiedUserMessage) async => PreparedTextGeneration(
          userMessage: identifiedUserMessage,
          messages: messages,
          activatedSkills: activatedSkills,
          activationAttempts: activationAttempts,
          skillToolCalls: skillToolCalls,
          preflightTokenUsage: preflightTokenUsage,
          requestedToolNames: requestedToolNames,
          approvalExemptToolNames: approvalExemptToolNames,
        ),
  );

  Future<bool> startTextWithPreparation({
    required Message userMessage,
    required TextGenerationPreparer prepare,
  }) async {
    if (hasBlockingRun) return false;

    final runId = _messageIdFactory('run');
    final turnId =
        userMessage.turnId.isEmpty
            ? _messageIdFactory('turn')
            : userMessage.turnId;
    final identifiedUser = userMessage.copyWith(
      messageId:
          userMessage.messageId.isEmpty ? '$runId:user' : userMessage.messageId,
      turnId: turnId,
      runId: runId,
      clearTerminalOutcome: true,
      hasPartialContent: false,
    );

    final provider =
        _providerFactory(_bot)
          ..setWebSearch(_capabilityProvider.getWebSearch())
          ..setDeepThinking(_capabilityProvider.getDeepThinking());
    _runProvider = provider;
    _startedAt = DateTime.now();
    _preflightTokenUsage = ModelTokenUsage.empty;
    _agentTokenUsage = ModelTokenUsage.empty;
    _terminalCompleter = Completer<ChatRunLifecycle>();
    _preparingRuns.add(runId);
    _snapshot = ChatGenerationSnapshot(
      chatId: chatId,
      runId: runId,
      turnId: turnId,
      lifecycle: ChatRunLifecycle.submitting,
      // Preparation can always be abandoned, even when the provider itself
      // cannot cancel an in-flight generation request.
      supportsCancellation: true,
      submittedUserMessage: identifiedUser,
    );
    notifyListeners();

    late final PreparedTextGeneration prepared;
    try {
      prepared = await prepare(identifiedUser);
    } catch (error) {
      _preparingRuns.remove(runId);
      if (_isActiveRun(runId) && !_snapshot.lifecycle.isTerminal) {
        await _finalizeRun(
          runId,
          ProviderTerminalType.failed,
          error: AppFailure.from(error, code: 'generation_prepare_failed').code,
        );
      }
      return false;
    }
    _preparingRuns.remove(runId);

    if (!_isActiveRun(runId) || _snapshot.lifecycle.isTerminal) return false;
    final preparedUser = prepared.userMessage.copyWith(
      messageId: identifiedUser.messageId,
      turnId: turnId,
      runId: runId,
      clearTerminalOutcome: true,
      hasPartialContent: false,
    );
    _preflightTokenUsage = prepared.preflightTokenUsage;
    _contextAssemblyReport = prepared.contextAssemblyReport;
    _snapshot = _snapshot.copyWith(
      supportsCancellation: provider.supportsCancellation,
      tokenUsage: prepared.preflightTokenUsage,
      toolCalls: prepared.skillToolCalls,
      skillActivations: [
        for (final skill in prepared.activatedSkills)
          MessageSkillActivation(
            name: skill.name,
            contentDigest: skill.contentDigest,
            trigger: skill.trigger.name,
          ),
      ],
      submittedUserMessage: preparedUser,
    );
    notifyListeners();

    try {
      await _messagePersister(preparedUser);
    } catch (error) {
      if (_isActiveRun(runId)) {
        _preflightCancellationRuns.remove(runId);
        _snapshot = _snapshot.copyWith(
          lifecycle: ChatRunLifecycle.failed,
          error: AppFailure.from(error, code: 'generation_start_failed').code,
          userPersisted: false,
        );
        _completeTerminal(ChatRunLifecycle.failed);
        notifyListeners();
      }
      return false;
    }

    if (!_isActiveRun(runId) || _snapshot.lifecycle.isTerminal) return false;
    _snapshot = _snapshot.copyWith(userPersisted: true, clearError: true);
    notifyListeners();
    await _persistSkillActivationsSafely(
      runId: runId,
      messageId: '$runId:assistant',
      activatedSkills: prepared.activatedSkills,
      activationAttempts: prepared.activationAttempts,
    );

    unawaited(_updateLastMessageSafely(preparedUser.content));

    if (!_isActiveRun(runId) || _snapshot.lifecycle.isTerminal) return false;
    if (_preflightCancellationRuns.remove(runId)) {
      await _finalizeRun(runId, ProviderTerminalType.cancelled);
      return false;
    }

    _snapshot = _snapshot.copyWith(
      lifecycle: ChatRunLifecycle.connecting,
      clearError: true,
    );
    notifyListeners();
    if (_preflightCancellationRuns.remove(runId)) {
      await _finalizeRun(runId, ProviderTerminalType.cancelled);
      return false;
    }

    final runToolRegistry =
        prepared.runScopedTools.isEmpty
            ? _toolRegistry
            : OverlayToolRegistry(
              parent: _toolRegistry,
              overlayTools: prepared.runScopedTools,
            );
    final agentTools = runToolRegistry.list(
      allowedNames: prepared.requestedToolNames,
    );
    if (provider.capabilities.supportsAgentLoop && agentTools.isNotEmpty) {
      return _startAgentRun(
        runId: runId,
        provider: provider,
        messages: prepared.messages,
        requestedToolNames: prepared.requestedToolNames,
        approvalExemptToolNames: prepared.approvalExemptToolNames,
        toolRegistry: runToolRegistry,
      );
    }

    provider.setCallbacks(
      onResponse: (text) => _onResponse(runId, text),
      onReasoningResponse: (text) => _onReasoning(runId, text),
      onToolCall: (toolCall) => _onToolCall(runId, toolCall),
      onCommandExecution: (execution) => _onCommandExecution(runId, execution),
      onTokenUsage: (usage) => _onTokenUsage(runId, usage),
      onComplete: () {},
      onError: (_) {},
      onTerminal: (event) => _onProviderTerminal(runId, event),
    );

    // Providers reset their cancellation state synchronously at the start of
    // generateText. Invoke it before publishing the cancellable active state
    // so an input event cannot be erased by that reset.
    late final Future<void> generation;
    try {
      generation = provider.generateText(prepared.messages);
    } catch (error) {
      await _finalizeRun(
        runId,
        ProviderTerminalType.failed,
        error: AppFailure.from(error, code: 'generation_persist_failed').code,
      );
      return false;
    }

    unawaited(
      generation
          .then((_) {
            if (_isActiveRun(runId) && !_finalizingRuns.contains(runId)) {
              unawaited(_finalizeRun(runId, ProviderTerminalType.completed));
            }
          })
          .catchError((Object error, StackTrace stackTrace) {
            if (_isActiveRun(runId) && !_finalizingRuns.contains(runId)) {
              unawaited(
                _finalizeRun(
                  runId,
                  provider.isCancelled
                      ? ProviderTerminalType.cancelled
                      : ProviderTerminalType.failed,
                  error:
                      AppFailure.from(
                        error,
                        code: 'generation_partial_persist_failed',
                      ).code,
                ),
              );
            }
          }),
    );
    if (!_isActiveRun(runId) || _snapshot.lifecycle.isTerminal) return false;
    if (!_finalizingRuns.contains(runId)) {
      _snapshot = _snapshot.copyWith(lifecycle: ChatRunLifecycle.active);
      notifyListeners();
    }
    return true;
  }

  Future<ChatRunLifecycle> cancel({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final runId = _snapshot.runId;
    final provider = _runProvider;
    if (runId == null || provider == null || !hasBlockingRun) {
      return _snapshot.lifecycle;
    }
    final isPreparing = _preparingRuns.contains(runId);
    if (!isPreparing && !provider.supportsCancellation) {
      return _snapshot.lifecycle;
    }

    if (isPreparing) {
      _preparingRuns.remove(runId);
      _snapshot = _snapshot.copyWith(
        lifecycle: ChatRunLifecycle.stopping,
        clearError: true,
      );
      notifyListeners();
      await _finalizeRun(runId, ProviderTerminalType.cancelled);
      return _snapshot.lifecycle;
    }

    final isPreflight =
        _snapshot.lifecycle == ChatRunLifecycle.submitting ||
        _snapshot.lifecycle == ChatRunLifecycle.connecting;
    if (isPreflight) {
      _preflightCancellationRuns.add(runId);
    }

    _snapshot = _snapshot.copyWith(
      lifecycle: ChatRunLifecycle.stopping,
      clearError: true,
    );
    notifyListeners();

    if (!isPreflight) {
      final agentCancellationToken = _agentCancellationToken;
      if (agentCancellationToken != null) {
        agentCancellationToken.cancel();
      } else {
        final result = await provider.cancelRequest();
        if (!result.accepted) {
          if (_isActiveRun(runId)) {
            _snapshot = _snapshot.copyWith(
              lifecycle: ChatRunLifecycle.active,
              error: 'provider_cancellation_not_supported',
            );
            notifyListeners();
          }
          return _snapshot.lifecycle;
        }
      }
    }

    try {
      return await _terminalCompleter!.future.timeout(timeout);
    } on TimeoutException {
      if (_isActiveRun(runId) &&
          _snapshot.lifecycle == ChatRunLifecycle.stopping &&
          !isPreflight) {
        _snapshot = _snapshot.copyWith(
          lifecycle: ChatRunLifecycle.active,
          error: 'provider_cancellation_timeout',
        );
        notifyListeners();
      }
      return _snapshot.lifecycle;
    }
  }

  Future<bool> stopForNavigation() async {
    if (!hasBlockingRun) return true;
    if (!_snapshot.supportsCancellation) return false;
    final result = await cancel();
    return result.isTerminal;
  }

  void acknowledgeTerminal() {
    if (!_snapshot.lifecycle.isTerminal) return;
    _snapshot = _snapshot.copyWith(
      lifecycle: ChatRunLifecycle.idle,
      clearRunId: true,
      clearTurnId: true,
      streamingResponse: '',
      reasoningResponse: '',
      toolCalls: const [],
      commandExecutions: const [],
      skillActivations: const [],
      clearPendingToolApproval: true,
      tokenUsage: ModelTokenUsage.empty,
      supportsCancellation: false,
      userPersisted: false,
      clearSubmittedUserMessage: true,
      clearError: true,
      clearTerminalMessage: true,
    );
    notifyListeners();
  }

  void _notifyView() => notifyListeners();

  @override
  Future<ToolApprovalDecision> requestApproval(
    ToolApprovalRequest request,
    AgentCancellationToken cancellationToken,
  ) async {
    if (!_isActiveRun(request.runId) || cancellationToken.isCancelled) {
      return ToolApprovalDecision.deny;
    }
    final previous = _toolApprovalCompleter;
    if (previous != null && !previous.isCompleted) {
      previous.complete(ToolApprovalDecision.deny);
    }
    final completer = Completer<ToolApprovalDecision>();
    _toolApprovalCompleter = completer;
    _snapshot = _snapshot.copyWith(pendingToolApproval: request);
    notifyListeners();
    try {
      return await Future.any<ToolApprovalDecision>([
        completer.future,
        cancellationToken.whenCancelled.then((_) => ToolApprovalDecision.deny),
      ]);
    } finally {
      if (identical(_toolApprovalCompleter, completer)) {
        _toolApprovalCompleter = null;
        if (_isActiveRun(request.runId)) {
          _snapshot = _snapshot.copyWith(clearPendingToolApproval: true);
          notifyListeners();
        }
      }
    }
  }

  void resolveToolApproval(ToolApprovalDecision decision) {
    final completer = _toolApprovalCompleter;
    if (completer == null || completer.isCompleted) return;
    completer.complete(decision);
  }

  void _onProviderTerminal(String runId, ProviderTerminalEvent event) {
    if (!_isActiveRun(runId) || _finalizingRuns.contains(runId)) return;
    final rawError = event.error;
    final error =
        rawError == null
            ? null
            : AppFailure.from(
              rawError,
              code: 'provider_generation_failed',
            ).code;
    unawaited(_finalizeRun(runId, event.type, error: error));
  }

  Future<void> _finalizeRun(
    String runId,
    ProviderTerminalType providerTerminal, {
    String? error,
  }) async {
    if (!_isActiveRun(runId) ||
        _snapshot.lifecycle.isTerminal ||
        !_finalizingRuns.add(runId)) {
      return;
    }

    _partialPersistenceTimer?.cancel();
    _partialPersistenceTimer = null;
    await _partialPersistenceQueue;

    var lifecycle = switch (providerTerminal) {
      ProviderTerminalType.completed => ChatRunLifecycle.completed,
      ProviderTerminalType.cancelled => ChatRunLifecycle.cancelled,
      ProviderTerminalType.failed => ChatRunLifecycle.failed,
    };
    final hasGeneratedContent =
        _snapshot.streamingResponse.isNotEmpty ||
        _snapshot.reasoningResponse.isNotEmpty ||
        _snapshot.toolCalls.isNotEmpty ||
        _snapshot.commandExecutions.isNotEmpty ||
        _snapshot.skillActivations.isNotEmpty;
    if (lifecycle == ChatRunLifecycle.completed && !hasGeneratedContent) {
      lifecycle = ChatRunLifecycle.emptyResponse;
    }

    Message? terminalMessage;
    if (hasGeneratedContent || lifecycle == ChatRunLifecycle.emptyResponse) {
      final outcome = switch (lifecycle) {
        ChatRunLifecycle.completed => MessageTerminalOutcome.completed,
        ChatRunLifecycle.cancelled => MessageTerminalOutcome.cancelled,
        ChatRunLifecycle.failed => MessageTerminalOutcome.failed,
        ChatRunLifecycle.emptyResponse => MessageTerminalOutcome.emptyResponse,
        _ => throw StateError('A terminal run must have a terminal outcome.'),
      };
      final duration =
          _startedAt == null
              ? null
              : DateTime.now().difference(_startedAt!).inMilliseconds;
      final terminalDraft = Message(
        messageId: '$runId:assistant',
        turnId: _snapshot.turnId ?? runId,
        runId: runId,
        chatId: chatId,
        botId: _bot.id,
        senderId: _bot.id,
        content: _snapshot.streamingResponse,
        reasoning: _snapshot.reasoningResponse,
        processInfo: MessageProcessInfo(
          reasoningStatus:
              _snapshot.reasoningResponse.isEmpty ? '' : outcome.name,
          durationMs: duration,
          toolCalls: List<MessageToolCall>.of(_snapshot.toolCalls),
          commandExecutions: List<MessageCommandExecution>.of(
            _snapshot.commandExecutions,
          ),
          skillActivations: List<MessageSkillActivation>.of(
            _snapshot.skillActivations,
          ),
        ),
        tokenUsage: _snapshot.tokenUsage,
        terminalOutcome: outcome,
        hasPartialContent:
            hasGeneratedContent &&
            (lifecycle == ChatRunLifecycle.cancelled ||
                lifecycle == ChatRunLifecycle.failed),
        timestamp: DateTime.now(),
      );
      var terminalPersisted = false;
      try {
        terminalMessage = await _messagePersister(terminalDraft);
        terminalPersisted = true;
      } catch (persistenceError) {
        lifecycle = ChatRunLifecycle.failed;
        error =
            AppFailure.from(
              persistenceError,
              code: 'generation_response_persist_failed',
            ).code;
        terminalMessage = terminalDraft.copyWith(
          terminalOutcome: MessageTerminalOutcome.failed,
          hasPartialContent: hasGeneratedContent,
        );
      }
      if (terminalPersisted && terminalMessage.content.isNotEmpty) {
        try {
          await _lastMessageUpdater(chatId, terminalMessage.content);
        } catch (lastMessageError) {
          debugPrint(
            'Failed to update chat preview for $chatId: $lastMessageError',
          );
        }
      }
      final observer = _terminalMessageObserver;
      if (terminalPersisted && observer != null) {
        unawaited(
          observer(
            chatId,
            _bot,
            terminalMessage,
            _contextAssemblyReport,
          ).catchError((Object observerError, StackTrace stackTrace) {
            debugPrint(
              'Failed to run terminal conversation observer: $observerError',
            );
          }),
        );
      }
    }

    if (!_isActiveRun(runId)) {
      _finalizingRuns.remove(runId);
      return;
    }
    _snapshot = _snapshot.copyWith(
      lifecycle: lifecycle,
      error: error,
      clearError: error == null,
      terminalMessage: terminalMessage,
    );
    _runProvider = null;
    _agentCancellationToken = null;
    final approvalCompleter = _toolApprovalCompleter;
    if (approvalCompleter != null && !approvalCompleter.isCompleted) {
      approvalCompleter.complete(ToolApprovalDecision.deny);
    }
    _toolApprovalCompleter = null;
    _snapshot = _snapshot.copyWith(clearPendingToolApproval: true);
    _completeTerminal(lifecycle);
    _applyPendingBot();
    _finalizingRuns.remove(runId);
    notifyListeners();
  }

  void _completeTerminal(ChatRunLifecycle lifecycle) {
    final completer = _terminalCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(lifecycle);
    }
  }

  void _applyPendingBot() {
    final bot = _pendingBot;
    if (bot == null) return;
    _pendingBot = null;
    _replaceCapabilityProvider(bot);
  }

  void _replaceCapabilityProvider(Bot bot) {
    _bot = bot;
    _capabilityProvider = _providerFactory(bot);
  }

  @override
  void dispose() {
    _partialPersistenceTimer?.cancel();
    _partialPersistenceTimer = null;
    super.dispose();
  }
}
