import 'package:flutter_test/flutter_test.dart';
import 'package:stars/domain/services/stars_system_prompt.dart';

void main() {
  test('describes Stars and safely includes operating system details', () {
    final prompt = buildStarsSystemPrompt(
      operatingSystem: 'test<os>',
      operatingSystemVersion: '1.0 & newer',
    );

    expect(prompt, startsWith('<stars_application_context>'));
    expect(prompt, contains('Application: Stars'));
    expect(
      prompt,
      contains(
        'Stars is a cross-platform AI chat client for configurable '
        'assistants, Skills, MCP tools, and locally stored conversations.',
      ),
    );
    expect(prompt, contains('Operating system type: test&lt;os&gt;'));
    expect(prompt, contains('Operating system version: 1.0 &amp; newer'));
    expect(prompt, endsWith('</stars_application_context>'));
  });

  test('places Stars context before the existing system prompt', () {
    final prompt = prependStarsSystemPrompt(
      '  Existing assistant instructions.  ',
      starsSystemPromptProvider: _testStarsSystemPrompt,
    );

    expect(prompt, startsWith('<stars_application_context>'));
    expect(
      prompt.indexOf('</stars_application_context>'),
      lessThan(prompt.indexOf('Existing assistant instructions.')),
    );
    expect(prompt, endsWith('Existing assistant instructions.'));
  });
}

String _testStarsSystemPrompt() => buildStarsSystemPrompt(
  operatingSystem: 'TestOS',
  operatingSystemVersion: '1.2.3',
);
