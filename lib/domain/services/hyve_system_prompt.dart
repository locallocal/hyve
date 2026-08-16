import 'dart:io';

typedef HyveSystemPromptProvider = String Function();

/// Builds the application context that precedes every model-facing system
/// prompt.
String currentHyveSystemPrompt() => buildHyveSystemPrompt(
  operatingSystem: Platform.operatingSystem,
  operatingSystemVersion: Platform.operatingSystemVersion,
);

String buildHyveSystemPrompt({
  required String operatingSystem,
  required String operatingSystemVersion,
}) {
  final normalizedOperatingSystem = _valueOrUnknown(operatingSystem);
  final normalizedVersion = _valueOrUnknown(operatingSystemVersion);
  return '''
<hyve_application_context>
Application: Hyve
Description: Hyve is a cross-platform AI chat client for configurable assistants, Skills, MCP tools, and locally stored conversations.
Operating system type: ${_xmlText(normalizedOperatingSystem)}
Operating system version: ${_xmlText(normalizedVersion)}
</hyve_application_context>''';
}

/// Builds the stable runtime identity for one conversation turn.
///
/// Keeping identifiers in a dedicated application-owned section prevents
/// them from being confused with the assistant's editable instructions.
String buildHyveConversationContext({
  required String agentId,
  required String agentName,
  required String conversationId,
}) {
  return '''
<hyve_conversation_context>
Purpose: Application-provided runtime identity for the current turn.
Agent ID: ${_xmlText(_valueOrUnknown(agentId))}
Agent name: ${_xmlText(_valueOrUnknown(agentName))}
Current conversation ID: ${_xmlText(_valueOrUnknown(conversationId))}
</hyve_conversation_context>''';
}

String prependHyveSystemPrompt(
  String existingPrompt, {
  HyveSystemPromptProvider hyveSystemPromptProvider = currentHyveSystemPrompt,
}) {
  final hyvePrompt = hyveSystemPromptProvider().trim();
  final normalizedExistingPrompt = existingPrompt.trim();
  if (hyvePrompt.isEmpty) return normalizedExistingPrompt;
  if (normalizedExistingPrompt.isEmpty) return hyvePrompt;
  return '$hyvePrompt\n\n$normalizedExistingPrompt';
}

String _valueOrUnknown(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? 'unknown' : normalized;
}

String _xmlText(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');
