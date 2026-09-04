import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/ui/features/projects/views/project_ui.dart';
import 'package:hyve/ui/features/projects/views/project_workspace_page.dart';

void main() {
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

  testWidgets('workspace pane switch keeps the message page mounted', (
    tester,
  ) async {
    var messageInitializations = 0;
    var messageDisposals = 0;
    var memberInitializations = 0;

    Widget buildSwitcher({required bool showMembers}) {
      return MaterialApp(
        home: Scaffold(
          body: ProjectWorkspacePaneStack(
            showMembers: showMembers,
            messages: _LifecycleProbe(
              label: 'messages',
              onInitialize: () => messageInitializations += 1,
              onDispose: () => messageDisposals += 1,
            ),
            members: _LifecycleProbe(
              label: 'members',
              onInitialize: () => memberInitializations += 1,
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildSwitcher(showMembers: false));
    expect(messageInitializations, 1);
    expect(memberInitializations, 1);
    expect(find.text('messages'), findsOneWidget);
    expect(find.text('members'), findsNothing);

    await tester.pumpWidget(buildSwitcher(showMembers: true));
    expect(messageInitializations, 1);
    expect(memberInitializations, 1);
    expect(messageDisposals, 0);
    expect(find.text('messages'), findsNothing);
    expect(find.text('members'), findsOneWidget);
    expect(
      find.byKey(
        const PageStorageKey<String>('project-message-list-page'),
        skipOffstage: false,
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(buildSwitcher(showMembers: false));
    expect(messageInitializations, 1);
    expect(messageDisposals, 0);
    expect(find.text('messages'), findsOneWidget);
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
