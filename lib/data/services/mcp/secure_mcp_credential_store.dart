import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/mcp_credential_store.dart';

final class SecureMcpCredentialStore implements McpCredentialStore {
  SecureMcpCredentialStore({
    FlutterSecureStorage? storage,
    FlutterSecureStorage? legacyStorage,
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
               : null);

  static const secureStorageAccountName =
      'io.github.locallocal.stars.mcp.credentials';
  static const legacyStorageAccountName = 'com.example.stars.mcp.credentials';

  final FlutterSecureStorage _storage;
  final FlutterSecureStorage? _legacyStorage;

  static bool get _usesLegacyAppleNamespace =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  @override
  Future<McpCredential?> read(String serverId) async {
    final storageKey = _key(serverId);
    var source = await _storage.read(key: storageKey);
    final legacyStorage = _legacyStorage;
    var migrateLegacy = false;
    if ((source == null || source.isEmpty) && legacyStorage != null) {
      source = await legacyStorage.read(key: storageKey);
      migrateLegacy = source != null && source.isNotEmpty;
    }
    if (source == null || source.isEmpty) return null;
    final decoded = jsonDecode(source);
    if (decoded is! Map || decoded.keys.any((key) => key is! String)) {
      throw const FormatException('MCP credential must be a JSON object.');
    }
    final values = decoded.cast<String, Object?>();
    final accessToken = _requiredString(values, 'accessToken');
    final environment = _stringMap(values['environment']);
    if (accessToken.isEmpty && environment.isEmpty) {
      throw const FormatException('MCP credential cannot be empty.');
    }
    final rawExpiry = values['expiresAt'];
    final DateTime? expiresAt;
    if (rawExpiry == null) {
      expiresAt = null;
    } else if (rawExpiry is String) {
      expiresAt = DateTime.parse(rawExpiry);
    } else {
      throw const FormatException('MCP credential expiry must be a string.');
    }
    final credential = McpCredential(
      accessToken: accessToken,
      environment: environment,
      tokenType: _requiredString(values, 'tokenType'),
      scope: _requiredString(values, 'scope'),
      expiresAt: expiresAt,
    );
    if (migrateLegacy) {
      await _storage.write(key: storageKey, value: source);
      try {
        await legacyStorage!.delete(key: storageKey);
      } on Object {
        // The new copy is authoritative; a later run can retry cleanup.
      }
    }
    return credential;
  }

  @override
  Future<void> write(String serverId, McpCredential credential) async {
    if (credential.accessToken.trim().isEmpty &&
        credential.environment.isEmpty) {
      throw ArgumentError.value(
        credential,
        'credential',
        'MCP credential cannot be empty.',
      );
    }
    final storageKey = _key(serverId);
    await _storage.write(
      key: storageKey,
      value: jsonEncode({
        'accessToken': credential.accessToken,
        'environment': credential.environment,
        'tokenType': credential.tokenType,
        'scope': credential.scope,
        'expiresAt': credential.expiresAt?.toUtc().toIso8601String(),
      }),
    );
    try {
      await _legacyStorage?.delete(key: storageKey);
    } on Object {
      // The new copy is authoritative; a later write can retry cleanup.
    }
  }

  @override
  Future<void> delete(String serverId) async {
    final storageKey = _key(serverId);
    await _legacyStorage?.delete(key: storageKey);
    await _storage.delete(key: storageKey);
  }

  String _key(String serverId) {
    if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9_.:-]{0,127}$').hasMatch(serverId)) {
      throw ArgumentError.value(serverId, 'serverId', 'Invalid MCP server id.');
    }
    return 'stars.mcp.credential.$serverId';
  }
}

Map<String, String> _stringMap(Object? value) {
  if (value is! Map ||
      value.keys.any((key) => key is! String) ||
      value.values.any((item) => item is! String)) {
    throw const FormatException(
      'MCP credential environment must be a string map.',
    );
  }
  return Map<String, String>.unmodifiable(value.cast<String, String>());
}

String _requiredString(Map<String, Object?> values, String key) {
  final value = values[key];
  if (value is String) return value;
  throw FormatException('MCP credential field "$key" must be a string.');
}
