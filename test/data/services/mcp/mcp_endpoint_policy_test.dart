import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/data/services/mcp/mcp_endpoint_policy.dart';
import 'package:hyve/domain/models/models.dart';

void main() {
  test(
    'accepts HTTPS endpoints that resolve only to public addresses',
    () async {
      final policy = McpEndpointPolicy(
        resolver: (_) async => [InternetAddress('8.8.8.8')],
      );

      await expectLater(
        policy.validate(Uri.parse('https://mcp.example.com/v1')),
        completes,
      );
    },
  );

  test('rejects non-HTTPS and local endpoints', () async {
    final policy = McpEndpointPolicy(
      resolver: (_) async => [InternetAddress('8.8.8.8')],
    );

    await expectLater(
      policy.validate(Uri.parse('http://example.com/mcp')),
      throwsA(
        isA<McpException>().having(
          (error) => error.code,
          'code',
          'mcp_https_required',
        ),
      ),
    );
    await expectLater(
      policy.validate(Uri.parse('https://localhost/mcp')),
      throwsA(
        isA<McpException>().having(
          (error) => error.code,
          'code',
          'mcp_private_endpoint_blocked',
        ),
      ),
    );
  });

  test('rejects DNS rebinding to a private address', () async {
    final policy = McpEndpointPolicy(
      resolver: (_) async => [InternetAddress('192.168.1.12')],
    );

    await expectLater(
      policy.validate(Uri.parse('https://mcp.example.com/v1')),
      throwsA(
        isA<McpException>().having(
          (error) => error.code,
          'code',
          'mcp_private_endpoint_blocked',
        ),
      ),
    );
  });
}
