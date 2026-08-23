import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/view_models/project_artifacts_controller.dart';
import 'package:hyve/ui/features/projects/views/project_artifacts_dialog.dart';

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
