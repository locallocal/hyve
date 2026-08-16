import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/generated/l10n.dart';
import 'package:hyve/l10n/app_localizations.dart';
import 'package:hyve/ui/features/chat/views/attachment_bars.dart';
import 'package:hyve/ui/features/chat/views/audio_player_widget.dart';
import 'package:hyve/utils/theme.dart';

void main() {
  testWidgets(
    'attachment buttons expose localized names, enabled state, and 48px targets',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final semantics = tester.ensureSemantics();
      var cameraCalls = 0;
      var galleryCalls = 0;
      var fileCalls = 0;

      try {
        await tester.pumpWidget(
          _harness(
            AttachmentBars(
              inputModalities: const [InputModality.image, InputModality.file],
              onCameraPressed: () => cameraCalls += 1,
              onGalleryPressed: () => galleryCalls += 1,
              onFilePressed: () => fileCalls += 1,
            ),
          ),
        );
        await tester.pumpAndSettle();

        for (final label in const ['拍照', '相册', '文件']) {
          final button = find.byWidgetPredicate(
            (widget) => widget is IconButton && widget.tooltip == label,
          );
          expect(button, findsOneWidget);
          final size = tester.getSize(button);
          expect(size.width, greaterThanOrEqualTo(48));
          expect(size.height, greaterThanOrEqualTo(48));

          final semanticButton = find.descendant(
            of: button,
            matching: find.bySemanticsLabel(label),
          );
          expect(semanticButton, findsOneWidget);
          expect(
            tester.getSemantics(semanticButton),
            matchesSemantics(
              label: label,
              isButton: true,
              hasEnabledState: true,
              isEnabled: true,
              isFocusable: true,
              hasFocusAction: true,
              hasTapAction: true,
            ),
          );

          await tester.tap(button);
          await tester.pump();
        }

        expect(cameraCalls, 1);
        expect(galleryCalls, 1);
        expect(fileCalls, 1);
      } finally {
        semantics.dispose();
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );

  testWidgets('audio play action has a localized name and 48px target', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final semantics = tester.ensureSemantics();

    try {
      await tester.pumpWidget(
        _harness(
          const AudioPlayerWidget(
            audioFilePath: '/tmp/hyve-ui-02-missing-audio.mp3',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final playAction = find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.tooltip == '播放音频',
      );
      expect(playAction, findsOneWidget);
      final size = tester.getSize(playAction);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
      final semanticButton = find.descendant(
        of: playAction,
        matching: find.bySemanticsLabel('播放音频'),
      );
      expect(semanticButton, findsOneWidget);
      expect(
        tester.getSemantics(semanticButton),
        matchesSemantics(
          label: '播放音频',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasFocusAction: true,
          hasTapAction: true,
        ),
      );

      await tester.pumpWidget(_harness(const SizedBox.shrink()));
      await tester.pump();
    } finally {
      semantics.dispose();
      debugDefaultTargetPlatformOverride = null;
    }
  });
}

Widget _harness(Widget child) {
  final shadTheme = buildHyveShadTheme(
    brightness: Brightness.light,
    fontSize: 16,
  );
  return ShadApp.custom(
    themeMode: ThemeMode.light,
    theme: shadTheme,
    appBuilder:
        (shadContext) => MaterialApp(
          theme: buildShadMaterialBridgeTheme(
            context: shadContext,
            fontSize: 16,
          ),
          locale: const Locale('zh', 'CN'),
          supportedLocales: supportedLocales,
          localizationsDelegates: const [
            GlobalShadLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            S.delegate,
          ],
          builder: (context, appChild) => ShadAppBuilder(child: appChild!),
          home: Scaffold(body: child),
        ),
  );
}
