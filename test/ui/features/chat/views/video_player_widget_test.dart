import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/generated/l10n.dart';
import 'package:hyve/l10n/app_localizations.dart';
import 'package:hyve/ui/features/chat/views/video_player_widget.dart';

void main() {
  testWidgets('video initialization failure uses the current locale', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en', 'US'),
        supportedLocales: supportedLocales,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          S.delegate,
        ],
        home: Scaffold(
          body: VideoPlayerWidget(videoFilePath: '/missing/video.mp4'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unable to load video'), findsOneWidget);
    expect(find.text('无法加载视频'), findsNothing);
  });
}
