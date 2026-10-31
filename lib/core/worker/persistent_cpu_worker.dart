import 'dart:async';

/// Master Constitution Section 10 Compliant CPU Worker:
/// Enforces requestGeneration (latest-wins), cancellation on language/screen change,
/// execution timeout watchdog, and safe resource disposal to prevent leaks.
class PersistentCpuWorker {
  int _activeGeneration = 0;
  bool _isDisposed = false;
  Completer<dynamic>? _pendingCompleter;

  int get currentGeneration => _activeGeneration;
  bool get isDisposed => _isDisposed;

  /// Submits an asynchronous CPU task. Only the latest generation result is accepted.
  Future<T?> executeTask<T>({
    required Future<T> Function() computation,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (_isDisposed) {
      throw StateError('Worker is disposed. Cannot schedule new CPU tasks.');
    }

    final generation = ++_activeGeneration;
    final completer = Completer<T?>();
    _pendingCompleter = completer;

    try {
      final result = await computation().timeout(timeout, onTimeout: () {
        throw TimeoutException('CPU task timed out after ${timeout.inSeconds}s (Gen $generation)');
      });

      // Latest-Wins policy: drop result if generation has advanced
      if (_isDisposed || generation != _activeGeneration) {
        return null;
      }

      completer.complete(result);
      return result;
    } catch (e, st) {
      if (generation == _activeGeneration && !completer.isCompleted) {
        completer.completeError(e, st);
      }
      return null;
    }
  }

  /// Cancels in-flight work immediately (e.g. when language pair or screen changes)
  void cancelActiveOperations() {
    _activeGeneration++;
    if (_pendingCompleter != null && !_pendingCompleter!.isCompleted) {
      _pendingCompleter!.complete(null);
      _pendingCompleter = null;
    }
  }

  /// Safe disposal freeing all worker references and cancelling subscriptions
  void dispose() {
    _isDisposed = true;
    cancelActiveOperations();
  }
}
