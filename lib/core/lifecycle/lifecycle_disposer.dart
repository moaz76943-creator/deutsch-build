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

  /// Idempotently disposes all managed resources. Never throws if called multiple times.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    for (final sub in _subscriptions.reversed) {
      try {
        sub.cancel();
      } catch (_) {}
    }
    _subscriptions.clear();

    for (final timer in _timers.reversed) {
      try {
        timer.cancel();
      } catch (_) {}
    }
    _timers.clear();

    for (final teardown in _teardownCallbacks.reversed) {
      try {
        teardown();
      } catch (_) {
        // Suppress teardown exceptions during batch disposal
      }
    }
    _teardownCallbacks.clear();
  }
}
