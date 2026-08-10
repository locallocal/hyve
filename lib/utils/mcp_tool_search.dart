import 'package:stars/domain/models/models.dart';

/// Filters MCP Tools with the same multi-term matching used across details.
List<McpToolDescriptor> filterMcpTools(
  List<McpToolDescriptor> tools,
  String query,
) {
  final terms = query
      .trim()
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((term) => term.isNotEmpty)
      .toList(growable: false);
  if (terms.isEmpty) return tools;

  return tools
      .where((tool) {
        final searchableText =
            [
              tool.title,
              tool.remoteName,
              tool.canonicalName,
              tool.description,
            ].join('\n').toLowerCase();
        return terms.every(searchableText.contains);
      })
      .toList(growable: false);
}
