import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/data/services/mcp/secure_mcp_credential_store.dart';
import 'package:hyve/domain/models/models.dart';

import '../../../helpers/memory_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('round-trips and deletes an MCP credential in secure storage', () async {
    final store = SecureMcpCredentialStore();
    final expiresAt = DateTime.utc(2030, 1, 2, 3, 4);

    await store.write(
      'server-1',
      McpCredential(
        accessToken: 'access-secret',
        scope: 'tools.read',
        expiresAt: expiresAt,
      ),
    );
    final restored = await store.read('server-1');

    expect(restored?.accessToken, 'access-secret');
    expect(restored?.scope, 'tools.read');
    expect(restored?.expiresAt, expiresAt);
    expect(restored.toString(), isNot(contains('access-secret')));

    await store.delete('server-1');
    expect(await store.read('server-1'), isNull);
  });

  test('stores stdio environment variables as secure credentials', () async {
    final store = SecureMcpCredentialStore();

    await store.write(
      'stdio-1',
      McpCredential(
        environment: {'API_KEY': 'stdio-secret', 'MCP_REGION': 'local'},
      ),
    );
    final restored = await store.read('stdio-1');

    expect(restored?.accessToken, isEmpty);
    expect(restored?.environment, {
      'API_KEY': 'stdio-secret',
      'MCP_REGION': 'local',
    });
    expect(restored.toString(), isNot(contains('stdio-secret')));
  });

  test(
    'rejects malformed credential records instead of accepting old shapes',
    () async {
      FlutterSecureStorage.setMockInitialValues({
        'hyve.mcp.credential.server-1': '{"accessToken":"old-shape"}',
      });
      final store = SecureMcpCredentialStore();

      await expectLater(store.read('server-1'), throwsFormatException);
    },
  );

  test('migrates and removes a legacy Apple credential on read', () async {
    final legacyStorage = MemorySecureStorage();
    final credential = McpCredential(accessToken: 'legacy-access-token');
    await SecureMcpCredentialStore(
      storage: legacyStorage,
    ).write('server-1', credential);
    final currentStorage = MemorySecureStorage();

    final restored = await SecureMcpCredentialStore(
      storage: currentStorage,
      legacyStorage: legacyStorage,
    ).read('server-1');

    expect(restored?.accessToken, 'legacy-access-token');
    expect(currentStorage.values, contains('hyve.mcp.credential.server-1'));
    expect(
      legacyStorage.values,
      isNot(contains('hyve.mcp.credential.server-1')),
    );
  });

  test('does not migrate a malformed legacy Apple credential', () async {
    final legacyStorage = MemorySecureStorage({
      'hyve.mcp.credential.server-1': '{"accessToken":"old-shape"}',
    });
    final currentStorage = MemorySecureStorage();
    final store = SecureMcpCredentialStore(
      storage: currentStorage,
      legacyStorage: legacyStorage,
    );

    await expectLater(store.read('server-1'), throwsFormatException);

    expect(currentStorage.values, isEmpty);
    expect(legacyStorage.values, contains('hyve.mcp.credential.server-1'));
  });
}
