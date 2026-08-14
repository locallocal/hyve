import 'dart:convert';
import 'dart:io';

const _catalogDirectory = 'lib/l10n';
const _templatePath = '$_catalogDirectory/intl_en.arb';

void main(List<String> arguments) {
  final write = arguments.contains('--write');
  if (arguments.any(
    (argument) => argument != '--write' && argument != '--check',
  )) {
    stderr.writeln(
      'Usage: dart run tool/sync_localizations.dart [--check|--write]',
    );
    exit(64);
  }

  final templateFile = File(_templatePath);
  final template = _readCatalog(templateFile);
  final expectedKeys = _messageKeys(template);
  final catalogFiles =
      Directory(_catalogDirectory)
          .listSync()
          .whereType<File>()
          .where(
            (file) =>
                file.path.endsWith('.arb') &&
                file.absolute.path != templateFile.absolute.path,
          )
          .toList()
        ..sort((left, right) => left.path.compareTo(right.path));

  var hasDrift = false;
  for (final file in catalogFiles) {
    final catalog = _readCatalog(file);
    final actualKeys = _messageKeys(catalog);
    final missing = expectedKeys.difference(actualKeys).toList()..sort();
    final unexpected = actualKeys.difference(expectedKeys).toList()..sort();

    if (unexpected.isNotEmpty) {
      hasDrift = true;
      stderr.writeln(
        '${file.path} has unexpected keys: ${unexpected.join(', ')}',
      );
    }
    if (missing.isEmpty) continue;

    hasDrift = true;
    if (!write) {
      stderr.writeln('${file.path} is missing keys: ${missing.join(', ')}');
      continue;
    }
    for (final key in template.keys) {
      if (missing.contains(key)) catalog[key] = template[key];
    }
    file.writeAsStringSync(
      '${const JsonEncoder.withIndent('    ').convert(catalog)}\n',
    );
    stdout.writeln(
      '${file.path}: added ${missing.length} English fallback messages.',
    );
  }

  if (hasDrift && !write) exit(1);
}

Map<String, Object?> _readCatalog(File file) {
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map || decoded.keys.any((key) => key is! String)) {
    throw FormatException('${file.path} must contain a JSON object.');
  }
  return decoded.cast<String, Object?>();
}

Set<String> _messageKeys(Map<String, Object?> catalog) =>
    catalog.keys.where((key) => !key.startsWith('@')).toSet();
