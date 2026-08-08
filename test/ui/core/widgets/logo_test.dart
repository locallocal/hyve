import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stars/ui/core/widgets/logo.dart';

void main() {
  testWidgets('loads the bundled Moonshot provider logo', (tester) async {
    await tester.pumpWidget(_logoHarness('Moonshot'));
    await tester.pumpAndSettle();

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('falls back when a provider asset is unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(_logoHarness('missing-provider'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.smart_toy_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _logoHarness(String provider) => MaterialApp(
  home: Builder(
    builder:
        (context) =>
            Center(child: buildProviderLogo(context, '', provider, 24)),
  ),
);
