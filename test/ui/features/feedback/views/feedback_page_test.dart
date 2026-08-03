import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stars/domain/repositories/feedback_repository.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/l10n/app_localizations.dart';
import 'package:stars/ui/features/feedback/view_models/feedback_view_model.dart';
import 'package:stars/ui/features/feedback/views/feedback_page.dart';
import 'package:stars/utils/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'desktop feedback controls match bot controls and center their text',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      final viewModel = FeedbackViewModel(
        feedbackRepository: const _FakeFeedbackRepository(),
      );
      addTearDown(viewModel.dispose);

      try {
        await tester.pumpWidget(_harness(viewModel));
        await tester.pumpAndSettle();

        final input = find.byKey(
          const ValueKey<String>('feedback-contact-input'),
        );
        expect(input, findsOneWidget);
        expect(
          tester.getSize(input).height,
          DesktopThemeTokens.botFormFieldHeight,
        );

        final editableText = find.descendant(
          of: input,
          matching: find.byType(EditableText),
        );
        await tester.enterText(editableText, 'user@example.com');
        await tester.pump();

        expect(
          tester.getRect(editableText).center.dy,
          closeTo(tester.getRect(input).center.dy, 0.5),
        );

        final submitButton = find.byKey(
          const ValueKey<String>('feedback-submit-button'),
        );
        expect(submitButton, findsOneWidget);
        final submitButtonWidget = tester.widget<ShadButton>(submitButton);
        expect(submitButtonWidget.height, isNull);
        expect(tester.getSize(submitButton).height, 40);

        final submitText = find.descendant(
          of: submitButton,
          matching: find.text(
            S.of(tester.element(submitButton)).submitFeedback,
          ),
        );
        expect(submitText, findsOneWidget);
        expect(
          tester.getRect(submitText).center.dy,
          closeTo(tester.getRect(submitButton).center.dy, 0.5),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    },
  );

  testWidgets('desktop feedback section title follows the app locale', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    final viewModel = FeedbackViewModel(
      feedbackRepository: const _FakeFeedbackRepository(),
    );
    addTearDown(viewModel.dispose);

    try {
      await tester.pumpWidget(_harness(viewModel, locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('Feedback Information'), findsOneWidget);
      expect(find.text('反馈信息'), findsNothing);
    } finally {
      debugDefaultTargetPlatformOverride = null;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  });
}

Widget _harness(
  FeedbackViewModel viewModel, {
  Locale locale = const Locale('zh', 'CN'),
}) {
  final shadTheme = buildStarsShadTheme(
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
          locale: locale,
          supportedLocales: supportedLocales,
          localizationsDelegates: const [
            GlobalShadLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            S.delegate,
          ],
          builder: (context, child) => ShadAppBuilder(child: child!),
          home: FeedbackPage(viewModel: viewModel),
        ),
  );
}

final class _FakeFeedbackRepository implements FeedbackRepository {
  const _FakeFeedbackRepository();

  @override
  Future<void> submit({required String content, String? contact}) async {}
}
