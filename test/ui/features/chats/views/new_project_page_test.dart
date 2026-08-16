import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/bot_repository.dart';
import 'package:hyve/domain/repositories/chat_repository.dart';
import 'package:hyve/domain/use_cases/create_chat.dart';
import 'package:hyve/generated/l10n.dart';
import 'package:hyve/l10n/app_localizations.dart';
import 'package:hyve/ui/features/chats/view_models/new_project_view_model.dart';
import 'package:hyve/ui/features/chats/views/new_project_page.dart';

import '../../../../support/widget_test_support.dart';

void main() {
  testWidgets('creates a named project with multiple selected Bots', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(tester.view.reset);
    final chatRepository = _ChatRepository();
    final bots = [_bot('bot-1', 'Researcher'), _bot('bot-2', 'Writer')];
    final viewModel = NewProjectViewModel(
      botRepository: _BotRepository(bots),
      createChat: CreateChat(chatRepository: chatRepository),
    );

    await withDesktopPlatform(() async {
      await tester.pumpWidget(
        shadHarness(
          brightness: Brightness.light,
          homeBuilder:
              (context) => Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed:
                        () => showShadDialog<CreatedProject>(
                          context: context,
                          barrierDismissible: false,
                          builder:
                              (context) => NewProjectPage(viewModel: viewModel),
                        ),
                    child: const Text('open'),
                  ),
                ),
              ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('新建项目'), findsOneWidget);
      expect(find.byType(ShadDialog), findsOneWidget);
      expect(
        tester.getSize(
          find.byKey(const ValueKey<String>('new-project-dialog-content')),
        ),
        const Size(840, 720),
      );
      expect(
        find.byKey(const ValueKey<String>('project-name-input')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('project-bot-bot-1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('project-bot-bot-2')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey<String>('create-project-submit')),
      );
      await tester.pump();
      expect(find.text('请输入项目名称。'), findsOneWidget);
      expect(find.text('请至少选择一个智能体。'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey<String>('project-name-input')),
        '发布计划',
      );
      await tester.tap(find.byKey(const ValueKey<String>('project-bot-bot-1')));
      await tester.tap(find.byKey(const ValueKey<String>('project-bot-bot-2')));
      await tester.pump();
      expect(find.text('已选择 2 个'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey<String>('create-project-submit')),
      );
      await tester.pumpAndSettle();

      expect(chatRepository.added, hasLength(1));
      expect(chatRepository.added.single.name, '发布计划');
      expect(chatRepository.added.single.projectBotIds, ['bot-1', 'bot-2']);
      expect(find.text('open'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('mobile dialog renders and selects Bots without a Shad theme', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    final bots = [_bot('bot-1', 'Researcher'), _bot('bot-2', 'Writer')];
    final viewModel = NewProjectViewModel(
      botRepository: _BotRepository(bots),
      createChat: CreateChat(chatRepository: _ChatRepository()),
    );

    await withMobilePlatform(() async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh', 'CN'),
          supportedLocales: supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            S.delegate,
          ],
          home: Builder(
            builder:
                (context) => Scaffold(
                  body: Center(
                    child: FilledButton(
                      onPressed:
                          () => showDialog<CreatedProject>(
                            context: context,
                            builder:
                                (context) =>
                                    NewProjectPage(viewModel: viewModel),
                          ),
                      child: const Text('open'),
                    ),
                  ),
                ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('新建项目'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsNWidgets(2));
      await tester.tap(find.byKey(const ValueKey<String>('project-bot-bot-1')));
      await tester.pump();

      expect(find.text('已选择 1 个'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

Bot _bot(String id, String name) => Bot(
  id: id,
  name: name,
  avatar: '',
  provider: 'OpenAI',
  baseURL: 'https://example.test',
  apiKey: '',
  apiType: Bot.apiTypeOpenAI,
  model: 'test-model',
  systemPrompt: '',
  createTimestamp: DateTime(2026),
  modifyTimestamp: DateTime(2026),
);

final class _BotRepository implements BotRepository {
  _BotRepository(this.items);

  final List<Bot> items;

  @override
  Stream<List<Bot>> get changes => const Stream.empty();

  @override
  Future<List<Bot>> getBots({bool forceRefresh = false}) async => items;

  @override
  Future<Bot?> getBot(String id) async => null;

  @override
  Future<void> addBot(Bot bot) async {}

  @override
  Future<void> updateBot(Bot bot) async {}

  @override
  Future<void> deleteBot(String id) async {}
}

final class _ChatRepository implements ChatRepository {
  final List<Chat> added = <Chat>[];

  @override
  Stream<List<Chat>> get changes => const Stream.empty();

  @override
  Future<void> addChat(Chat chat) async => added.add(chat);

  @override
  Future<List<Chat>> getChats({bool forceRefresh = false}) async => added;

  @override
  Future<Chat?> getChat(String id) async => null;

  @override
  Future<void> deleteChat(String id) async {}

  @override
  Future<void> deleteChatsForBot(String botId) async {}

  @override
  Future<void> updateLastMessage(String id, String content) async {}

  @override
  Future<void> clearHistory(String id) async {}

  @override
  void invalidate() {}
}
