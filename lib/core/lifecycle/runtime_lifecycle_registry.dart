import 'dart:async';
import 'dart:collection';

class _LifecycleEntry {
  final FutureOr<void> Function() dispose;
  final Object? owner;
  const _LifecycleEntry(this.dispose, this.owner);
}


/// Prefer one token per screen/session. Disposal stays on the token itself,
/// so the singleton need not retain a reference to each retired owner.
class LifecycleOwnerToken {
  bool _disposed = false;
  bool get isDisposed => _disposed;
}
/// Scoped, idempotent cleanup. Disposed owner tombstones are explicitly bounded,
/// unlike the unbounded singleton set in the proposed J079 implementation.
class RuntimeLifecycleRegistry {
  RuntimeLifecycleRegistry._();
  static final RuntimeLifecycleRegistry instance = RuntimeLifecycleRegistry._();

  static const int maxRememberedOwners = 128;
  static const Duration cleanupTimeout = Duration(seconds: 2);

  final List<_LifecycleEntry> _entries = [];
  final LinkedHashSet<Object> _disposedOwners = LinkedHashSet<Object>();
  bool _isDisposed = false;

  void registerSubscription(StreamSubscription<dynamic> sub, {Object? owner}) {
    registerResource(sub.cancel, owner: owner);
  }

  void registerTimer(Timer timer, {Object? owner}) {
    registerResource(timer.cancel, owner: owner);
  }

  void registerResource(FutureOr<void> Function() onDispose, {Object? owner}) {
    final ownerDisposed = owner is LifecycleOwnerToken
        ? owner.isDisposed
        : owner != null && _disposedOwners.contains(owner);
    if (_isDisposed || ownerDisposed) {
      // Execute synchronously when possible, while safely observing async errors.
      try {
        final result = onDispose();
        if (result is Future) {
          unawaited(result.timeout(cleanupTimeout).then<void>(
            (_) {},
            onError: (Object _, StackTrace __) {},
          ));
        }
      } catch (_) {
        // An independent disposer must not crash a lifecycle transition.
      }
      return;
    }
    _entries.add(_LifecycleEntry(onDispose, owner));
  }

  Future<void> _disposeEntry(_LifecycleEntry entry) async {
    try {
      await Future<void>.sync(entry.dispose).timeout(cleanupTimeout);
    } catch (_) {
      // Failure or timeout cannot prevent other resources being released.
    }
  }

  Future<void> disposeByOwner(Object owner) async {
    if (_isDisposed) return;
    if (owner is LifecycleOwnerToken) {
      // This is a lifetime property on the token, not a global strong ref.
      owner._disposed = true;
    } else {
      // Compatibility fallback for pre-existing string/object owners.
      _disposedOwners.remove(owner);
      _disposedOwners.add(owner);
      while (_disposedOwners.length > maxRememberedOwners) {
        _disposedOwners.remove(_disposedOwners.first);
      }
    }

    final owned = _entries.where((entry) => entry.owner == owner).toList();
    _entries.removeWhere((entry) => entry.owner == owner);
    for (final entry in owned.reversed) {
      await _disposeEntry(entry);
    }
  }

  Future<void> disposeAll() async {
    if (_isDisposed) return;
    _isDisposed = true;
    final entries = _entries.reversed.toList();
    _entries.clear();
    _disposedOwners.clear();
    for (final entry in entries) {
      await _disposeEntry(entry);
    }
  }

  bool get isDisposed => _isDisposed;

  // Observability for deterministic bounded-memory tests.
  int get rememberedDisposedOwnerCount => _disposedOwners.length;

  void resetForTesting() {
    _entries.clear();
    _disposedOwners.clear();
    _isDisposed = false;
  }
}
