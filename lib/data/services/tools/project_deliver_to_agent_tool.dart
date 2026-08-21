import 'package:hyve/domain/models/models.dart';

final class ProjectDeliverToAgentTool implements ExecutableTool {
  const ProjectDeliverToAgentTool({
    required ProjectAgentDeliveryExecutor deliver,
  }) : _deliver = deliver;

  static const name = 'project.deliver_to_agent';

  final ProjectAgentDeliveryExecutor _deliver;

  @override
  ToolDefinition get definition => ToolDefinition(
    name: name,
    title: 'Deliver to project Agent',
    description:
        'Deliver structured information, a task, a question, or a result to '
        'one or more active Agents in the current project. This is the only '
        'supported way to initiate an Agent-to-Agent handoff.',
    inputSchema: const <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'targetAgentIds': <String, Object?>{
          'type': 'array',
          'items': <String, Object?>{'type': 'string', 'minLength': 1},
          'minItems': 1,
          'uniqueItems': true,
        },
        'kind': <String, Object?>{
          'type': 'string',
          'enum': <String>['information', 'task', 'question', 'result'],
        },
        'summary': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 512,
        },
        'payload': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 32768,
        },
        'projectArtifactVersionIds': <String, Object?>{
          'type': 'array',
          'items': <String, Object?>{'type': 'string', 'minLength': 1},
          'uniqueItems': true,
        },
        'visibility': <String, Object?>{
          'type': 'string',
          'enum': <String>['project', 'targets'],
          'default': 'project',
        },
        'requestPublicReply': <String, Object?>{
          'type': 'boolean',
          'default': false,
        },
      },
      'required': <String>['targetAgentIds', 'kind', 'summary', 'payload'],
      'additionalProperties': false,
    },
    outputSchema: const <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'eventId': <String, Object?>{'type': 'string'},
        'turnId': <String, Object?>{'type': 'string'},
        'deliveryRunId': <String, Object?>{'type': 'string'},
        'messageSequence': <String, Object?>{'type': 'integer', 'minimum': 1},
        'duplicate': <String, Object?>{'type': 'boolean'},
      },
      'required': <String>[
        'eventId',
        'turnId',
        'deliveryRunId',
        'messageSequence',
        'duplicate',
      ],
      'additionalProperties': false,
    },
    source: ToolSource.builtIn,
    riskLevel: ToolRiskLevel.write,
    capabilities: const <ToolCapability>{ToolCapability.projectRouting},
  );

  @override
  Future<ToolResult> execute(
    ToolCallRequest call,
    AgentCancellationToken cancellationToken,
  ) async {
    cancellationToken.throwIfCancelled();
    final arguments = call.arguments;
    final targets =
        (arguments['targetAgentIds']! as List<Object?>).cast<String>();
    final artifactVersionIds =
        (arguments['projectArtifactVersionIds'] as List<Object?>?)
            ?.cast<String>() ??
        const <String>[];
    final kind = AgentDeliveryKind.values.byName(arguments['kind']! as String);
    final visibility = AgentDeliveryVisibility.values.byName(
      arguments['visibility'] as String? ??
          AgentDeliveryVisibility.project.name,
    );
    try {
      final result = await _deliver(
        AgentDeliveryRequest(
          targetAgentIds: targets,
          kind: kind,
          summary: arguments['summary']! as String,
          payload: arguments['payload']! as String,
          projectArtifactVersionIds: artifactVersionIds,
          visibility: visibility,
          requestPublicReply: arguments['requestPublicReply'] as bool? ?? false,
        ),
      );
      cancellationToken.throwIfCancelled();
      final structured = <String, Object?>{
        'eventId': result.eventId,
        'turnId': result.turnId,
        'deliveryRunId': result.deliveryRunId,
        'messageSequence': result.messageSequence,
        'duplicate': result.duplicate,
      };
      return ToolResult(
        callId: call.callId,
        name: call.name,
        content:
            result.duplicate
                ? 'An identical delivery already exists; the existing result '
                    'was reused.'
                : 'The delivery was accepted and queued in the target inbox.',
        structuredContent: structured,
      );
    } on ProjectRunCancelledException {
      throw const AgentRunCancelledException();
    } on AgentDeliveryFailure catch (failure) {
      return ToolResult(
        callId: call.callId,
        name: call.name,
        content: 'The project delivery was rejected.',
        isError: true,
        errorCode: failure.code,
      );
    }
  }
}
