import 'dart:async';

/// Master Constitution Section 10 & 13 Compliant Lifecycle Disposer:
/// Enforces idempotent, leak-free disposal of streams, timers, and listeners
/// when navigating away from screens or tearing down state notifiers.
class LifecycleDisposer {
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final List<Timer> _timers = [];
  final List<void Function()> _teardownCallbacks = [];
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;
  int get activeSubscriptionCount => _subscriptions.length;
  int get activeTimerCount => _timers.length;

  /// Registers a stream subscription for automatic cancellation on dispose
  T bindSubscription<T extends StreamSubscription<dynamic>>(T subscription) {
    if (_isDisposed) {
      subscription.cancel();
      return subscription;
    }
    _subscriptions.add(subscription);
    return subscription;
  }

  /// Registers a timer for automatic cancellation on dispose
  Timer bindTimer(Timer timer) {
    if (_isDisposed) {
      timer.cancel();
      return timer;
    }
    _timers.add(timer);
    return timer;
  }

  /// Adds a custom cleanup callback (e.g. controller or audio player release)
  void addTeardown(void Function() callback) {
    if (_isDisposed) {
      callback();
      return;
    }
    _teardownCallbacks.add(callback);
  }

  /// Guards a callback so it doesn't execute if already disposed.
  T? guard<T>(T Function() callback) {
    if (_isDisposed) return null;
    return callback();
  }

  /// Guards a future so it returns null if disposed before it completes.
  Future<T?> guardFuture<T>(Future<T> future) async {
    final result = await future;
    if (_isDisposed) return null;
    return result;
  }

  /// Idempotently disposes all managed resources. Never throws if called multiple times.
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    final futures = <Future<dynamic>>[];

    final subs = _subscriptions.reversed.toList();
    _subscriptions.clear();
    for (final sub in subs) {
      try {
        final f = sub.cancel();
        futures.add(f);
      } catch (_) {}
    }

    final tmrs = _timers.reversed.toList();
    _timers.clear();
    for (final timer in tmrs) {
      try {
        timer.cancel();
      } catch (_) {}
    }

    final teardowns = _teardownCallbacks.reversed.toList();
    _teardownCallbacks.clear();
    for (final teardown in teardowns) {
      try {
        // Run teardown
        final dynamic result = (teardown as dynamic)();
        if (result is Future) {
          futures.add(result);
        }
      } catch (_) {
        // Suppress teardown exceptions during batch disposal
      }
    }

    if (futures.isNotEmpty) {
      try {
        await Future.wait(futures).timeout(const Duration(seconds: 5));
      } catch (_) {
        // Ignore timeout or other errors during disposal
      }
    }
  }
}
