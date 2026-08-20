import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/views/project_message_composer.dart';

void main() {
  test(
    'structured controller preserves ids across duplicate names and edits',
    () {
      final controller = StructuredProjectMessageController(text: '@同名 hello');
      addTearDown(controller.dispose);
      controller.insertMention(
        agent: _agent('agent-2', '同名'),
        replaceRange: const TextRange(start: 0, end: 3),
      );
      expect(controller.mentions.single.agentId, 'agent-2');

      controller.value = controller.value.copyWith(
        text: '请 ${controller.text}',
        selection: TextSelection.collapsed(offset: controller.text.length + 2),
      );
      expect(controller.mentions.single.start, 2);
      expect(controller.draft().mentionedAgentIds, <String>['agent-2']);

      controller.value = const TextEditingValue(text: '请 @名 hello');
      expect(controller.mentions, isEmpty);
    },
  );

  testWidgets(
    'composer sends while runs are active and keeps cancel separate',
    (tester) async {
      final controller = StructuredProjectMessageController();
      addTearDown(controller.dispose);
      ProjectMessageDraft? sent;
      var cancelCalls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProjectMessageComposer(
              controller: controller,
              activeAgents: <Agent>[_agent('agent-1', '研究员')],
              activeRunCount: 2,
              onCancelRuns: () => cancelCalls++,
              onSend: (draft) => sent = draft,
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey<String>('project-message-field')),
        '新的消息',
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey<String>('project-send-message')),
      );
      await tester.pump();
      expect(sent?.text, '新的消息');

      await tester.tap(
        find.byKey(const ValueKey<String>('project-cancel-runs')),
      );
      expect(cancelCalls, 1);
    },
  );

  testWidgets('mention selection saves the selected Agent id', (tester) async {
    final controller = StructuredProjectMessageController();
    addTearDown(controller.dispose);
    ProjectMessageDraft? sent;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectMessageComposer(
            controller: controller,
            activeAgents: <Agent>[
              _agent('agent-1', '同名'),
              _agent('agent-2', '同名'),
            ],
            onSend: (draft) => sent = draft,
          ),
        ),
      ),
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('project-message-field')),
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('project-message-field')),
      '@同',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey<String>('project-mention-agent-2')),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey<String>('project-send-message')),
    );
    expect(sent?.mentionedAgentIds, <String>['agent-2']);
  });

  test('ambiguous pasted names are not guessed', () {
    final controller = StructuredProjectMessageController(text: '@同名 处理');
    addTearDown(controller.dispose);
    controller.convertUniquePlainTextMentions(<Agent>[
      _agent('agent-1', '同名'),
      _agent('agent-2', '同名'),
    ]);
    expect(controller.mentions, isEmpty);
  });
}

Agent _agent(String id, String name) => Agent(
  id: id,
  name: name,
  avatar: '',
  provider: 'test',
  baseUrl: '',
  apiKey: '',
  apiType: Bot.apiTypeOpenAI,
  model: 'model',
  systemPrompt: '',
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);
