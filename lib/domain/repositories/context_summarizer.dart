import 'package:stars/domain/models/conversation_memory.dart';
import 'package:stars/domain/models/message.dart';

final class ContextSummaryRequest {
  ContextSummaryRequest({
    required this.chatId,
    required this.summaryId,
    required List<Message> sourceMessages,
    this.previousSummary,
    required this.targetTokens,
  }) : sourceMessages = List.unmodifiable(sourceMessages);

  final String chatId;
  final String summaryId;
  final List<Message> sourceMessages;
  final ConversationSummaryDocument? previousSummary;
  final int targetTokens;
}

final class ContextSummaryResult {
  ContextSummaryResult({
    required this.markdown,
    List<ConversationMemoryItem> items = const [],
    this.usage = ModelTokenUsage.empty,
    this.provider = '',
    this.model = '',
  }) : items = List.unmodifiable(items);

  final String markdown;
  final List<ConversationMemoryItem> items;
  final ModelTokenUsage usage;
  final String provider;
  final String model;
}

abstract interface class ContextSummarizer {
  Future<ContextSummaryResult> summarize(ContextSummaryRequest request);
}
