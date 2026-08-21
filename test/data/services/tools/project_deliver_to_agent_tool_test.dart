import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/data/services/tools/project_deliver_to_agent_tool.dart';
import 'package:hyve/domain/models/models.dart';

void main() {
  test(
    'defaults visibility to project and returns structured audit ids',
    () async {
      AgentDeliveryRequest? captured;
      final tool = ProjectDeliverToAgentTool(
        deliver: (request) async {
          captured = request;
          return const AgentDeliveryExecutionResult(
            eventId: 'event-1',
            turnId: 'turn-1',
            deliveryRunId: 'delivery-run-1',
            messageSequence: 4,
          );
        },
      );
      final call = ToolCallRequest(
        callId: 'call-1',
        name: ProjectDeliverToAgentTool.name,
        arguments: const <String, Object?>{
          'targetAgentIds': <String>['agent-2'],
          'kind': 'task',
          'summary': 'Review',
          'payload': 'Review the result.',
        },
      );

      final result = await tool.execute(call, AgentCancellationToken());

      expect(result.isError, isFalse);
      expect(captured?.visibility, AgentDeliveryVisibility.project);
      expect(captured?.requestPublicReply, isFalse);
      expect(captured?.targetAgentIds, const <String>['agent-2']);
      expect(result.structuredContent, <String, Object?>{
        'eventId': 'event-1',
        'turnId': 'turn-1',
        'deliveryRunId': 'delivery-run-1',
        'messageSequence': 4,
        'duplicate': false,
      });
    },
  );

  test('surfaces domain rejection as a stable tool error', () async {
    final tool = ProjectDeliverToAgentTool(
      deliver:
          (_) async =>
              throw const AgentDeliveryFailure('delivery_target_not_active'),
    );

    final result = await tool.execute(_call(), AgentCancellationToken());

    expect(result.isError, isTrue);
    expect(result.errorCode, 'delivery_target_not_active');
  });

  test(
    'cancellation prevents a pending delivery from reporting success',
    () async {
      final release = Completer<void>();
      final tool = ProjectDeliverToAgentTool(
        deliver: (_) async {
          await release.future;
          return const AgentDeliveryExecutionResult(
            eventId: 'event-1',
            turnId: 'turn-1',
            deliveryRunId: 'delivery-run-1',
            messageSequence: 2,
          );
        },
      );
      final token = AgentCancellationToken();

      final pending = tool.execute(_call(), token);
      token.cancel();
      release.complete();

      await expectLater(pending, throwsA(isA<AgentRunCancelledException>()));
    },
  );

  test('schema rejects duplicate targets and invalid visibility', () {
    final definition =
        ProjectDeliverToAgentTool(
          deliver: (_) async => throw UnimplementedError(),
        ).definition;
    final issues = const JsonSchemaValidator().validate(<String, Object?>{
      'targetAgentIds': <String>['agent-2', 'agent-2'],
      'kind': 'task',
      'summary': 'Review',
      'payload': 'Review the result.',
      'visibility': 'private',
    }, definition.inputSchema);

    expect(issues.map((issue) => issue.code), contains('unique_items'));
    expect(issues.map((issue) => issue.code), contains('enum'));
  });
}

ToolCallRequest _call() => ToolCallRequest(
  callId: 'call-1',
  name: ProjectDeliverToAgentTool.name,
  arguments: const <String, Object?>{
    'targetAgentIds': <String>['agent-2'],
    'kind': 'information',
    'summary': 'Summary',
    'payload': 'Payload',
    'visibility': 'targets',
    'requestPublicReply': true,
  },
);
