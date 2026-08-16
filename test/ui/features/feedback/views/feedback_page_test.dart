import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/repositories/feedback_repository.dart';
import 'package:hyve/generated/l10n.dart';
import 'package:hyve/l10n/app_localizations.dart';
import 'package:hyve/ui/features/feedback/view_models/feedback_view_model.dart';
import 'package:hyve/ui/features/feedback/views/feedback_page.dart';
import 'package:hyve/utils/theme.dart';

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
          HyveDesktopThemeSpec.botFormFieldHeight,
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

  testWidgets('empty feedback uses the feedback-specific validation message', (
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
      await tester.pumpWidget(_harness(viewModel));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey<String>('feedback-submit-button')),
      );
      await tester.pump();

      expect(find.text('请输入反馈内容'), findsOneWidget);
      expect(find.text('请填写智能体名称、API地址和API密钥'), findsNothing);
    } finally {
      debugDefaultTargetPlatformOverride = null;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  });

  testWidgets('narrow mobile feedback supports pseudolocalized text at 2x', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    final viewModel = FeedbackViewModel(
      feedbackRepository: const _FakeFeedbackRepository(),
    );
    addTearDown(viewModel.dispose);

    try {
      await tester.pumpWidget(
        _harness(
          viewModel,
          textScaler: const TextScaler.linear(2),
          stringsDelegate: const _LongFeedbackStringsDelegate(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(_longHelpAndFeedback), findsOneWidget);
      expect(find.text(_longFeedbackInformation), findsOneWidget);
      expect(find.text(_longSubmitFeedback), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text(_longSubmitFeedback));
      await tester.pumpAndSettle();

      expect(find.text(_longFeedbackRequired), findsOneWidget);
      expect(
        tester.widget<SnackBar>(find.byType(SnackBar)).behavior,
        SnackBarBehavior.fixed,
      );
      expect(tester.takeException(), isNull);
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
  TextScaler textScaler = TextScaler.noScaling,
  LocalizationsDelegate<S> stringsDelegate = S.delegate,
}) {
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
          locale: locale,
          supportedLocales: supportedLocales,
          localizationsDelegates: [
            GlobalShadLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            stringsDelegate,
          ],
          builder:
              (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: textScaler),
                child: ShadAppBuilder(child: child!),
              ),
          home: FeedbackPage(viewModel: viewModel),
        ),
  );
}

final class _FakeFeedbackRepository implements FeedbackRepository {
  const _FakeFeedbackRepository();

  @override
  Future<void> submit({required String content, String? contact}) async {}
}

const _longHelpAndFeedback = '⟦Help and feedback — expanded localization⟧';
const _longFeedbackInformation =
    '⟦Detailed feedback information and supporting context⟧';
const _longSubmitFeedback = '⟦Submit this detailed feedback now⟧';
const _longFeedbackRequired =
    '⟦Please enter detailed feedback before submitting this form⟧';

final class _LongFeedbackStrings extends S {
  @override
  String get helpAndFeedback => _longHelpAndFeedback;

  @override
  String get feedbackInformation => _longFeedbackInformation;

  @override
  String get feedbackDescription =>
      '⟦Describe your thoughts, problems, and suggestions in detail⟧';

  @override
  String get contactInfoHint =>
      '⟦Optional contact information for a follow-up response⟧';

  @override
  String get submitFeedback => _longSubmitFeedback;

  @override
  String get feedbackContentRequired => _longFeedbackRequired;
}

final class _LongFeedbackStringsDelegate extends LocalizationsDelegate<S> {
  const _LongFeedbackStringsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<S> load(Locale locale) => SynchronousFuture(_LongFeedbackStrings());

  @override
  bool shouldReload(_LongFeedbackStringsDelegate old) => false;
}
