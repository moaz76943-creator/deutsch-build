class CancellationToken {
  bool _isCancelled = false;
  final List<void Function()> _listeners = [];
  final Stopwatch _stopwatch = Stopwatch()..start();
  final Duration _yieldThreshold = const Duration(milliseconds: 16);

  bool get isCancelled => _isCancelled;

  void cancel() {
    if (_isCancelled) return;
    _isCancelled = true;
    for (final listener in _listeners) {
      listener();
    }
    _listeners.clear();
  }

  void onCancel(void Function() callback) {
    if (_isCancelled) {
      callback();
    } else {
      _listeners.add(callback);
    }
  }

  void throwIfCancelled() {
    if (_isCancelled) {
      throw StateError('Operation was cancelled by user or timeout');
    }
  }

  Future<void> yieldAndCheck() async {
    throwIfCancelled();
    if (_stopwatch.elapsed > _yieldThreshold) {
      await Future.delayed(Duration.zero);
      throwIfCancelled();
      _stopwatch.reset();
    }
  }
}
