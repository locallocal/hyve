import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:stars/domain/models/models.dart';

final class SkillScriptManifestParser {
  const SkillScriptManifestParser();

  static const int maxManifestBytes = 128 * 1024;
  static final RegExp _toolName = RegExp(r'^[a-zA-Z0-9_.-]{1,96}$');

  Future<List<SkillScriptToolManifest>> parse(SkillDescriptor skill) async {
    final file = File(path.join(skill.rootPath, 'scripts', 'tools.json'));
    if (!await file.exists()) return const [];
    if (await file.length() > maxManifestBytes) {
      throw const SkillInstallException('scripts/tools.json 超过 128 KB 限制。');
    }
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map || decoded['schemaVersion'] != 1) {
        throw const SkillInstallException('脚本工具清单版本无效。');
      }
      final rawTools = decoded['tools'];
      if (rawTools is! List || rawTools.length > 32) {
        throw const SkillInstallException('脚本工具清单必须包含不超过 32 个工具。');
      }
      final tools = <SkillScriptToolManifest>[];
      final names = <String>{};
      for (final raw in rawTools) {
        if (raw is! Map) {
          throw const SkillInstallException('脚本工具定义必须是对象。');
        }
        final item = raw.map((key, value) => MapEntry(key.toString(), value));
        final localName = item['name']?.toString().trim() ?? '';
        final canonicalName = 'skill.${skill.name}.$localName';
        if (!_toolName.hasMatch(localName) || !names.add(canonicalName)) {
          throw const SkillInstallException('脚本工具名称无效或重复。');
        }
        final entry = _entry(item['entry']);
        final entryFile = File(
          path.joinAll([skill.rootPath, ...entry.split('/')]),
        );
        if (!await entryFile.exists()) {
          throw const SkillInstallException('脚本工具入口文件不存在。');
        }
        final inputSchema = _schema(item['inputSchema'], required: true)!;
        final outputSchema = _schema(item['outputSchema'], required: false);
        final capabilities = _capabilities(item['capabilities']);
        tools.add(
          SkillScriptToolManifest(
            name: canonicalName,
            title: item['title']?.toString().trim() ?? '',
            description: item['description']?.toString().trim() ?? '',
            entry: entry,
            interpreter: _interpreter(item['interpreter']),
            inputSchema: inputSchema,
            outputSchema: outputSchema,
            riskLevel: _risk(item['riskLevel']),
            capabilities: capabilities,
          ),
        );
      }
      return List.unmodifiable(tools);
    } on FormatException {
      throw const SkillInstallException('scripts/tools.json 不是有效的 JSON。');
    }
  }

  String _entry(Object? value) {
    final entry = value?.toString().trim().replaceAll('\\', '/') ?? '';
    final normalized = path.posix.normalize(entry);
    if (normalized.isEmpty ||
        normalized == '.' ||
        path.posix.isAbsolute(normalized) ||
        !normalized.startsWith('scripts/') ||
        normalized.contains('/../') ||
        normalized.startsWith('../')) {
      throw const SkillInstallException('脚本入口必须位于 scripts/ 目录中。');
    }
    return normalized;
  }

  SkillScriptInterpreter _interpreter(Object? value) {
    final name = value?.toString() ?? '';
    return SkillScriptInterpreter.values.firstWhere(
      (item) => item.name == name,
      orElse: () => throw const SkillInstallException('脚本解释器不在允许列表中。'),
    );
  }

  Map<String, Object?>? _schema(Object? value, {required bool required}) {
    if (value == null && !required) return null;
    if (value is! Map) {
      throw const SkillInstallException('脚本工具 Schema 必须是对象。');
    }
    final schema = value.map((key, item) => MapEntry(key.toString(), item));
    if (schema['type'] != 'object') {
      throw const SkillInstallException('脚本工具 Schema 必须描述 object。');
    }
    if (!const JsonSchemaValidator().supports(schema)) {
      throw const SkillInstallException('脚本工具 Schema 包含不受支持的约束。');
    }
    return schema;
  }

  ToolRiskLevel _risk(Object? value) {
    final name = value?.toString() ?? ToolRiskLevel.readOnly.name;
    return ToolRiskLevel.values.firstWhere(
      (item) => item.name == name,
      orElse: () => throw const SkillInstallException('脚本工具风险级别无效。'),
    );
  }

  Set<ToolCapability> _capabilities(Object? value) {
    if (value == null) return const {ToolCapability.compute};
    if (value is! List) {
      throw const SkillInstallException('脚本工具 capabilities 必须是数组。');
    }
    final capabilities = <ToolCapability>{};
    for (final raw in value) {
      final capability = ToolCapability.values.where(
        (item) => item.name == raw.toString(),
      );
      if (capability.isEmpty) {
        throw SkillInstallException('未知脚本能力：$raw');
      }
      final selected = capability.single;
      if (selected == ToolCapability.network ||
          selected == ToolCapability.localRead ||
          selected == ToolCapability.localWrite ||
          selected == ToolCapability.externalRead ||
          selected == ToolCapability.externalWrite) {
        throw SkillInstallException('脚本沙箱不开放 ${selected.name} 能力。');
      }
      capabilities.add(selected);
    }
    return capabilities.isEmpty ? const {ToolCapability.compute} : capabilities;
  }
}
