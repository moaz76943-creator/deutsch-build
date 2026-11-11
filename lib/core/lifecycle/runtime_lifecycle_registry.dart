import 'dart:async';

import 'package:flutter/foundation.dart';

/// مسجل مركزي لدورة حياة الموارد المؤقتة والاشتراكات لمنع تسريبات الذاكرة
import 'dart:collection';

class RuntimeLifecycleRegistry {
  static const int maxTrackedResources = 5000;
  static const int maxRememberedOwners = 100;
  static const int maxLegacyOwnerTombstones = 100;

  RuntimeLifecycleRegistry._();
  static final RuntimeLifecycleRegistry instance = RuntimeLifecycleRegistry._();

  final Map<Object, List<FutureOr<void> Function()>> _cleanups = {};
  final LinkedHashSet<Object> _disposedOwners = LinkedHashSet<Object>();
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  int get trackedResourceCount {
    int count = 0;
    for (var list in _cleanups.values) {
      count += list.length;
    }
    return count;
  }

  bool isOwnerDisposed(Object owner) {
    return _isDisposed || _disposedOwners.contains(owner);
  }

  void registerSubscription(
    StreamSubscription<dynamic> sub, {
    Object owner = 'global',
  }) {
    registerCleanup(() => sub.cancel(), owner: owner);
  }

  void registerTimer(Timer timer, {Object owner = 'global'}) {
    if (_isDisposed) {
      timer.cancel();
      return;
    }
    registerCleanup(() {
      timer.cancel();
    }, owner: owner);
  }

  void registerCleanup(
    FutureOr<void> Function() cleanup, {
    Object owner = 'global',
  }) {
    if (isOwnerDisposed(owner)) {
      _safeCleanup(cleanup);
      return;
    }
    if (trackedResourceCount >= maxTrackedResources) {
      throw StateError('Max tracked resources exceeded');
    }
    _cleanups.putIfAbsent(owner, () => []).add(cleanup);
  }

  Future<void> disposeOwner(Object owner) async {
    if (isOwnerDisposed(owner)) return;
    _disposedOwners.add(owner);
    if (_disposedOwners.length > maxRememberedOwners) {
      _disposedOwners.remove(_disposedOwners.first);
    }
    await _disposeOwnerResources(owner);
  }

  Future<void> disposeAll() async {
    if (_isDisposed) return;
    _isDisposed = true;

    final owners = _cleanups.keys.toList().reversed;
    for (final owner in owners) {
      if (!_disposedOwners.contains(owner)) {
        _disposedOwners.add(owner);
        if (_disposedOwners.length > maxRememberedOwners) {
          _disposedOwners.remove(_disposedOwners.first);
        }
        await _disposeOwnerResources(owner);
      }
    }

    _cleanups.clear();
  }

  Future<void> _disposeOwnerResources(Object owner) async {
    final cleanups = _cleanups[owner];
    if (cleanups == null || cleanups.isEmpty) return;

    // LIFO order for deterministic shutdown
    final callbacks = cleanups.reversed.toList();
    _cleanups.remove(owner); // clear before execution to handle race conditions

    for (final cleanup in callbacks) {
      await _safeCleanup(cleanup);
    }
  }

  Future<void> _safeCleanup(FutureOr<void> Function() cleanup) async {
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

  T? guard<T>(T Function() callback, {Object owner = 'global'}) {
    if (isOwnerDisposed(owner)) {
      return null;
    }
    return callback();
  }

  Future<T?> guardFuture<T>(Future<T> future, {Object owner = 'global'}) async {
    final result = await future;
    if (isOwnerDisposed(owner)) {
      return null;
    }
    return result;
  }

  // Legacy APIs and metrics getters
  void registerResource(FutureOr<void> Function() cleanup,
      {Object owner = 'global'}) {
    registerCleanup(cleanup, owner: owner);
  }

  Future<void> disposeByOwner(Object owner) async {
    await disposeOwner(owner);
  }

  int get rememberedDisposedOwnerCount => _disposedOwners.length;
  int get legacyTombstoneCount => _disposedOwners.length;

  @visibleForTesting
  void resetForTesting() {
    resetForTest();
  }

  @visibleForTesting
  void resetForTest() {
    _cleanups.clear();
    _disposedOwners.clear();
    _isDisposed = false;
  }
}

class LifecycleOwner {
  const LifecycleOwner();
}

class LifecycleOwnerToken extends LifecycleOwner {
  LifecycleOwnerToken();
  bool get isDisposed =>
      RuntimeLifecycleRegistry.instance.isOwnerDisposed(this);
}
