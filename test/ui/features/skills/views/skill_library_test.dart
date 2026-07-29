import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/skill_repository.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/l10n/app_localizations.dart';
import 'package:stars/ui/features/skills/view_models/skill_library_view_model.dart';
import 'package:stars/ui/features/skills/views/skill_library.dart';
import 'package:stars/utils/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('desktop Skill library filters and clears search', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;

    final viewModel = SkillLibraryViewModel(
      skillRepository: _FakeSkillRepository([
        _skill('Release Notes', 'Create polished changelogs'),
        _skill('Code Review', 'Find concise improvements'),
      ]),
      pickerRepository: const _FakeSkillPickerRepository(),
    );
    addTearDown(viewModel.dispose);
    try {
      await viewModel.load();

      await tester.pumpWidget(_harness(viewModel));
      await tester.pumpAndSettle();

      expect(find.text('Release Notes'), findsOneWidget);
      expect(find.text('Code Review'), findsOneWidget);

      final searchField = find.descendant(
        of: find.byKey(const ValueKey<String>('skill-search-field')),
        matching: find.byType(EditableText),
      );
      await tester.enterText(searchField, 'CONCISE');
      await tester.pump();

      expect(find.text('Release Notes'), findsNothing);
      expect(find.text('Code Review'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey<String>('clear-skill-search')),
      );
      await tester.pump();

      expect(find.text('Release Notes'), findsOneWidget);
      expect(find.text('Code Review'), findsOneWidget);

      await tester.enterText(searchField, 'missing');
      await tester.pump();

      expect(find.text('未找到匹配的技能'), findsOneWidget);
      expect(find.text('Release Notes'), findsNothing);
      expect(find.text('Code Review'), findsNothing);
    } finally {
      debugDefaultTargetPlatformOverride = null;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  });

  testWidgets('desktop Skill library moves between pages', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;

    final viewModel = SkillLibraryViewModel(
      skillRepository: _FakeSkillRepository([
        for (var index = 1; index <= 11; index += 1)
          _skill(
            'Skill ${index.toString().padLeft(2, '0')}',
            'Description $index',
          ),
      ]),
      pickerRepository: const _FakeSkillPickerRepository(),
    );
    addTearDown(viewModel.dispose);
    try {
      await viewModel.load();

      await tester.pumpWidget(_harness(viewModel));
      await tester.pumpAndSettle();

      expect(find.text('Skill 01'), findsOneWidget);
      expect(find.text('Skill 10'), findsOneWidget);
      expect(find.text('Skill 11'), findsNothing);
      expect(find.text('1 / 2'), findsOneWidget);

      final nextPage = find.byKey(const ValueKey<String>('skill-next-page'));
      await tester.ensureVisible(nextPage);
      await tester.tap(nextPage);
      await tester.pump();

      expect(find.text('Skill 01'), findsNothing);
      expect(find.text('Skill 10'), findsNothing);
      expect(find.text('Skill 11'), findsOneWidget);
      expect(find.text('2 / 2'), findsOneWidget);

      final previousPage = find.byKey(
        const ValueKey<String>('skill-previous-page'),
      );
      await tester.tap(previousPage);
      await tester.pump();

      expect(find.text('Skill 01'), findsOneWidget);
      expect(find.text('Skill 11'), findsNothing);
      expect(find.text('1 / 2'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  });

  testWidgets('desktop Skill card actions use the Agent-style menu', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;

    final skill = _skill('Release Notes', 'Create polished changelogs');
    final viewModel = SkillLibraryViewModel(
      skillRepository: _FakeSkillRepository([skill]),
      pickerRepository: const _FakeSkillPickerRepository(),
    );
    addTearDown(viewModel.dispose);
    try {
      await viewModel.load();

      await tester.pumpWidget(_harness(viewModel));
      await tester.pumpAndSettle();

      final menuButton = find.byKey(
        ValueKey<String>('desktop-skill-menu-button-${skill.id}'),
      );
      expect(menuButton, findsOneWidget);
      final menuIconButton = tester.widget<ShadIconButton>(
        find.descendant(of: menuButton, matching: find.byType(ShadIconButton)),
      );
      expect(menuIconButton.decoration?.disableSecondaryBorder, isTrue);
      expect(find.text('技能详情'), findsNothing);
      expect(find.text('卸载技能'), findsNothing);
      expect(
        find.byKey(ValueKey<String>('desktop-skill-details-${skill.id}')),
        findsNothing,
      );

      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      final actionMenu = find.byKey(
        ValueKey<String>('desktop-skill-action-menu-${skill.id}'),
      );
      final detailsAction = find.byKey(
        ValueKey<String>('desktop-skill-details-${skill.id}'),
      );
      expect(actionMenu, findsOneWidget);
      expect(
        find.descendant(of: actionMenu, matching: find.byType(ShadButton)),
        findsNWidgets(2),
      );
      expect(detailsAction, findsOneWidget);
      expect(
        find.byKey(ValueKey<String>('desktop-skill-uninstall-${skill.id}')),
        findsOneWidget,
      );
      expect(find.text('详情'), findsOneWidget);
      expect(find.text('卸载'), findsOneWidget);
      expect(
        tester.getRect(actionMenu).right,
        closeTo(tester.getRect(menuButton).right, 1),
      );

      await tester.tap(detailsAction);
      await tester.pumpAndSettle();

      expect(actionMenu, findsNothing);
      expect(find.byType(ShadDialog), findsOneWidget);
      expect(find.text('Instructions for Release Notes'), findsOneWidget);

      await tester.tap(find.text('关闭'));
      await tester.pumpAndSettle();

      await tester.tap(menuButton);
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(ValueKey<String>('desktop-skill-uninstall-${skill.id}')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ShadDialog), findsOneWidget);
      expect(find.text('确定卸载技能“Release Notes”？相关智能体绑定也会被移除。'), findsOneWidget);

      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
    } finally {
      debugDefaultTargetPlatformOverride = null;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  });
}

Widget _harness(SkillLibraryViewModel viewModel) {
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
          locale: const Locale('zh', 'CN'),
          supportedLocales: supportedLocales,
          localizationsDelegates: const [
            GlobalShadLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            S.delegate,
          ],
          builder: (context, child) => ShadAppBuilder(child: child!),
          home: SkillLibraryPage(viewModel: viewModel),
        ),
  );
}

SkillDescriptor _skill(String name, String description) {
  final timestamp = DateTime(2026, 7, 26);
  return SkillDescriptor(
    id: 'user:$name',
    name: name,
    description: description,
    version: '1.0.0',
    scope: SkillScope.user,
    sourceUri: 'file:///$name',
    rootPath: '/skills/$name',
    contentDigest: 'digest-$name',
    trustState: SkillTrustState.userReviewed,
    validationStatus: SkillValidationStatus.valid,
    compatibility: '',
    installedAt: timestamp,
    updatedAt: timestamp,
  );
}

final class _FakeSkillRepository implements SkillRepository {
  const _FakeSkillRepository(this.skills);

  final List<SkillDescriptor> skills;

  @override
  Stream<List<SkillDescriptor>> get changes => const Stream.empty();

  @override
  Future<List<SkillDescriptor>> getInstalled({
    bool forceRefresh = false,
  }) async => List<SkillDescriptor>.unmodifiable(skills);

  @override
  Future<SkillDescriptor?> getById(String id) async =>
      skills.where((skill) => skill.id == id).firstOrNull;

  @override
  Future<SkillDescriptor> install(SkillImportSource source) =>
      throw UnsupportedError('Import is not used in this test.');

  @override
  Future<SkillContent> load(String skillId, {String? contentDigest}) async {
    final skill = skills.firstWhere((skill) => skill.id == skillId);
    return SkillContent(
      descriptor: skill,
      instructions: 'Instructions for ${skill.name}',
      files: const ['SKILL.md'],
    );
  }

  @override
  Future<SkillResourceContent> readResource(
    String skillId,
    String relativePath, {
    String? contentDigest,
  }) => throw UnsupportedError('Resource reading is not used in this test.');

  @override
  Future<void> uninstall(String skillId) =>
      throw UnsupportedError('Uninstall is not used in this test.');
}

final class _FakeSkillPickerRepository implements SkillPickerRepository {
  const _FakeSkillPickerRepository();

  @override
  Future<SkillImportSource?> pickDirectory() async => null;

  @override
  Future<SkillImportSource?> pickZipArchive() async => null;
}
