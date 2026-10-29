import 'dart:async';
import 'dart:isolate';

class WorkerQueueExhaustedException implements Exception {
  const WorkerQueueExhaustedException();
  @override
  String toString() => 'WorkerQueueExhaustedException: queue capacity reached';
}

class WorkerCancelledException implements Exception {
  const WorkerCancelledException();
  @override
  String toString() => 'WorkerCancelledException: generation invalidated';
}

/// One long-lived CPU isolate; no compute-per-request isolate churn.
class PersistentCpuWorker {
  PersistentCpuWorker._init();
  static final PersistentCpuWorker instance = PersistentCpuWorker._init();

  static const Duration jobTimeout = Duration(seconds: 8);
  int _maxQueueSize = 50;
  int _activeJobs = 0;
  int _generation = 0;
  int _nextRequestId = 0;
  bool _disposed = false;
  Isolate? _isolate;
  ReceivePort? _receive;
  SendPort? _send;
  Future<SendPort>? _opening;
  Completer<SendPort>? _ready;
  final Map<int, Completer<double>> _pending = {};

  Future<SendPort> _ensureStarted() {
    if (_disposed) return Future.error(StateError('Worker disposed'));
    if (_send != null) return Future.value(_send!);
    return _opening ??= _open();
  }

  Future<SendPort> _open() async {
    final receive = ReceivePort();
    _receive = receive;
    final ready = Completer<SendPort>();
    _ready = ready;
    // A concurrent dispose or isolate exit may fail the handshake before
    // Isolate.spawn resolves. Observe the handshake error immediately.
    unawaited(ready.future.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    ));
    receive.listen(_handleMessage);
    try {
      _isolate = await Isolate.spawn(
        _persistentWorkerEntry,
        receive.sendPort,
        onError: receive.sendPort,
        onExit: receive.sendPort,
      );
      final port = await ready.future.timeout(const Duration(seconds: 5));
      if (_disposed) throw const WorkerCancelledException();
      _send = port;
      return port;
    } catch (_) {
      _terminate();
      rethrow;
    } finally {
      _opening = null;
    }
  }

  void _handleMessage(dynamic message) {
    if (message is SendPort) {
      final ready = _ready;
      if (ready != null && !ready.isCompleted) ready.complete(message);
      return;
    }
    if (message is Map) {
      final id = message['id'];
      if (id is! int) return;
      final completer = _pending.remove(id);
      if (completer == null || completer.isCompleted) return;
      final value = message['value'];
      if (value is num) {
        completer.complete(value.toDouble());
      } else {
        completer.completeError(StateError('Worker rejected request'));
      }
      return;
    }
    // Isolate error or unexpected exit: observe all in-flight failures.
    final error = StateError('Persistent CPU isolate terminated');
    final ready = _ready;
    if (ready != null && !ready.isCompleted) ready.completeError(error);
    _rejectPending(error);
    _terminate();
  }

  void _rejectPending(Object error) {
    final pending = _pending.values.toList();
    _pending.clear();
    for (final job in pending) {
      if (!job.isCompleted) job.completeError(error);
    }
  }

  void _terminate() {
    _send = null;
    _ready = null;
    _receive?.close();
    _receive = null;
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
  }

  Future<double> calculateNewEaseFactor(double currentEase, int rating) async {
    if (_disposed) throw StateError('Worker disposed');
    if (!currentEase.isFinite || currentEase < 0 || rating < 0 || rating > 5) {
      throw ArgumentError('Invalid ease or rating');
    }
    if (_activeJobs >= _maxQueueSize) {
      throw const WorkerQueueExhaustedException();
    }
    ++_activeJobs;
    final generation = _generation;
    try {
      final port = await _ensureStarted();
      if (_disposed || generation != _generation) {
        throw const WorkerCancelledException();
      }
      final id = ++_nextRequestId;
      final completed = Completer<double>();
      _pending[id] = completed;
      try {
        port.send({'id': id, 'ease': currentEase, 'rating': rating});
      } catch (_) {
        _pending.remove(id);
        rethrow;
      }
      // Never leave a stalled CPU isolate holding queue capacity forever.
      // One timed-out worker invalidates other in-flight results and restarts
      // lazily on the next request; it never retries an SRS transaction.
      final double value;
      try {
        value = await completed.future.timeout(jobTimeout);
      } on TimeoutException {
        _pending.remove(id);
        _rejectPending(TimeoutException('CPU worker became unresponsive'));
        _terminate();
        rethrow;
      }
      if (_disposed || generation != _generation) {
        throw const WorkerCancelledException();
      }
      return value;
    } finally {
      --_activeJobs;
    }
  }

  /// Invalidates pending SRS calculations when the learning session changes.
  void cancelCurrentGeneration() {
    ++_generation;
    _rejectPending(const WorkerCancelledException());
  }

  void setMaxQueueSize(int size) {
    if (size <= 0 || size > 1000) throw RangeError.range(size, 1, 1000);
    _maxQueueSize = size;
  }

  int get activeJobs => _activeJobs;

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    cancelCurrentGeneration();
    final ready = _ready;
    if (ready != null && !ready.isCompleted) {
      ready.completeError(StateError('Worker disposed'));
    }
    _terminate();
  }

  /// Test-only lifecycle reset; in-flight jobs remain invalidated.
  void reset() {
    dispose();
    _disposed = false;
    _maxQueueSize = 50;
    _opening = null;
  }
}

void _persistentWorkerEntry(SendPort mainPort) {
  final receive = ReceivePort();
  mainPort.send(receive.sendPort);
  receive.listen((dynamic request) {
    if (request is! Map) return;
    final id = request['id'];
    if (id is! int) return;
    try {
      final ease = (request['ease'] as num).toDouble();
      final rating = request['rating'] as int;
      final delta = 5 - rating;
      final adjusted = ease + (0.1 - delta * (0.08 + delta * 0.02));
      mainPort.send({'id': id, 'value': adjusted < 1.3 ? 1.3 : adjusted});
    } catch (_) {
      mainPort.send({'id': id, 'error': 'invalid request'});
    }
  });
}
