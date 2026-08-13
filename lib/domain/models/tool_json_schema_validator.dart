part of 'tool.dart';

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
