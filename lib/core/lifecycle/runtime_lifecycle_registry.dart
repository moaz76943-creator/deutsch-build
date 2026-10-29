import 'dart:async';
import 'package:flutter/foundation.dart';

/// مسجل مركزي لدورة حياة الموارد المؤقتة والاشتراكات لمنع تسريبات الذاكرة
class RuntimeLifecycleRegistry {
  RuntimeLifecycleRegistry._();
  static final RuntimeLifecycleRegistry instance = RuntimeLifecycleRegistry._();

  final Map<String, List<FutureOr<void> Function()>> _cleanups = {};
  final Set<String> _disposedOwners = {};
  bool _isDisposed = false;

  final List<StreamSubscription<dynamic>> subscriptions = [];
  final List<Timer> timers = [];

  bool get isDisposed => _isDisposed;

  bool isOwnerDisposed(String owner) {
    return _isDisposed || _disposedOwners.contains(owner);
  }

  void registerSubscription(StreamSubscription<dynamic> sub, {String owner = 'global'}) {
    if (isDisposed) {
      sub.cancel();
      return;
    }
    subscriptions.add(sub);
    registerCleanup(() {
      subscriptions.remove(sub);
      return sub.cancel();
    }, owner: owner);
  }

  void registerTimer(Timer timer, {String owner = 'global'}) {
    if (isDisposed) {
      timer.cancel();
      return;
    }
    timers.add(timer);
    registerCleanup(() {
      timers.remove(timer);
      timer.cancel();
    }, owner: owner);
  }

  void registerCleanup(FutureOr<void> Function() cleanup,
      {String owner = 'global'}) {
    if (isOwnerDisposed(owner)) {
      safeCleanup(cleanup);
      return;
    }
    _cleanups.putIfAbsent(owner, () => []).add(cleanup);
  }

  Future<void> disposeOwner(String owner) async {
    if (isOwnerDisposed(owner)) return;
    _disposedOwners.add(owner);
    await disposeOwnerResources(owner);
  }

  Future<void> disposeAll() async {
    _isDisposed = true;

    final owners = _cleanups.keys.toList().reversed;
    for (final owner in owners) {
      if (!_disposedOwners.contains(owner)) {
        _disposedOwners.add(owner);
        await disposeOwnerResources(owner);
      }
    }

    _cleanups.clear();
    timers.clear();
    subscriptions.clear();
  }

  Future<void> disposeOwnerResources(String owner) async {
    final cleanups = _cleanups[owner];
    if (cleanups == null || cleanups.isEmpty) return;

    // LIFO order for deterministic shutdown
    final callbacks = cleanups.reversed.toList();
    _cleanups.remove(owner); // clear before execution to handle race conditions

    for (final cleanup in callbacks) {
      await safeCleanup(cleanup);
    }
  }

  Future<void> safeCleanup(FutureOr<void> Function() cleanup) async {
    try {
      final result = cleanup();
      if (result is Future) {
        // Enforce a bounded cleanup timeout, e.g., 5 seconds.
        await result.timeout(const Duration(seconds: 5));
      }
    } catch (e, stackTrace) {
      // Ensure one failing disposer does not skip remaining cleanups.
      // Log or handle the exception safely here.
      debugPrint('RuntimeLifecycleRegistry: Cleanup error: $e\n$stackTrace');
    }
  }

  T? guard<T>(T Function() callback, {String owner = 'global'}) {
    if (isOwnerDisposed(owner)) {
      return null;
    }
    return callback();
  }

  Future<T?> guardFuture<T>(Future<T> future, {String owner = 'global'}) async {
    final result = await future;
    if (isOwnerDisposed(owner)) {
      return null;
    }
    return result;
  }

  @visibleForTesting
  void resetForTest() {
    _cleanups.clear();
    _disposedOwners.clear();
    _isDisposed = false;
    subscriptions.clear();
    timers.clear();
  }
}
