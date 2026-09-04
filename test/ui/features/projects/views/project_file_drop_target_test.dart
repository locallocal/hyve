import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/ui/features/projects/views/project_file_drop_target.dart';

void main() {
  testWidgets('drop target adapts and forwards dropped file paths', (
    tester,
  ) async {
    List<String>? dropped;
    for (final size in <Size>[const Size(280, 360), const Size(1000, 700)]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProjectFileDropTarget(
              idleLabel: 'Drop files here to import',
              activeLabel: 'Release to import',
              onDropped: (paths) => dropped = paths,
              child: const SizedBox.expand(
                key: ValueKey<String>('drop-content'),
                child: Placeholder(),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull, reason: '$size');
      expect(find.text('Drop files here to import'), findsOneWidget);
    }
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final targetRect = tester.getRect(
      find.byKey(const ValueKey<String>('artifact-drop-target')),
    );
    final contentRect = tester.getRect(
      find.byKey(const ValueKey<String>('drop-content')),
    );
    expect(contentRect, targetRect);

    final target = tester.widget<DropTarget>(find.byType(DropTarget));
    target.onDragEntered?.call(
      DropEventDetails(localPosition: Offset.zero, globalPosition: Offset.zero),
    );
    await tester.pump();
    expect(find.text('Release to import'), findsOneWidget);
    expect(
      tester.getRect(find.byKey(const ValueKey<String>('drop-content'))),
      targetRect,
    );

    target.onDragDone?.call(
      DropDoneDetails(
        files: <DropItem>[DropItemFile('/tmp/report.md')],
        localPosition: Offset.zero,
        globalPosition: Offset.zero,
      ),
    );
    await tester.pump();
    expect(dropped, <String>['/tmp/report.md']);
    expect(find.text('Drop files here to import'), findsOneWidget);
  });
}
