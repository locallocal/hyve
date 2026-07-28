import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/generated/l10n.dart';
import 'package:stars/l10n/app_localizations.dart';
import 'package:stars/ui/features/chat/views/tool_approval_card.dart';

void main() {
  testWidgets('shows tool risk and arguments and returns decisions', (
    tester,
  ) async {
    final decisions = <ToolApprovalDecision>[];
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          S.delegate,
        ],
        home: Scaffold(
          body: ToolApprovalCard(
            request: ToolApprovalRequest(
              runId: 'run-1',
              call: ToolCallRequest(
                callId: 'call-1',
                name: 'save_note',
                arguments: const {'title': 'Release'},
              ),
              definition: ToolDefinition(
                name: 'save_note',
                title: 'Save note',
                description: 'Write a note to local storage.',
                inputSchema: const {
                  'type': 'object',
                  'properties': {
                    'title': {'type': 'string'},
                  },
                  'required': ['title'],
                  'additionalProperties': false,
                },
                source: ToolSource.builtIn,
                riskLevel: ToolRiskLevel.write,
                capabilities: const {ToolCapability.localWrite},
              ),
              reason: 'write_requires_approval',
            ),
            onDecision: decisions.add,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('tool-approval-card')), findsOneWidget);
    expect(find.text('Save note'), findsOneWidget);
    expect(find.text('write'), findsOneWidget);
    expect(find.text('title: Release'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('approve-tool-call')));
    await tester.pump();
    expect(decisions, [ToolApprovalDecision.allowOnce]);

    await tester.tap(find.byKey(const ValueKey('deny-tool-call')));
    await tester.pump();
    expect(decisions, [
      ToolApprovalDecision.allowOnce,
      ToolApprovalDecision.deny,
    ]);
  });
}
