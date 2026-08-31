import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/data/services/ai/provider_project_agent_execution_gateway.dart';
import 'package:hyve/data/services/tools/project_artifact_tools.dart';
import 'package:hyve/domain/models/ai_models.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/ai_provider_repository.dart';

void main() {
  final decisionVariants = <({String name, String text, String reason})>[
    (
      name: 'Markdown JSON',
      text: '''```JSON
{"choice":"pass","reasonCode":"no_value","intendedContribution":""}
```''',
      reason: 'no_value',
    ),
    (
      name: 'surrounding prose',
      text:
          'Decision follows: {"choice":"pass","reasonCode":"not_needed"} Done.',
      reason: 'not_needed',
    ),
    (
      name: 'snake case fields',
      text:
          '{"choice":"PASS","reason_code":"no_value",'
          '"intended_contribution":""}',
      reason: 'no_value',
    ),
    (
      name: 'reasoning object before the decision',
      text:
          'Analysis: {"choice":"pass","reason":"tentative",'
          '"confidence":0.9}\nFinal: '
          '{"choice":"pass","reasonCode":"no_value"}',
      reason: 'no_value',
    ),
  ];
  for (final variant in decisionVariants) {
    test('accepts recoverable ${variant.name} participation output', () async {
      final gateway = ProviderProjectAgentExecutionGateway(
        providers: _Providers(_TextProvider(variant.text)),
      );

      final result = await gateway.decide(_decisionRequest());

      expect(result.choice, ParticipationChoice.pass);
      expect(result.reasonCode, variant.reason);
      expect(result.intendedContribution, isEmpty);
    });
  }

  test('accepts a valid participation decision with extra metadata', () async {
    final gateway = ProviderProjectAgentExecutionGateway(
      providers: _Providers(
        _TextProvider(
          '{"choice":"reply","reasonCode":"relevant",'
          '"intendedContribution":"answer the question","confidence":0.92}',
        ),
      ),
    );

    final result = await gateway.decide(_decisionRequest());

    expect(result.choice, ParticipationChoice.reply);
    expect(result.reasonCode, 'relevant');
    expect(result.intendedContribution, 'answer the question');
  });

  test('recovers a nested decision with common field aliases', () async {
    final gateway = ProviderProjectAgentExecutionGateway(
      providers: _Providers(
        _TextProvider(
          '{"result":{"decision":"respond","rationale":"useful",'
          '"contribution":"summarize findings"}}',
        ),
      ),
    );

    final result = await gateway.decide(_decisionRequest());

    expect(result.choice, ParticipationChoice.reply);
    expect(result.reasonCode, 'useful');
    expect(result.intendedContribution, 'summarize findings');
  });

  test('rejects participation output without a reason', () async {
    final gateway = ProviderProjectAgentExecutionGateway(
      providers: _Providers(
        _TextProvider('{"choice":"pass","intendedContribution":""}'),
      ),
    );

    expect(gateway.decide(_decisionRequest()), throwsFormatException);
  });

  test(
    'requests the strict participation schema from capable providers',
    () async {
      final provider = _SchemaTextProvider(
        '{"choice":"reply","reasonCode":"relevant",'
        '"intendedContribution":"answer the question"}',
      );
      final gateway = ProviderProjectAgentExecutionGateway(
        providers: _Providers(provider),
      );

      final result = await gateway.decide(_decisionRequest());

      expect(result.choice, ParticipationChoice.reply);
      expect(provider.schemaName, 'participation_decision');
      expect(provider.jsonSchema, {
        'type': 'object',
        'properties': {
          'choice': {
            'type': 'string',
            'enum': ['reply', 'pass'],
          },
          'reasonCode': {'type': 'string'},
          'intendedContribution': {'type': 'string'},
        },
        'required': ['choice', 'reasonCode', 'intendedContribution'],
        'additionalProperties': false,
      });
    },
  );

  test('exposes and audits scoped project artifact tools', () async {
    final session = _ModelSession(<List<ModelEvent>>[
      <ModelEvent>[
        ToolCallRequested(
          callId: 'artifact-call',
          name: ProjectArtifactToolNames.list,
          arguments: const <String, Object?>{},
        ),
        const ModelTurnCompleted(stopReason: 'tool_calls'),
      ],
      const <ModelEvent>[
        TextDelta('Artifact inspected.'),
        ModelTurnCompleted(stopReason: 'stop'),
      ],
    ]);
    final provider = _Provider(session);
    final tool = _ArtifactListTool();
    final gateway = ProviderProjectAgentExecutionGateway(
      providers: _Providers(provider),
    );

    final result = await gateway.reply(
      ProjectAgentReplyRequest(
        runId: 'run-1',
        projectId: 'project-1',
        agent: _agent(),
        sourceEvent: _event(),
        contextThroughMessageSequence: 1,
        visibleHistory: <ProjectEvent>[_event()],
        cancellationToken: ProjectRunCancellationToken(),
        projectTools: <ExecutableTool>[tool],
      ),
    );

    expect(result.status, ProjectAgentReplyStatus.completed);
    expect(result.text, 'Artifact inspected.');
    expect(tool.executions, 1);
    expect(
      provider.lastRequest?.tools.map((definition) => definition.name),
      <String>[ProjectArtifactToolNames.list],
    );
    expect(session.continuations.single.single.content, contains('"count":0'));
    expect(result.toolInvocations, hasLength(1));
    expect(
      result.toolInvocations.single.status,
      ToolInvocationStatus.succeeded,
    );
    expect(result.toolInvocations.single.name, ProjectArtifactToolNames.list);
  });
}

final class _ArtifactListTool implements ExecutableTool {
  var executions = 0;

  @override
  final ToolDefinition definition = ToolDefinition(
    name: ProjectArtifactToolNames.list,
    title: 'List artifacts',
    description: 'List current project artifacts.',
    inputSchema: const <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{},
      'additionalProperties': false,
    },
    outputSchema: const <String, Object?>{'type': 'object'},
    source: ToolSource.builtIn,
    riskLevel: ToolRiskLevel.readOnly,
    capabilities: const <ToolCapability>{ToolCapability.localRead},
  );

  @override
  Future<ToolResult> execute(
    ToolCallRequest call,
    AgentCancellationToken cancellationToken,
  ) async {
    executions++;
    return ToolResult(
      callId: call.callId,
      name: call.name,
      content: '{"count":0,"artifacts":[]}',
      structuredContent: const <String, Object?>{
        'count': 0,
        'artifacts': <Object?>[],
      },
    );
  }
}

final class _ModelSession implements AgentModelSession {
  _ModelSession(this.turns);

  final List<List<ModelEvent>> turns;
  final List<List<ToolResult>> continuations = <List<ToolResult>>[];
  var _turn = 0;

  @override
  Stream<ModelEvent> start() => Stream<ModelEvent>.fromIterable(turns[_turn++]);

  @override
  Stream<ModelEvent> continueWith(List<ToolResult> results) {
    continuations.add(List<ToolResult>.of(results));
    return Stream<ModelEvent>.fromIterable(turns[_turn++]);
  }

  @override
  Future<void> cancel() async {}

  @override
  void close() {}
}

final class _Provider extends AiProvider {
  _Provider(this.session) : super(_bot());

  final AgentModelSession session;
  ModelRequest? lastRequest;

  @override
  AiProviderCapabilities get capabilities => const AiProviderCapabilities(
    supportsStructuredToolCalls: true,
    supportsToolResults: true,
  );

  @override
  AgentModelSession openModelSession(ModelRequest request) {
    lastRequest = request;
    return session;
  }

  @override
  Future<void> generateText(List<ChatMessage> messages) async {}
}

final class _TextProvider extends AiProvider {
  _TextProvider(this.text) : super(_bot());

  final String text;

  @override
  Future<void> generateText(List<ChatMessage> messages) async {
    onResponse(text);
  }
}

final class _SchemaTextProvider extends AiProvider {
  _SchemaTextProvider(this.text) : super(_bot());

  final String text;
  String? schemaName;
  Map<String, Object?>? jsonSchema;

  @override
  Future<void> generateText(List<ChatMessage> messages) async {
    throw StateError('Expected the structured output API.');
  }

  @override
  Future<void> generateJsonSchemaText(
    List<ChatMessage> messages, {
    required String schemaName,
    required Map<String, Object?> jsonSchema,
  }) async {
    this.schemaName = schemaName;
    this.jsonSchema = jsonSchema;
    onResponse(text);
  }
}

final class _Providers implements AiProviderRepository {
  const _Providers(this.provider);

  final AiProvider provider;

  @override
  AiProvider create(Bot bot) => provider;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Agent _agent() => Agent(
  id: 'agent-1',
  name: 'Researcher',
  avatar: '',
  provider: 'test',
  baseUrl: '',
  apiKey: '',
  apiType: Bot.apiTypeOpenAI,
  model: 'model',
  systemPrompt: 'Work carefully.',
  createdAt: DateTime(2026, 8, 22),
  updatedAt: DateTime(2026, 8, 22),
);

Bot _bot() => Bot(
  id: 'agent-1',
  name: 'Researcher',
  avatar: '',
  provider: 'test',
  baseURL: '',
  apiKey: '',
  apiType: Bot.apiTypeOpenAI,
  model: 'model',
  systemPrompt: '',
  createTimestamp: DateTime(2026, 8, 22),
  modifyTimestamp: DateTime(2026, 8, 22),
);

ProjectEvent _event() => ProjectEvent(
  id: 'event-1',
  projectId: 'project-1',
  turnId: 'turn-1',
  sequence: 1,
  messageSequence: 1,
  eventType: ProjectEventType.userMessage,
  actorType: ProjectEventActorType.user,
  actorId: 'me',
  content: 'Inspect project artifacts.',
  payload: ProjectMessagePayload(),
  createdAt: DateTime(2026, 8, 22),
  updatedAt: DateTime(2026, 8, 22),
);

BroadcastParticipationRequest _decisionRequest() =>
    BroadcastParticipationRequest(
      runId: 'decision-run-1',
      projectId: 'project-1',
      agent: _agent(),
      sourceEvent: _event(),
      decisionSystemPrompt: 'Return a decision.',
      visibleHistory: <ProjectEvent>[_event()],
      maxInputTokens: 4096,
      maxOutputTokens: 128,
      estimatedInputTokens: 64,
      cancellationToken: ProjectRunCancellationToken(),
    );
