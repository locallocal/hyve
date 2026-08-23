import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/ui/features/projects/views/project_initial_load_gate.dart';

void main() {
  testWidgets('holds empty project content until the first snapshot is ready', (
    tester,
  ) async {
    final ready = ValueNotifier<bool>(false);
    addTearDown(ready.dispose);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh', 'CN'),
        home: Scaffold(
          body: ValueListenableBuilder<bool>(
            valueListenable: ready,
            builder: (context, value, _) {
              return ProjectInitialLoadGate(
                ready: value,
                loadingLabel: '正在加载项目',
                child: const Text('发送消息开始协作'),
              );
            },
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('project-workspace-loading')),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('发送消息开始协作'), findsNothing);
    expect(
      tester
          .getSemantics(
            find.byKey(const ValueKey<String>('project-workspace-loading')),
          )
          .label,
      '正在加载项目',
    );

    ready.value = true;
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('project-workspace-loading')),
      findsNothing,
    );
    expect(find.text('发送消息开始协作'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
