import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/utils/theme.dart';

import '../../../support/widget_test_support.dart';

void main() {
  testWidgets('desktop action surface supports Enter and Space activation', (
    tester,
  ) async {
    final focusNode = FocusNode(debugLabel: 'desktop-action-surface-test');
    addTearDown(focusNode.dispose);
    var activations = 0;

    await tester.pumpWidget(
      shadHarness(
        brightness: Brightness.light,
        homeBuilder:
            (context) => Scaffold(
              body: Center(
                child: HyveDesktopActionSurface(
                  focusNode: focusNode,
                  label: 'Open details',
                  hint: 'Shows more information',
                  onPressed: () => activations += 1,
                  builder:
                      (context, highlighted) => ShadCard(
                        key: const ValueKey<String>('action-card'),
                        backgroundColor:
                            highlighted
                                ? ShadTheme.of(context).colorScheme.accent
                                : null,
                        child: const Text('Details'),
                      ),
                ),
              ),
            ),
      ),
    );

    await tester.pumpAndSettle();
    focusNode.requestFocus();
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(activations, 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(activations, 2);

    final semantics = tester.getSemantics(
      find.byType(HyveDesktopActionSurface),
    );
    expect(semantics.label, 'Open details');
    expect(semantics.hint, 'Shows more information');
    expect(semantics.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
  });
}
