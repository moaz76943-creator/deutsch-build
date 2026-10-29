import 'dart:async';

class SrsUpdateQueue {
  Future<void> _lastOperation = Future.value();

  Future<T> synchronized<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _lastOperation = _lastOperation.then((_) async {
      try {
        final result = await action();
        completer.complete(result);
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }
}
