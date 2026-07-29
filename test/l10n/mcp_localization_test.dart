import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stars/generated/l10n.dart';

void main() {
  const pageKeys = <String>{
    'mcpServers',
    'mcpServersDescription',
    'searchMcpServers',
    'noMatchingMcpServers',
    'addMcpServer',
    'remoteMcpOnly',
    'localMcpDisabledDescription',
    'mcpLocalProcessSecurityTitle',
    'mcpLocalProcessSecurityDescription',
    'mcpProgressiveDiscoveryDescription',
    'mcpHttpsRequired',
    'mcpPrivateEndpointBlocked',
    'mcpAuthorizationRequired',
    'mcpRequestTimedOut',
    'mcpUnsupportedProtocol',
    'mcpStdioStartFailed',
    'mcpInvalidStdioEnvironment',
    'mcpConnectionFailed',
    'deleteMcpServer',
    'confirmDeleteMcpServer',
    'mcpTools',
    'refreshMcpTools',
    'editMcpServer',
    'noMcpToolsDiscovered',
    'mcpToolSchemaUnsupported',
    'mcpConnected',
    'mcpConnecting',
    'mcpConnectionError',
    'mcpDisconnected',
    'mcpServerName',
    'mcpNamespace',
    'mcpNamespaceDescription',
    'mcpConnectionSettings',
    'mcpTransport',
    'mcpTransportStreamableHttp',
    'mcpTransportStdio',
    'mcpEndpoint',
    'mcpCommand',
    'mcpCommandDescription',
    'mcpArguments',
    'mcpArgumentsDescription',
    'mcpEnvironment',
    'mcpEnvironmentDescription',
    'mcpAuthentication',
    'mcpNoAuthentication',
    'mcpAccessToken',
    'mcpTokenStoredSecurely',
    'mcpTokenLeaveBlank',
    'saveAndConnect',
    'noMcpServers',
    'noMcpServersDescription',
  };

  test('English and Chinese catalogs define the complete MCP feature copy', () {
    for (final locale in ['en', 'zh_CN', 'zh_TW']) {
      final messages =
          jsonDecode(File('lib/l10n/intl_$locale.arb').readAsStringSync())
              as Map<String, dynamic>;
      expect(
        pageKeys.difference(messages.keys.toSet()),
        isEmpty,
        reason: '$locale is missing MCP translations',
      );
      expect(messages['mcpConnectionFailed'], contains('{error}'));
      expect(messages['confirmDeleteMcpServer'], contains('{name}'));
    }
  });

  test('every locale names the MCP settings entry', () {
    final arbFiles = Directory('lib/l10n').listSync().whereType<File>().where(
      (file) => RegExp(r'intl_.+\.arb$').hasMatch(file.path),
    );

    for (final file in arbFiles) {
      final messages =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      expect(messages['mcpServers'], isA<String>());
      expect(messages['mcpServersDescription'], isA<String>());
    }
  });

  test(
    'generated MCP messages load for English and Simplified Chinese',
    () async {
      await S.load(const Locale('en'));
      expect(S.current.mcpServers, 'MCP Servers');
      expect(S.current.searchMcpServers, 'Search MCP servers');
      expect(
        S.current.mcpConnectionFailed('network'),
        'MCP connection failed: network',
      );

      await S.load(const Locale('zh', 'CN'));
      expect(S.current.mcpServers, 'MCP 服务器');
      expect(S.current.searchMcpServers, '搜索 MCP 服务器');
      expect(S.current.mcpConnectionFailed('网络'), 'MCP 连接失败：网络');
    },
  );
}
