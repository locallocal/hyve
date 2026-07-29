import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/mcp_credential_store.dart';

final class SecureMcpCredentialStore implements McpCredentialStore {
  SecureMcpCredentialStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(migrateWithBackup: true),
            iOptions: IOSOptions(
              accountName: 'com.example.stars.mcp.credentials',
            ),
            mOptions: MacOsOptions(
              accountName: 'com.example.stars.mcp.credentials',
            ),
          );

  final FlutterSecureStorage _storage;

  @override
  Future<McpCredential?> read(String serverId) async {
    final source = await _storage.read(key: _key(serverId));
    if (source == null || source.isEmpty) return null;
    try {
      final decoded = jsonDecode(source);
      if (decoded is! Map) return null;
      final values = decoded.map(
        (key, value) => MapEntry(key.toString(), value as Object?),
      );
      final accessToken = values['accessToken']?.toString() ?? '';
      final environment = _stringMap(values['environment']);
      if (accessToken.isEmpty && environment.isEmpty) return null;
      final expiresAt = DateTime.tryParse(
        values['expiresAt']?.toString() ?? '',
      );
      return McpCredential(
        accessToken: accessToken,
        environment: environment,
        tokenType: values['tokenType']?.toString() ?? 'Bearer',
        scope: values['scope']?.toString() ?? '',
        expiresAt: expiresAt,
      );
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> write(String serverId, McpCredential credential) {
    if (credential.accessToken.trim().isEmpty &&
        credential.environment.isEmpty) {
      throw ArgumentError.value(
        credential,
        'credential',
        'MCP credential cannot be empty.',
      );
    }
    return _storage.write(
      key: _key(serverId),
      value: jsonEncode({
        'accessToken': credential.accessToken,
        'environment': credential.environment,
        'tokenType': credential.tokenType,
        'scope': credential.scope,
        'expiresAt': credential.expiresAt?.toUtc().toIso8601String(),
      }),
    );
  }

  @override
  Future<void> delete(String serverId) => _storage.delete(key: _key(serverId));

  String _key(String serverId) {
    final safeId = serverId.replaceAll(RegExp(r'[^A-Za-z0-9_.:-]'), '_');
    return 'stars.mcp.credential.$safeId';
  }
}

Map<String, String> _stringMap(Object? value) {
  if (value is! Map) return const {};
  return Map<String, String>.unmodifiable(
    value.map((key, mapValue) => MapEntry(key.toString(), mapValue.toString())),
  );
}
