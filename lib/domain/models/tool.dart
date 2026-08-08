import 'dart:async';

enum ToolSource { builtIn, mcp, skillScript }

enum ToolRiskLevel { readOnly, write, destructive }

enum ToolCapability {
  compute,
  localRead,
  network,
  externalRead,
  localWrite,
  externalWrite,
  process,
}

final class ToolDefinition {
  ToolDefinition({
    required this.name,
    this.title = '',
    this.mcpServerName = '',
    required this.description,
    required Map<String, Object?> inputSchema,
    Map<String, Object?>? outputSchema,
    required this.source,
    required this.riskLevel,
    Set<ToolCapability> capabilities = const {},
  }) : inputSchema = Map<String, Object?>.unmodifiable(inputSchema),
       outputSchema =
           outputSchema == null
               ? null
               : Map<String, Object?>.unmodifiable(outputSchema),
       capabilities = Set<ToolCapability>.unmodifiable(capabilities) {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'Tool name cannot be empty.');
    }
    if (this.inputSchema['type'] != 'object') {
      throw ArgumentError.value(
        inputSchema,
        'inputSchema',
        'Tool input schema must describe an object.',
      );
    }
  }

  final String name;
  final String title;
  final String mcpServerName;
  final String description;
  final Map<String, Object?> inputSchema;
  final Map<String, Object?>? outputSchema;
  final ToolSource source;
  final ToolRiskLevel riskLevel;
  final Set<ToolCapability> capabilities;
}

final class ToolCallRequest {
  ToolCallRequest({
    required this.callId,
    required this.name,
    Map<String, Object?> arguments = const {},
  }) : arguments = Map<String, Object?>.unmodifiable(arguments);

  final String callId;
  final String name;
  final Map<String, Object?> arguments;
}

final class ToolResult {
  ToolResult({
    required this.callId,
    required this.name,
    required this.content,
    this.structuredContent,
    this.isError = false,
    this.errorCode = '',
  });

  final String callId;
  final String name;
  final String content;
  final Object? structuredContent;
  final bool isError;
  final String errorCode;

  ToolResult copyWith({
    String? content,
    Object? structuredContent,
    bool clearStructuredContent = false,
    bool? isError,
    String? errorCode,
  }) {
    return ToolResult(
      callId: callId,
      name: name,
      content: content ?? this.content,
      structuredContent:
          clearStructuredContent
              ? null
              : structuredContent ?? this.structuredContent,
      isError: isError ?? this.isError,
      errorCode: errorCode ?? this.errorCode,
    );
  }
}

enum ToolPolicyOutcome { allow, requireApproval, deny }

final class ToolPolicyDecision {
  const ToolPolicyDecision({required this.outcome, this.reason = ''});

  const ToolPolicyDecision.allow({this.reason = ''})
    : outcome = ToolPolicyOutcome.allow;

  const ToolPolicyDecision.requireApproval({this.reason = ''})
    : outcome = ToolPolicyOutcome.requireApproval;

  const ToolPolicyDecision.deny({this.reason = ''})
    : outcome = ToolPolicyOutcome.deny;

  final ToolPolicyOutcome outcome;
  final String reason;
}

final class ToolPolicyContext {
  ToolPolicyContext({
    required this.runId,
    required this.chatId,
    required this.botId,
    Set<String> requestedToolNames = const {},
    Set<String> approvalExemptToolNames = const {},
  }) : requestedToolNames = Set<String>.unmodifiable(requestedToolNames),
       approvalExemptToolNames = Set<String>.unmodifiable(
         approvalExemptToolNames,
       );

  final String runId;
  final String chatId;
  final String botId;
  final Set<String> requestedToolNames;
  final Set<String> approvalExemptToolNames;
}

abstract interface class ToolPolicy {
  ToolPolicyDecision evaluate(
    ToolDefinition definition,
    ToolCallRequest call,
    ToolPolicyContext context,
  );
}

final class DefaultToolPolicy implements ToolPolicy {
  const DefaultToolPolicy({
    this.allowNetwork = false,
    this.allowLocalRead = false,
    this.allowExternalRead = false,
    this.allowDestructiveWithApproval = false,
    this.allowSkillScripts = false,
  });

  final bool allowNetwork;
  final bool allowLocalRead;
  final bool allowExternalRead;
  final bool allowDestructiveWithApproval;
  final bool allowSkillScripts;

  @override
  ToolPolicyDecision evaluate(
    ToolDefinition definition,
    ToolCallRequest call,
    ToolPolicyContext context,
  ) {
    if (!context.requestedToolNames.contains(definition.name)) {
      return const ToolPolicyDecision.deny(
        reason: 'tool_not_requested_by_active_skill',
      );
    }
    if (definition.source == ToolSource.mcp &&
        context.approvalExemptToolNames.contains(definition.name)) {
      return const ToolPolicyDecision.allow(
        reason: 'bot_mcp_tool_approval_exempt',
      );
    }
    const historyTools = {
      'search_conversation_history',
      'read_conversation_history',
    };
    if (definition.source == ToolSource.builtIn &&
        definition.riskLevel == ToolRiskLevel.readOnly &&
        definition.capabilities.length == 1 &&
        definition.capabilities.contains(ToolCapability.localRead) &&
        historyTools.contains(definition.name) &&
        context.approvalExemptToolNames.contains(definition.name)) {
      return const ToolPolicyDecision.allow(
        reason: 'conversation_history_read_only_exempt',
      );
    }
    if (definition.source == ToolSource.skillScript ||
        definition.capabilities.contains(ToolCapability.process)) {
      return allowSkillScripts
          ? const ToolPolicyDecision.requireApproval(
            reason: 'skill_script_requires_approval',
          )
          : const ToolPolicyDecision.deny(reason: 'process_execution_disabled');
    }
    if (definition.riskLevel == ToolRiskLevel.destructive) {
      return allowDestructiveWithApproval
          ? const ToolPolicyDecision.requireApproval(
            reason: 'destructive_write_requires_approval',
          )
          : const ToolPolicyDecision.deny(reason: 'destructive_tools_disabled');
    }
    if (definition.capabilities.isEmpty) {
      return const ToolPolicyDecision.requireApproval(
        reason: 'unspecified_capability_requires_approval',
      );
    }
    if (definition.riskLevel == ToolRiskLevel.write ||
        definition.capabilities.contains(ToolCapability.localWrite) ||
        definition.capabilities.contains(ToolCapability.externalWrite)) {
      return const ToolPolicyDecision.requireApproval(
        reason: 'write_requires_approval',
      );
    }
    if (definition.capabilities.contains(ToolCapability.network) &&
        !allowNetwork) {
      return const ToolPolicyDecision.requireApproval(
        reason: 'network_requires_approval',
      );
    }
    if (definition.capabilities.contains(ToolCapability.localRead) &&
        !allowLocalRead) {
      return const ToolPolicyDecision.requireApproval(
        reason: 'local_read_requires_approval',
      );
    }
    if (definition.capabilities.contains(ToolCapability.externalRead) &&
        !allowExternalRead) {
      return const ToolPolicyDecision.requireApproval(
        reason: 'external_read_requires_approval',
      );
    }
    return const ToolPolicyDecision.allow();
  }
}

enum ToolApprovalDecision { allowOnce, deny }

final class ToolApprovalRequest {
  const ToolApprovalRequest({
    required this.runId,
    required this.call,
    required this.definition,
    required this.reason,
  });

  final String runId;
  final ToolCallRequest call;
  final ToolDefinition definition;
  final String reason;
}

abstract interface class ToolApprovalHandler {
  Future<ToolApprovalDecision> requestApproval(
    ToolApprovalRequest request,
    AgentCancellationToken cancellationToken,
  );
}

final class DenyToolApprovalHandler implements ToolApprovalHandler {
  const DenyToolApprovalHandler();

  @override
  Future<ToolApprovalDecision> requestApproval(
    ToolApprovalRequest request,
    AgentCancellationToken cancellationToken,
  ) async {
    return ToolApprovalDecision.deny;
  }
}

final class AgentCancellationToken {
  final Completer<void> _cancelled = Completer<void>();

  bool get isCancelled => _cancelled.isCompleted;
  Future<void> get whenCancelled => _cancelled.future;

  void cancel() {
    if (!_cancelled.isCompleted) _cancelled.complete();
  }

  void throwIfCancelled() {
    if (isCancelled) throw const AgentRunCancelledException();
  }
}

final class AgentRunCancelledException implements Exception {
  const AgentRunCancelledException();

  @override
  String toString() => 'Agent run cancelled.';
}

abstract interface class ExecutableTool {
  ToolDefinition get definition;

  Future<ToolResult> execute(
    ToolCallRequest call,
    AgentCancellationToken cancellationToken,
  );
}

abstract interface class ToolRegistry {
  List<ToolDefinition> list({Set<String> allowedNames = const {}});

  ExecutableTool? find(String name);
}

final class StaticToolRegistry implements ToolRegistry {
  factory StaticToolRegistry(Iterable<ExecutableTool> tools) {
    final items = List<ExecutableTool>.of(tools);
    final indexed = <String, ExecutableTool>{
      for (final tool in items) tool.definition.name: tool,
    };
    if (indexed.length != items.length) {
      throw ArgumentError('Tool names must be globally unique.');
    }
    return StaticToolRegistry._(Map.unmodifiable(indexed));
  }

  const StaticToolRegistry._(this._tools);

  final Map<String, ExecutableTool> _tools;

  @override
  ExecutableTool? find(String name) => _tools[name];

  @override
  List<ToolDefinition> list({Set<String> allowedNames = const {}}) {
    final definitions = [
      for (final entry in _tools.entries)
        if (allowedNames.isEmpty || allowedNames.contains(entry.key))
          entry.value.definition,
    ]..sort((left, right) => left.name.compareTo(right.name));
    return List<ToolDefinition>.unmodifiable(definitions);
  }
}

final class DynamicToolRegistry implements ToolRegistry {
  factory DynamicToolRegistry(Iterable<ExecutableTool> fixedTools) {
    final fixed = <String, ExecutableTool>{};
    for (final tool in fixedTools) {
      if (fixed.containsKey(tool.definition.name)) {
        throw ArgumentError('Tool names must be globally unique.');
      }
      fixed[tool.definition.name] = tool;
    }
    return DynamicToolRegistry._(Map.unmodifiable(fixed));
  }

  DynamicToolRegistry._(this._fixedTools);

  final Map<String, ExecutableTool> _fixedTools;
  Map<String, Map<String, ExecutableTool>> _dynamicSources = const {};

  void replaceDynamic(Iterable<ExecutableTool> tools) {
    replaceDynamicSource('default', tools);
  }

  void replaceDynamicSource(String source, Iterable<ExecutableTool> tools) {
    if (source.trim().isEmpty) {
      throw ArgumentError.value(source, 'source', 'Source cannot be empty.');
    }
    final next = <String, ExecutableTool>{};
    for (final tool in tools) {
      final name = tool.definition.name;
      final usedByOtherSource = _dynamicSources.entries.any(
        (entry) => entry.key != source && entry.value.containsKey(name),
      );
      if (_fixedTools.containsKey(name) ||
          usedByOtherSource ||
          next.containsKey(name)) {
        throw ArgumentError.value(
          name,
          'tools',
          'Tool names must be globally unique.',
        );
      }
      next[name] = tool;
    }
    _dynamicSources = Map<String, Map<String, ExecutableTool>>.unmodifiable({
      ..._dynamicSources,
      source: Map<String, ExecutableTool>.unmodifiable(next),
    });
  }

  @override
  ExecutableTool? find(String name) {
    final fixed = _fixedTools[name];
    if (fixed != null) return fixed;
    for (final tools in _dynamicSources.values) {
      final dynamic = tools[name];
      if (dynamic != null) return dynamic;
    }
    return null;
  }

  @override
  List<ToolDefinition> list({Set<String> allowedNames = const {}}) {
    final definitions = [
      for (final entry in [
        ..._fixedTools.entries,
        for (final source in _dynamicSources.values) ...source.entries,
      ])
        if (allowedNames.isEmpty || allowedNames.contains(entry.key))
          entry.value.definition,
    ]..sort((left, right) => left.name.compareTo(right.name));
    return List<ToolDefinition>.unmodifiable(definitions);
  }
}

/// A request-local overlay used for tools that must capture immutable run data.
final class OverlayToolRegistry implements ToolRegistry {
  factory OverlayToolRegistry({
    required ToolRegistry parent,
    required Iterable<ExecutableTool> overlayTools,
  }) {
    final overlay = <String, ExecutableTool>{};
    for (final tool in overlayTools) {
      final name = tool.definition.name;
      if (overlay.containsKey(name) || parent.find(name) != null) {
        throw ArgumentError.value(
          name,
          'overlayTools',
          'Tool name is reserved.',
        );
      }
      overlay[name] = tool;
    }
    return OverlayToolRegistry._(parent, Map.unmodifiable(overlay));
  }

  const OverlayToolRegistry._(this._parent, this._overlay);

  final ToolRegistry _parent;
  final Map<String, ExecutableTool> _overlay;

  @override
  ExecutableTool? find(String name) => _overlay[name] ?? _parent.find(name);

  @override
  List<ToolDefinition> list({Set<String> allowedNames = const {}}) {
    final definitions = [
      ..._parent.list(allowedNames: allowedNames),
      for (final entry in _overlay.entries)
        if (allowedNames.isEmpty || allowedNames.contains(entry.key))
          entry.value.definition,
    ]..sort((left, right) => left.name.compareTo(right.name));
    return List.unmodifiable(definitions);
  }
}

enum ToolInvocationStatus {
  requested,
  awaitingApproval,
  running,
  succeeded,
  failed,
  denied,
  cancelled,
  timedOut,
  duplicate,
}

final class ToolInvocationRecord {
  ToolInvocationRecord({
    required this.callId,
    required this.name,
    this.title = '',
    this.mcpServerName = '',
    required this.source,
    required this.riskLevel,
    required this.status,
    Map<String, Object?> arguments = const {},
    this.resultSummary = '',
    this.errorCode = '',
    this.approvalDecision = '',
    required this.startedAt,
    this.completedAt,
    this.durationMs,
  }) : arguments = Map<String, Object?>.unmodifiable(arguments);

  final String callId;
  final String name;
  final String title;
  final String mcpServerName;
  final ToolSource source;
  final ToolRiskLevel riskLevel;
  final ToolInvocationStatus status;
  final Map<String, Object?> arguments;
  final String resultSummary;
  final String errorCode;
  final String approvalDecision;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? durationMs;

  ToolInvocationRecord copyWith({
    ToolInvocationStatus? status,
    String? resultSummary,
    String? errorCode,
    String? approvalDecision,
    DateTime? completedAt,
    int? durationMs,
  }) {
    return ToolInvocationRecord(
      callId: callId,
      name: name,
      title: title,
      mcpServerName: mcpServerName,
      source: source,
      riskLevel: riskLevel,
      status: status ?? this.status,
      arguments: arguments,
      resultSummary: resultSummary ?? this.resultSummary,
      errorCode: errorCode ?? this.errorCode,
      approvalDecision: approvalDecision ?? this.approvalDecision,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      durationMs: durationMs ?? this.durationMs,
    );
  }
}

final class JsonSchemaValidationIssue {
  const JsonSchemaValidationIssue({
    required this.path,
    required this.code,
    required this.message,
  });

  final String path;
  final String code;
  final String message;
}

const _supportedJsonSchemaKeywords = <String>{
  r'$schema',
  'title',
  'description',
  'default',
  'type',
  'enum',
  'const',
  'properties',
  'required',
  'additionalProperties',
  'items',
  'minLength',
  'maxLength',
  'pattern',
  'format',
  'minimum',
  'maximum',
  'exclusiveMinimum',
  'exclusiveMaximum',
  'minItems',
  'maxItems',
  'uniqueItems',
  'minProperties',
  'maxProperties',
  'allOf',
  'anyOf',
  'oneOf',
  'not',
  // FastMCP annotation; it changes result wrapping, not validation semantics.
  'x-fastmcp-wrap-result',
};

final class JsonSchemaValidator {
  const JsonSchemaValidator();

  bool supports(Map<String, Object?> schema) => _supportsSchema(schema);

  List<JsonSchemaValidationIssue> validate(
    Object? value,
    Map<String, Object?> schema,
  ) {
    final issues = <JsonSchemaValidationIssue>[];
    _validateValue(value, schema, r'$', issues);
    return List<JsonSchemaValidationIssue>.unmodifiable(issues);
  }

  void _validateValue(
    Object? value,
    Map<String, Object?> schema,
    String path,
    List<JsonSchemaValidationIssue> issues,
  ) {
    for (final keyword in schema.keys) {
      if (!_supportedJsonSchemaKeywords.contains(keyword)) {
        issues.add(
          JsonSchemaValidationIssue(
            path: path,
            code: 'unsupported_schema_keyword',
            message: 'Schema keyword "$keyword" is not supported.',
          ),
        );
      }
    }
    if (issues.any(
      (issue) =>
          issue.path == path && issue.code == 'unsupported_schema_keyword',
    )) {
      return;
    }

    _validateCompositions(value, schema, path, issues);
    final enumValues = schema['enum'];
    if (enumValues is List<Object?> && !enumValues.contains(value)) {
      issues.add(
        JsonSchemaValidationIssue(
          path: path,
          code: 'enum',
          message: 'Value is not one of the allowed values.',
        ),
      );
      return;
    }
    if (schema.containsKey('const') && schema['const'] != value) {
      issues.add(
        JsonSchemaValidationIssue(
          path: path,
          code: 'const',
          message: 'Value does not match the required constant.',
        ),
      );
      return;
    }

    final rawType = schema['type'];
    final acceptedTypes =
        rawType is List
            ? rawType.whereType<String>().toSet()
            : rawType is String
            ? <String>{rawType}
            : const <String>{};
    if (acceptedTypes.isNotEmpty &&
        !acceptedTypes.any((type) => _matchesType(value, type))) {
      issues.add(
        JsonSchemaValidationIssue(
          path: path,
          code: 'type',
          message:
              'Value does not match schema type ${acceptedTypes.join('|')}.',
        ),
      );
      return;
    }

    if (value is Map) {
      final object = value.map((key, item) => MapEntry(key.toString(), item));
      final required =
          (schema['required'] as List<Object?>?)?.whereType<String>().toSet() ??
          const <String>{};
      for (final key in required) {
        if (!object.containsKey(key)) {
          issues.add(
            JsonSchemaValidationIssue(
              path: '$path.$key',
              code: 'required',
              message: 'Required property is missing.',
            ),
          );
        }
      }
      final properties = _schemaMap(schema['properties']);
      final additionalProperties = schema['additionalProperties'];
      for (final entry in object.entries) {
        final propertySchema = _schemaMap(properties[entry.key]);
        if (propertySchema.isNotEmpty) {
          _validateValue(
            entry.value,
            propertySchema,
            '$path.${entry.key}',
            issues,
          );
        } else if (additionalProperties == false) {
          issues.add(
            JsonSchemaValidationIssue(
              path: '$path.${entry.key}',
              code: 'additional_property',
              message: 'Additional properties are not allowed.',
            ),
          );
        } else {
          final additionalSchema = _schemaMap(additionalProperties);
          if (additionalSchema.isNotEmpty) {
            _validateValue(
              entry.value,
              additionalSchema,
              '$path.${entry.key}',
              issues,
            );
          }
        }
      }
      _validateLength(
        object.length,
        schema,
        path,
        issues,
        minimumKey: 'minProperties',
        maximumKey: 'maxProperties',
      );
    }

    if (value is List) {
      final itemSchema = _schemaMap(schema['items']);
      if (itemSchema.isNotEmpty) {
        for (var index = 0; index < value.length; index += 1) {
          _validateValue(value[index], itemSchema, '$path[$index]', issues);
        }
      }
      _validateLength(
        value.length,
        schema,
        path,
        issues,
        minimumKey: 'minItems',
        maximumKey: 'maxItems',
      );
      if (schema['uniqueItems'] == true) {
        for (var index = 0; index < value.length; index += 1) {
          if (value.indexOf(value[index]) != index) {
            issues.add(
              JsonSchemaValidationIssue(
                path: path,
                code: 'unique_items',
                message: 'Array items must be unique.',
              ),
            );
            break;
          }
        }
      }
    }

    if (value is String) {
      _validateLength(
        value.runes.length,
        schema,
        path,
        issues,
        minimumKey: 'minLength',
        maximumKey: 'maxLength',
      );
      final pattern = schema['pattern'];
      if (pattern is String) {
        try {
          if (!RegExp(pattern).hasMatch(value)) {
            issues.add(
              JsonSchemaValidationIssue(
                path: path,
                code: 'pattern',
                message: 'String does not match the required pattern.',
              ),
            );
          }
        } on FormatException {
          issues.add(
            JsonSchemaValidationIssue(
              path: path,
              code: 'invalid_schema',
              message: 'Schema pattern is invalid.',
            ),
          );
        }
      }
      final format = schema['format'];
      final validFormat = switch (format) {
        'date-time' => DateTime.tryParse(value) != null,
        'uri' => Uri.tryParse(value)?.hasScheme ?? false,
        'email' => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value),
        null => true,
        _ => false,
      };
      if (!validFormat) {
        issues.add(
          JsonSchemaValidationIssue(
            path: path,
            code: 'format',
            message: 'String does not match the required format.',
          ),
        );
      }
    }

    if (value is num) {
      _validateNumber(value, schema, path, issues);
    }
  }

  bool _supportsSchema(Map<String, Object?> schema) {
    if (schema.keys.any(
      (keyword) => !_supportedJsonSchemaKeywords.contains(keyword),
    )) {
      return false;
    }
    final format = schema['format'];
    if (format != null &&
        format != 'date-time' &&
        format != 'uri' &&
        format != 'email') {
      return false;
    }
    final rawType = schema['type'];
    const supportedTypes = {
      'null',
      'boolean',
      'object',
      'array',
      'number',
      'integer',
      'string',
    };
    if (rawType is String && !supportedTypes.contains(rawType)) return false;
    if (rawType is List &&
        rawType.any(
          (type) => type is! String || !supportedTypes.contains(type),
        )) {
      return false;
    }
    final rawProperties = schema['properties'];
    if (rawProperties != null && rawProperties is! Map) return false;
    final properties = _schemaMap(rawProperties);
    for (final property in properties.values) {
      if (property is! Map || !_supportsSchema(_schemaMap(property))) {
        return false;
      }
    }
    for (final key in const ['items', 'not']) {
      final rawChild = schema[key];
      if (rawChild == null) continue;
      if (rawChild is! Map || !_supportsSchema(_schemaMap(rawChild))) {
        return false;
      }
    }
    final additionalProperties = schema['additionalProperties'];
    if (additionalProperties != null &&
        additionalProperties is! bool &&
        (additionalProperties is! Map ||
            !_supportsSchema(_schemaMap(additionalProperties)))) {
      return false;
    }
    for (final key in const ['allOf', 'anyOf', 'oneOf']) {
      final children = schema[key];
      if (children == null) continue;
      if (children is! List || children.isEmpty) return false;
      for (final rawChild in children) {
        if (rawChild is! Map || !_supportsSchema(_schemaMap(rawChild))) {
          return false;
        }
      }
    }
    return true;
  }

  void _validateCompositions(
    Object? value,
    Map<String, Object?> schema,
    String path,
    List<JsonSchemaValidationIssue> issues,
  ) {
    final allOf = schema['allOf'];
    if (allOf is List) {
      for (final child in allOf) {
        final childSchema = _schemaMap(child);
        if (childSchema.isNotEmpty) {
          _validateValue(value, childSchema, path, issues);
        }
      }
    }

    final anyOf = schema['anyOf'];
    if (anyOf is List && !_matchesSchemaCount(value, anyOf, path, minimum: 1)) {
      issues.add(
        JsonSchemaValidationIssue(
          path: path,
          code: 'any_of',
          message: 'Value does not match any allowed schema.',
        ),
      );
    }

    final oneOf = schema['oneOf'];
    if (oneOf is List &&
        !_matchesSchemaCount(value, oneOf, path, minimum: 1, maximum: 1)) {
      issues.add(
        JsonSchemaValidationIssue(
          path: path,
          code: 'one_of',
          message: 'Value must match exactly one allowed schema.',
        ),
      );
    }

    final notSchema = _schemaMap(schema['not']);
    if (notSchema.isNotEmpty) {
      final nestedIssues = <JsonSchemaValidationIssue>[];
      _validateValue(value, notSchema, path, nestedIssues);
      if (nestedIssues.isEmpty) {
        issues.add(
          JsonSchemaValidationIssue(
            path: path,
            code: 'not',
            message: 'Value matches a forbidden schema.',
          ),
        );
      }
    }
  }

  bool _matchesSchemaCount(
    Object? value,
    List<Object?> schemas,
    String path, {
    required int minimum,
    int? maximum,
  }) {
    var matches = 0;
    for (final rawSchema in schemas) {
      final schema = _schemaMap(rawSchema);
      if (schema.isEmpty) continue;
      final nestedIssues = <JsonSchemaValidationIssue>[];
      _validateValue(value, schema, path, nestedIssues);
      if (nestedIssues.isEmpty) matches += 1;
    }
    return matches >= minimum && (maximum == null || matches <= maximum);
  }

  void _validateLength(
    int length,
    Map<String, Object?> schema,
    String path,
    List<JsonSchemaValidationIssue> issues, {
    required String minimumKey,
    required String maximumKey,
  }) {
    final minimum = schema[minimumKey];
    if (minimum is num && length < minimum) {
      issues.add(
        JsonSchemaValidationIssue(
          path: path,
          code: minimumKey,
          message: 'Value is shorter than the schema minimum.',
        ),
      );
    }
    final maximum = schema[maximumKey];
    if (maximum is num && length > maximum) {
      issues.add(
        JsonSchemaValidationIssue(
          path: path,
          code: maximumKey,
          message: 'Value is longer than the schema maximum.',
        ),
      );
    }
  }

  void _validateNumber(
    num value,
    Map<String, Object?> schema,
    String path,
    List<JsonSchemaValidationIssue> issues,
  ) {
    final minimum = schema['minimum'];
    final maximum = schema['maximum'];
    final exclusiveMinimum = schema['exclusiveMinimum'];
    final exclusiveMaximum = schema['exclusiveMaximum'];
    if (minimum is num && value < minimum) {
      issues.add(
        JsonSchemaValidationIssue(
          path: path,
          code: 'minimum',
          message: 'Number is below the schema minimum.',
        ),
      );
    }
    if (maximum is num && value > maximum) {
      issues.add(
        JsonSchemaValidationIssue(
          path: path,
          code: 'maximum',
          message: 'Number is above the schema maximum.',
        ),
      );
    }
    if (exclusiveMinimum is num && value <= exclusiveMinimum) {
      issues.add(
        JsonSchemaValidationIssue(
          path: path,
          code: 'exclusive_minimum',
          message: 'Number is not above the exclusive minimum.',
        ),
      );
    }
    if (exclusiveMaximum is num && value >= exclusiveMaximum) {
      issues.add(
        JsonSchemaValidationIssue(
          path: path,
          code: 'exclusive_maximum',
          message: 'Number is not below the exclusive maximum.',
        ),
      );
    }
  }

  bool _matchesType(Object? value, String type) {
    return switch (type) {
      'null' => value == null,
      'object' => value is Map,
      'array' => value is List,
      'string' => value is String,
      'integer' => value is int,
      'number' => value is num,
      'boolean' => value is bool,
      _ => true,
    };
  }

  Map<String, Object?> _schemaMap(Object? value) {
    if (value is! Map) return const {};
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
}
