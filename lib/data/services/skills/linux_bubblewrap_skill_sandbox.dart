import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/skill_script_sandbox.dart';

typedef SkillInstallationVerifier =
    Future<void> Function(String rootPath, String contentDigest);

final class LinuxBubblewrapSkillSandbox implements SkillScriptSandbox {
  LinuxBubblewrapSkillSandbox({
    this.bubblewrapPath = '/usr/bin/bwrap',
    this.prlimitPath = '/usr/bin/prlimit',
    required SkillInstallationVerifier installationVerifier,
  }) : _installationVerifier = installationVerifier;

  final String bubblewrapPath;
  final String prlimitPath;
  final SkillInstallationVerifier _installationVerifier;
  SkillSandboxStatus? _cachedStatus;

  @override
  Future<SkillSandboxStatus> probe() async {
    final cached = _cachedStatus;
    if (cached != null) return cached;
    if (!Platform.isLinux) {
      return _cachedStatus = const SkillSandboxStatus(
        availability: SkillSandboxAvailability.unsupportedPlatform,
        reason: 'skill_scripts_linux_only',
      );
    }
    if (!await File(bubblewrapPath).exists() ||
        !await File(prlimitPath).exists()) {
      return _cachedStatus = const SkillSandboxStatus(
        availability: SkillSandboxAvailability.helperUnavailable,
        reason: 'sandbox_helper_missing',
      );
    }
    Directory? probeDirectory;
    try {
      probeDirectory = await Directory.systemTemp.createTemp(
        'hyve-sandbox-probe-',
      );
      final process = await Process.start(
        bubblewrapPath,
        _bubblewrapArguments(
          skillRoot: probeDirectory.path,
          maxWorkBytes: 1024 * 1024,
          command: '/bin/true',
          commandArguments: const [],
        ),
        environment: const {},
        includeParentEnvironment: false,
      );
      final exitCode = await process.exitCode.timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          process.kill(ProcessSignal.sigkill);
          return -1;
        },
      );
      await process.stdout.drain<void>();
      await process.stderr.drain<void>();
      return _cachedStatus =
          exitCode == 0
              ? const SkillSandboxStatus(
                availability: SkillSandboxAvailability.available,
              )
              : const SkillSandboxStatus(
                availability: SkillSandboxAvailability.probeFailed,
                reason: 'sandbox_probe_failed',
              );
    } on Object {
      return _cachedStatus = const SkillSandboxStatus(
        availability: SkillSandboxAvailability.probeFailed,
        reason: 'sandbox_probe_failed',
      );
    } finally {
      if (probeDirectory != null && await probeDirectory.exists()) {
        await probeDirectory.delete(recursive: true);
      }
    }
  }

  @override
  Future<SkillScriptExecutionResult> execute(
    SkillScriptExecutionRequest request,
    AgentCancellationToken cancellationToken,
  ) async {
    final status = await probe();
    if (!status.isAvailable) {
      throw SkillInstallException(status.reason);
    }
    cancellationToken.throwIfCancelled();
    await _installationVerifier(request.skillRootPath, request.contentDigest);
    cancellationToken.throwIfCancelled();
    final normalizedEntry = path.posix.normalize(
      request.entry.replaceAll('\\', '/'),
    );
    if (!normalizedEntry.startsWith('scripts/') ||
        normalizedEntry.contains('/../')) {
      throw const SkillInstallException('脚本入口已越过 scripts/ 边界。');
    }
    final hostEntry = File(
      path.joinAll([request.skillRootPath, ...normalizedEntry.split('/')]),
    );
    if (!await hostEntry.exists()) {
      throw const SkillInstallException('脚本入口文件不存在。');
    }

    final stopwatch = Stopwatch()..start();
    final interpreter = switch (request.interpreter) {
      SkillScriptInterpreter.python3 => '/usr/bin/python3',
      SkillScriptInterpreter.bash => '/bin/bash',
    };
    final limits = request.limits;
    final process = await Process.start(
      prlimitPath,
      [
        '--cpu=${limits.cpuSeconds}',
        '--as=${limits.memoryBytes}',
        '--nproc=${limits.maxProcesses}',
        '--nofile=${limits.maxOpenFiles}',
        '--fsize=${limits.maxFileBytes}',
        '--',
        bubblewrapPath,
        ..._bubblewrapArguments(
          skillRoot: request.skillRootPath,
          maxWorkBytes: limits.maxFileBytes,
          command: interpreter,
          commandArguments: ['/skill/$normalizedEntry'],
        ),
      ],
      environment: const {},
      includeParentEnvironment: false,
    );
    final stdoutCollector = _collect(process.stdout, limits.maxOutputBytes);
    final stderrCollector = _collect(process.stderr, limits.maxOutputBytes);
    process.stdin.write(jsonEncode(request.arguments));
    await process.stdin.close();

    var timedOut = false;
    var cancelled = false;
    final outcome = await Future.any<int>([
      process.exitCode,
      Future<int>.delayed(limits.wallTime, () => -2),
      cancellationToken.whenCancelled.then((_) => -3),
    ]);
    if (outcome == -2 || outcome == -3) {
      timedOut = outcome == -2;
      cancelled = outcome == -3;
      process.kill(ProcessSignal.sigkill);
      await process.exitCode;
    }
    final stdout = await stdoutCollector;
    final stderr = await stderrCollector;
    if (cancelled) throw const AgentRunCancelledException();
    stopwatch.stop();
    return SkillScriptExecutionResult(
      exitCode: outcome < 0 ? -1 : outcome,
      stdout: utf8.decode(stdout.bytes, allowMalformed: true),
      stderr: utf8.decode(stderr.bytes, allowMalformed: true),
      duration: stopwatch.elapsed,
      timedOut: timedOut,
      outputTruncated: stdout.truncated || stderr.truncated,
    );
  }

  List<String> _bubblewrapArguments({
    required String skillRoot,
    required int maxWorkBytes,
    required String command,
    required List<String> commandArguments,
  }) {
    final arguments = <String>[
      '--unshare-all',
      '--unshare-user',
      '--disable-userns',
      '--die-with-parent',
      '--new-session',
      '--clearenv',
      '--setenv',
      'PATH',
      '/usr/bin:/bin',
      '--setenv',
      'HOME',
      '/nonexistent',
      '--proc',
      '/proc',
      '--dev',
      '/dev',
      '--size',
      '$maxWorkBytes',
      '--tmpfs',
      '/tmp',
      '--ro-bind',
      skillRoot,
      '/skill',
      '--size',
      '$maxWorkBytes',
      '--tmpfs',
      '/work',
      '--chdir',
      '/work',
    ];
    for (final runtimeRoot in const ['/usr', '/bin', '/lib', '/lib64']) {
      if (Directory(runtimeRoot).existsSync()) {
        arguments.addAll(['--ro-bind', runtimeRoot, runtimeRoot]);
      }
    }
    arguments.addAll(['--', command, ...commandArguments]);
    return arguments;
  }

  Future<_LimitedBytes> _collect(Stream<List<int>> stream, int limit) async {
    final builder = BytesBuilder(copy: false);
    var truncated = false;
    await for (final chunk in stream) {
      final remaining = limit - builder.length;
      if (remaining <= 0) {
        truncated = true;
        continue;
      }
      if (chunk.length > remaining) {
        builder.add(chunk.sublist(0, remaining));
        truncated = true;
      } else {
        builder.add(chunk);
      }
    }
    return _LimitedBytes(builder.takeBytes(), truncated);
  }
}

final class _LimitedBytes {
  const _LimitedBytes(this.bytes, this.truncated);

  final Uint8List bytes;
  final bool truncated;
}
