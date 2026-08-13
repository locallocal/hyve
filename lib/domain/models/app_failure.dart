import 'dart:async';
import 'dart:io';

import 'package:stars/domain/models/mcp.dart';

enum AppFailureKind {
  validation,
  authentication,
  networkTimeout,
  rateLimited,
  providerRejected,
  storage,
  migration,
  cancelled,
  unknown,
}

/// A product-safe failure. [debugCause] is diagnostic-only and must never be
/// rendered directly by a view.
final class AppFailure implements Exception {
  const AppFailure({
    required this.kind,
    required this.code,
    required this.retryable,
    this.arguments = const <String, Object?>{},
    this.debugCause,
  });

  const AppFailure.validation(String code, {Object? cause})
    : this(
        kind: AppFailureKind.validation,
        code: code,
        retryable: false,
        debugCause: cause,
      );

  const AppFailure.storage(String code, {Object? cause})
    : this(
        kind: AppFailureKind.storage,
        code: code,
        retryable: true,
        debugCause: cause,
      );

  const AppFailure.providerRejected(String code, {Object? cause})
    : this(
        kind: AppFailureKind.providerRejected,
        code: code,
        retryable: false,
        debugCause: cause,
      );

  const AppFailure.cancelled({Object? cause})
    : this(
        kind: AppFailureKind.cancelled,
        code: 'request_cancelled',
        retryable: true,
        debugCause: cause,
      );

  final AppFailureKind kind;
  final String code;
  final bool retryable;
  final Map<String, Object?> arguments;
  final Object? debugCause;

  factory AppFailure.from(Object error, {String code = 'unknown_failure'}) {
    if (error is AppFailure) return error;
    if (error is McpException) {
      final isTimeout = error.code.contains('timeout');
      final isAuthorizationFailure =
          error.code.contains('authorization') ||
          error.statusCode == 401 ||
          error.statusCode == 403;
      return AppFailure(
        kind:
            isTimeout
                ? AppFailureKind.networkTimeout
                : isAuthorizationFailure
                ? AppFailureKind.authentication
                : AppFailureKind.providerRejected,
        code: error.code,
        retryable:
            isTimeout || error.statusCode == null || error.statusCode! >= 500,
        debugCause: error,
      );
    }
    if (error is TimeoutException) {
      return AppFailure(
        kind: AppFailureKind.networkTimeout,
        code: 'network_timeout',
        retryable: true,
        debugCause: error,
      );
    }
    if (error is FileSystemException || error is IOException) {
      return AppFailure.storage(code, cause: error);
    }
    if (error is ArgumentError || error is FormatException) {
      return AppFailure.validation(code, cause: error);
    }

    // Classify common provider/transport failures without copying their raw
    // messages (which can contain endpoints, response bodies, or secrets).
    final diagnostic = error.toString().toLowerCase();
    if (diagnostic.contains('401') ||
        diagnostic.contains('403') ||
        diagnostic.contains('unauthorized') ||
        diagnostic.contains('authentication')) {
      return AppFailure(
        kind: AppFailureKind.authentication,
        code: 'authentication_failed',
        retryable: false,
        debugCause: error,
      );
    }
    if (diagnostic.contains('429') || diagnostic.contains('rate limit')) {
      return AppFailure(
        kind: AppFailureKind.rateLimited,
        code: 'rate_limited',
        retryable: true,
        debugCause: error,
      );
    }
    if (diagnostic.contains('timeout') || diagnostic.contains('timed out')) {
      return AppFailure(
        kind: AppFailureKind.networkTimeout,
        code: 'network_timeout',
        retryable: true,
        debugCause: error,
      );
    }
    if (diagnostic.contains('database') ||
        diagnostic.contains('sqlite') ||
        diagnostic.contains('storage')) {
      return AppFailure.storage(code, cause: error);
    }
    return AppFailure(
      kind: AppFailureKind.unknown,
      code: code,
      retryable: true,
      debugCause: error,
    );
  }

  @override
  String toString() => 'AppFailure($code)';
}
