import 'dart:async';
import 'dart:convert';

import 'package:hyve/domain/models/ai_models.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/ai_provider_repository.dart';

final class AgentRunLimits {
  const AgentRunLimits({
    this.maxModelTurns = 6,
    this.maxToolCalls = 12,
    this.maxSameCallRetries = 1,
    this.totalTimeout = const Duration(minutes: 3),
    this.toolTimeout = const Duration(seconds: 30),
    this.approvalTimeout = const Duration(minutes: 2),
    this.maxToolOutputCharacters = 16000,
  }) : assert(maxModelTurns > 0),
       assert(maxToolCalls > 0),
       assert(maxSameCallRetries >= 0),
       assert(maxToolOutputCharacters > 0);

  final int maxModelTurns;
  final int maxToolCalls;
  final int maxSameCallRetries;
  final Duration totalTimeout;
  final Duration toolTimeout;
  final Duration approvalTimeout;
  final int maxToolOutputCharacters;
}

final class AgentRunRequest {
  AgentRunRequest({
    required this.runId,
    required this.chatId,
    required this.botId,
    required List<ChatMessage> messages,
    required Set<String> requestedToolNames,
    Set<String> approvalExemptToolNames = const {},
    AgentCancellationToken? cancellationToken,
  }) : messages = List<ChatMessage>.unmodifiable(messages),
       requestedToolNames = Set<String>.unmodifiable(requestedToolNames),
       approvalExemptToolNames = Set<String>.unmodifiable(
         approvalExemptToolNames,
       ),
       cancellationToken = cancellationToken ?? AgentCancellationToken();

  final String runId;
  final String chatId;
  final String botId;
  final List<ChatMessage> messages;
  final Set<String> requestedToolNames;
  final Set<String> approvalExemptToolNames;
  final AgentCancellationToken cancellationToken;
}

enum RunResultStatus { completed, cancelled, failed, timedOut, limitExceeded }

final class AgentRunResult {
  AgentRunResult({
    required this.status,
    required this.text,
    required this.reasoning,
    required this.tokenUsage,
    required List<ToolInvocationRecord> toolInvocations,
    this.error = '',
  }) : toolInvocations = List<ToolInvocationRecord>.unmodifiable(
         toolInvocations,
       );

  final RunResultStatus status;
  final String text;
  final String reasoning;
  final ModelTokenUsage tokenUsage;
  final List<ToolInvocationRecord> toolInvocations;
  final String error;
}

typedef ModelEventObserver = void Function(ModelEvent event);
typedef ToolInvocationObserver = void Function(ToolInvocationRecord invocation);

final class AgentRunCoordinator {
  const AgentRunCoordinator({
    required ToolRegistry toolRegistry,
    required ToolPolicy toolPolicy,
    ToolApprovalHandler approvalHandler = const DenyToolApprovalHandler(),
    JsonSchemaValidator schemaValidator = const JsonSchemaValidator(),
    AgentRunLimits limits = const AgentRunLimits(),
  }) : _toolRegistry = toolRegistry,
       _toolPolicy = toolPolicy,
       _approvalHandler = approvalHandler,
       _schemaValidator = schemaValidator,
       _limits = limits;

  final ToolRegistry _toolRegistry;
  final ToolPolicy _toolPolicy;
  final ToolApprovalHandler _approvalHandler;
  final JsonSchemaValidator _schemaValidator;
  final AgentRunLimits _limits;

  Future<AgentRunResult> run({
    required AiProvider provider,
    required AgentRunRequest request,
    ModelEventObserver? onModelEvent,
    ToolInvocationObserver? onToolInvocation,
  }) async {
    final exposedTools =
        request.requestedToolNames.isEmpty
            ? const <ToolDefinition>[]
            : _toolRegistry.list(allowedNames: request.requestedToolNames);
    final exposedNames = exposedTools.map((tool) => tool.name).toSet();
    final policyContext = ToolPolicyContext(
      runId: request.runId,
      chatId: request.chatId,
      botId: request.botId,
      requestedToolNames: request.requestedToolNames,
      approvalExemptToolNames: request.approvalExemptToolNames,
    );
    final supportsParallelToolCalls =
        provider.capabilities.supportsParallelToolCalls;
    final invocations = <ToolInvocationRecord>[];
    final invocationIndexes = <String, int>{};
    final completedCalls = <String, _CompletedCall>{};
    final callAttempts = <String, int>{};
    var text = '';
    var reasoning = '';
    var usage = ModelTokenUsage.empty;
    var timedOut = false;
    var toolCallCount = 0;
    AgentModelSession? session;
    final timeoutTimer = Timer(_limits.totalTimeout, () {
      timedOut = true;
      request.cancellationToken.cancel();
    });

    void observeInvocation(ToolInvocationRecord invocation) {
      final existingIndex = invocationIndexes[invocation.callId];
      if (existingIndex == null) {
        invocationIndexes[invocation.callId] = invocations.length;
        invocations.add(invocation);
      } else {
        invocations[existingIndex] = invocation;
      }
      onToolInvocation?.call(invocation);
    }

    try {
      request.cancellationToken.throwIfCancelled();
      session = provider.openModelSession(
        ModelRequest(
          messages: request.messages,
          tools: exposedTools,
          options: ModelGenerationOptions(
            allowParallelToolCalls:
                provider.capabilities.supportsParallelToolCalls,
            webSearch: provider.getWebSearch(),
            deepThinking: provider.getDeepThinking(),
          ),
        ),
      );
      final activeSession = session;
      unawaited(
        request.cancellationToken.whenCancelled.then((_) async {
          await activeSession.cancel();
        }),
      );

      var results = const <ToolResult>[];
      for (
        var modelTurn = 0;
        modelTurn < _limits.maxModelTurns;
        modelTurn += 1
      ) {
        request.cancellationToken.throwIfCancelled();
        final calls = <ToolCallRequested>[];
        final events =
            modelTurn == 0
                ? activeSession.start()
                : activeSession.continueWith(results);
        await _consumeEvents(events, request.cancellationToken, (event) {
          onModelEvent?.call(event);
          switch (event) {
            case TextDelta():
              text += event.text;
            case ReasoningDelta():
              reasoning += event.text;
            case ToolCallRequested():
              calls.add(event);
            case UsageReported():
              usage = usage + event.usage;
            case ModelTurnFailed():
              throw _AgentModelFailure(event.error, event.code);
            case ToolCallStarted():
            case ToolCallArgumentsDelta():
            case ModelTurnCompleted():
              break;
          }
        });

        if (calls.isEmpty) {
          return AgentRunResult(
            status: RunResultStatus.completed,
            text: text,
            reasoning: reasoning,
            tokenUsage: usage,
            toolInvocations: invocations,
          );
        }
        if (calls.any(
          (call) => call.callId.trim().isEmpty || call.name.trim().isEmpty,
        )) {
          return AgentRunResult(
            status: RunResultStatus.failed,
            text: text,
            reasoning: reasoning,
            tokenUsage: usage,
            toolInvocations: invocations,
            error: 'invalid_provider_tool_call',
          );
        }
        if (modelTurn + 1 >= _limits.maxModelTurns) {
          return AgentRunResult(
            status: RunResultStatus.limitExceeded,
            text: text,
            reasoning: reasoning,
            tokenUsage: usage,
            toolInvocations: invocations,
            error: 'model_turn_limit_reached',
          );
        }

        if (toolCallCount + calls.length > _limits.maxToolCalls) {
          return AgentRunResult(
            status: RunResultStatus.limitExceeded,
            text: text,
            reasoning: reasoning,
            tokenUsage: usage,
            toolInvocations: invocations,
            error: 'tool_call_limit_reached',
          );
        }
        toolCallCount += calls.length;
        final callRequests =
            calls.map((event) => event.toToolCallRequest()).toList();
        final canRunInParallel =
            supportsParallelToolCalls &&
            callRequests.length > 1 &&
            callRequests.map((call) => call.callId).toSet().length ==
                callRequests.length &&
            callRequests.every(_isParallelSafe);
        final nextResults =
            canRunInParallel
                ? await Future.wait([
                  for (final call in callRequests)
                    _executeToolCall(
                      call: call,
                      runId: request.runId,
                      exposedNames: exposedNames,
                      policyContext: policyContext,
                      cancellationToken: request.cancellationToken,
                      completedCalls: completedCalls,
                      callAttempts: callAttempts,
                      observeInvocation: observeInvocation,
                    ),
                ])
                : await _executeSequentially(
                  calls: callRequests,
                  runId: request.runId,
                  exposedNames: exposedNames,
                  policyContext: policyContext,
                  cancellationToken: request.cancellationToken,
                  completedCalls: completedCalls,
                  callAttempts: callAttempts,
                  observeInvocation: observeInvocation,
                );
        results = List<ToolResult>.unmodifiable(nextResults);
      }

      return AgentRunResult(
        status: RunResultStatus.limitExceeded,
        text: text,
        reasoning: reasoning,
        tokenUsage: usage,
        toolInvocations: invocations,
        error: 'model_turn_limit_reached',
      );
    } on AgentRunCancelledException {
      return AgentRunResult(
        status: timedOut ? RunResultStatus.timedOut : RunResultStatus.cancelled,
        text: text,
        reasoning: reasoning,
        tokenUsage: usage,
        toolInvocations: invocations,
        error: timedOut ? 'agent_run_timeout' : '',
      );
    } on _AgentModelFailure catch (error) {
      return AgentRunResult(
        status: RunResultStatus.failed,
        text: text,
        reasoning: reasoning,
        tokenUsage: usage,
        toolInvocations: invocations,
        error:
            error.code.isEmpty
                ? AppFailure.from(
                  error.message,
                  code: 'agent_model_failed',
                ).code
                : error.code,
      );
    } catch (error) {
      return AgentRunResult(
        status: RunResultStatus.failed,
        text: text,
        reasoning: reasoning,
        tokenUsage: usage,
        toolInvocations: invocations,
        error: AppFailure.from(error, code: 'agent_run_failed').code,
      );
    } finally {
      timeoutTimer.cancel();
      session?.close();
    }
  }

  Future<List<ToolResult>> _executeSequentially({
    required List<ToolCallRequest> calls,
    required String runId,
    required Set<String> exposedNames,
    required ToolPolicyContext policyContext,
    required AgentCancellationToken cancellationToken,
    required Map<String, _CompletedCall> completedCalls,
    required Map<String, int> callAttempts,
    required void Function(ToolInvocationRecord) observeInvocation,
  }) async {
    final results = <ToolResult>[];
    for (final call in calls) {
      cancellationToken.throwIfCancelled();
      results.add(
        await _executeToolCall(
          call: call,
          runId: runId,
          exposedNames: exposedNames,
          policyContext: policyContext,
          cancellationToken: cancellationToken,
          completedCalls: completedCalls,
          callAttempts: callAttempts,
          observeInvocation: observeInvocation,
        ),
      );
    }
    return results;
  }

  bool _isParallelSafe(ToolCallRequest call) {
    final definition = _toolRegistry.find(call.name)?.definition;
    if (definition == null || definition.riskLevel != ToolRiskLevel.readOnly) {
      return false;
    }
    return definition.capabilities.isNotEmpty &&
        definition.capabilities.every(
          (capability) => capability == ToolCapability.compute,
        );
  }

  Future<ToolResult> _executeToolCall({
    required ToolCallRequest call,
    required String runId,
    required Set<String> exposedNames,
    required ToolPolicyContext policyContext,
    required AgentCancellationToken cancellationToken,
    required Map<String, _CompletedCall> completedCalls,
    required Map<String, int> callAttempts,
    required void Function(ToolInvocationRecord) observeInvocation,
  }) async {
    final fingerprint = _fingerprint(call);
    final attempts = (callAttempts[call.callId] ?? 0) + 1;
    callAttempts[call.callId] = attempts;
    if (attempts > _limits.maxSameCallRetries + 1) {
      return ToolResult(
        callId: call.callId,
        name: call.name,
        content: 'The tool retry limit was reached.',
        isError: true,
        errorCode: 'tool_retry_limit_reached',
      );
    }
    final previous = completedCalls[call.callId];
    if (previous != null) {
      final definition = _toolRegistry.find(call.name)?.definition;
      final now = DateTime.now();
      observeInvocation(
        ToolInvocationRecord(
          callId: call.callId,
          name: call.name,
          title: definition?.title ?? '',
          mcpServerName: definition?.mcpServerName ?? '',
          source: definition?.source ?? ToolSource.builtIn,
          riskLevel: definition?.riskLevel ?? ToolRiskLevel.readOnly,
          status: ToolInvocationStatus.duplicate,
          arguments: call.arguments,
          resultSummary:
              previous.fingerprint == fingerprint
                  ? 'duplicate_call_reused'
                  : 'duplicate_call_id_conflict',
          errorCode:
              previous.fingerprint == fingerprint
                  ? ''
                  : 'duplicate_call_id_conflict',
          startedAt: now,
          completedAt: now,
          durationMs: 0,
        ),
      );
      if (previous.fingerprint == fingerprint) return previous.result;
      return ToolResult(
        callId: call.callId,
        name: call.name,
        content: 'The call id was already used with different arguments.',
        isError: true,
        errorCode: 'duplicate_call_id_conflict',
      );
    }

    final tool = _toolRegistry.find(call.name);
    if (tool == null || !exposedNames.contains(call.name)) {
      final now = DateTime.now();
      final result = ToolResult(
        callId: call.callId,
        name: call.name,
        content: 'The requested tool is not available for this run.',
        isError: true,
        errorCode: 'tool_not_available',
      );
      observeInvocation(
        ToolInvocationRecord(
          callId: call.callId,
          name: call.name,
          title: tool?.definition.title ?? '',
          mcpServerName: tool?.definition.mcpServerName ?? '',
          source: tool?.definition.source ?? ToolSource.builtIn,
          riskLevel: tool?.definition.riskLevel ?? ToolRiskLevel.readOnly,
          status: ToolInvocationStatus.denied,
          arguments: call.arguments,
          resultSummary: result.content,
          errorCode: result.errorCode,
          startedAt: now,
          completedAt: now,
          durationMs: 0,
        ),
      );
      completedCalls[call.callId] = _CompletedCall(fingerprint, result);
      return result;
    }
    final definition = tool.definition;
    final startedAt = DateTime.now();
    var record = ToolInvocationRecord(
      callId: call.callId,
      name: call.name,
      title: definition.title,
      mcpServerName: definition.mcpServerName,
      source: definition.source,
      riskLevel: definition.riskLevel,
      status: ToolInvocationStatus.requested,
      arguments: call.arguments,
      startedAt: startedAt,
    );
    observeInvocation(record);

    final inputIssues = _schemaValidator.validate(
      call.arguments,
      definition.inputSchema,
    );
    if (inputIssues.isNotEmpty) {
      final result = ToolResult(
        callId: call.callId,
        name: call.name,
        content: 'Tool arguments failed schema validation.',
        isError: true,
        errorCode: 'invalid_tool_arguments',
      );
      record = _completeRecord(
        record,
        status: ToolInvocationStatus.failed,
        errorCode: result.errorCode,
        resultSummary: _issuesSummary(inputIssues),
      );
      observeInvocation(record);
      completedCalls[call.callId] = _CompletedCall(fingerprint, result);
      return result;
    }

    final policyDecision = _toolPolicy.evaluate(
      definition,
      call,
      policyContext,
    );
    if (policyDecision.outcome == ToolPolicyOutcome.deny) {
      final result = ToolResult(
        callId: call.callId,
        name: call.name,
        content: 'The tool call was blocked by application policy.',
        isError: true,
        errorCode:
            policyDecision.reason.isEmpty
                ? 'tool_policy_denied'
                : policyDecision.reason,
      );
      record = _completeRecord(
        record,
        status: ToolInvocationStatus.denied,
        errorCode: result.errorCode,
        resultSummary: policyDecision.reason,
        approvalDecision: ToolApprovalDecision.deny.name,
      );
      observeInvocation(record);
      completedCalls[call.callId] = _CompletedCall(fingerprint, result);
      return result;
    }

    if (policyDecision.outcome == ToolPolicyOutcome.requireApproval) {
      record = record.copyWith(status: ToolInvocationStatus.awaitingApproval);
      observeInvocation(record);
      ToolApprovalDecision approval;
      try {
        approval = await _raceCancellation(
          _approvalHandler
              .requestApproval(
                ToolApprovalRequest(
                  runId: runId,
                  call: call,
                  definition: definition,
                  reason: policyDecision.reason,
                ),
                cancellationToken,
              )
              .timeout(_limits.approvalTimeout),
          cancellationToken,
        );
      } on AgentRunCancelledException {
        record = _completeRecord(
          record,
          status: ToolInvocationStatus.cancelled,
          errorCode: 'agent_run_cancelled',
          approvalDecision: ToolApprovalDecision.deny.name,
        );
        observeInvocation(record);
        rethrow;
      } on TimeoutException {
        final result = ToolResult(
          callId: call.callId,
          name: call.name,
          content: 'Tool approval timed out.',
          isError: true,
          errorCode: 'tool_approval_timeout',
        );
        record = _completeRecord(
          record,
          status: ToolInvocationStatus.timedOut,
          errorCode: result.errorCode,
          approvalDecision: ToolApprovalDecision.deny.name,
        );
        observeInvocation(record);
        completedCalls[call.callId] = _CompletedCall(fingerprint, result);
        return result;
      }
      if (approval != ToolApprovalDecision.allowOnce) {
        final result = ToolResult(
          callId: call.callId,
          name: call.name,
          content: 'The user denied the tool call.',
          isError: true,
          errorCode: 'tool_approval_denied',
        );
        record = _completeRecord(
          record,
          status: ToolInvocationStatus.denied,
          errorCode: result.errorCode,
          approvalDecision: approval.name,
        );
        observeInvocation(record);
        completedCalls[call.callId] = _CompletedCall(fingerprint, result);
        return result;
      }
      record = record.copyWith(approvalDecision: approval.name);
    }

    cancellationToken.throwIfCancelled();
    record = record.copyWith(status: ToolInvocationStatus.running);
    observeInvocation(record);
    ToolResult result;
    try {
      result = await _raceCancellation(
        tool.execute(call, cancellationToken).timeout(_limits.toolTimeout),
        cancellationToken,
      );
    } on TimeoutException {
      result = ToolResult(
        callId: call.callId,
        name: call.name,
        content: 'Tool execution timed out.',
        isError: true,
        errorCode: 'tool_execution_timeout',
      );
      record = _completeRecord(
        record,
        status: ToolInvocationStatus.timedOut,
        errorCode: result.errorCode,
      );
      observeInvocation(record);
      completedCalls[call.callId] = _CompletedCall(fingerprint, result);
      return result;
    } on AgentRunCancelledException {
      record = _completeRecord(
        record,
        status: ToolInvocationStatus.cancelled,
        errorCode: 'agent_run_cancelled',
      );
      observeInvocation(record);
      rethrow;
    } catch (_) {
      result = ToolResult(
        callId: call.callId,
        name: call.name,
        content: 'Tool execution failed.',
        isError: true,
        errorCode: 'tool_execution_failed',
      );
    }

    if (!result.isError && definition.outputSchema != null) {
      final structuredContent = result.structuredContent;
      if (structuredContent == null) {
        result = ToolResult(
          callId: call.callId,
          name: call.name,
          content: 'Tool output failed schema validation.',
          isError: true,
          errorCode: 'invalid_tool_output',
        );
      } else {
        final outputIssues = _schemaValidator.validate(
          structuredContent,
          definition.outputSchema!,
        );
        if (outputIssues.isNotEmpty) {
          result = ToolResult(
            callId: call.callId,
            name: call.name,
            content: 'Tool output failed schema validation.',
            isError: true,
            errorCode: 'invalid_tool_output',
          );
        }
      }
    }
    result = _truncateResult(result);
    record = _completeRecord(
      record,
      status:
          result.isError
              ? ToolInvocationStatus.failed
              : ToolInvocationStatus.succeeded,
      errorCode: result.errorCode,
      resultSummary: _auditResultSummary(definition, result),
    );
    observeInvocation(record);
    completedCalls[call.callId] = _CompletedCall(fingerprint, result);
    return result;
  }

  Future<void> _consumeEvents(
    Stream<ModelEvent> events,
    AgentCancellationToken cancellationToken,
    void Function(ModelEvent event) consume,
  ) async {
    final iterator = StreamIterator<ModelEvent>(events);
    try {
      while (await _raceCancellation(iterator.moveNext(), cancellationToken)) {
        consume(iterator.current);
      }
    } finally {
      await iterator.cancel();
    }
  }

  Future<T> _raceCancellation<T>(
    Future<T> operation,
    AgentCancellationToken cancellationToken,
  ) {
    cancellationToken.throwIfCancelled();
    return Future.any<T>([
      operation,
      cancellationToken.whenCancelled.then<T>(
        (_) => throw const AgentRunCancelledException(),
      ),
    ]);
  }

  ToolInvocationRecord _completeRecord(
    ToolInvocationRecord record, {
    required ToolInvocationStatus status,
    String resultSummary = '',
    String errorCode = '',
    String approvalDecision = '',
  }) {
    final completedAt = DateTime.now();
    return record.copyWith(
      status: status,
      resultSummary: _truncate(resultSummary, 512),
      errorCode: errorCode,
      approvalDecision:
          approvalDecision.isEmpty ? record.approvalDecision : approvalDecision,
      completedAt: completedAt,
      durationMs: completedAt.difference(record.startedAt).inMilliseconds,
    );
  }

  ToolResult _truncateResult(ToolResult result) {
    if (result.content.runes.length <= _limits.maxToolOutputCharacters) {
      return result;
    }
    const suffix = '\n[tool output truncated]';
    final retained = _limits.maxToolOutputCharacters - suffix.runes.length;
    return result.copyWith(
      content:
          '${String.fromCharCodes(result.content.runes.take(retained))}$suffix',
      clearStructuredContent: true,
    );
  }

  String _issuesSummary(List<JsonSchemaValidationIssue> issues) {
    return issues
        .take(3)
        .map((issue) => '${issue.path}:${issue.code}')
        .join(', ');
  }

  String _auditResultSummary(ToolDefinition definition, ToolResult result) {
    if (result.isError) {
      return result.errorCode.isEmpty ? 'tool_error' : result.errorCode;
    }
    if (conversationHistoryToolNames.contains(definition.name) &&
        result.structuredContent is Map) {
      final structured = result.structuredContent! as Map;
      return jsonEncode({
        'count': structured['count'],
        'truncated': structured['truncated'],
        'message_ids': structured['message_ids'],
      });
    }
    final isPureBuiltIn =
        definition.source == ToolSource.builtIn &&
        definition.capabilities.every(
          (capability) => capability == ToolCapability.compute,
        );
    return isPureBuiltIn ? result.content : 'completed';
  }

  String _fingerprint(ToolCallRequest call) {
    return '${call.name}:${_canonicalJson(call.arguments)}';
  }

  String _canonicalJson(Object? value) {
    if (value is Map) {
      final entries =
          value.entries.toList()
            ..sort((left, right) => '${left.key}'.compareTo('${right.key}'));
      return '{${entries.map((entry) => '${jsonEncode(entry.key.toString())}:${_canonicalJson(entry.value)}').join(',')}}';
    }
    if (value is List) {
      return '[${value.map(_canonicalJson).join(',')}]';
    }
    return jsonEncode(value);
  }

  String _truncate(String value, int maxCharacters) {
    if (value.runes.length <= maxCharacters) return value;
    return '${String.fromCharCodes(value.runes.take(maxCharacters - 1))}…';
  }
}

final class _CompletedCall {
  const _CompletedCall(this.fingerprint, this.result);

  final String fingerprint;
  final ToolResult result;
}

final class _AgentModelFailure implements Exception {
  const _AgentModelFailure(this.message, this.code);

  final String message;
  final String code;
}
