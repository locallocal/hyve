import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/view_models/project_artifacts_controller.dart';
import 'package:hyve/ui/features/projects/views/project_artifacts_dialog.dart';

import '../../../../support/widget_test_support.dart';

void main() {
  testWidgets('initial artifact refresh runs after the mounting build', (
    tester,
  ) async {
    final controller = _SynchronousArtifactsController();
    addTearDown(controller.dispose);

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
                      ),
                ),
          ),
        ),
      ),
    );

    expect(controller.refreshCount, 1);
    expect(tester.takeException(), isNull);

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
              (_) => Scaffold(
                body: ProjectArtifactsDialog(
                  viewModel: controller,
                  embedded: true,
                ),
              ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const ValueKey<String>('artifact-primary-toolbar')),
        findsOneWidget,
      );
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
          expect(control.value.height, 36, reason: control.key);
        }
        expect(primaryRow.height, 36);
      }

      expectAlignedRow();

      tester.view.physicalSize = const Size(392, 720);
      await tester.pumpAndSettle();

      expectAlignedRow();
      expect(tester.takeException(), isNull);
    });
  });

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
  int refreshCount = 0;

  @override
  List<ProjectArtifactEntry> get artifacts => const <ProjectArtifactEntry>[];

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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
