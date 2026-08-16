import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyve/data/services/bot_api_key_cipher.dart';

import '../../helpers/memory_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('encrypts and decrypts a Bot API key across cipher instances', () async {
    final cipher = SecureBotApiKeyCipher();

    final encrypted = await cipher.encrypt(
      botId: 'bot-1',
      apiKey: 'sk-sensitive-value',
    );
    final secondEncrypted = await cipher.encrypt(
      botId: 'bot-1',
      apiKey: 'sk-sensitive-value',
    );

    expect(encrypted, startsWith(SecureBotApiKeyCipher.envelopePrefix));
    expect(encrypted, isNot(contains('sk-sensitive-value')));
    expect(secondEncrypted, isNot(encrypted));
    expect(
      await SecureBotApiKeyCipher().decrypt(
        botId: 'bot-1',
        encrypted: encrypted,
      ),
      'sk-sensitive-value',
    );
  });

  test('authenticates ciphertext against the Bot id and contents', () async {
    final cipher = SecureBotApiKeyCipher();
    final encrypted = await cipher.encrypt(
      botId: 'bot-1',
      apiKey: 'sk-sensitive-value',
    );

    await expectLater(
      cipher.decrypt(botId: 'bot-2', encrypted: encrypted),
      throwsA(isA<SecretBoxAuthenticationError>()),
    );

    final encoded = encrypted.substring(
      SecureBotApiKeyCipher.envelopePrefix.length,
    );
    final bytes = base64Url.decode(encoded);
    bytes[bytes.length ~/ 2] ^= 1;
    final tampered =
        '${SecureBotApiKeyCipher.envelopePrefix}${base64UrlEncode(bytes)}';
    await expectLater(
      cipher.decrypt(botId: 'bot-1', encrypted: tampered),
      throwsA(isA<SecretBoxAuthenticationError>()),
    );
  });

  test('keeps an empty API key empty without creating an envelope', () async {
    final cipher = SecureBotApiKeyCipher();

    expect(await cipher.encrypt(botId: 'bot-1', apiKey: ''), isEmpty);
    expect(await cipher.decrypt(botId: 'bot-1', encrypted: ''), isEmpty);
  });

  test('migrates the legacy Apple master key namespace on read', () async {
    final legacyStorage = MemorySecureStorage();
    final encrypted = await SecureBotApiKeyCipher(
      storage: legacyStorage,
    ).encrypt(botId: 'bot-1', apiKey: 'sk-legacy-value');
    final currentStorage = MemorySecureStorage();

    final decrypted = await SecureBotApiKeyCipher(
      storage: currentStorage,
      legacyStorage: legacyStorage,
    ).decrypt(botId: 'bot-1', encrypted: encrypted);

    expect(decrypted, 'sk-legacy-value');
    expect(currentStorage.values, contains('hyve.bot.api-key.master.v1'));
    expect(legacyStorage.values, isNot(contains('hyve.bot.api-key.master.v1')));
  });

  test('does not migrate an invalid legacy Apple master key', () async {
    final encrypted = await SecureBotApiKeyCipher(
      storage: MemorySecureStorage(),
    ).encrypt(botId: 'bot-1', apiKey: 'sk-value');
    final legacyStorage = MemorySecureStorage({
      'hyve.bot.api-key.master.v1': base64UrlEncode([1, 2, 3]),
    });
    final currentStorage = MemorySecureStorage();

    await expectLater(
      SecureBotApiKeyCipher(
        storage: currentStorage,
        legacyStorage: legacyStorage,
      ).decrypt(botId: 'bot-1', encrypted: encrypted),
      throwsFormatException,
    );

    expect(currentStorage.values, isEmpty);
    expect(legacyStorage.values, contains('hyve.bot.api-key.master.v1'));
  });
}
