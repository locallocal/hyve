import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/ui/core/widgets/desktop_chat_primitives.dart';
import 'package:hyve/utils/theme.dart';

import '../../../support/widget_test_support.dart';

void main() {
  testWidgets('large Hyve dialogs share responsive canonical constraints', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    for (final (windowSize, expectedSize) in <(Size, Size)>[
      (const Size(1280, 900), hyveLargeDialogMaxSize),
      (const Size(800, 600), const Size(768, 568)),
    ]) {
      tester.view.physicalSize = windowSize;
      await tester.pumpWidget(
        shadHarness(
          brightness: Brightness.light,
          homeBuilder:
              (_) => const Scaffold(
                body: SizedBox(
                  key: ValueKey<String>('large-dialog-size-probe'),
                ),
              ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        hyveLargeDialogSizeOf(
          tester.element(
            find.byKey(const ValueKey<String>('large-dialog-size-probe')),
          ),
        ),
        expectedSize,
      );
    }
  });

  testWidgets('Hyve dialog close matches Theme Settings and dismisses', (
    tester,
  ) async {
    await tester.pumpWidget(
      shadHarness(
        brightness: Brightness.light,
        homeBuilder:
            (context) => Scaffold(
              body: Center(
                child: Builder(
                  builder:
                      (context) => FilledButton(
                        onPressed:
                            () => showChatShadDialog<void>(
                              context: context,
                              builder:
                                  (_) => const HyveDialog(
                                    key: ValueKey<String>('test-hyve-dialog'),
                                    closeButtonKey: ValueKey<String>(
                                      'test-hyve-dialog-close',
                                    ),
                                    title: Text('Dialog title'),
                                    child: SizedBox(width: 320, height: 120),
                                  ),
                            ),
                        child: const Text('Open dialog'),
                      ),
                ),
              ),
            ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    final close = find.byKey(const ValueKey<String>('test-hyve-dialog-close'));
    final dialogSurface =
        find.ancestor(of: close, matching: find.byType(Stack)).first;
    expect(find.byType(ShadDialog), findsOneWidget);
    expect(tester.getSize(close), const Size.square(44));
    expect(
      find.descendant(of: close, matching: find.byIcon(LucideIcons.x)),
      findsOneWidget,
    );
    expect(
      tester.getRect(dialogSurface).right - tester.getRect(close).right,
      closeTo(8, 0.01),
    );
    expect(
      tester.getRect(close).top - tester.getRect(dialogSurface).top,
      closeTo(12, 0.01),
    );

    await tester.tap(close);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('test-hyve-dialog')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

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
