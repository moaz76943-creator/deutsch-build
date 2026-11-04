import 'dart:async';

import 'package:flutter/foundation.dart';

/// مسجل مركزي لدورة حياة الموارد المؤقتة والاشتراكات لمنع تسريبات الذاكرة
class RuntimeLifecycleRegistry {
  RuntimeLifecycleRegistry._();
  static final RuntimeLifecycleRegistry instance = RuntimeLifecycleRegistry._();

  final Map<String, List<FutureOr<void> Function()>> _cleanups = {};
  final Set<String> _disposedOwners = {};
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  bool isOwnerDisposed(String owner) {
    return _isDisposed || _disposedOwners.contains(owner);
  }

  void registerSubscription(
    StreamSubscription<dynamic> sub, {
    String owner = 'global',
  }) {
    registerCleanup(() => sub.cancel(), owner: owner);
  }

  void registerTimer(Timer timer, {String owner = 'global'}) {
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
    String owner = 'global',
  }) {
    if (isOwnerDisposed(owner)) {
      safeCleanup(cleanup);
      return;
    }
    _cleanups.putIfAbsent(owner, () => []).add(cleanup);
  }

  Future<void> disposeOwner(String owner) async {
    if (isOwnerDisposed(owner)) return;
    _disposedOwners.add(owner);
    await _disposeOwnerResources(owner);
  }

  Future<void> disposeAll() async {
    if (_isDisposed) return;
    _isDisposed = true;

    final owners = _cleanups.keys.toList().reversed;
    for (final owner in owners) {
      if (!_disposedOwners.contains(owner)) {
        _disposedOwners.add(owner);
        await _disposeOwnerResources(owner);
      }
    }

    _cleanups.clear();
  }

  Future<void> _disposeOwnerResources(String owner) async {
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
  }
}
