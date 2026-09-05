import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/view_models/project_artifacts_controller.dart';
import 'package:hyve/ui/features/projects/views/project_artifacts_dialog.dart';
import 'package:hyve/ui/features/projects/views/project_ui.dart';
import 'package:hyve/utils/theme.dart';

import '../../../../support/widget_test_support.dart';

void main() {
  testWidgets('initial artifact refresh runs after the mounting build', (
    tester,
  ) async {
    final controller = _SynchronousArtifactsController();
    addTearDown(controller.dispose);
    var closeRequests = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListenableBuilder(
            listenable: controller,
            builder:
                (context, _) => Builder(
                  builder:
                      (context) => ProjectArtifactsDialog(
                        viewModel: controller,
                        embedded: true,
                        onClose: () => closeRequests += 1,
                      ),
                ),
          ),
        ),
      ),
    );

    expect(controller.refreshCount, 1);
    expect(tester.takeException(), isNull);

    await tester.tap(
      find.byKey(const ValueKey<String>('project-artifacts-close')),
    );
    await tester.pump();
    expect(closeRequests, 1);

    await tester.pump();
    expect(find.byType(ProjectArtifactsDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('artifact toolbar controls share one exactly aligned row', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 720);
    addTearDown(tester.view.reset);
    final controller = _SynchronousArtifactsController();
    addTearDown(controller.dispose);

    await withDesktopPlatform(() async {
      await tester.pumpWidget(
        shadHarness(
          brightness: Brightness.light,
          homeBuilder:
              (context) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(padding: const EdgeInsets.only(top: 24)),
                child: Scaffold(
                  body: ProjectArtifactsDialog(
                    viewModel: controller,
                    embedded: true,
                    onClose: () {},
                  ),
                ),
              ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final header = find.byKey(
        const ValueKey<String>('project-artifacts-header'),
      );
      expect(header, findsOneWidget);
      expect(tester.widget(header), isA<ProjectSectionHeader>());
      expect(
        find.ancestor(of: header, matching: find.byType(SafeArea)),
        findsOneWidget,
      );
      expect(tester.getRect(header).top, 44);
      expect(find.text('浏览项目文件、预览版本历史，并使用系统软件打开文件。'), findsOneWidget);
      final headerIconFrame = find.descendant(
        of: header,
        matching: find.byKey(
          const ValueKey<String>('project-section-header-icon-frame'),
        ),
      );
      expect(headerIconFrame, findsOneWidget);
      expect(tester.getSize(headerIconFrame), const Size.square(40));
      final iconDecoration =
          tester.widget<Container>(headerIconFrame).decoration!
              as BoxDecoration;
      final iconBorder = iconDecoration.border! as Border;
      expect(
        iconBorder.top.color,
        ShadTheme.of(tester.element(header)).colorScheme.border,
      );
      expect(
        find.byKey(const ValueKey<String>('artifact-primary-toolbar')),
        findsOneWidget,
      );
      final backActions = find.byType(ProjectBackAction);
      final shadBackButtons = find.descendant(
        of: backActions,
        matching: find.byType(ShadIconButton),
      );
      expect(backActions, findsNWidgets(2));
      expect(shadBackButtons, findsNWidgets(2));
      for (final button in tester.widgetList<ShadIconButton>(shadBackButtons)) {
        expect(button.variant, ShadButtonVariant.outline);
      }
      void expectAlignedRow() {
        final primaryRow = tester.getRect(
          find.byKey(const ValueKey<String>('artifact-primary-toolbar')),
        );
        final searchContainer = tester.getRect(
          find.byKey(const ValueKey<String>('artifact-search-container')),
        );
        final kindFilter = tester.getRect(
          find.byKey(const ValueKey<String>('artifact-kind-filter')),
        );
        final importButton = tester.getRect(
          find.descendant(
            of: find.byKey(const ValueKey<String>('artifact-import-button')),
            matching: find.byType(ShadButton),
          ),
        );
        final createButton = tester.getRect(
          find.descendant(
            of: find.byKey(const ValueKey<String>('artifact-create-button')),
            matching: find.byType(ShadButton),
          ),
        );
        final artifactSearch = find.descendant(
          of: find.byKey(const ValueKey<String>('artifact-search-field')),
          matching: find.byType(ShadInput),
        );

        expect(searchContainer.left, primaryRow.left);
        expect(searchContainer.width, greaterThan(250));
        expect(searchContainer.right, lessThan(kindFilter.left));
        expect(kindFilter.right, lessThan(importButton.left));
        expect(importButton.right, lessThan(createButton.left));
        expect(createButton.right, primaryRow.right);
        for (final control
            in <String, Rect>{
              'search': searchContainer,
              'kind filter': kindFilter,
              'import': importButton,
              'create': createButton,
            }.entries) {
          expect(control.value.top, primaryRow.top, reason: control.key);
          expect(
            control.value.height,
            HyveDesktopThemeSpec.botFormFieldHeight,
            reason: control.key,
          );
        }
        expect(primaryRow.height, HyveDesktopThemeSpec.botFormFieldHeight);
        expect(
          tester.widget<ShadInput>(artifactSearch).alignment,
          AlignmentDirectional.centerStart,
        );
        expect(
          tester.widget<ShadInput>(artifactSearch).placeholderAlignment,
          AlignmentDirectional.centerStart,
        );
        expect(
          tester
              .getRect(
                find.descendant(
                  of: artifactSearch,
                  matching: find.byType(Text),
                ),
              )
              .center
              .dy,
          closeTo(tester.getRect(artifactSearch).center.dy, 0.5),
        );
        expect(
          tester
              .getRect(
                find.descendant(
                  of: artifactSearch,
                  matching: find.byType(EditableText),
                ),
              )
              .center
              .dy,
          closeTo(tester.getRect(artifactSearch).center.dy, 0.5),
        );
      }

      expectAlignedRow();

      tester.view.physicalSize = const Size(392, 720);
      await tester.pumpAndSettle();

      expectAlignedRow();
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('artifact tiles use Shad action surfaces without Material ink', (
    tester,
  ) async {
    final controller = _SynchronousArtifactsController(
      artifacts: <ProjectArtifactEntry>[_artifactEntry()],
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      shadHarness(
        brightness: Brightness.light,
        homeBuilder:
            (_) =>
                ProjectArtifactsDialog(viewModel: controller, embedded: true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNothing);
    expect(find.byType(HyveDesktopActionSurface), findsOneWidget);
    expect(find.byType(ShadCard), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final brightness in <Brightness>[Brightness.light, Brightness.dark]) {
    testWidgets('artifact row stays readable while its menu is open in '
        '${brightness.name} mode', (tester) async {
      final controller = _SynchronousArtifactsController(
        artifacts: <ProjectArtifactEntry>[
          _artifactEntryAt('root', 'README.md'),
        ],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        shadHarness(
          brightness: brightness,
          locale: const Locale('en'),
          homeBuilder:
              (_) => Scaffold(
                body: ProjectThemeScope(
                  child: ProjectArtifactsDialog(
                    viewModel: controller,
                    embedded: true,
                  ),
                ),
              ),
        ),
      );
      await tester.pumpAndSettle();

      final artifact = find.byKey(
        const ValueKey<String>('project-artifact-root'),
      );
      final popover = find.descendant(
        of: artifact,
        matching: find.byType(ShadPopover),
      );
      final moreButton = find.descendant(
        of: artifact,
        matching: find.byIcon(LucideIcons.ellipsis),
      );
      expect(popover, findsOneWidget);
      expect(moreButton, findsOneWidget);

      final artifactCard = find.descendant(
        of: artifact,
        matching: find.byType(ShadCard),
      );
      final colors = ShadTheme.of(tester.element(artifact)).colorScheme;

      void expectRowColors(Color background, Color foreground) {
        final artifactCardWidget = tester.widget<ShadCard>(artifactCard);
        final title = tester.widget<Text>(find.text('README.md'));
        expect(artifactCardWidget.backgroundColor, background);
        expect(title.style?.color, foreground);
        expect(artifactCardWidget.backgroundColor, isNot(title.style?.color));
      }

      expect(find.text('Preview and version history'), findsNothing);
      expectRowColors(colors.card, colors.cardForeground);

      await tester.tap(moreButton);
      await tester.pumpAndSettle();

      final previewLabel = find.text('Preview and version history');

      expect(previewLabel, findsOneWidget);
      expect(find.text('Open with system app'), findsOneWidget);
      expectRowColors(colors.card, colors.cardForeground);
      expect(
        find.descendant(of: artifact, matching: find.byType(ListTile)),
        findsNothing,
      );
      expect(find.byType(ShadDialog), findsNothing);

      await tester.tap(find.text('Open with system app'));
      await tester.pumpAndSettle();

      expect(controller.openedArtifactIds, <String>['root']);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'browses folders, returns, previews files, and opens externally',
    (tester) async {
      final rootFile = _artifactEntryAt('root', 'README.md');
      final summary = _artifactEntryAt('summary', 'reports/summary.md');
      final nested = _artifactEntryAt('nested', 'reports/2026/result.md');
      final controller = _SynchronousArtifactsController(
        artifacts: <ProjectArtifactEntry>[rootFile, summary, nested],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        shadHarness(
          brightness: Brightness.light,
          locale: const Locale('en'),
          homeBuilder:
              (_) => Scaffold(
                body: SizedBox(
                  width: 900,
                  height: 720,
                  child: ProjectArtifactsDialog(
                    viewModel: controller,
                    embedded: true,
                  ),
                ),
              ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('artifact-directory-reports')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('project-artifact-root')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('project-artifact-summary')),
        findsNothing,
      );

      await tester.tap(
        find.byKey(const ValueKey<String>('artifact-directory-reports')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('artifact-directory-2026')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('project-artifact-summary')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey<String>('artifact-directory-2026')),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey<String>('project-artifact-nested')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey<String>('artifact-directory-back')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('project-artifact-summary')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('artifact-markdown-preview')),
        findsOneWidget,
      );
      expect(find.text('Preview: summary.md'), findsOneWidget);
      final previewDialog = tester.widget<ShadDialog>(
        find.byType(ShadDialog).last,
      );
      expect(previewDialog.constraints?.maxWidth, greaterThan(720));
      expect(previewDialog.constraints?.maxHeight, greaterThan(520));
      final metadataRect = tester.getRect(
        find.byKey(const ValueKey<String>('artifact-preview-metadata')),
      );
      final actionsRect = tester.getRect(
        find.byKey(const ValueKey<String>('artifact-preview-actions')),
      );
      final badgesRect = tester.getRect(
        find.byKey(const ValueKey<String>('artifact-version-badges')),
      );
      final closeRect = tester.getRect(
        find.byKey(const ValueKey<String>('project-artifact-preview-close')),
      );
      final previewLayoutSize = tester.getSize(
        find.byKey(const ValueKey<String>('artifact-preview-layout')),
      );
      expect(
        (metadataRect.center.dy - actionsRect.center.dy).abs(),
        lessThanOrEqualTo(1),
      );
      expect(actionsRect.top, greaterThanOrEqualTo(closeRect.bottom + 4));
      expect(actionsRect.left, greaterThan(metadataRect.left));
      expect(badgesRect.top - metadataRect.bottom, inInclusiveRange(0, 8));
      expect(
        previewLayoutSize.height,
        greaterThan(previewDialog.constraints!.maxHeight - 100),
      );
      expect(find.widgetWithText(ProjectActionButton, 'Close'), findsNothing);

      await tester.tap(
        find.byKey(const ValueKey<String>('artifact-open-external')),
      );
      await tester.pumpAndSettle();
      expect(controller.openedArtifactIds, <String>['summary']);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('supports retained offstage layout in expanding Shad tabs', (
    tester,
  ) async {
    final controller = _SynchronousArtifactsController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      shadHarness(
        brightness: Brightness.light,
        homeBuilder:
            (_) => SizedBox(
              width: 368,
              height: 700,
              child: ShadTabs<int>(
                value: 1,
                maintainState: true,
                tabs: <ShadTab<int>>[
                  ShadTab<int>(
                    value: 0,
                    expandContent: true,
                    content: ProjectArtifactsDialog(
                      viewModel: controller,
                      embedded: true,
                    ),
                    child: const Text('Artifacts tab'),
                  ),
                  const ShadTab<int>(
                    value: 1,
                    expandContent: true,
                    content: SizedBox.shrink(),
                    child: Text('Execution tab'),
                  ),
                ],
              ),
            ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}

final class _SynchronousArtifactsController extends ChangeNotifier
    implements ProjectArtifactsController {
  _SynchronousArtifactsController({
    this.artifacts = const <ProjectArtifactEntry>[],
  });

  int refreshCount = 0;
  final List<String> openedArtifactIds = <String>[];

  @override
  final List<ProjectArtifactEntry> artifacts;

  @override
  bool get artifactBusy => false;

  @override
  String get errorCode => '';

  @override
  Future<void> refreshArtifacts({
    String? query,
    Set<ProjectArtifactKind>? kinds,
  }) {
    refreshCount += 1;
    notifyListeners();
    return Future<void>.value();
  }

  @override
  Future<List<ProjectArtifactVersion>> artifactVersions(
    ProjectArtifactEntry entry,
  ) async => <ProjectArtifactVersion>[entry.currentVersion];

  @override
  Future<ProjectArtifactReadResult?> previewArtifact(
    ProjectArtifactEntry entry, {
    String versionId = '',
  }) async {
    final text = 'Preview: ${entry.artifact.name}';
    return ProjectArtifactReadResult(
      artifact: entry.artifact,
      version: entry.currentVersion,
      bytes: Uint8List.fromList(utf8.encode(text)),
      offset: 0,
      nextOffset: text.length,
      endOfFile: true,
      text: text,
    );
  }

  @override
  Future<List<ProjectArtifactMessageReference>> artifactMessageReferences(
    ProjectArtifactEntry entry, {
    String versionId = '',
  }) async => const <ProjectArtifactMessageReference>[];

  @override
  Future<String?> prepareArtifactFile(
    ProjectArtifactEntry entry, {
    String versionId = '',
  }) async => '/tmp/${entry.artifact.name}';

  @override
  Future<bool> openArtifact(
    ProjectArtifactEntry entry, {
    String versionId = '',
  }) async {
    openedArtifactIds.add(entry.artifact.id);
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ProjectArtifactEntry _artifactEntry() {
  final createdAt = DateTime(2026, 8, 22);
  final artifact = ProjectArtifact(
    id: 'artifact-1',
    projectId: 'project-1',
    name: 'result.md',
    relativePath: 'reports/result.md',
    kind: ProjectArtifactKind.document,
    mimeType: 'text/markdown',
    currentVersionId: 'version-1',
    searchStatus: ProjectArtifactSearchStatus.indexed,
    createdByType: ProjectArtifactActorType.agent,
    createdById: 'agent-1',
    sourceRunId: 'run-1',
    createdAt: createdAt,
    updatedAt: createdAt,
  );
  return ProjectArtifactEntry(
    artifact: artifact,
    currentVersion: ProjectArtifactVersion(
      id: 'version-1',
      artifactId: artifact.id,
      versionNumber: 1,
      relativeBlobPath: 'artifacts/artifact-1/version-1',
      contentDigest:
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      byteLength: 15,
      mimeType: artifact.mimeType,
      createdByType: ProjectArtifactActorType.agent,
      createdById: 'agent-1',
      sourceRunId: 'run-1',
      createdAt: createdAt,
    ),
  );
}

ProjectArtifactEntry _artifactEntryAt(String id, String relativePath) {
  final createdAt = DateTime(2026, 8, 22);
  final name = relativePath.split('/').last;
  final versionId = 'version-$id';
  final artifact = ProjectArtifact(
    id: id,
    projectId: 'project-1',
    name: name,
    relativePath: relativePath,
    kind: ProjectArtifactKind.document,
    mimeType: 'text/markdown',
    currentVersionId: versionId,
    searchStatus: ProjectArtifactSearchStatus.indexed,
    createdByType: ProjectArtifactActorType.agent,
    createdById: 'agent-1',
    sourceRunId: 'run-1',
    createdAt: createdAt,
    updatedAt: createdAt,
  );
  return ProjectArtifactEntry(
    artifact: artifact,
    currentVersion: ProjectArtifactVersion(
      id: versionId,
      artifactId: id,
      versionNumber: 1,
      relativeBlobPath: 'artifacts/blobs/$id/$versionId/content',
      contentDigest:
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      byteLength: 15,
      mimeType: artifact.mimeType,
      createdByType: ProjectArtifactActorType.agent,
      createdById: 'agent-1',
      sourceRunId: 'run-1',
      createdAt: createdAt,
    ),
  );
}
