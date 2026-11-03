import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'worker_contract.dart';

class WorkerQueueExhaustedException implements Exception {
  final String message;
  WorkerQueueExhaustedException(this.message);
  @override
  String toString() => "WorkerQueueExhaustedException: $message";
}

class WorkerCancelledException implements Exception {
  final String message;
  WorkerCancelledException(this.message);
  @override
  String toString() => "WorkerCancelledException: $message";
}

class _WorkerTask<T> {
  final Future<T> Function() computation;
  final Completer<T?> completer;
  final int generation;
  final Duration timeout;

  _WorkerTask(this.computation, this.completer, this.generation, this.timeout);
}

class PersistentCpuWorker with WidgetsBindingObserver {
  static PersistentCpuWorker? _instance;
  static PersistentCpuWorker get instance => _instance ??= PersistentCpuWorker._();

  PersistentCpuWorker._() {
    WidgetsBinding.instance.addObserver(this);
  }

  int _activeGeneration = 0;
  bool _isDisposed = false;

  int _maxQueueSize = 50;
  int _maxConcurrentTasks = 4;

  int _activeTasks = 0;
  final Queue<_WorkerTask<dynamic>> _queue = Queue();

  int get currentGeneration => _activeGeneration;
  bool get isDisposed => _isDisposed;
  bool get isClosed => _isDisposed;
  int get pendingCount => _queue.length;

  static Future<PersistentCpuWorker> start({int initialEpoch = 0}) async {
    final worker = instance;
    worker._activeGeneration = initialEpoch;
    return worker;
  }

  static void resetForTesting() {
    if (_instance != null) {
      WidgetsBinding.instance.removeObserver(_instance!);
    }
    _instance = PersistentCpuWorker._();
    _instance!._maxQueueSize = 50;
    _instance!._maxConcurrentTasks = 4;
  }

  void reset() {
    _activeGeneration = 0;
    cancelAll();
    _isDisposed = false;
  }

  void setMaxQueueSize(int size) {
    _maxQueueSize = size;
  }

  Future<T?> executeTask<T, R>(
    Future<T> Function(R) computation,
    R payload, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (_isDisposed) {
      throw StateError('Worker is disposed. Cannot schedule new CPU tasks.');
    }

    if (_activeTasks + _queue.length >= _maxQueueSize + _maxConcurrentTasks) {
      throw WorkerQueueExhaustedException('Queue is full');
    }

    final generation = _activeGeneration;
    final completer = Completer<T?>();

    // Note: We wrap the computation into a no-arg function to match _WorkerTask
    _queue.add(_WorkerTask<T>(() => computation(payload), completer, generation, timeout));

    _pump();

    return completer.future;
  }

  // A helper that calculates new ease factor via compute to run in background.
  Future<double> calculateNewEaseFactor(double easeFactor, int quality) async {
    return (await executeTask<double, Map<String, dynamic>>(
      _heavySrsMath,
      {'easeFactor': easeFactor, 'quality': quality},
    )) ?? 0.0;
  }

  // Must be a top-level or static function to be used with compute
  static Future<double> _heavySrsMath(Map<String, dynamic> data) async {
    final easeFactor = data['easeFactor'] as double;
    final quality = data['quality'] as int;

    if (easeFactor < 0.0) {
      throw ArgumentError('easeFactor must be positive');
    }

    // Some complex math simulating real SRS update
    double newEase = easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (newEase < 1.3) newEase = 1.3;
    return newEase;
  }

  Future<WorkerResult<R>> submit<R>(WorkerJob<Object?> job) async {
    if (_isDisposed) {
      return WorkerResult(id: job.id, epoch: job.epoch, status: WorkerStatuses.closed, payload: null, errorCode: 'closed');
    }

    try {
      final res = await executeTask<R, Object?>(
        _runJob,
        job,
      );

      if (res == null) {
         return WorkerResult(id: job.id, epoch: job.epoch, status: WorkerStatuses.stale, payload: null, errorCode: 'cancelled');
      }
      return WorkerResult(id: job.id, epoch: job.epoch, status: WorkerStatuses.ok, payload: res, errorCode: null);
    } catch (e) {
      if (e is WorkerCancelledException) {
         return WorkerResult(id: job.id, epoch: job.epoch, status: WorkerStatuses.stale, payload: null, errorCode: 'cancelled');
      }
      return WorkerResult(id: job.id, epoch: job.epoch, status: WorkerStatuses.error, payload: null, errorCode: e.toString());
    }
  }

  static Future<R> _runJob<R>(Object? jobObj) async {
    // Mocking job execution for the system runtime
    return null as R;
  }

  void _pump() {
    if (_activeTasks >= _maxConcurrentTasks || _queue.isEmpty || _isDisposed) {
      return;
    }

    final task = _queue.removeFirst();

    if (task.generation != _activeGeneration) {
      if (!task.completer.isCompleted) {
        task.completer.completeError(WorkerCancelledException('Generation changed'));
      }
      _pump(); // Try next task
      return;
    }

    _activeTasks++;

    Future(() async {
      try {
        final result = await compute(
          _isolateRunner,
          task.computation
        ).timeout(task.timeout, onTimeout: () {
          throw TimeoutException('CPU task timed out');
        });

        if (task.generation != _activeGeneration || _isDisposed) {
           if (!task.completer.isCompleted) {
             task.completer.completeError(WorkerCancelledException('Generation changed or disposed'));
           }
        } else if (!task.completer.isCompleted) {
          task.completer.complete(result);
        }
      } catch (e, st) {
        if (!task.completer.isCompleted) {
           task.completer.completeError(e, st);
        }
      } finally {
        _activeTasks--;
        _pump();
      }
    });

    _pump();
  }

  static Future<dynamic> _isolateRunner(Future<dynamic> Function() computation) async {
     return await computation();
  }

  void advanceEpoch(int epoch) {
    _activeGeneration = epoch;
  }

  void cancelCurrentGeneration() {
    _activeGeneration++;
    _cancelPending();
  }

  void cancelAll() {
    _activeGeneration++;
    _cancelPending();
  }

  void _cancelPending() {
    final currentTasks = _queue.toList();
    _queue.clear();
    for (var task in currentTasks) {
       if (!task.completer.isCompleted) {
          task.completer.completeError(WorkerCancelledException('Cancelled'));
       }
    }
  }

  void cancelActiveOperations() {
    cancelAll();
  }

  void close() {
    dispose();
  }

  void dispose() {
    _isDisposed = true;
    cancelActiveOperations();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
       cancelAll();
    }
  }
}
