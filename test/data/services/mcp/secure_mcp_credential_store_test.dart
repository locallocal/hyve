import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stars/data/services/mcp/secure_mcp_credential_store.dart';
import 'package:stars/domain/models/models.dart';

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
}
