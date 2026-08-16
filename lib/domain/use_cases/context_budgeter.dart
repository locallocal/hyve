import 'dart:math' as math;

import 'package:hyve/domain/models/conversation_memory.dart';

final class ContextBudgetException implements Exception {
  const ContextBudgetException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class RecentTurnSelection {
  RecentTurnSelection({
    required List<ConversationTurn> included,
    required List<ConversationTurn> omitted,
    required this.estimatedTokens,
  }) : included = List.unmodifiable(included),
       omitted = List.unmodifiable(omitted);

  final List<ConversationTurn> included;
  final List<ConversationTurn> omitted;
  final int estimatedTokens;
}

final class ContextBudgeter {
  const ContextBudgeter({this.policy = const ContextBudgetPolicy()});

  final ContextBudgetPolicy policy;

  int calculateInputBudget(
    ModelContextProfile profile, {
    int? reservedOutputTokens,
  }) {
    final safetyMargin = math.max(
      policy.minimumSafetyMarginTokens,
      (profile.contextWindowTokens * policy.safetyMarginRatio).floor(),
    );
    final budget =
        profile.contextWindowTokens -
        (reservedOutputTokens ?? profile.defaultMaxOutputTokens) -
        policy.protocolOverheadTokens -
        safetyMargin;
    if (budget <= 0) {
      throw const ContextBudgetException(
        'System constraints and output reservation exceed the model context. '
        'Reduce the prompt or output limit, or select a larger context model.',
      );
    }
    return budget;
  }

  int historyLookupReserve(int inputBudgetTokens) => math.min(
    policy.maximumHistoryLookupReserveTokens,
    (inputBudgetTokens * policy.historyLookupReserveRatio).floor(),
  );

  RecentTurnSelection selectRecentTurns({
    required List<ConversationTurn> turns,
    required int availableTokens,
    int? minimumRecentTurns,
  }) {
    if (availableTokens < 0) {
      throw ArgumentError.value(availableTokens, 'availableTokens');
    }
    final minimum = minimumRecentTurns ?? policy.minimumRecentTurns;
    final includedReversed = <ConversationTurn>[];
    var used = 0;
    for (final turn in turns.reversed) {
      if (!turn.isClosed) continue;
      final mustKeep = includedReversed.length < minimum;
      if (!mustKeep && used + turn.estimatedTokens > availableTokens) break;
      includedReversed.add(turn);
      used += turn.estimatedTokens;
    }
    final included = includedReversed.reversed.toList(growable: false);
    final includedIds = included.map((turn) => turn.id).toSet();
    final omitted = [
      for (final turn in turns)
        if (turn.isClosed && !includedIds.contains(turn.id)) turn,
    ];
    return RecentTurnSelection(
      included: included,
      omitted: omitted,
      estimatedTokens: used,
    );
  }

  ContextCompressionAction actionFor({
    required int estimatedInputTokens,
    required int inputBudgetTokens,
    int actualInputTokens = 0,
    required int completeCandidateTurns,
    required int expectedSavingsTokens,
  }) {
    if (inputBudgetTokens <= 0) {
      throw ArgumentError.value(inputBudgetTokens, 'inputBudgetTokens');
    }
    final ratio = estimatedInputTokens / inputBudgetTokens;
    if (ratio >= policy.hardCompactionRatio ||
        actualInputTokens >=
            inputBudgetTokens * policy.actualInputCompactionRatio) {
      return ContextCompressionAction.synchronous;
    }
    if (ratio >= policy.softCompactionRatio &&
        completeCandidateTurns >= policy.minimumCompactionTurns &&
        expectedSavingsTokens >= policy.minimumCompactionSavingsTokens) {
      return ContextCompressionAction.backgroundReady;
    }
    return ContextCompressionAction.none;
  }
}
