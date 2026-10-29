import 'dart:async';

/// مسجل مركزي لدورة حياة الموارد المؤقتة والاشتراكات لمنع تسريبات الذاكرة
class RuntimeLifecycleRegistry {
  RuntimeLifecycleRegistry._();
  static final RuntimeLifecycleRegistry instance = RuntimeLifecycleRegistry._();

  static const String _defaultOwnerKey = 'global';
  static const Duration _cleanupTimeout = Duration(seconds: 5);

  final Map<String, List<StreamSubscription<dynamic>>> _subscriptions = {};
  final Map<String, List<Timer>> _timers = {};
  final Map<String, List<FutureOr<void> Function()>> _callbacks = {};

  final Set<String> _disposedOwners = {};
  bool _isGlobalDisposed = false;

  void registerSubscription(StreamSubscription<dynamic> sub, {String? ownerKey}) {
    final key = ownerKey ?? _defaultOwnerKey;
    if (_isGlobalDisposed || _disposedOwners.contains(key)) {
      try {
        sub.cancel();
      } catch (_) {}
      return;
    }
    _subscriptions.putIfAbsent(key, () => []).add(sub);
  }

  void registerTimer(Timer timer, {String? ownerKey}) {
    final key = ownerKey ?? _defaultOwnerKey;
    if (_isGlobalDisposed || _disposedOwners.contains(key)) {
      try {
        timer.cancel();
      } catch (_) {}
      return;
    }
    _timers.putIfAbsent(key, () => []).add(timer);
  }

  void registerCleanupCallback(FutureOr<void> Function() callback, {String? ownerKey}) {
    final key = ownerKey ?? _defaultOwnerKey;
    if (_isGlobalDisposed || _disposedOwners.contains(key)) {
      _runCallbackSafe(callback);
      return;
    }
    _callbacks.putIfAbsent(key, () => []).add(callback);
  }

  Future<void> disposeOwner(String ownerKey) async {
    if (_isGlobalDisposed || _disposedOwners.contains(ownerKey)) return;
    _disposedOwners.add(ownerKey);

    await _disposeResourcesForOwner(ownerKey);
  }

  Future<void> disposeAll() async {
    if (_isGlobalDisposed) return;
    _isGlobalDisposed = true;

    final allKeys = <String>{
      ..._timers.keys,
      ..._subscriptions.keys,
      ..._callbacks.keys,
    };

    for (final key in allKeys) {
      if (!_disposedOwners.contains(key)) {
        await _disposeResourcesForOwner(key);
      }
    }

    _timers.clear();
    _subscriptions.clear();
    _callbacks.clear();
    // We do not clear _disposedOwners, because if a screen tries to register a resource
    // after disposeAll(), it should be cancelled immediately. However, since _isGlobalDisposed is true,
    // the global disposed check will catch it anyway.
  }

  Future<void> _disposeResourcesForOwner(String key) async {
    // 1. Timers
    final timers = _timers.remove(key) ?? [];
    for (final timer in timers) {
      try {
        timer.cancel();
      } catch (_) {}
    }

    // 2. Subscriptions
    final subs = _subscriptions.remove(key) ?? [];
    for (final sub in subs) {
      try {
        final future = sub.cancel();
        // cancel() on streams might not return a Future, or might return Future<void> or Future<dynamic>
        // but typically stream.cancel() returns Future. We can safely await it and timeout.
        await Future.sync(() => future).timeout(_cleanupTimeout);
      } catch (_) {}
    }

    // 3. Callbacks
    final callbacks = _callbacks.remove(key) ?? [];
    for (final callback in callbacks) {
      await _runCallbackSafe(callback);
    }
  }

  Future<void> _runCallbackSafe(FutureOr<void> Function() callback) async {
    try {
      final result = callback();
      if (result is Future) {
        await result.timeout(_cleanupTimeout);
      }
    } catch (_) {}
  }

  bool get isDisposed => _isGlobalDisposed;

  /// Resets the registry. Primarily useful for testing.
  void reset() {
    _isGlobalDisposed = false;
    _timers.clear();
    _subscriptions.clear();
    _callbacks.clear();
    _disposedOwners.clear();
  }
}
