import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/views/project_message_composer.dart';
import 'package:hyve/utils/theme.dart';

import '../../../../support/widget_test_support.dart';

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

  test('structured controller restores a failed optimistic draft', () {
    final controller = StructuredProjectMessageController();
    addTearDown(controller.dispose);
    final draft = ProjectMessageDraft(
      text: '@研究员 请重试',
      mentions: const <MentionSpan>[
        MentionSpan(
          agentId: 'agent-1',
          start: 0,
          length: 4,
          displayTextSnapshot: '@研究员',
        ),
      ],
    );

    controller.restoreDraft(draft);

    expect(controller.text, draft.text);
    expect(controller.selection.baseOffset, draft.text.length);
    expect(controller.mentions.single.agentId, 'agent-1');
  });

  testWidgets('submitting composer uses Shad pending state and blocks resend', (
    tester,
  ) async {
    final controller = StructuredProjectMessageController(text: 'Sending');
    addTearDown(controller.dispose);
    var sends = 0;

    await tester.pumpWidget(
      shadHarness(
        brightness: Brightness.light,
        homeBuilder:
            (_) => Scaffold(
              body: ProjectMessageComposer(
                controller: controller,
                activeAgents: const <Agent>[],
                submitting: true,
                onSend: (_) => sends += 1,
              ),
            ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<ShadTextarea>(find.byType(ShadTextarea)).enabled,
      false,
    );
    expect(find.byIcon(LucideIcons.loaderCircle), findsOneWidget);
    final sendButton = tester.widget<ShadIconButton>(
      find.descendant(
        of: find.byKey(const ValueKey<String>('project-send-message')),
        matching: find.byType(ShadIconButton),
      ),
    );
    expect(sendButton.enabled, false);

    await tester.tap(
      find.byKey(const ValueKey<String>('project-send-message')),
      warnIfMissed: false,
    );
    expect(sends, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('composer sends without exposing an active-run stop action', (
    tester,
  ) async {
    final controller = StructuredProjectMessageController();
    addTearDown(controller.dispose);
    ProjectMessageDraft? sent;
    await tester.pumpWidget(
      shadHarness(
        brightness: Brightness.light,
        homeBuilder:
            (_) => Scaffold(
              body: ProjectMessageComposer(
                controller: controller,
                activeAgents: <Agent>[_agent('agent-1', '研究员')],
                onSend: (draft) => sent = draft,
              ),
            ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('project-cancel-runs')),
      findsNothing,
    );
    expect(find.byIcon(LucideIcons.square), findsNothing);
    expect(find.text('Stop active runs'), findsNothing);

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
    expect(tester.takeException(), isNull);
  });

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

  testWidgets('typed mention at the end keeps its Agent id when sent', (
    tester,
  ) async {
    final controller = StructuredProjectMessageController();
    addTearDown(controller.dispose);
    ProjectMessageDraft? sent;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectMessageComposer(
            controller: controller,
            activeAgents: <Agent>[_agent('agent-1', '研究员')],
            onSend: (draft) => sent = draft,
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey<String>('project-message-field')),
      '请处理这条消息 @研究员',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey<String>('project-send-message')),
    );

    expect(sent?.mentionedAgentIds, <String>['agent-1']);
  });

  testWidgets('composer sends selected project attachments', (tester) async {
    final controller = StructuredProjectMessageController();
    addTearDown(controller.dispose);
    ProjectMessageDraft? sent;
    var pickCalls = 0;
    int? removedIndex;
    (int, bool)? promotion;
    const attachment = PendingAttachment(
      sourcePath: '/picker/report.md',
      kind: PendingAttachmentKind.file,
      displayName: 'report.md',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectMessageComposer(
            controller: controller,
            activeAgents: const <Agent>[],
            attachments: const <PendingAttachment>[attachment],
            onPickAttachment: () => pickCalls++,
            onRemoveAttachment: (index) => removedIndex = index,
            onToggleAttachmentPromotion:
                (index, selected) => promotion = (index, selected),
            onSend: (draft) => sent = draft,
          ),
        ),
      ),
    );

    expect(find.text('report.md'), findsOneWidget);
    final initialChip = tester.widget<InputChip>(find.byType(InputChip));
    expect(initialChip.selected, isFalse);
    await tester.tap(find.byType(InputChip));
    expect(promotion, (0, true));
    await tester.tap(
      find.byKey(const ValueKey<String>('project-pick-attachment')),
    );
    expect(pickCalls, 1);
    await tester.tap(
      find.byKey(const ValueKey<String>('project-send-message')),
    );
    expect(sent?.attachments, const <PendingAttachment>[attachment]);

    final chip = tester.widget<InputChip>(find.byType(InputChip));
    chip.onDeleted?.call();
    expect(removedIndex, 0);
  });

  testWidgets('composer remains usable at narrow and wide widths', (
    tester,
  ) async {
    final controller = StructuredProjectMessageController(text: 'message');
    addTearDown(controller.dispose);
    for (final size in <Size>[const Size(320, 640), const Size(1200, 800)]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: ProjectMessageComposer(
                controller: controller,
                activeAgents: const <Agent>[],
                attachments: const <PendingAttachment>[
                  PendingAttachment(
                    sourcePath: '/picker/a-long-report-name.md',
                    kind: PendingAttachmentKind.file,
                    displayName: 'a-long-report-name.md',
                  ),
                ],
                onPickAttachment: () {},
                onSend: (_) {},
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull, reason: '$size');
      expect(
        find.byKey(const ValueKey<String>('project-message-field')),
        findsOneWidget,
      );
      final field = tester.widget<TextField>(
        find.byKey(const ValueKey<String>('project-message-field')),
      );
      final enabledBorder =
          field.decoration!.enabledBorder! as OutlineInputBorder;
      final focusedBorder =
          field.decoration!.focusedBorder! as OutlineInputBorder;
      final tokens = HyveDesktopTokens.of(
        tester.element(find.byType(TextField)),
      );
      expect(enabledBorder.borderRadius, HyveDesktopThemeSpec.controlRadius);
      expect(enabledBorder.borderSide.color, tokens.separator);
      expect(focusedBorder.borderRadius, HyveDesktopThemeSpec.controlRadius);
      expect(focusedBorder.borderSide.color, tokens.focusRing);
      final surfaceRect = tester.getRect(
        find.byKey(const ValueKey<String>('project-composer-surface')),
      );
      for (final actionKey in const <String>[
        'project-pick-attachment',
        'project-send-message',
      ]) {
        final actionRect = tester.getRect(find.byKey(ValueKey(actionKey)));
        expect(
          surfaceRect.contains(actionRect.center),
          isTrue,
          reason: size.toString(),
        );
      }
      final pickRect = tester.getRect(
        find.byKey(const ValueKey<String>('project-pick-attachment')),
      );
      final sendRect = tester.getRect(
        find.byKey(const ValueKey<String>('project-send-message')),
      );
      expect(pickRect.right, closeTo(sendRect.left, 0.01));
      expect(pickRect.bottom, closeTo(sendRect.bottom, 0.01));
      expect(find.text('Add attachment'), findsNothing);
      expect(find.text('Send'), findsNothing);
    }
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets('desktop composer uses Shad controls and preserves actions', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 700);
    addTearDown(tester.view.reset);
    final controller = StructuredProjectMessageController();
    addTearDown(controller.dispose);
    ProjectMessageDraft? sent;
    (int, bool)? promotion;
    var pickCalls = 0;

    await withDesktopPlatform(() async {
      await tester.pumpWidget(
        shadHarness(
          brightness: Brightness.light,
          homeBuilder:
              (_) => Scaffold(
                body: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: 760,
                    child: ProjectMessageComposer(
                      controller: controller,
                      activeAgents: const <Agent>[],
                      attachments: const <PendingAttachment>[
                        PendingAttachment(
                          sourcePath: '/picker/report.md',
                          kind: PendingAttachmentKind.file,
                          displayName: 'report.md',
                        ),
                      ],
                      onToggleAttachmentPromotion:
                          (index, selected) => promotion = (index, selected),
                      onPickAttachment: () => pickCalls += 1,
                      onSend: (draft) => sent = draft,
                    ),
                  ),
                ),
              ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ShadTextarea), findsOneWidget);
      expect(find.byType(ShadCard), findsNothing);
      expect(find.byType(ShadBadge), findsOneWidget);
      final textarea = tester.widget<ShadTextarea>(find.byType(ShadTextarea));
      final shadTheme = ShadTheme.of(tester.element(find.byType(ShadTextarea)));
      final searchBorder = shadTheme.inputTheme.decoration?.border;
      final composerBorder = shadTheme.textareaTheme.decoration?.border;
      expect(textarea.decoration, isNull);
      expect(composerBorder?.top?.width, searchBorder?.top?.width);
      expect(composerBorder?.top?.color, searchBorder?.top?.color);
      expect(composerBorder?.radius, searchBorder?.radius);
      expect(
        tester
            .widget<DecoratedBox>(
              find.byKey(const ValueKey<String>('project-composer-surface')),
            )
            .child,
        isA<Stack>(),
      );
      expect(find.byIcon(LucideIcons.plus), findsOneWidget);
      expect(find.byIcon(LucideIcons.square), findsNothing);
      expect(find.byIcon(LucideIcons.send), findsOneWidget);
      expect(find.text('Add attachment'), findsNothing);
      expect(find.text('Send'), findsNothing);
      expect(find.text('停止运行'), findsNothing);
      expect(find.bySemanticsLabel('添加附件'), findsOneWidget);
      expect(find.bySemanticsLabel('发送'), findsOneWidget);

      final surfaceRect = tester.getRect(
        find.byKey(const ValueKey<String>('project-composer-surface')),
      );
      final pickRect = tester.getRect(
        find.byKey(const ValueKey<String>('project-pick-attachment')),
      );
      final sendRect = tester.getRect(
        find.byKey(const ValueKey<String>('project-send-message')),
      );
      expect(surfaceRect.contains(pickRect.center), isTrue);
      expect(surfaceRect.contains(sendRect.center), isTrue);
      expect(pickRect.right, closeTo(sendRect.left, 0.01));
      expect(pickRect.bottom, closeTo(sendRect.bottom, 0.01));
      expect(surfaceRect.right - sendRect.right, closeTo(6, 0.01));
      expect(surfaceRect.bottom - sendRect.bottom, closeTo(4, 0.01));

      await tester.tap(
        find.byKey(const ValueKey<String>('project-pick-attachment')),
      );
      await tester.pump();
      expect(pickCalls, 1);

      await tester.tap(find.text('report.md'));
      await tester.pump();
      expect(promotion, (0, true));

      await tester.enterText(
        find.byKey(const ValueKey<String>('project-message-field')),
        'Ship the report',
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('project-send-message')),
      );
      await tester.pump();

      expect(sent?.text, 'Ship the report');
      expect(tester.takeException(), isNull);
    });
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
