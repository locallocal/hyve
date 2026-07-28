import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:stars/domain/models/ai_models.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/ai_provider_repository.dart';
import 'package:stars/domain/use_cases/agent_run_coordinator.dart';

void main() {
  group('AgentRunCoordinator', () {
    test('runs model, tool, and final model turn', () async {
      final tool = _FakeTool(name: 'calculate');
      final session = _FakeModelSession([
        [
          const TextDelta('Checking. '),
          const ToolCallStarted(callId: 'call-1', name: 'calculate'),
          ToolCallRequested(
            callId: 'call-1',
            name: 'calculate',
            arguments: const {'value': 2},
          ),
          const UsageReported(
            ModelTokenUsage(
              model: 'test',
              inputTokens: 10,
              outputTokens: 2,
              totalTokens: 12,
            ),
          ),
          const ModelTurnCompleted(stopReason: 'tool_calls'),
        ],
        [
          const TextDelta('The answer is 4.'),
          const UsageReported(
            ModelTokenUsage(
              model: 'test',
              inputTokens: 15,
              outputTokens: 5,
              totalTokens: 20,
            ),
          ),
          const ModelTurnCompleted(stopReason: 'stop'),
        ],
      ]);
      final coordinator = AgentRunCoordinator(
        toolRegistry: StaticToolRegistry([tool]),
        toolPolicy: const DefaultToolPolicy(),
      );
      final events = <ModelEvent>[];
      final records = <ToolInvocationRecord>[];

      final result = await coordinator.run(
        provider: _FakeProvider(session),
        request: _request(toolNames: {'calculate'}),
        onModelEvent: events.add,
        onToolInvocation: records.add,
      );

      expect(result.status, AgentRunStatus.completed);
      expect(result.text, 'Checking. The answer is 4.');
      expect(result.tokenUsage.inputTokens, 25);
      expect(result.tokenUsage.outputTokens, 7);
      expect(tool.executions, 1);
      expect(session.continuations, hasLength(1));
      expect(session.continuations.single.single.content, '4');
      expect(records.last.status, ToolInvocationStatus.succeeded);
      expect(
        result.toolInvocations.single.status,
        ToolInvocationStatus.succeeded,
      );
      expect(events.whereType<ToolCallRequested>(), hasLength(1));
    });

    test('returns schema error to model without executing tool', () async {
      final tool = _FakeTool(name: 'calculate');
      final session = _FakeModelSession([
        [
          ToolCallRequested(
            callId: 'invalid-1',
            name: 'calculate',
            arguments: const {'value': 'not-a-number'},
          ),
          const ModelTurnCompleted(stopReason: 'tool_calls'),
        ],
        [
          const TextDelta('I could not calculate that.'),
          const ModelTurnCompleted(stopReason: 'stop'),
        ],
      ]);
      final coordinator = AgentRunCoordinator(
        toolRegistry: StaticToolRegistry([tool]),
        toolPolicy: const DefaultToolPolicy(),
      );

      final result = await coordinator.run(
        provider: _FakeProvider(session),
        request: _request(toolNames: {'calculate'}),
      );

      expect(result.status, AgentRunStatus.completed);
      expect(tool.executions, 0);
      final returned = session.continuations.single.single;
      expect(returned.isError, isTrue);
      expect(returned.errorCode, 'invalid_tool_arguments');
      expect(result.toolInvocations.single.status, ToolInvocationStatus.failed);
    });

    test('reuses duplicate call id without repeating side effects', () async {
      final tool = _FakeTool(name: 'calculate');
      final repeated = ToolCallRequested(
        callId: 'same-call',
        name: 'calculate',
        arguments: const {'value': 2},
      );
      final session = _FakeModelSession([
        [
          repeated,
          repeated,
          const ModelTurnCompleted(stopReason: 'tool_calls'),
        ],
        [const TextDelta('done'), const ModelTurnCompleted(stopReason: 'stop')],
      ]);
      final coordinator = AgentRunCoordinator(
        toolRegistry: StaticToolRegistry([tool]),
        toolPolicy: const DefaultToolPolicy(),
      );

      final result = await coordinator.run(
        provider: _FakeProvider(session),
        request: _request(toolNames: {'calculate'}),
      );

      expect(result.status, AgentRunStatus.completed);
      expect(tool.executions, 1);
      expect(session.continuations.single, hasLength(2));
      expect(
        result.toolInvocations.single.status,
        ToolInvocationStatus.duplicate,
      );
    });

    test('runs independent pure computation calls in parallel', () async {
      final tool = _ParallelTool();
      final session = _FakeModelSession([
        [
          ToolCallRequested(
            callId: 'parallel-1',
            name: 'parallel_compute',
            arguments: const {'value': 1},
          ),
          ToolCallRequested(
            callId: 'parallel-2',
            name: 'parallel_compute',
            arguments: const {'value': 2},
          ),
          const ModelTurnCompleted(stopReason: 'tool_calls'),
        ],
        [
          const TextDelta('both done'),
          const ModelTurnCompleted(stopReason: 'stop'),
        ],
      ]);
      final coordinator = AgentRunCoordinator(
        toolRegistry: StaticToolRegistry([tool]),
        toolPolicy: const DefaultToolPolicy(),
        limits: const AgentRunLimits(toolTimeout: Duration(seconds: 1)),
      );

      final result = await coordinator.run(
        provider: _FakeProvider(session, supportsParallelToolCalls: true),
        request: _request(toolNames: {'parallel_compute'}),
      );

      expect(result.status, AgentRunStatus.completed);
      expect(tool.executions, 2);
      expect(session.continuations.single.map((item) => item.content), [
        '1',
        '2',
      ]);
    });

    test('requires approval for writes and records denial', () async {
      final tool = _FakeTool(
        name: 'save_note',
        riskLevel: ToolRiskLevel.write,
        capabilities: const {ToolCapability.localWrite},
      );
      final session = _FakeModelSession([
        [
          ToolCallRequested(
            callId: 'write-1',
            name: 'save_note',
            arguments: const {'value': 2},
          ),
          const ModelTurnCompleted(stopReason: 'tool_calls'),
        ],
        [
          const TextDelta('The write was denied.'),
          const ModelTurnCompleted(stopReason: 'stop'),
        ],
      ]);
      final coordinator = AgentRunCoordinator(
        toolRegistry: StaticToolRegistry([tool]),
        toolPolicy: const DefaultToolPolicy(),
        approvalHandler: const _FixedApprovalHandler(ToolApprovalDecision.deny),
      );

      final result = await coordinator.run(
        provider: _FakeProvider(session),
        request: _request(toolNames: {'save_note'}),
      );

      expect(tool.executions, 0);
      expect(
        session.continuations.single.single.errorCode,
        'tool_approval_denied',
      );
      expect(result.toolInvocations.single.status, ToolInvocationStatus.denied);
      expect(
        result.toolInvocations.single.approvalDecision,
        ToolApprovalDecision.deny.name,
      );
    });

    test('cancels approval wait and provider session', () async {
      final tool = _FakeTool(name: 'save_note', riskLevel: ToolRiskLevel.write);
      final session = _FakeModelSession([
        [
          ToolCallRequested(
            callId: 'write-1',
            name: 'save_note',
            arguments: const {'value': 2},
          ),
          const ModelTurnCompleted(stopReason: 'tool_calls'),
        ],
      ]);
      final approval = _PendingApprovalHandler();
      final token = AgentCancellationToken();
      final coordinator = AgentRunCoordinator(
        toolRegistry: StaticToolRegistry([tool]),
        toolPolicy: const DefaultToolPolicy(),
        approvalHandler: approval,
      );

      final run = coordinator.run(
        provider: _FakeProvider(session),
        request: _request(toolNames: {'save_note'}, cancellationToken: token),
      );
      await approval.requested.future;
      token.cancel();
      final result = await run;

      expect(result.status, AgentRunStatus.cancelled);
      expect(tool.executions, 0);
      expect(session.cancelled, isTrue);
      expect(
        result.toolInvocations.single.status,
        ToolInvocationStatus.cancelled,
      );
    });

    test('stops at configured tool call limit', () async {
      final tool = _FakeTool(name: 'calculate');
      final session = _FakeModelSession([
        [
          ToolCallRequested(
            callId: 'one',
            name: 'calculate',
            arguments: const {'value': 1},
          ),
          ToolCallRequested(
            callId: 'two',
            name: 'calculate',
            arguments: const {'value': 2},
          ),
          const ModelTurnCompleted(stopReason: 'tool_calls'),
        ],
      ]);
      final coordinator = AgentRunCoordinator(
        toolRegistry: StaticToolRegistry([tool]),
        toolPolicy: const DefaultToolPolicy(),
        limits: const AgentRunLimits(maxToolCalls: 1),
      );

      final result = await coordinator.run(
        provider: _FakeProvider(session),
        request: _request(toolNames: {'calculate'}),
      );

      expect(result.status, AgentRunStatus.limitExceeded);
      expect(result.error, 'tool_call_limit_reached');
      expect(tool.executions, 0);
      expect(session.continuations, isEmpty);
    });

    test('cancels a hanging provider at total run timeout', () async {
      final session = _HangingModelSession();
      final coordinator = AgentRunCoordinator(
        toolRegistry: StaticToolRegistry(const []),
        toolPolicy: const DefaultToolPolicy(),
        limits: const AgentRunLimits(totalTimeout: Duration(milliseconds: 20)),
      );

      final result = await coordinator.run(
        provider: _FakeProvider(session),
        request: _request(toolNames: const {}),
      );

      expect(result.status, AgentRunStatus.timedOut);
      expect(result.error, 'agent_run_timeout');
      expect(session.cancelled, isTrue);
    });
  });

  group('JsonSchemaValidator', () {
    test('validates required properties, types, and additional fields', () {
      const validator = JsonSchemaValidator();
      final issues = validator.validate(
        {'name': 3, 'extra': true},
        const {
          'type': 'object',
          'properties': {
            'name': {'type': 'string'},
            'count': {'type': 'integer'},
          },
          'required': ['name', 'count'],
          'additionalProperties': false,
        },
      );

      expect(
        issues.map((issue) => issue.code),
        containsAll(['required', 'type', 'additional_property']),
      );
    });

    test('fails closed for unsupported schema constraints', () {
      const validator = JsonSchemaValidator();

      final issues = validator.validate('value', const {
        'type': 'string',
        r'$ref': '#/definitions/value',
      });

      expect(
        issues.map((issue) => issue.code),
        contains('unsupported_schema_keyword'),
      );
    });
  });
}

AgentRunRequest _request({
  required Set<String> toolNames,
  AgentCancellationToken? cancellationToken,
}) {
  return AgentRunRequest(
    runId: 'run-1',
    chatId: 'chat-1',
    botId: 'bot-1',
    messages: [ChatMessage(role: 'user', content: 'help')],
    requestedToolNames: toolNames,
    cancellationToken: cancellationToken,
  );
}

final class _FakeTool implements ExecutableTool {
  _FakeTool({
    required String name,
    ToolRiskLevel riskLevel = ToolRiskLevel.readOnly,
    Set<ToolCapability> capabilities = const {ToolCapability.compute},
  }) : definition = ToolDefinition(
         name: name,
         description: 'A test tool.',
         inputSchema: const {
           'type': 'object',
           'properties': {
             'value': {'type': 'integer'},
           },
           'required': ['value'],
           'additionalProperties': false,
         },
         outputSchema: const {
           'type': 'object',
           'properties': {
             'result': {'type': 'integer'},
           },
           'required': ['result'],
           'additionalProperties': false,
         },
         source: ToolSource.builtIn,
         riskLevel: riskLevel,
         capabilities: capabilities,
       );

  @override
  final ToolDefinition definition;
  int executions = 0;

  @override
  Future<ToolResult> execute(
    ToolCallRequest call,
    AgentCancellationToken cancellationToken,
  ) async {
    executions += 1;
    final value = call.arguments['value']! as int;
    return ToolResult(
      callId: call.callId,
      name: call.name,
      content: '${value * 2}',
      structuredContent: {'result': value * 2},
    );
  }
}

final class _FakeModelSession implements AgentModelSession {
  _FakeModelSession(this.turns);

  final List<List<ModelEvent>> turns;
  final List<List<ToolResult>> continuations = [];
  var _turnIndex = 0;
  bool cancelled = false;

  @override
  Stream<ModelEvent> start() => Stream.fromIterable(turns[_turnIndex++]);

  @override
  Stream<ModelEvent> continueWith(List<ToolResult> results) {
    continuations.add(List<ToolResult>.of(results));
    return Stream.fromIterable(turns[_turnIndex++]);
  }

  @override
  Future<void> cancel() async {
    cancelled = true;
  }

  @override
  void close() {}
}

final class _HangingModelSession implements AgentModelSession {
  final StreamController<ModelEvent> _controller =
      StreamController<ModelEvent>();
  bool cancelled = false;

  @override
  Stream<ModelEvent> start() => _controller.stream;

  @override
  Stream<ModelEvent> continueWith(List<ToolResult> results) {
    throw StateError('A hanging session cannot continue.');
  }

  @override
  Future<void> cancel() async {
    cancelled = true;
    await _controller.close();
  }

  @override
  void close() {
    if (!_controller.isClosed) {
      unawaited(_controller.close());
    }
  }
}

final class _FakeProvider extends AiProvider {
  _FakeProvider(this.session, {this.supportsParallelToolCalls = false})
    : super(_bot);

  final AgentModelSession session;
  final bool supportsParallelToolCalls;

  @override
  AiProviderCapabilities get capabilities => AiProviderCapabilities(
    supportsStructuredToolCalls: true,
    supportsToolResults: true,
    supportsParallelToolCalls: supportsParallelToolCalls,
  );

  @override
  AgentModelSession openModelSession(ModelRequest request) => session;

  @override
  Future<void> generateText(List<ChatMessage> messages) async {}
}

final class _ParallelTool implements ExecutableTool {
  @override
  final ToolDefinition definition = ToolDefinition(
    name: 'parallel_compute',
    description: 'A parallel test computation.',
    inputSchema: const {
      'type': 'object',
      'properties': {
        'value': {'type': 'integer'},
      },
      'required': ['value'],
      'additionalProperties': false,
    },
    source: ToolSource.builtIn,
    riskLevel: ToolRiskLevel.readOnly,
    capabilities: const {ToolCapability.compute},
  );

  final Completer<void> _bothStarted = Completer<void>();
  int executions = 0;

  @override
  Future<ToolResult> execute(
    ToolCallRequest call,
    AgentCancellationToken cancellationToken,
  ) async {
    executions += 1;
    if (executions == 2 && !_bothStarted.isCompleted) {
      _bothStarted.complete();
    }
    await _bothStarted.future;
    final value = call.arguments['value']! as int;
    return ToolResult(callId: call.callId, name: call.name, content: '$value');
  }
}

final class _FixedApprovalHandler implements ToolApprovalHandler {
  const _FixedApprovalHandler(this.decision);

  final ToolApprovalDecision decision;

  @override
  Future<ToolApprovalDecision> requestApproval(
    ToolApprovalRequest request,
    AgentCancellationToken cancellationToken,
  ) async {
    return decision;
  }
}

final class _PendingApprovalHandler implements ToolApprovalHandler {
  final Completer<void> requested = Completer<void>();

  @override
  Future<ToolApprovalDecision> requestApproval(
    ToolApprovalRequest request,
    AgentCancellationToken cancellationToken,
  ) {
    if (!requested.isCompleted) requested.complete();
    return Completer<ToolApprovalDecision>().future;
  }
}

final _bot = Bot(
  id: 'bot-1',
  name: 'Test bot',
  avatar: '',
  provider: 'test',
  baseURL: '',
  apiKey: '',
  apiType: Bot.apiTypeOpenAI,
  model: 'test',
  systemPrompt: '',
  createTimestamp: DateTime(2026),
  modifyTimestamp: DateTime(2026),
);
