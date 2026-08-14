import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/l10n/app_localizations.dart';
import 'package:stars/utils/time.dart';

void main() {
  group('formatTimestamp', () {
    testWidgets('uses the calendar date across a midnight boundary', (
      tester,
    ) async {
      final now = DateTime(2026, 8, 14, 0, 1);
      final timestamp = DateTime(2026, 8, 13, 23, 59);

      final result = await _format(tester, timestamp: timestamp, now: now);

      expect(result, DateFormat.yMd('en_US').format(timestamp));
    });

    testWidgets('keeps relative minutes for earlier times on the same day', (
      tester,
    ) async {
      final result = await _format(
        tester,
        timestamp: DateTime(2026, 8, 14, 9, 55),
        now: DateTime(2026, 8, 14, 10),
      );

      expect(result, '5 minutes ago');
    });

    testWidgets('formats earlier hours using the active locale', (
      tester,
    ) async {
      final timestamp = DateTime(2026, 8, 14, 8, 15);

      final result = await _format(
        tester,
        timestamp: timestamp,
        now: DateTime(2026, 8, 14, 10),
      );

      expect(result, DateFormat.jm('en_US').format(timestamp));
    });

    testWidgets('does not describe a future time as just now', (tester) async {
      final timestamp = DateTime(2026, 8, 14, 10, 5);

      final result = await _format(
        tester,
        timestamp: timestamp,
        now: DateTime(2026, 8, 14, 10),
      );

      expect(result, DateFormat.jm('en_US').format(timestamp));
      expect(result, isNot('Just now'));
    });

    testWidgets('formats future calendar dates instead of relative text', (
      tester,
    ) async {
      final timestamp = DateTime(2026, 8, 15, 10);

      final result = await _format(
        tester,
        timestamp: timestamp,
        now: DateTime(2026, 8, 14, 10),
      );

      expect(result, DateFormat.yMd('en_US').format(timestamp));
      expect(result, isNot('Just now'));
    });

    testWidgets('uses locale-aware date ordering', (tester) async {
      final timestamp = DateTime(2026, 8, 13, 10);
      final now = DateTime(2026, 8, 14, 10);

      final english = await _format(tester, timestamp: timestamp, now: now);
      final chinese = await _format(
        tester,
        timestamp: timestamp,
        now: now,
        locale: const Locale('zh', 'CN'),
      );

      expect(english, DateFormat.yMd('en_US').format(timestamp));
      expect(chinese, DateFormat.yMd('zh_CN').format(timestamp));
      expect(chinese, isNot(english));
    });
  });
}

Future<String> _format(
  WidgetTester tester, {
  required DateTime timestamp,
  required DateTime now,
  Locale locale = const Locale('en', 'US'),
}) async {
  late String result;
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        S.delegate,
      ],
      home: Builder(
        builder: (context) {
          result = formatTimestamp(context, timestamp, clock: () => now);
          return Text(result);
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return result;
}
