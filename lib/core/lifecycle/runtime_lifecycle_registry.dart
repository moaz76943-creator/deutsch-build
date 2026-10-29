import 'dart:async';
import 'dart:collection';

/// An ownership token. Its disposed state is kept on the token itself instead
/// of in the global registry, so releasing thousands of screens stays O(active).
class LifecycleOwner {
  bool _disposed = false;
  bool get isDisposed => _disposed;
}

class _LifecycleEntry {
  _LifecycleEntry(this.dispose, this.owner);
  final FutureOr<void> Function() dispose;
  final Object? owner;
}

/// Tracks temporary UI resources; never owns persistent learner data.
class RuntimeLifecycleRegistry {
  RuntimeLifecycleRegistry._();
  static final RuntimeLifecycleRegistry instance = RuntimeLifecycleRegistry._();

  static const int maxTrackedResources = 4096;
  static const int maxLegacyOwnerTombstones = 256;
  static const Duration disposerTimeout = Duration(seconds: 5);

  final List<_LifecycleEntry> _entries = <_LifecycleEntry>[];
  final LinkedHashSet<Object> _legacyDisposedOwners = LinkedHashSet<Object>();
  final List<void Function()> _memoryPressureListeners = <void Function()>[];
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;
  int get trackedResourceCount => _entries.length;
  int get legacyTombstoneCount => _legacyDisposedOwners.length;

  void registerSubscription(
    StreamSubscription<dynamic> subscription, {
    Object? owner,
    String? ownerKey,
  }) {
    registerResource(subscription.cancel, owner: owner ?? ownerKey);
  }

  void registerTimer(
    Timer timer, {
    Object? owner,
    String? ownerKey,
  }) {
    registerResource(timer.cancel, owner: owner ?? ownerKey);
  }

  void registerCleanupCallback(
    FutureOr<void> Function() callback, {
    Object? owner,
    String? ownerKey,
  }) {
    registerResource(callback, owner: owner ?? ownerKey);
  }

  void registerResource(
    FutureOr<void> Function() onDispose, {
    Object? owner,
    String? ownerKey,
  }) {
    final effectiveOwner = owner ?? ownerKey;
    if (_isDisposed ||
        (effectiveOwner is LifecycleOwner && effectiveOwner.isDisposed) ||
        (effectiveOwner != null && _legacyDisposedOwners.contains(effectiveOwner))) {
      _disposeLate(onDispose);
      return;
    }
    if (_entries.length >= maxTrackedResources) {
      _disposeLate(onDispose);
      throw StateError('Lifecycle resource capacity exceeded');
    }
    _entries.add(_LifecycleEntry(onDispose, effectiveOwner));
  }

  void registerMemoryPressureListener(void Function() listener) {
    if (_isDisposed) return;
    _memoryPressureListeners.add(listener);
  }

  void unregisterMemoryPressureListener(void Function() listener) {
    _memoryPressureListeners.remove(listener);
  }

  void notifyMemoryPressure() {
    if (_isDisposed) return;
    for (final listener in List<void Function()>.from(_memoryPressureListeners)) {
      try {
        listener();
      } catch (_) {}
    }
  }

  Future<void> disposeOwner(String ownerKey) => disposeByOwner(ownerKey);

  Future<void> disposeByOwner(Object owner) async {
    if (_isDisposed) return;
    if (owner is LifecycleOwner) {
      owner._disposed = true;
    } else {
      // Bounded fallback for old primitive owner IDs.
      _legacyDisposedOwners.remove(owner);
      _legacyDisposedOwners.add(owner);
      if (_legacyDisposedOwners.length > maxLegacyOwnerTombstones) {
        _legacyDisposedOwners.remove(_legacyDisposedOwners.first);
      }
    }

    final disposing = <_LifecycleEntry>[];
    _entries.removeWhere((entry) {
      if (identical(entry.owner, owner) || entry.owner == owner) {
        disposing.add(entry);
        return true;
      }
      return false;
    });
    for (final entry in disposing.reversed) {
      await _safeDispose(entry.dispose);
    }
  }

  Future<void> disposeAll() async {
    if (_isDisposed) return;
    _isDisposed = true;
    final disposing = _entries.reversed.toList(growable: false);
    _entries.clear();
    _legacyDisposedOwners.clear();
    for (final entry in disposing) {
      if (entry.owner is LifecycleOwner) {
        (entry.owner! as LifecycleOwner)._disposed = true;
      }
      await _safeDispose(entry.dispose);
    }
  }

  Future<void> _safeDispose(FutureOr<void> Function() disposer) async {
    try {
      await Future<void>.sync(disposer).timeout(disposerTimeout);
    } catch (_) {
      // One invalid resource must not prevent independent resource cleanup.
    }
  }

  void _disposeLate(FutureOr<void> Function() disposer) {
    try {
      final result = disposer();
      if (result is Future) {
        result.timeout(disposerTimeout).then<void>((_) {},
            onError: (Object _, StackTrace __) {});
      }
    } catch (_) {
      // A synchronous late disposer is also best-effort.
    }
  }

  /// Tests only. Not a production lifecycle resurrection API.
  void resetForTesting() {
    _entries.clear();
    _legacyDisposedOwners.clear();
    _memoryPressureListeners.clear();
    _isDisposed = false;
  }

  void reset() => resetForTesting();
}
