import 'dart:async';

class _RegistryEntry {
  final FutureOr<void> Function() onDispose;
  final Object? owner;

  _RegistryEntry({required this.onDispose, this.owner});
}

/// مسجل مركزي لدورة حياة الموارد المؤقتة والاشتراكات لمنع تسريبات الذاكرة
class RuntimeLifecycleRegistry {
  RuntimeLifecycleRegistry._();
  static final RuntimeLifecycleRegistry instance = RuntimeLifecycleRegistry._();

  final List<_RegistryEntry> _entries = [];
  bool _isDisposed = false;
  final Set<Object> _disposedOwners = {};

  void registerSubscription(StreamSubscription<dynamic> sub, {Object? owner}) {
    registerResource(sub.cancel, owner: owner);
  }

  void registerTimer(Timer timer, {Object? owner}) {
    registerResource(timer.cancel, owner: owner);
  }

  void registerResource(FutureOr<void> Function() onDispose, {Object? owner}) {
    if (_isDisposed || (owner != null && _disposedOwners.contains(owner))) {
      _safeDisposeSyncOrFireAndForget(onDispose);
      return;
    }
    _entries.add(_RegistryEntry(onDispose: onDispose, owner: owner));
  }

  Future<void> disposeAll() async {
    _isDisposed = true;
    _disposedOwners.clear();

    final entriesToDispose = _entries.reversed.toList();
    _entries.clear();

    for (final entry in entriesToDispose) {
      await _safeDispose(entry.onDispose);
    }
  }

  Future<void> disposeByOwner(Object owner) async {
    if (_isDisposed) return;

    _disposedOwners.add(owner);

    final entriesToDispose = _entries.where((e) => e.owner == owner).toList().reversed.toList();
    _entries.removeWhere((e) => e.owner == owner);

    for (final entry in entriesToDispose) {
      await _safeDispose(entry.onDispose);
    }
  }

  Future<void> _safeDispose(FutureOr<void> Function() onDispose) async {
    try {
      final result = onDispose();
      if (result is Future) {
        await result.timeout(const Duration(seconds: 5));
      }
    } catch (_) {
      // Ignored to ensure one failing disposer does not skip the rest.
    }
  }

  void _safeDisposeSyncOrFireAndForget(FutureOr<void> Function() onDispose) {
    try {
      final result = onDispose();
      if (result is Future) {
        result.timeout(const Duration(seconds: 5)).catchError((_) {});
      }
    } catch (_) {}
  }

  bool get isDisposed => _isDisposed;

  void resetForTesting() {
    _isDisposed = false;
    _entries.clear();
    _disposedOwners.clear();
  }
}
