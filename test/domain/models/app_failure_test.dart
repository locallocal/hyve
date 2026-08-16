import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/domain/models/models.dart';

void main() {
  test('classifies retryable transport failures without exposing cause', () {
    final failure = AppFailure.from(
      TimeoutException('secret endpoint and response body'),
    );

    expect(failure.kind, AppFailureKind.networkTimeout);
    expect(failure.retryable, isTrue);
    expect(failure.code, 'network_timeout');
    expect(failure.toString(), 'AppFailure(network_timeout)');
    expect(failure.toString(), isNot(contains('secret endpoint')));
  });

  test('classifies provider authentication and rate limiting', () {
    final authentication = AppFailure.from(Exception('HTTP 401 API key bad'));
    final rateLimit = AppFailure.from(Exception('HTTP 429 rate limit'));

    expect(authentication.kind, AppFailureKind.authentication);
    expect(authentication.retryable, isFalse);
    expect(rateLimit.kind, AppFailureKind.rateLimited);
    expect(rateLimit.retryable, isTrue);
  });

  test('preserves a safe MCP code without exposing its raw message', () {
    final failure = AppFailure.from(
      const McpException(
        'mcp_stdio_start_failed',
        message: 'secret command and environment',
      ),
    );

    expect(failure.kind, AppFailureKind.providerRejected);
    expect(failure.code, 'mcp_stdio_start_failed');
    expect(failure.toString(), isNot(contains('secret command')));
  });
}
