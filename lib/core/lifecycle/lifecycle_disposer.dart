import 'dart:async';
import 'package:deutsch_bilarabi/core/lifecycle/runtime_lifecycle_registry.dart';

/// Master Constitution Section 10 & 13 Compliant Lifecycle Disposer:
/// Enforces idempotent, leak-free disposal of streams, timers, and listeners
/// when navigating away from screens or tearing down state notifiers.
class LifecycleDisposer {
  late final String _ownerId = 'LifecycleDisposer_${identityHashCode(this)}';

  int _activeSubscriptionCount = 0;
  int _activeTimerCount = 0;

  bool get isDisposed => RuntimeLifecycleRegistry.instance.isOwnerDisposed(_ownerId);
  int get activeSubscriptionCount => _activeSubscriptionCount;
  int get activeTimerCount => _activeTimerCount;

  /// Registers a stream subscription for automatic cancellation on dispose
  T bindSubscription<T extends StreamSubscription<dynamic>>(T subscription) {
    if (isDisposed) {
      subscription.cancel();
      return subscription;
    }
    _activeSubscriptionCount++;
    RuntimeLifecycleRegistry.instance.registerCleanup(() {
      subscription.cancel();
      _activeSubscriptionCount--;
    }, owner: _ownerId);
    return subscription;
  }

  /// Registers a timer for automatic cancellation on dispose
  Timer bindTimer(Timer timer) {
    if (isDisposed) {
      timer.cancel();
      return timer;
    }
    _activeTimerCount++;
    RuntimeLifecycleRegistry.instance.registerCleanup(() {
      timer.cancel();
      _activeTimerCount--;
    }, owner: _ownerId);
    return timer;
  }

  /// Adds a custom cleanup callback (e.g. controller or audio player release)
  void addTeardown(void Function() callback) {
    if (isDisposed) {
      callback();
      return;
    }
    RuntimeLifecycleRegistry.instance.registerCleanup(() {
      callback();
    }, owner: _ownerId);
  }

  /// Idempotently disposes all managed resources. Never throws if called multiple times.
  void dispose() {
    // This is safe since RuntimeLifecycleRegistry handles the actual exceptions and idempotency.
    RuntimeLifecycleRegistry.instance.disposeOwner(_ownerId);
  }
}
