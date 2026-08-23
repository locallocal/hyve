import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/ui/features/chats/views/chat_item.dart';

import '../../../../support/widget_test_support.dart';

void main() {
  testWidgets(
    'selected project placeholder icon contrasts with its background',
    (tester) async {
      for (final brightness in Brightness.values) {
        await tester.pumpWidget(
          shadHarness(
            brightness: brightness,
            homeBuilder:
                (_) => Scaffold(
                  body: SizedBox(
                    width: 320,
                    child: ChatListItem(
                      title: 'Project',
                      lastMessage: 'Latest update',
                      timestamp: '09:42',
                      isSelected: true,
                      onTap: () {},
                    ),
                  ),
                ),
          ),
        );
        await tester.pumpAndSettle();

        final iconFinder = find.byIcon(Icons.folder_outlined);
        final icon = tester.widget<Icon>(iconFinder);
        final iconContext = tester.element(iconFinder);
        final scheme = ShadTheme.of(iconContext).colorScheme;
        final background =
            (iconContext
                        .findAncestorWidgetOfExactType<DecoratedBox>()!
                        .decoration
                    as BoxDecoration)
                .color!;

        expect(icon.color, scheme.mutedForeground, reason: brightness.name);
        expect(background, scheme.muted, reason: brightness.name);
        expect(
          _contrastRatio(icon.color!, background),
          greaterThanOrEqualTo(3),
          reason: brightness.name,
        );
        expect(tester.takeException(), isNull);
      }
    },
  );
}

double _contrastRatio(Color foreground, Color background) {
  final lighter = foreground.computeLuminance();
  final darker = background.computeLuminance();
  final high = lighter > darker ? lighter : darker;
  final low = lighter > darker ? darker : lighter;
  return (high + 0.05) / (low + 0.05);
}
