import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/ai_models.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/ai_provider_repository.dart';
import 'package:hyve/generated/l10n.dart';
import 'package:hyve/ui/core/widgets/desktop_chat_primitives.dart';
import 'package:hyve/ui/features/chat/views/conversation_model_controls.dart';
import 'package:hyve/utils/theme.dart';

void main() {
  testWidgets('shows inspector-aligned switches and toggles provider options', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final provider = _CapabilityProvider();

    await tester.pumpWidget(_harness(provider));
    await tester.pumpAndSettle();

    final webRow = find.byKey(
      const ValueKey<String>('conversation-web-search-row'),
    );
    final thinkingRow = find.byKey(
      const ValueKey<String>('conversation-deep-thinking-row'),
    );
    final webSwitch = find.byKey(
      const ValueKey<String>('conversation-web-search-toggle'),
    );
    final thinkingSwitch = find.byKey(
      const ValueKey<String>('conversation-deep-thinking-toggle'),
    );
    expect(webRow, findsOneWidget);
    expect(thinkingRow, findsOneWidget);
    expect(find.byType(HyveInspectorInfoRow), findsNWidgets(2));
    expect(find.byType(ShadSwitch), findsNWidgets(2));
    expect(find.byType(ShadButton), findsNothing);
    expect(find.text('联网搜索'), findsOneWidget);
    expect(find.text('深度思考'), findsOneWidget);
    expect(
      tester.getRect(find.text('联网搜索')).left,
      closeTo(tester.getRect(find.text('深度思考')).left, 0.01),
    );
    expect(
      tester.getRect(webSwitch).right,
      closeTo(tester.getRect(webRow).right, 0.01),
    );
    expect(
      tester.getRect(thinkingSwitch).right,
      closeTo(tester.getRect(thinkingRow).right, 0.01),
    );
    expect(tester.getSize(webSwitch).width, 44);
    expect(tester.getSize(thinkingSwitch).width, 44);
    expect(tester.widget<ShadSwitch>(webSwitch).value, isFalse);
    expect(tester.widget<ShadSwitch>(thinkingSwitch).value, isFalse);

    await tester.tap(webSwitch);
    await tester.pump();

    expect(provider.getWebSearch(), isTrue);
    expect(provider.getDeepThinking(), isFalse);
    expect(tester.widget<ShadSwitch>(webSwitch).value, isTrue);
    expect(tester.widget<ShadSwitch>(thinkingSwitch).value, isFalse);

    await tester.tap(thinkingSwitch);
    await tester.pump();

    expect(provider.getDeepThinking(), isTrue);
    expect(tester.widget<ShadSwitch>(thinkingSwitch).value, isTrue);
  });
}

Widget _harness(AiProvider provider) {
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
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const [
            GlobalShadLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            S.delegate,
          ],
          builder: (context, child) => ShadAppBuilder(child: child!),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 320,
                child: ConversationModelControls(provider: provider),
              ),
            ),
          ),
        ),
  );
}

final class _CapabilityProvider extends AiProvider {
  _CapabilityProvider() : super(_bot);

  @override
  bool supportWebSearch() => true;

  @override
  bool supportDeepThinking() => true;

  @override
  Future<void> generateText(List<ChatMessage> messages) async {}
}

final _bot = Bot(
  id: 'bot-1',
  name: 'Bot',
  avatar: '',
  provider: 'test',
  baseURL: '',
  apiKey: '',
  apiType: Bot.apiTypeOpenAI,
  model: 'test-model',
  systemPrompt: '',
  createTimestamp: DateTime(2026),
  modifyTimestamp: DateTime(2026),
);
