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

  testWidgets('focus ring preserves child constraints in high contrast', (
    tester,
  ) async {
    final focusNode = FocusNode(debugLabel: 'high-contrast-action-surface');
    addTearDown(focusNode.dispose);
    Size? childSize;

    await tester.pumpWidget(
      shadHarness(
        brightness: Brightness.light,
        homeBuilder:
            (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(highContrast: true),
              child: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 300,
                    height: 200,
                    child: HyveDesktopActionSurface(
                      focusNode: focusNode,
                      label: 'Open details',
                      onPressed: () {},
                      builder:
                          (context, highlighted) => LayoutBuilder(
                            builder: (context, constraints) {
                              childSize = constraints.biggest;
                              return const SizedBox.expand();
                            },
                          ),
                    ),
                  ),
                ),
              ),
            ),
      ),
    );

    await tester.pumpAndSettle();
    final unfocusedSize = childSize;
    expect(unfocusedSize, const Size(300, 200));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    focusNode.requestFocus();
    await tester.pumpAndSettle();

    expect(focusNode.hasFocus, isTrue);
    expect(childSize, unfocusedSize);
  });

  testWidgets('focused descendants do not highlight the action surface', (
    tester,
  ) async {
    final surfaceFocusNode = FocusNode(debugLabel: 'action-surface');
    final childFocusNode = FocusNode(debugLabel: 'nested-action');
    final previousHighlightStrategy = FocusManager.instance.highlightStrategy;
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(() {
      FocusManager.instance.highlightStrategy = previousHighlightStrategy;
    });
    addTearDown(surfaceFocusNode.dispose);
    addTearDown(childFocusNode.dispose);
    var highlighted = false;

    await tester.pumpWidget(
      shadHarness(
        brightness: Brightness.light,
        homeBuilder:
            (context) => Scaffold(
              body: HyveDesktopActionSurface(
                focusNode: surfaceFocusNode,
                label: 'Open details',
                onPressed: () {},
                builder: (context, value) {
                  highlighted = value;
                  return TextButton(
                    focusNode: childFocusNode,
                    onPressed: () {},
                    child: const Text('More actions'),
                  );
                },
              ),
            ),
      ),
    );

    surfaceFocusNode.requestFocus();
    await tester.pumpAndSettle();
    expect(surfaceFocusNode.hasPrimaryFocus, isTrue);
    expect(highlighted, isTrue);

    childFocusNode.requestFocus();
    await tester.pumpAndSettle();
    expect(childFocusNode.hasPrimaryFocus, isTrue);
    expect(surfaceFocusNode.hasFocus, isTrue);
    expect(highlighted, isFalse);
  });
}
