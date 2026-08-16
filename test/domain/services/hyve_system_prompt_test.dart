import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/domain/services/hyve_system_prompt.dart';

void main() {
  test('describes Hyve and safely includes operating system details', () {
    final prompt = buildHyveSystemPrompt(
      operatingSystem: 'test<os>',
      operatingSystemVersion: '1.0 & newer',
    );

    expect(prompt, startsWith('<hyve_application_context>'));
    expect(prompt, contains('Application: Hyve'));
    expect(
      prompt,
      contains(
        'Hyve is a cross-platform AI chat client for configurable '
        'assistants, Skills, MCP tools, and locally stored conversations.',
      ),
    );
    expect(prompt, contains('Operating system type: test&lt;os&gt;'));
    expect(prompt, contains('Operating system version: 1.0 &amp; newer'));
    expect(prompt, endsWith('</hyve_application_context>'));
  });

  test('places Hyve context before the existing system prompt', () {
    final prompt = prependHyveSystemPrompt(
      '  Existing assistant instructions.  ',
      hyveSystemPromptProvider: _testHyveSystemPrompt,
    );

    expect(prompt, startsWith('<hyve_application_context>'));
    expect(
      prompt.indexOf('</hyve_application_context>'),
      lessThan(prompt.indexOf('Existing assistant instructions.')),
    );
    expect(prompt, endsWith('Existing assistant instructions.'));
  });

  test('safely describes the current agent and conversation identity', () {
    final prompt = buildHyveConversationContext(
      agentId: 'agent<1>',
      agentName: 'Research & Review',
      conversationId: 'chat>2',
    );

    expect(prompt, startsWith('<hyve_conversation_context>'));
    expect(
      prompt,
      contains('Application-provided runtime identity for the current turn.'),
    );
    expect(prompt, contains('Agent ID: agent&lt;1&gt;'));
    expect(prompt, contains('Agent name: Research &amp; Review'));
    expect(prompt, contains('Current conversation ID: chat&gt;2'));
    expect(prompt, endsWith('</hyve_conversation_context>'));
  });
}

String _testHyveSystemPrompt() => buildHyveSystemPrompt(
  operatingSystem: 'TestOS',
  operatingSystemVersion: '1.2.3',
);
