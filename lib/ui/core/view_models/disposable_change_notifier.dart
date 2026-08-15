import 'package:flutter/foundation.dart';

/// A [ChangeNotifier] that makes asynchronous completion disposal-safe.
///
/// Subclasses must still check [isDisposed] before mutating presentation state
/// after an `await`. The guarded [notifyListeners] is the final safety net that
/// prevents a late completion from notifying an already disposed notifier.
abstract class DisposableChangeNotifier extends ChangeNotifier {
  bool _isDisposed = false;

  @protected
  bool get isDisposed => _isDisposed;

  /// Releases subscriptions, timers, and cancellation tokens.
  ///
  /// The notifier is marked disposed before this hook runs, so synchronous
  /// callbacks caused by cancellation cannot publish more presentation state.
  @protected
  void disposeResources() {}

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    try {
      disposeResources();
    } finally {
      super.dispose();
    }
  }
}
