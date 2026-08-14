import 'dart:io';

const _sourceRoots = <String>[
  'lib',
  'test',
  'integration_test',
  'test_driver',
  'tool',
];

Future<void> main() async {
  final files = <String>[];
  for (final root in _sourceRoots) {
    final directory = Directory(root);
    if (!directory.existsSync()) continue;
    files.addAll(
      directory
          .listSync(recursive: true)
          .whereType<File>()
          .map((file) => file.path.replaceAll('\\', '/'))
          .where(
            (path) =>
                path.endsWith('.dart') && !path.startsWith('lib/generated/'),
          ),
    );
  }
  files.sort();

  for (var offset = 0; offset < files.length; offset += 100) {
    final end = (offset + 100).clamp(0, files.length);
    final result = await Process.start(Platform.resolvedExecutable, [
      'format',
      '--output=none',
      '--set-exit-if-changed',
      ...files.sublist(offset, end),
    ], mode: ProcessStartMode.inheritStdio);
    final exitCode = await result.exitCode;
    if (exitCode != 0) {
      stderr.writeln(
        'Formatting check failed. Run "dart format" on the reported files.',
      );
      exit(exitCode);
    }
  }
}
