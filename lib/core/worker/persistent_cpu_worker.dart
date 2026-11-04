import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:isolate';

import 'package:cryptography/cryptography.dart';

import '../storage/validation_hash_cache.dart';
import 'worker_contract.dart';

import 'package:flutter/widgets.dart' show AppLifecycleState;

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

/// One reusable isolate owns typed jobs, named computations and SRS math.
/// Named computations retain latest-wins; typed jobs retain caller-owned epochs.
/// Function values originate in app code, never in the public typed job protocol.
class PersistentCpuWorker {
  PersistentCpuWorker();

  static PersistentCpuWorker? _instance;
  static PersistentCpuWorker get instance =>
      _instance ??= PersistentCpuWorker();
  static const int maxPendingJobs = _TypedCpuWorker.maxPendingJobs;
  static const Duration jobTimeout = Duration(seconds: 8);
  static const String _callbackType = 'internal.callback';
  static const Set<String> _jobTypes = {
    WorkerJobTypes.jsonDecode,
    WorkerJobTypes.checksum128,
    WorkerJobTypes.sha256,
    WorkerJobTypes.fuzzyRank,
    WorkerJobTypes.srsSchedule,
  };

  final Map<int, _WorkerRequest> _requests = {};
  _TypedCpuWorker? _cpu;
  Future<_TypedCpuWorker>? _opening;
  int _currentEpoch = 0;
  int _generation = 0;
  int _lifecycle = 0;
  int _nextId = 0;
  int _maxQueueSize = 50;
  int _workerStarts = 0;
  bool _disposed = false;
  bool _paused = false;

  static Future<PersistentCpuWorker> start({int initialEpoch = 0}) async {
    if (initialEpoch < 0)
      throw ArgumentError.value(initialEpoch, 'initialEpoch');
    final worker = PersistentCpuWorker().._currentEpoch = initialEpoch;
    await worker._ensureCpu();
    return worker;
  }

  int get currentEpoch => _currentEpoch;
  int get currentGeneration => _generation;
  int get pendingCount => _cpu?.pendingCount ?? _requests.length;
  int get pendingJobs => _requests.length;
  int get activeJobs => _requests.length;
  int get workerStarts => _workerStarts;
  int get spawnCount => _workerStarts;
  bool get isClosed => _disposed;
  bool get isDisposed => _disposed;
  bool get hasInFlightJob => _cpu?.hasInFlightJob ?? false;

  Future<WorkerResult<R>> submit<R>(WorkerJob<Object?> job) {
    if (_disposed)
      return Future.error(StateError('PersistentCpuWorker is closed.'));
    _TypedCpuWorker._validateJob(job);
    if (!_jobTypes.contains(job.type)) {
      return Future.value(WorkerResult<R>(
          id: job.id,
          epoch: job.epoch,
          status: WorkerStatuses.error,
          payload: null,
          errorCode: 'unsupported_job_type'));
    }
    return _schedule(job).then((result) => WorkerResult<R>(
          id: result.id,
          epoch: result.epoch,
          status: result.status,
          payload: result.payload as R?,
          errorCode: result.errorCode,
        ));
  }

  Future<T?> executeTask<T>({
    required Future<T> Function() computation,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (_disposed) throw StateError('PersistentCpuWorker is closed.');
    ++_generation;
    for (final request in _requests.values.toList()) {
      if (request.named) _complete(request, _cancelled(request.job));
    }
    final result = await _schedule(
        WorkerJob<Object?>(
          id: 'named-${++_nextId}',
          type: _callbackType,
          epoch: _currentEpoch,
          payload: {'function': computation, 'hasArgument': false},
        ),
        named: true,
        timeout: timeout);
    if (result.status == WorkerStatuses.stale ||
        result.status == WorkerStatuses.closed) return null;
    return _payload<T>(result);
  }

  /// Explicit payload API for the historical concurrent generic tasks.
  /// Dart cannot overload executeTask<T> with executeTask<T,R>.
  Future<R> executeTaskWithPayload<T, R>(
    FutureOr<R> Function(T) computation,
    T payload, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final result = await _schedule(
        WorkerJob<Object?>(
          id: 'payload-${++_nextId}',
          type: _callbackType,
          epoch: _currentEpoch,
          payload: {
            'function': computation,
            'argument': payload,
            'hasArgument': true
          },
        ),
        timeout: timeout);
    return _payload<R>(result);
  }

  Future<double> calculateNewEaseFactor(double currentEase, int rating) async {
    if (!currentEase.isFinite || currentEase < 0 || rating < 0 || rating > 5) {
      throw ArgumentError('Invalid ease or rating');
    }
    final result = await _schedule(WorkerJob<Object?>(
      id: 'srs-${++_nextId}',
      type: WorkerJobTypes.srsSchedule,
      epoch: _currentEpoch,
      payload: {'ease': currentEase, 'rating': rating},
    ));
    return _payload<double>(result);
  }

  R _payload<R>(WorkerResult<Object?> result) {
    if (result.status == WorkerStatuses.stale ||
        result.status == WorkerStatuses.closed) {
      throw const WorkerCancelledException();
    }
    if (result.errorCode == 'job_timeout') {
      throw TimeoutException('CPU worker job timed out');
    }
    if (result.status != WorkerStatuses.ok) {
      final payload = result.payload;
      final detail = payload is Map ? payload['error'] : null;
      throw StateError(detail is String
          ? detail
          : 'CPU worker rejected request: ${result.errorCode}');
    }
    return result.payload as R;
  }

  Future<WorkerResult<Object?>> _schedule(
    WorkerJob<Object?> job, {
    bool named = false,
    Duration timeout = jobTimeout,
  }) {
    if (_disposed || _paused)
      return Future.error(StateError('CPU worker unavailable'));
    if (timeout <= Duration.zero || timeout > const Duration(minutes: 1)) {
      return Future.error(ArgumentError.value(timeout, 'timeout'));
    }
    if (job.epoch != _currentEpoch) return Future.value(_cancelled(job));
    if (_requests.length >= _maxQueueSize) {
      return Future.error(const WorkerQueueExhaustedException());
    }
    final request = _WorkerRequest(++_nextId, job, named);
    _requests[request.key] = request;
    unawaited(_runRequest(request, timeout));
    return request.completer.future;
  }

  Future<void> _runRequest(_WorkerRequest request, Duration timeout) async {
    try {
      final cpu = await _ensureCpu();
      if (!request.active) return;
      final result = await cpu.submit<Object?>(request.job,
          timeout: timeout,
          internalCallback: request.job.type == _callbackType);
      if (cpu.isClosed && identical(_cpu, cpu)) _cpu = null;
      _complete(request, result);
    } catch (error, stack) {
      if (request.active) {
        request.active = false;
        _requests.remove(request.key);
        request.completer.completeError(error, stack);
      }
    }
  }

  Future<_TypedCpuWorker> _ensureCpu() {
    if (_disposed) return Future.error(StateError('CPU worker disposed'));
    final cpu = _cpu;
    if (cpu != null && !cpu.isClosed) return Future.value(cpu);
    final opening = _opening;
    if (opening != null) return opening;
    final next = _openCpu(_lifecycle);
    _opening = next;
    unawaited(next.then<void>((_) {
      if (identical(_opening, next)) _opening = null;
    }, onError: (Object _, StackTrace __) {
      if (identical(_opening, next)) _opening = null;
    }));
    return next;
  }

  Future<_TypedCpuWorker> _openCpu(int lifecycle) async {
    final cpu = await _TypedCpuWorker.start(initialEpoch: _currentEpoch);
    if (_disposed || lifecycle != _lifecycle) {
      await cpu.abort();
      throw const WorkerCancelledException();
    }
    cpu.advanceEpoch(_currentEpoch);
    _cpu = cpu;
    ++_workerStarts;
    return cpu;
  }

  void _complete(_WorkerRequest request, WorkerResult<Object?> result) {
    if (!request.active) return;
    request.active = false;
    _requests.remove(request.key);
    request.completer.complete(result);
  }

  WorkerResult<Object?> _cancelled(WorkerJob<Object?> job) => WorkerResult(
      id: job.id,
      epoch: job.epoch,
      status: WorkerStatuses.stale,
      payload: null,
      errorCode: 'stale_epoch');

  void advanceEpoch(int nextEpoch) {
    if (nextEpoch < 0) throw ArgumentError.value(nextEpoch, 'nextEpoch');
    if (_disposed || nextEpoch <= _currentEpoch) return;
    _currentEpoch = nextEpoch;
    ++_generation;
    _cpu?.advanceEpoch(nextEpoch);
    for (final request in _requests.values.toList()) {
      if (request.job.epoch != nextEpoch)
        _complete(request, _cancelled(request.job));
    }
  }

  void cancelActiveOperations() => cancelCurrentGeneration();
  void cancelAll() => cancelCurrentGeneration();
  void cancelCurrentGeneration() => advanceEpoch(_currentEpoch + 1);

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _paused = true;
      cancelCurrentGeneration();
    } else if (state == AppLifecycleState.resumed) {
      _paused = false;
    }
  }

  void setMaxQueueSize(int size) {
    if (size < 1 || size > maxPendingJobs)
      throw RangeError.range(size, 1, maxPendingJobs);
    _maxQueueSize = size;
  }

  void dispose() {
    if (_disposed) return;
    cancelCurrentGeneration();
    _disposed = true;
    ++_lifecycle;
    final cpu = _cpu;
    _cpu = null;
    if (cpu != null) unawaited(cpu.abort());
  }

  Future<void> close() async {
    final cpu = _cpu;
    final opening = _opening;
    dispose();
    if (cpu != null) await cpu.close();
    if (opening != null) {
      try {
        await (await opening).abort();
      } on Object {/* Already closed. */}
    }
  }

  void reset() {
    dispose();
    _disposed = false;
    _paused = false;
    _opening = null;
    _maxQueueSize = 50;
    _workerStarts = 0;
  }

  static void resetForTesting() {
    _instance?.dispose();
    _instance = PersistentCpuWorker();
  }
}

class _WorkerRequest {
  _WorkerRequest(this.key, this.job, this.named);
  final int key;
  final WorkerJob<Object?> job;
  final bool named;
  final completer = Completer<WorkerResult<Object?>>();
  bool active = true;
}

final class _TypedCpuWorker {
  static const int maxPendingJobs = 256;

  _TypedCpuWorker._({
    required Isolate isolate,
    required SendPort commandPort,
    required ReceivePort responsePort,
    required ReceivePort exitPort,
    required int initialEpoch,
  })  : _isolate = isolate,
        _commandPort = commandPort,
        _responsePort = responsePort,
        _exitPort = exitPort,
        _currentEpoch = initialEpoch {
    _responseSubscription = _responsePort.listen(_handleResponse);
    _exitSubscription = _exitPort.listen(_handleExit);
  }

  static Future<_TypedCpuWorker> start({
    required int initialEpoch,
  }) async {
    if (initialEpoch < 0) {
      throw ArgumentError.value(
        initialEpoch,
        'initialEpoch',
        'must not be negative',
      );
    }

    final bootstrap = ReceivePort('phase13b.cpu.bootstrap');
    final responses = ReceivePort('phase13b.cpu.responses');
    final exits = ReceivePort('phase13b.cpu.exits');

    final isolate = await Isolate.spawn<Map<String, Object?>>(
      _cpuWorkerMain,
      <String, Object?>{
        'bootstrapPort': bootstrap.sendPort,
        'responsePort': responses.sendPort,
      },
      debugName: 'salim.cpu-worker',
      errorsAreFatal: true,
      onExit: exits.sendPort,
      onError: exits.sendPort,
    );

    final command = await bootstrap.first.timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        isolate.kill(priority: Isolate.immediate);
        bootstrap.close();
        responses.close();
        exits.close();
        throw StateError('CPU worker bootstrap timed out.');
      },
    );
    bootstrap.close();

    if (command is! SendPort) {
      isolate.kill(priority: Isolate.immediate);
      responses.close();
      exits.close();
      throw StateError('CPU worker did not provide a command port.');
    }

    return _TypedCpuWorker._(
      isolate: isolate,
      commandPort: command,
      responsePort: responses,
      exitPort: exits,
      initialEpoch: initialEpoch,
    );
  }

  final Isolate _isolate;
  final SendPort _commandPort;
  final ReceivePort _responsePort;
  final ReceivePort _exitPort;
  final Queue<_QueuedWorkerJob> _pending = Queue<_QueuedWorkerJob>();

  late final StreamSubscription<Object?> _responseSubscription;
  late final StreamSubscription<Object?> _exitSubscription;

  _QueuedWorkerJob? _inFlight;
  int _currentEpoch;
  bool _accepting = true;
  bool _closed = false;
  bool _unexpectedExit = false;
  int _spawnCount = 1;

  Completer<void>? _shutdownCompleter;

  int get currentEpoch => _currentEpoch;
  int get pendingCount => _pending.length;
  int get spawnCount => _spawnCount;
  bool get isClosed => _closed || _unexpectedExit;
  bool get hasInFlightJob => _inFlight != null;

  Future<WorkerResult<R>> submit<R>(
    WorkerJob<Object?> job, {
    Duration timeout = const Duration(seconds: 8),
    bool internalCallback = false,
  }) {
    if (!_accepting || _closed) {
      return Future<WorkerResult<R>>.error(
        StateError('_TypedCpuWorker is closed.'),
      );
    }

    _validateJob(job);

    if (_pending.length >= maxPendingJobs) {
      return Future<WorkerResult<R>>.error(
        StateError(
          'CPU worker queue capacity exceeded: $maxPendingJobs.',
        ),
      );
    }

    if (job.epoch != _currentEpoch) {
      return Future<WorkerResult<R>>.value(
        WorkerResult<R>(
          id: job.id,
          epoch: job.epoch,
          status: WorkerStatuses.stale,
          payload: null,
          errorCode: 'stale_epoch',
        ),
      );
    }

    if (job.type == PersistentCpuWorker._callbackType && !internalCallback) {
      throw ArgumentError('Callbacks are not typed source jobs');
    }
    final pending = _QueuedWorkerJob(job);
    pending.timer = Timer(timeout, () => _timeout(pending));
    _pending.addLast(pending);
    _dispatchNext();

    return pending.completer.future.then<WorkerResult<R>>(
      (result) => WorkerResult<R>(
        id: result.id,
        epoch: result.epoch,
        status: result.status,
        payload: result.payload as R?,
        errorCode: result.errorCode,
      ),
    );
  }

  void advanceEpoch(int nextEpoch) {
    if (_closed) return;
    if (nextEpoch < _currentEpoch) {
      return;
    }
    if (nextEpoch == _currentEpoch) {
      return;
    }

    _currentEpoch = nextEpoch;
    final retained = Queue<_QueuedWorkerJob>();

    while (_pending.isNotEmpty) {
      final queued = _pending.removeFirst();
      if (queued.job.epoch == nextEpoch) {
        retained.addLast(queued);
        continue;
      }
      _complete(
        queued,
        WorkerResult<Object?>(
          id: queued.job.id,
          epoch: queued.job.epoch,
          status: WorkerStatuses.stale,
          payload: null,
          errorCode: 'stale_epoch',
        ),
      );
    }

    _pending.addAll(retained);
    _dispatchNext();
  }

  Future<void>? _closing;

  Future<void> abort() {
    _isolate.kill(priority: Isolate.immediate);
    _handleExit(null);
    return close();
  }

  void _timeout(_QueuedWorkerJob queued) {
    if (queued.completer.isCompleted) return;
    if (!identical(_inFlight, queued)) {
      _pending.remove(queued);
      _complete(
          queued,
          WorkerResult<Object?>(
              id: queued.job.id,
              epoch: queued.job.epoch,
              status: WorkerStatuses.error,
              payload: null,
              errorCode: 'job_timeout'));
      return;
    }
    _inFlight = null;
    _complete(
        queued,
        WorkerResult<Object?>(
            id: queued.job.id,
            epoch: queued.job.epoch,
            status: WorkerStatuses.error,
            payload: null,
            errorCode: 'job_timeout'));
    unawaited(abort());
  }

  Future<void> close() => _closing ??= _close();

  Future<void> _close() async {
    if (_closed) return;
    _accepting = false;

    while (_pending.isNotEmpty) {
      final queued = _pending.removeFirst();
      _complete(
        queued,
        WorkerResult<Object?>(
          id: queued.job.id,
          epoch: queued.job.epoch,
          status: WorkerStatuses.closed,
          payload: null,
          errorCode: 'worker_closed',
        ),
      );
    }

    final inFlight = _inFlight;
    if (inFlight != null && !inFlight.completer.isCompleted) {
      try {
        await inFlight.completer.future.timeout(
          const Duration(seconds: 3),
        );
      } on TimeoutException {
        _unexpectedExit = true;
        _inFlight = null;
        _complete(
          inFlight,
          WorkerResult<Object?>(
            id: inFlight.job.id,
            epoch: inFlight.job.epoch,
            status: WorkerStatuses.closed,
            payload: null,
            errorCode: 'shutdown_timeout',
          ),
        );
        _isolate.kill(priority: Isolate.immediate);
      } on Object {
        // The shutdown path still proceeds if the in-flight job failed.
      }
    }

    if (!_unexpectedExit) {
      _shutdownCompleter ??= Completer<void>();
      _commandPort.send(const <String, Object?>{'kind': 'shutdown'});
      try {
        await _shutdownCompleter!.future.timeout(
          const Duration(seconds: 3),
        );
      } on TimeoutException {
        _isolate.kill(priority: Isolate.immediate);
      }
    }

    _closed = true;
    await _responseSubscription.cancel();
    await _exitSubscription.cancel();
    _responsePort.close();
    _exitPort.close();
    _isolate.kill(priority: Isolate.immediate);
  }

  void _dispatchNext() {
    if (!_accepting || _closed || _inFlight != null) return;

    while (_pending.isNotEmpty) {
      final queued = _pending.removeFirst();
      if (queued.job.epoch != _currentEpoch) {
        _complete(
          queued,
          WorkerResult<Object?>(
            id: queued.job.id,
            epoch: queued.job.epoch,
            status: WorkerStatuses.stale,
            payload: null,
            errorCode: 'stale_epoch',
          ),
        );
        continue;
      }

      _inFlight = queued;
      try {
        _commandPort.send(
          <String, Object?>{
            'kind': 'job',
            'job': _jobToWire(queued.job),
          },
        );
        return;
      } on Object {
        _inFlight = null;
        _complete(
          queued,
          WorkerResult<Object?>(
            id: queued.job.id,
            epoch: queued.job.epoch,
            status: WorkerStatuses.error,
            payload: null,
            errorCode: 'invalid_payload',
          ),
        );
      }
    }
  }

  void _handleResponse(Object? raw) {
    if (_closed || raw is! Map) return;
    final kind = raw['kind'];

    if (kind == 'shutdownAck') {
      final completer = _shutdownCompleter;
      if (completer != null && !completer.isCompleted) {
        completer.complete();
      }
      return;
    }

    if (kind != 'result') return;
    final queued = _inFlight;
    if (queued == null) return;

    var result = _resultFromWire(raw['result'], fallback: queued.job);
    if (result.epoch != _currentEpoch && result.status == WorkerStatuses.ok) {
      result = WorkerResult<Object?>(
        id: result.id,
        epoch: result.epoch,
        status: WorkerStatuses.stale,
        payload: null,
        errorCode: 'stale_epoch',
      );
    }

    _inFlight = null;
    _complete(queued, result);
    _dispatchNext();
  }

  void _handleExit(Object? _) {
    if (_closed) return;
    _unexpectedExit = true;
    _accepting = false;

    final queued = _inFlight;
    _inFlight = null;
    if (queued != null) {
      _complete(
        queued,
        WorkerResult<Object?>(
          id: queued.job.id,
          epoch: queued.job.epoch,
          status: WorkerStatuses.error,
          payload: null,
          errorCode: 'worker_exit',
        ),
      );
    }

    while (_pending.isNotEmpty) {
      final pending = _pending.removeFirst();
      _complete(
        pending,
        WorkerResult<Object?>(
          id: pending.job.id,
          epoch: pending.job.epoch,
          status: WorkerStatuses.error,
          payload: null,
          errorCode: 'worker_exit',
        ),
      );
    }

    final shutdown = _shutdownCompleter;
    if (shutdown != null && !shutdown.isCompleted) {
      shutdown.complete();
    }
  }

  static void _validateJob(WorkerJob<Object?> job) {
    if (job.id.trim().isEmpty || job.id.length > 160) {
      throw ArgumentError.value(job.id, 'job.id', 'must be 1..160 chars');
    }
    if (job.type.trim().isEmpty || job.type.length > 80) {
      throw ArgumentError.value(
        job.type,
        'job.type',
        'must be 1..80 chars',
      );
    }
    if (job.epoch < 0) {
      throw ArgumentError.value(job.epoch, 'job.epoch', 'must be >= 0');
    }
  }

  static void _complete(
    _QueuedWorkerJob queued,
    WorkerResult<Object?> result,
  ) {
    if (!queued.completer.isCompleted) {
      queued.timer?.cancel();
      queued.completer.complete(result);
    }
  }
}

final class _QueuedWorkerJob {
  _QueuedWorkerJob(this.job);

  final WorkerJob<Object?> job;
  Timer? timer;
  final Completer<WorkerResult<Object?>> completer =
      Completer<WorkerResult<Object?>>();
}

Map<String, Object?> _jobToWire(WorkerJob<Object?> job) => <String, Object?>{
      'id': job.id,
      'type': job.type,
      'epoch': job.epoch,
      'payload': job.payload,
    };

WorkerResult<Object?> _resultFromWire(
  Object? raw, {
  required WorkerJob<Object?> fallback,
}) {
  if (raw is! Map) {
    return WorkerResult<Object?>(
      id: fallback.id,
      epoch: fallback.epoch,
      status: WorkerStatuses.error,
      payload: null,
      errorCode: 'invalid_result',
    );
  }

  final id = raw['id'];
  final epoch = raw['epoch'];
  final status = raw['status'];
  final errorCode = raw['errorCode'];

  return WorkerResult<Object?>(
    id: id is String && id.isNotEmpty ? id : fallback.id,
    epoch: epoch is num ? epoch.toInt() : fallback.epoch,
    status: status is String ? status : WorkerStatuses.error,
    payload: raw['payload'],
    errorCode: errorCode is String ? errorCode : null,
  );
}

void _cpuWorkerMain(Map<String, Object?> bootstrap) async {
  final bootstrapValue = bootstrap['bootstrapPort'];
  final responseValue = bootstrap['responsePort'];
  if (bootstrapValue is! SendPort || responseValue is! SendPort) {
    return;
  }
  final bootstrapPort = bootstrapValue;
  final responsePort = responseValue;

  final commands = ReceivePort('phase13b.cpu.commands');
  bootstrapPort.send(commands.sendPort);

  await for (final raw in commands) {
    if (raw is! Map) continue;
    final kind = raw['kind'];

    if (kind == 'shutdown') {
      responsePort.send(const <String, Object?>{'kind': 'shutdownAck'});
      commands.close();
      Isolate.exit();
    }

    if (kind != 'job') continue;
    final job = raw['job'];
    final result = await _executeWireJob(job);
    responsePort.send(
      <String, Object?>{
        'kind': 'result',
        'result': result,
      },
    );
  }
}

Future<Map<String, Object?>> _executeWireJob(Object? raw) async {
  if (raw is! Map) {
    return _errorWire(
      id: 'invalid',
      epoch: 0,
      code: 'invalid_job',
    );
  }

  final idValue = raw['id'];
  final typeValue = raw['type'];
  final epochValue = raw['epoch'];
  final payload = raw['payload'];
  final id = idValue is String ? idValue : 'invalid';
  final type = typeValue is String ? typeValue : '';
  final epoch = epochValue is num ? epochValue.toInt() : 0;

  try {
    switch (type) {
      case PersistentCpuWorker._callbackType:
        final arguments = _payloadMap(payload);
        final function = arguments['function'];
        if (function is! Function)
          throw const FormatException('invalid computation');
        try {
          final value = await Function.apply(
              function,
              arguments['hasArgument'] == true
                  ? [arguments['argument']]
                  : const []);
          return _okWire(id: id, epoch: epoch, payload: value);
        } catch (error) {
          return {
            'id': id,
            'epoch': epoch,
            'status': WorkerStatuses.error,
            'payload': {'error': error.toString()},
            'errorCode': 'computation_error'
          };
        }
      case WorkerJobTypes.srsSchedule:
        final values = _payloadMap(payload);
        final ease = values['ease'];
        final rating = values['rating'];
        if (ease is! num ||
            !ease.isFinite ||
            ease < 0 ||
            rating is! int ||
            rating < 0 ||
            rating > 5) {
          throw const FormatException('invalid SRS calculation');
        }
        final delta = 5 - rating;
        final adjusted =
            ease.toDouble() + (0.1 - delta * (0.08 + delta * 0.02));
        return _okWire(
            id: id, epoch: epoch, payload: adjusted < 1.3 ? 1.3 : adjusted);
      case WorkerJobTypes.jsonDecode:
        return _okWire(
          id: id,
          epoch: epoch,
          payload: _decodePayload(payload),
        );
      case WorkerJobTypes.checksum128:
        return _okWire(
          id: id,
          epoch: epoch,
          payload: _checksum128(payload),
        );
      case WorkerJobTypes.sha256:
        return _okWire(
          id: id,
          epoch: epoch,
          payload: await _sha256(payload),
        );
      case WorkerJobTypes.fuzzyRank:
        return _okWire(
          id: id,
          epoch: epoch,
          payload: _rankFuzzy(payload),
        );
      default:
        return _errorWire(
          id: id,
          epoch: epoch,
          code: 'unsupported_job_type',
        );
    }
  } on FormatException {
    return _errorWire(
      id: id,
      epoch: epoch,
      code: 'invalid_payload',
    );
  } on ArgumentError {
    return _errorWire(
      id: id,
      epoch: epoch,
      code: 'invalid_payload',
    );
  } on Object {
    return _errorWire(
      id: id,
      epoch: epoch,
      code: 'worker_exception',
    );
  }
}

Object? _decodePayload(Object? payload) {
  final map = _payloadMap(payload);
  final encoded = map['encoded'];
  if (encoded is! String || encoded.length > 16 * 1024 * 1024) {
    throw const FormatException('json payload is invalid');
  }
  return jsonDecode(encoded);
}

String _checksum128(Object? payload) {
  final map = _payloadMap(payload);
  final scopeKey = map['scopeKey'];
  final contentValue = map['content'];
  final jsonValue = map['jsonValue'];
  final validatorVersion = map['validatorVersion'];
  if (scopeKey is! String ||
      validatorVersion is! String ||
      scopeKey.length > 240 ||
      validatorVersion.length > 80) {
    throw const FormatException('checksum payload is invalid');
  }

  final String content;
  if (contentValue is String) {
    content = contentValue;
  } else if (jsonValue != null) {
    content = jsonEncode(jsonValue);
  } else {
    throw const FormatException('checksum payload is invalid');
  }
  if (content.length > 16 * 1024 * 1024) {
    throw const FormatException('checksum payload is invalid');
  }

  return ContentChecksum.compute(
    scopeKey: scopeKey,
    content: content,
    validatorVersion: validatorVersion,
  );
}

Future<String> _sha256(Object? payload) async {
  final map = _payloadMap(payload);
  final content = map['content'];
  if (content is! String || content.length > 16 * 1024 * 1024) {
    throw const FormatException('sha256 payload is invalid');
  }
  final digest = await Sha256().hash(utf8.encode(content));
  final buffer = StringBuffer();
  for (final byte in digest.bytes) {
    buffer.write(byte.toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}

List<Map<String, Object?>> _rankFuzzy(Object? payload) {
  final map = _payloadMap(payload);
  final queryValue = map['query'];
  final candidatesValue = map['candidates'];
  final limitValue = map['limit'];

  if (queryValue is! String ||
      queryValue.length > 512 ||
      candidatesValue is! List ||
      candidatesValue.length > 5000) {
    throw const FormatException('fuzzy payload is invalid');
  }

  final query = _normalize(queryValue);
  if (query.isEmpty) {
    return const <Map<String, Object?>>[];
  }

  final limit =
      limitValue is num ? limitValue.toInt().clamp(1, 100).toInt() : 20;
  final ranked = <_RankedCandidate>[];

  for (var index = 0; index < candidatesValue.length; index += 1) {
    final raw = candidatesValue[index];
    if (raw is! Map) continue;
    final id = raw['id'];
    final text = raw['text'];
    if (id is! String ||
        id.trim().isEmpty ||
        id.length > 160 ||
        text is! String ||
        text.length > 2048) {
      continue;
    }

    final normalized = _normalize(text);
    if (normalized.isEmpty) continue;

    ranked.add(
      _RankedCandidate(
        id: id.trim(),
        text: text,
        score: _fuzzyScore(query, normalized),
        order: index,
      ),
    );
  }

  ranked.sort((left, right) {
    final byScore = right.score.compareTo(left.score);
    if (byScore != 0) return byScore;
    final byOrder = left.order.compareTo(right.order);
    if (byOrder != 0) return byOrder;
    return left.id.compareTo(right.id);
  });

  return List<Map<String, Object?>>.unmodifiable(
    ranked.take(limit).map(
          (item) => <String, Object?>{
            'id': item.id,
            'text': item.text,
            'score': item.score,
          },
        ),
  );
}

Map<Object?, Object?> _payloadMap(Object? payload) {
  if (payload is! Map) {
    throw const FormatException('worker payload must be a map');
  }
  return payload;
}

String _normalize(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

double _fuzzyScore(String query, String candidate) {
  if (query == candidate) return 1.0;

  final maxLength =
      query.length > candidate.length ? query.length : candidate.length;
  if (maxLength == 0) return 1.0;

  final distance = _levenshtein(query, candidate);
  final editScore = (1.0 - (distance / maxLength)).clamp(0.0, 1.0);

  var containment = 0.0;
  if (candidate.contains(query) || query.contains(candidate)) {
    final shorter =
        query.length < candidate.length ? query.length : candidate.length;
    containment = 0.78 + (0.2 * (shorter / maxLength));
  }

  final tokenScore = _tokenOverlap(query, candidate);
  final combined = <double>[
    editScore.toDouble(),
    containment,
    tokenScore,
  ].reduce((left, right) => left > right ? left : right);

  return double.parse(combined.clamp(0.0, 1.0).toStringAsFixed(6));
}

double _tokenOverlap(String query, String candidate) {
  final queryTokens =
      query.split(' ').where((value) => value.isNotEmpty).toSet();
  final candidateTokens =
      candidate.split(' ').where((value) => value.isNotEmpty).toSet();
  if (queryTokens.isEmpty || candidateTokens.isEmpty) return 0.0;

  final intersection = queryTokens.intersection(candidateTokens).length;
  final union = queryTokens.union(candidateTokens).length;
  return union == 0 ? 0.0 : intersection / union;
}

int _levenshtein(String left, String right) {
  if (left == right) return 0;
  if (left.isEmpty) return right.length;
  if (right.isEmpty) return left.length;

  var previous = List<int>.generate(right.length + 1, (index) => index);

  for (var i = 1; i <= left.length; i += 1) {
    final current = List<int>.filled(right.length + 1, 0);
    current[0] = i;
    for (var j = 1; j <= right.length; j += 1) {
      final substitutionCost =
          left.codeUnitAt(i - 1) == right.codeUnitAt(j - 1) ? 0 : 1;
      final deletion = previous[j] + 1;
      final insertion = current[j - 1] + 1;
      final substitution = previous[j - 1] + substitutionCost;
      current[j] = _min3(deletion, insertion, substitution);
    }
    previous = current;
  }

  return previous[right.length];
}

int _min3(int a, int b, int c) {
  var result = a < b ? a : b;
  if (c < result) result = c;
  return result;
}

Map<String, Object?> _okWire({
  required String id,
  required int epoch,
  required Object? payload,
}) =>
    <String, Object?>{
      'id': id,
      'epoch': epoch,
      'status': WorkerStatuses.ok,
      'payload': payload,
      'errorCode': null,
    };

Map<String, Object?> _errorWire({
  required String id,
  required int epoch,
  required String code,
}) =>
    <String, Object?>{
      'id': id,
      'epoch': epoch,
      'status': WorkerStatuses.error,
      'payload': null,
      'errorCode': code,
    };

final class _RankedCandidate {
  const _RankedCandidate({
    required this.id,
    required this.text,
    required this.score,
    required this.order,
  });

  final String id;
  final String text;
  final double score;
  final int order;
}
