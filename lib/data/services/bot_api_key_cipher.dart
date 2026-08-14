import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class BotApiKeyCipher {
  bool isEncrypted(String value);

  Future<String> encrypt({required String botId, required String apiKey});

  Future<String> decrypt({required String botId, required String encrypted});
}

/// Encrypts Bot API keys before SQLite persistence.
///
/// The AES key is kept in platform secure storage while the authenticated,
/// versioned ciphertext is stored in the Bot row. The Bot id is authenticated
/// as associated data so ciphertext cannot be moved between Bots.
final class SecureBotApiKeyCipher implements BotApiKeyCipher {
  SecureBotApiKeyCipher({
    FlutterSecureStorage? storage,
    FlutterSecureStorage? legacyStorage,
    Cipher? cipher,
  }) : _storage =
           storage ??
           const FlutterSecureStorage(
             aOptions: AndroidOptions(),
             iOptions: IOSOptions(accountName: secureStorageAccountName),
             mOptions: MacOsOptions(accountName: secureStorageAccountName),
           ),
       _legacyStorage =
           legacyStorage ??
           (storage == null && _usesLegacyAppleNamespace
               ? const FlutterSecureStorage(
                 aOptions: AndroidOptions(),
                 iOptions: IOSOptions(accountName: legacyStorageAccountName),
                 mOptions: MacOsOptions(accountName: legacyStorageAccountName),
               )
               : null),
       _cipher = cipher ?? AesGcm.with256bits();

  static const envelopePrefix = 'stars:bot-api-key:v1:';
  static const secureStorageAccountName =
      'io.github.locallocal.stars.bot.api-key';
  static const legacyStorageAccountName = 'com.example.stars.bot.api-key';
  static const _keyStorageKey = 'stars.bot.api-key.master.v1';
  static const _secretKeyLength = 32;

  final FlutterSecureStorage _storage;
  final FlutterSecureStorage? _legacyStorage;
  final Cipher _cipher;
  Future<SecretKey>? _secretKey;

  static bool get _usesLegacyAppleNamespace =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  @override
  bool isEncrypted(String value) => value.startsWith(envelopePrefix);

  @override
  Future<String> encrypt({
    required String botId,
    required String apiKey,
  }) async {
    if (apiKey.isEmpty) return '';
    _validateBotId(botId);
    final secretBox = await _cipher.encrypt(
      utf8.encode(apiKey),
      secretKey: await _loadSecretKey(),
      aad: _associatedData(botId),
    );
    return '$envelopePrefix${base64UrlEncode(secretBox.concatenation())}';
  }

  @override
  Future<String> decrypt({
    required String botId,
    required String encrypted,
  }) async {
    if (encrypted.isEmpty) return '';
    _validateBotId(botId);
    if (!isEncrypted(encrypted)) {
      throw const FormatException('Bot API key is not encrypted.');
    }

    final payload = encrypted.substring(envelopePrefix.length);
    if (payload.isEmpty) {
      throw const FormatException('Bot API key ciphertext is empty.');
    }
    final bytes = base64Url.decode(payload);
    final secretBox = SecretBox.fromConcatenation(
      bytes,
      nonceLength: _cipher.nonceLength,
      macLength: _cipher.macAlgorithm.macLength,
    );
    final clearText = await _cipher.decrypt(
      secretBox,
      secretKey: await _loadSecretKey(),
      aad: _associatedData(botId),
    );
    return utf8.decode(clearText);
  }

  Future<SecretKey> _loadSecretKey() => _secretKey ??= _readSecretKey();

  Future<SecretKey> _readSecretKey() async {
    var stored = await _storage.read(key: _keyStorageKey);
    final legacyStorage = _legacyStorage;
    var migrateLegacy = false;
    if (stored == null && legacyStorage != null) {
      stored = await legacyStorage.read(key: _keyStorageKey);
      migrateLegacy = stored != null;
    }
    if (stored != null) {
      final bytes = base64Url.decode(stored);
      if (bytes.length != _secretKeyLength) {
        throw const FormatException('Bot API key master key is invalid.');
      }
      if (migrateLegacy) {
        await _storage.write(key: _keyStorageKey, value: stored);
        try {
          await legacyStorage!.delete(key: _keyStorageKey);
        } on Object {
          // The new copy is authoritative; a later run can retry cleanup.
        }
      }
      return SecretKey(bytes);
    }

    final secretKey = await _cipher.newSecretKey();
    final bytes = await secretKey.extractBytes();
    if (bytes.length != _secretKeyLength) {
      throw StateError('Bot API key cipher generated an invalid key.');
    }
    await _storage.write(key: _keyStorageKey, value: base64UrlEncode(bytes));
    return secretKey;
  }

  List<int> _associatedData(String botId) =>
      utf8.encode('stars.bot.api-key:$botId');

  void _validateBotId(String botId) {
    if (botId.trim().isEmpty) {
      throw ArgumentError.value(botId, 'botId', 'Bot id cannot be empty.');
    }
  }
}
