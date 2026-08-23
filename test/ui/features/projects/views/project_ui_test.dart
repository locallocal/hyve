import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/ui/features/projects/views/project_ui.dart';

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
}
