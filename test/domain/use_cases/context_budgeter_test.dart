import 'package:flutter_test/flutter_test.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/use_cases/context_budgeter.dart';

void main() {
  const profile = ModelContextProfile(
    contextWindowTokens: 10000,
    defaultMaxOutputTokens: 1000,
  );

  test('calculates output, protocol, and safety reservations', () {
    const budgeter = ContextBudgeter(
      policy: ContextBudgetPolicy(protocolOverheadTokens: 200),
    );

    expect(budgeter.calculateInputBudget(profile), 8288);
    expect(budgeter.historyLookupReserve(8288), 828);
  });

  test('throws a useful error when P0 cannot fit', () {
    const budgeter = ContextBudgeter();
    const tiny = ModelContextProfile(
      contextWindowTokens: 1000,
      defaultMaxOutputTokens: 900,
    );

    expect(
      () => budgeter.calculateInputBudget(tiny),
      throwsA(isA<ContextBudgetException>()),
    );
  });

  test('selects complete recent turns without splitting them', () {
    const budgeter = ContextBudgeter(
      policy: ContextBudgetPolicy(minimumRecentTurns: 1),
    );
    final turns = [_turn('one', 40), _turn('two', 40), _turn('three', 40)];

    final selection = budgeter.selectRecentTurns(
      turns: turns,
      availableTokens: 85,
    );

    expect(selection.included.map((turn) => turn.id), ['two', 'three']);
    expect(selection.omitted.map((turn) => turn.id), ['one']);
    expect(selection.estimatedTokens, 80);
  });

  test('uses hard and soft compaction thresholds', () {
    const budgeter = ContextBudgeter();

    expect(
      budgeter.actionFor(
        estimatedInputTokens: 900,
        inputBudgetTokens: 1000,
        completeCandidateTurns: 1,
        expectedSavingsTokens: 1,
      ),
      ContextCompressionAction.synchronous,
    );
    expect(
      budgeter.actionFor(
        estimatedInputTokens: 700,
        inputBudgetTokens: 1000,
        completeCandidateTurns: 3,
        expectedSavingsTokens: 1024,
      ),
      ContextCompressionAction.backgroundReady,
    );
  });

  test('never creates holes in the retained recent-turn suffix', () {
    const budgeter = ContextBudgeter(
      policy: ContextBudgetPolicy(minimumRecentTurns: 1),
    );
    final selection = budgeter.selectRecentTurns(
      turns: [
        _turn('old-small', 5),
        _turn('middle-large', 100),
        _turn('latest', 10),
      ],
      availableTokens: 20,
    );

    expect(selection.included.map((turn) => turn.id), ['latest']);
    expect(selection.omitted.map((turn) => turn.id), [
      'old-small',
      'middle-large',
    ]);
  });
}

ConversationTurn _turn(String id, int tokens) =>
    ConversationTurn(id: id, messages: const [], estimatedTokens: tokens);
