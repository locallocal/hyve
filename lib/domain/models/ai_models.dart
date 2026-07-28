import 'package:stars/domain/models/models.dart';

class ChatMessage {
  ChatMessage({
    required this.role,
    required this.content,
    List<String> images = const [],
    List<String> files = const [],
  }) : images = List<String>.unmodifiable(images),
       files = List<String>.unmodifiable(files);

  final String role;
  final String content;
  final List<String> images;
  final List<String> files;
}

typedef StreamResponseCallback = void Function(String text);
typedef ToolCallCallback = void Function(MessageToolCall toolCall);
typedef CommandExecutionCallback =
    void Function(MessageCommandExecution commandExecution);
typedef TokenUsageCallback = void Function(ModelTokenUsage usage);
typedef ProviderCompleteCallback = void Function();
typedef ProviderErrorCallback = void Function(String error);

enum ProviderTerminalType { completed, cancelled, failed }

class ProviderTerminalEvent {
  const ProviderTerminalEvent({required this.type, this.error});

  final ProviderTerminalType type;
  final String? error;
}

typedef ProviderTerminalCallback = void Function(ProviderTerminalEvent event);

final class AiProviderCapabilities {
  const AiProviderCapabilities({
    this.supportsStructuredToolCalls = false,
    this.supportsToolResults = false,
    this.supportsParallelToolCalls = false,
  });

  static const legacy = AiProviderCapabilities();

  final bool supportsStructuredToolCalls;
  final bool supportsToolResults;
  final bool supportsParallelToolCalls;

  bool get supportsAutomaticSkillActivation =>
      supportsStructuredToolCalls && supportsToolResults;
}

final class SkillToolCall {
  SkillToolCall({
    required this.callId,
    required this.name,
    Map<String, Object?> arguments = const {},
  }) : arguments = Map<String, Object?>.unmodifiable(arguments);

  final String callId;
  final String name;
  final Map<String, Object?> arguments;
}

final class SkillToolResult {
  const SkillToolResult({
    required this.callId,
    required this.name,
    required this.content,
    this.isError = false,
  });

  final String callId;
  final String name;
  final String content;
  final bool isError;
}

final class SkillToolTurn {
  SkillToolTurn({
    List<SkillToolCall> calls = const [],
    this.isComplete = false,
    this.tokenUsage = ModelTokenUsage.empty,
  }) : calls = List<SkillToolCall>.unmodifiable(calls);

  final List<SkillToolCall> calls;
  final bool isComplete;
  final ModelTokenUsage tokenUsage;
}

final class SkillToolSessionRequest {
  SkillToolSessionRequest({
    required List<ChatMessage> messages,
    required List<SkillCatalogEntry> catalog,
  }) : messages = List<ChatMessage>.unmodifiable(messages),
       catalog = List<SkillCatalogEntry>.unmodifiable(catalog);

  final List<ChatMessage> messages;
  final List<SkillCatalogEntry> catalog;
}

abstract interface class SkillToolSession {
  Future<SkillToolTurn> start();

  Future<SkillToolTurn> continueWith(List<SkillToolResult> results);

  void close();
}

enum ProviderCancellationStatus { requested, alreadyRequested, unsupported }

class ProviderCancellationResult {
  const ProviderCancellationResult(this.status);

  final ProviderCancellationStatus status;

  bool get accepted =>
      status == ProviderCancellationStatus.requested ||
      status == ProviderCancellationStatus.alreadyRequested;
}
