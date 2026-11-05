import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../storage/validation_hash_cache.dart';
import 'worker_contract.dart';

class WorkerQueueExhaustedException implements Exception {
  @override
  String toString() => "WorkerQueueExhaustedException";
}

class WorkerCancelledException implements Exception {
  @override
  String toString() => "WorkerCancelledException";
}

abstract class _QueuedTask {
  int get generation;
  Completer<dynamic> get completer;
  Future<void> execute();
  void cancel();
}

class _QueuedComputeTask<Q, R> implements _QueuedTask {
  final ComputeCallback<Q, R> task;
  final Q message;
  @override
  final Completer<dynamic> completer;
  @override
  final int generation;
  final PersistentCpuWorker worker;

  _QueuedComputeTask(this.task, this.message, this.completer, this.generation, this.worker);

  @override
  Future<void> execute() async {
    if (generation != worker.currentEpoch || worker.isDisposed) {
      cancel();
      return;
    }

    try {
      final result = await compute<Q, R>(task, message);

      if (generation == worker.currentEpoch && !worker.isDisposed) {
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      } else {
        cancel();
      }
    } catch (e, st) {
      if (!completer.isCompleted) {
        completer.completeError(e, st);
      }
    }
  }

  @override
  void cancel() {
    if (!completer.isCompleted) {
      completer.completeError(WorkerCancelledException());
    }
  }
}

class _QueuedWorkerJobTask<R> implements _QueuedTask {
  final WorkerJob<Object?> job;
  @override
  final Completer<dynamic> completer;
  @override
  final int generation;
  final PersistentCpuWorker worker;

  _QueuedWorkerJobTask(this.job, this.completer, this.generation, this.worker);

  @override
  Future<void> execute() async {
    if (generation != worker.currentEpoch || worker.isDisposed) {
      cancel();
      return;
    }

    try {
      final rawResult = await compute<Map<String, Object?>, Map<String, Object?>>(_executeWireJob, _jobToWire(job));
      final result = _resultFromWire(rawResult, fallback: job);

      if (generation == worker.currentEpoch && !worker.isDisposed) {
        if (!completer.isCompleted) {
          completer.complete(
            WorkerResult<R>(
              id: result.id,
              epoch: result.epoch,
              status: result.status,
              payload: result.payload as R?,
              errorCode: result.errorCode,
            ),
          );
        }
      } else {
        cancel();
      }
    } catch (e) {
      if (!completer.isCompleted) {
        completer.complete(
          WorkerResult<R>(
            id: job.id,
            epoch: job.epoch,
            status: WorkerStatuses.error,
            payload: null,
            errorCode: 'worker_exception',
          ),
        );
      }
    }
  }

  @override
  void cancel() {
    if (!completer.isCompleted) {
      completer.complete(
        WorkerResult<R>(
          id: job.id,
          epoch: job.epoch,
          status: WorkerStatuses.stale,
          payload: null,
          errorCode: 'stale_epoch',
        ),
      );
    }
  }
}

class PersistentCpuWorker with WidgetsBindingObserver {
  static PersistentCpuWorker instance = PersistentCpuWorker._init();

  final int maxConcurrentTasks;
  int maxQueueSize;
  bool _disposed = false;

  int _activeJobs = 0;
  int _currentEpoch = 0;
  final Queue<_QueuedTask> _queue = Queue<_QueuedTask>();

  int get currentEpoch => _currentEpoch;
  bool get isDisposed => _disposed;

  PersistentCpuWorker._init()
      : maxConcurrentTasks = 4,
        maxQueueSize = 50 {
    try {
      WidgetsBinding.instance.addObserver(this);
    } catch (_) {}
  }

  static Future<PersistentCpuWorker> start({int initialEpoch = 0}) async {
    if (initialEpoch < 0) {
      throw ArgumentError.value(
        initialEpoch,
        'initialEpoch',
        'must not be negative',
      );
    }

    instance._currentEpoch = initialEpoch;
    return instance;
  }

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

  void advanceEpoch(int nextEpoch) {
    if (_disposed) return;
    if (nextEpoch < _currentEpoch) {
      return;
    }
    if (nextEpoch == _currentEpoch) {
      return;
    }
    _currentEpoch = nextEpoch;
    cancelAll(incrementEpoch: false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      cancelAll();
    }
  }

  void cancelAll({bool incrementEpoch = true}) {
    if (incrementEpoch) {
      _currentEpoch++;
    }
    for (final task in _queue) {
      task.cancel();
    }
    _queue.clear();
  }

  void dispose() {
    _disposed = true;
    try {
      WidgetsBinding.instance.removeObserver(this);
    } catch (_) {}
    cancelAll(incrementEpoch: false);
  }

  Future<R> executeTaskWithPayload<Q, R>(
      ComputeCallback<Q, R> task, Q message) {
    if (_disposed) {
      return Future.error(StateError("Worker is disposed"));
    }

    if ((_queue.length + _activeJobs) >= maxQueueSize) {
      return Future.error(WorkerQueueExhaustedException());
    }

    final completer = Completer<dynamic>();
    final queuedTask = _QueuedComputeTask<Q, R>(task, message, completer, _currentEpoch, this);
    _queue.add(queuedTask);

    _pump();

    return completer.future.then((value) => value as R);
  }

  Future<WorkerResult<R>> submit<R>(WorkerJob<Object?> job) {
    if (_disposed) {
      return Future<WorkerResult<R>>.error(
        StateError('PersistentCpuWorker is closed.'),
      );
    }

    _validateJob(job);

    if ((_queue.length + _activeJobs) >= maxQueueSize) {
      return Future<WorkerResult<R>>.error(
        StateError('CPU worker queue capacity exceeded: $maxQueueSize.'),
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

    final completer = Completer<dynamic>();
    final pending = _QueuedWorkerJobTask<R>(job, completer, _currentEpoch, this);
    _queue.add(pending);

    _pump();

    return completer.future.then((value) => value as WorkerResult<R>);
  }

  Future<double> calculateNewEaseFactor(double ease, int rating) {
    return executeTaskWithPayload<Map<String, dynamic>, double>(_heavySrsMath, {
      'ease': ease,
      'rating': rating,
    });
  }

  void _pump() {
    if (_disposed) return;

    while (_activeJobs < maxConcurrentTasks && _queue.isNotEmpty) {
      final queuedTask = _queue.removeFirst();
      _executeQueuedTask(queuedTask);
    }
  }

  Future<void> _executeQueuedTask(_QueuedTask queuedTask) async {
    _activeJobs++;
    try {
      await queuedTask.execute();
    } finally {
      _activeJobs--;
      _pump();
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

  static double _heavySrsMath(dynamic rawData) {
    final data = rawData as Map<String, dynamic>;
    double ease = data['ease'] as double;
    int rating = data['rating'] as int;

    if (ease < 0) {
      throw ArgumentError("Ease cannot be negative");
    }

    double newEase = ease + (0.1 - (5 - rating) * (0.08 + (5 - rating) * 0.02));
    if (newEase < 1.3) newEase = 1.3;

    return newEase;
  }
}

// --- Background Isolate Wire Implementations ---

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
  final digest = sha256.convert(utf8.encode(content));
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
