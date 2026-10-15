import 'dart:async';

abstract class _Resource {
  final String? owner;
  _Resource(this.owner);
  FutureOr<void> dispose();
}

class _SubscriptionResource extends _Resource {
  final StreamSubscription<dynamic> subscription;
  _SubscriptionResource(this.subscription, String? owner) : super(owner);

  @override
  FutureOr<void> dispose() => subscription.cancel();
}

class _TimerResource extends _Resource {
  final Timer timer;
  _TimerResource(this.timer, String? owner) : super(owner);

  @override
  void dispose() => timer.cancel();
}

class _CallbackResource extends _Resource {
  final FutureOr<void> Function() onDispose;
  _CallbackResource(this.onDispose, String? owner) : super(owner);

  @override
  FutureOr<void> dispose() => onDispose();
}

/// مسجل مركزي لدورة حياة الموارد المؤقتة والاشتراكات لمنع تسريبات الذاكرة
class RuntimeLifecycleRegistry {
  RuntimeLifecycleRegistry._();
  static final RuntimeLifecycleRegistry instance = RuntimeLifecycleRegistry._();

  final List<_Resource> _resources = [];
  bool _isDisposed = false;

  void registerSubscription(StreamSubscription<dynamic> sub, {String? owner}) {
    if (_isDisposed) {
      sub.cancel();
      return;
    }
    _resources.add(_SubscriptionResource(sub, owner));
  }

  void registerTimer(Timer timer, {String? owner}) {
    if (_isDisposed) {
      timer.cancel();
      return;
    }
    _resources.add(_TimerResource(timer, owner));
  }

  void registerCallback(FutureOr<void> Function() onDispose, {String? owner}) {
    if (_isDisposed) {
      try {
        final result = onDispose();
        if (result is Future) {
          result.timeout(const Duration(seconds: 5)).catchError((e, st) {
            print('Cleanup timeout or error on disposed registry: $e\n$st');
          });
        }
      } catch (e, st) {
        print('Cleanup error on disposed registry: $e\n$st');
      }
      return;
    }
    _resources.add(_CallbackResource(onDispose, owner));
  }

  Future<void> disposeOwner(String owner) async {
    // Execute cleanup in deterministic reverse-insertion (LIFO) order.
    final resourcesToDispose = _resources.where((r) => r.owner == owner).toList().reversed;
    _resources.removeWhere((r) => r.owner == owner);

    for (final resource in resourcesToDispose) {
      await _disposeSafely(resource);
    }
  }

  Future<void> disposeAll() async {
    _isDisposed = true;

    // Copy and reverse for LIFO
    final resourcesToDispose = _resources.toList().reversed;
    _resources.clear();

    for (final resource in resourcesToDispose) {
      await _disposeSafely(resource);
    }
  }

  Future<void> _disposeSafely(_Resource resource) async {
    try {
      final result = resource.dispose();
      if (result is Future) {
        await result.timeout(const Duration(seconds: 5));
      }
    } catch (e, st) {
      // Ensure one failing disposer does not skip all remaining independent cleanup operations.
      print('Error disposing resource owned by ${resource.owner}: $e\n$st');
    }
  }

  bool get isDisposed => _isDisposed;

  void resetForTesting() {
    _resources.clear();
    _isDisposed = false;
  }
}
