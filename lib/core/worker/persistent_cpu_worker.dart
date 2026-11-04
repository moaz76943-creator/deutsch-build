import 'dart:async';

/// Master Constitution Section 10 Compliant CPU Worker:
/// Enforces requestGeneration (latest-wins), cancellation on language/screen change,
/// execution timeout watchdog, and safe resource disposal to prevent leaks.
class PersistentCpuWorker {
  int _activeGeneration = 0;
  bool _isDisposed = false;
  Completer<dynamic>? _pendingCompleter;

  int get currentGeneration => _activeGeneration;
  bool get isDisposed => _isDisposed;

  /// Submits an asynchronous CPU task. Only the latest generation result is accepted.
  Future<T?> executeTask<T>({
    required Future<T> Function() computation,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (_isDisposed) {
      throw StateError('Worker is disposed. Cannot schedule new CPU tasks.');
    }

    final generation = ++_activeGeneration;
    final completer = Completer<T?>();
    _pendingCompleter = completer;

class PersistentCpuWorker with WidgetsBindingObserver {
  static PersistentCpuWorker instance = PersistentCpuWorker._init();

  final int maxConcurrentTasks;
  int maxQueueSize;
  bool _disposed = false;

  int _activeJobs = 0;
  int _generation = 0;
  final Queue<_QueuedTask<dynamic, dynamic>> _queue = Queue<_QueuedTask<dynamic, dynamic>>();

  PersistentCpuWorker._init()
      : maxConcurrentTasks = 4,
        maxQueueSize = 50 {
    _registerObserver();
  }

  void _registerObserver() {
    try {
      final result = await computation().timeout(timeout, onTimeout: () {
        throw TimeoutException('CPU task timed out after ${timeout.inSeconds}s (Gen $generation)');
      });

  @visibleForTesting
  static void resetForTesting() {
    instance.dispose();
    instance = PersistentCpuWorker._init();
  }

  @visibleForTesting
  void reset() {
    cancelAll();
    _disposed = false;
  }

  @visibleForTesting
  void setMaxQueueSize(int size) {
    maxQueueSize = size;
  }

  @visibleForTesting
  void cancelCurrentGeneration() {
    cancelAll();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      cancelAll();
    }
  }

  void cancelAll() {
    _generation++;
    for (final task in _queue) {
      if (!task.completer.isCompleted) {
        task.completer.completeError(WorkerCancelledException());
      }

      completer.complete(result);
      return result;
    } catch (e, st) {
      if (generation == _activeGeneration && !completer.isCompleted) {
        completer.completeError(e, st);
      }
      return null;
    }
  }

  /// Cancels in-flight work immediately (e.g. when language pair or screen changes)
  void cancelActiveOperations() {
    _activeGeneration++;
    if (_pendingCompleter != null && !_pendingCompleter!.isCompleted) {
      _pendingCompleter!.complete(null);
      _pendingCompleter = null;
    }
  }

  /// Safe disposal freeing all worker references and cancelling subscriptions
  void dispose() {
    _disposed = true;
    try {
      WidgetsBinding.instance.removeObserver(this);
    } catch (_) {}
    cancelAll();
  }

  Future<R> executeTask<Q, R>(ComputeCallback<Q, R> task, Q message) {
    if (_disposed) {
      return Future.error(StateError('Worker is disposed'));
    }
    if (_queue.length >= maxQueueSize) {
      return Future.error(WorkerQueueExhaustedException());
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

  void _pump() {
    if (_disposed) return;
    if (_activeJobs >= maxConcurrentTasks || _queue.isEmpty) {
      return;
    }

    _currentEpoch = nextEpoch;
    final retained = Queue<_QueuedWorkerJob>();

  void _unpackAndExecute(dynamic task) {
    if (task is _QueuedTask) {
      _executeQueuedTask(task);
    }
  }

  void _executeQueuedTask<Q, R>(_QueuedTask<Q, R> queuedTask) {
    if (queuedTask.generation != _generation || _disposed) {
      if (!queuedTask.completer.isCompleted) {
        queuedTask.completer.completeError(WorkerCancelledException());
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
        final result = await compute<Q, R>(queuedTask.task, queuedTask.message);

        if (queuedTask.generation == _generation && !_disposed) {
          if (!queuedTask.completer.isCompleted) {
            queuedTask.completer.complete(result);
          }
        } else {
          if (!queuedTask.completer.isCompleted) {
            queuedTask.completer.completeError(WorkerCancelledException());
          }
        }
      } catch (e, st) {
        if (!queuedTask.completer.isCompleted) {
          queuedTask.completer.completeError(e, st);
        }
      } finally {
        _activeJobs--;
        _pump();
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

  // دالة رياضية معزولة تماماً (SM-2 Logic)
  static double _heavySrsMath(dynamic rawData) {
    final data = rawData as Map<String, dynamic>;
    double ease = data['ease'] as double;
    int rating = data['rating'] as int;

    if (ease < 0) {
      throw ArgumentError('Invalid ease');
    }

    // معادلة الحفظ والمراجعة المتباعدة
    double newEase = ease + (0.1 - (5 - rating) * (0.08 + (5 - rating) * 0.02));
    if (newEase < 1.3) newEase = 1.3;

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
