import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/ui/features/projects/views/project_ui.dart';
import 'package:hyve/ui/features/projects/views/project_workspace_page.dart';

import '../../../../support/widget_test_support.dart';

void main() {
  test('workspace controller toggles the execution page', () {
    final controller = ProjectWorkspaceController();
    addTearDown(controller.dispose);

    controller.toggleExecution();
    expect(controller.value, ProjectWorkspacePane.execution);
    expect(controller.showingExecution, isTrue);

    controller.toggleExecution();
    expect(controller.value, ProjectWorkspacePane.messages);
  });

  testWidgets('project content follows the composer width at every size', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    for (final width in <double>[600, 1200]) {
      tester.view.physicalSize = Size(width, 700);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProjectContentBounds(
              child: ColoredBox(
                key: const ValueKey<String>('project-content'),
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final rect = tester.getRect(
        find.byKey(const ValueKey<String>('project-content')),
      );
      final expectedWidth = math.min(width - 32, projectContentMaxWidth);
      expect(rect.width, expectedWidth, reason: 'window width $width');
      expect(rect.center.dx, width / 2, reason: 'window width $width');
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('workspace tool panes keep the message page mounted', (
    tester,
  ) async {
    var messageInitializations = 0;
    var messageDisposals = 0;
    var memberInitializations = 0;
    var artifactInitializations = 0;
    var executionInitializations = 0;

    Widget buildSwitcher({required ProjectWorkspacePane pane}) {
      return MaterialApp(
        home: Scaffold(
          body: ProjectWorkspacePaneStack(
            pane: pane,
            messages: _LifecycleProbe(
              label: 'messages',
              onInitialize: () => messageInitializations += 1,
              onDispose: () => messageDisposals += 1,
            ),
            members: _LifecycleProbe(
              label: 'members',
              onInitialize: () => memberInitializations += 1,
            ),
            artifacts: _LifecycleProbe(
              label: 'artifacts',
              onInitialize: () => artifactInitializations += 1,
            ),
            execution: _LifecycleProbe(
              label: 'execution',
              onInitialize: () => executionInitializations += 1,
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildSwitcher(pane: ProjectWorkspacePane.messages));
    expect(messageInitializations, 1);
    expect(memberInitializations, 1);
    expect(artifactInitializations, 1);
    expect(executionInitializations, 1);
    expect(find.text('messages'), findsOneWidget);
    expect(find.text('members'), findsNothing);

    await tester.pumpWidget(buildSwitcher(pane: ProjectWorkspacePane.members));
    expect(messageInitializations, 1);
    expect(memberInitializations, 1);
    expect(messageDisposals, 0);
    expect(find.text('messages'), findsNothing);
    expect(find.text('members'), findsOneWidget);

    await tester.pumpWidget(
      buildSwitcher(pane: ProjectWorkspacePane.artifacts),
    );
    expect(messageInitializations, 1);
    expect(memberInitializations, 1);
    expect(artifactInitializations, 1);
    expect(messageDisposals, 0);
    expect(find.text('artifacts'), findsOneWidget);
    expect(
      find.byKey(
        const PageStorageKey<String>('project-message-list-page'),
        skipOffstage: false,
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(
      buildSwitcher(pane: ProjectWorkspacePane.execution),
    );
    expect(messageInitializations, 1);
    expect(executionInitializations, 1);
    expect(messageDisposals, 0);
    expect(find.text('execution'), findsOneWidget);
    expect(
      find.byKey(
        const PageStorageKey<String>('project-message-list-page'),
        skipOffstage: false,
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(buildSwitcher(pane: ProjectWorkspacePane.messages));
    expect(messageInitializations, 1);
    expect(messageDisposals, 0);
    expect(find.text('messages'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('member and artifact headers keep identical geometry', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 700);
    addTearDown(tester.view.reset);

    Widget section({
      required Key key,
      required IconData icon,
      required String title,
      required String description,
    }) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ProjectSectionHeader(
          key: key,
          icon: icon,
          title: title,
          description: description,
          trailing: ProjectBackAction(label: '返回消息', onPressed: () {}),
        ),
      ),
    );

    await tester.pumpWidget(
      shadHarness(
        brightness: Brightness.light,
        homeBuilder:
            (context) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(padding: const EdgeInsets.only(top: 24)),
              child: ProjectWorkspacePaneStack(
                pane: ProjectWorkspacePane.members,
                messages: const SizedBox.shrink(),
                members: section(
                  key: const ValueKey<String>('member-reference-header'),
                  icon: LucideIcons.bot,
                  title: '项目成员',
                  description: '查看消息处理状态，并管理智能体顺序、产物权限和项目参与状态。',
                ),
                artifacts: section(
                  key: const ValueKey<String>('artifact-comparison-header'),
                  icon: LucideIcons.folderKanban,
                  title: '项目产物',
                  description: '浏览项目文件、预览版本历史，并使用系统软件打开文件。',
                ),
                execution: const SizedBox.shrink(),
              ),
            ),
      ),
    );
    await tester.pumpAndSettle();

    final membersRect = tester.getRect(
      find.byKey(
        const ValueKey<String>('member-reference-header'),
        skipOffstage: false,
      ),
    );
    final artifactsRect = tester.getRect(
      find.byKey(
        const ValueKey<String>('artifact-comparison-header'),
        skipOffstage: false,
      ),
    );
    expect(artifactsRect.top, membersRect.top);
    expect(artifactsRect.size, membersRect.size);
    expect(membersRect.top, 44);
    expect(tester.takeException(), isNull);
  });
}

final class _LifecycleProbe extends StatefulWidget {
  const _LifecycleProbe({
    required this.label,
    required this.onInitialize,
    this.onDispose,
  });

  final String label;
  final VoidCallback onInitialize;
  final VoidCallback? onDispose;

  @override
  State<_LifecycleProbe> createState() => _LifecycleProbeState();
}

final class _LifecycleProbeState extends State<_LifecycleProbe> {
  @override
  void initState() {
    super.initState();
    widget.onInitialize();
  }

  @override
  void dispose() {
    widget.onDispose?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(child: Text(widget.label));
}
