import 'dart:async';

/// مسجل مركزي لدورة حياة الموارد المؤقتة والاشتراكات لمنع تسريبات الذاكرة
class RuntimeLifecycleRegistry {
  RuntimeLifecycleRegistry._();
  static final RuntimeLifecycleRegistry instance = RuntimeLifecycleRegistry._();

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final List<Timer> _timers = [];
  bool _isDisposed = false;

  void registerSubscription(StreamSubscription<dynamic> sub) {
    if (_isDisposed) {
      sub.cancel();
      return;
    }
    _subscriptions.add(sub);
  }

  void registerTimer(Timer timer) {
    if (_isDisposed) {
      timer.cancel();
      return;
    }
    _timers.add(timer);
  }

  Future<void> disposeAll() async {
    _isDisposed = true;
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();

    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
  }

  bool get isDisposed => _isDisposed;
}
