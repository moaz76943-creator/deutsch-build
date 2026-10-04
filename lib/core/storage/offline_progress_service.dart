import 'dart:async';
import 'dart:convert';

import '../agents/memory_models.dart';

enum TaskMasteryStatus {
  notStarted,
  learning,
  mastered,
}

final class OfflineTaskProgress {
  const OfflineTaskProgress({
    required this.taskId,
    required this.points,
    required this.bestScore,
    required this.completed,
    required this.mastery,
    required this.updatedAtEpochMs,
    this.sourceLanguageId,
    this.targetLanguageId,
  });

  final String taskId;
  final int points;
  final double bestScore;
  final bool completed;
  final TaskMasteryStatus mastery;
  final int updatedAtEpochMs;
  final String? sourceLanguageId;
  final String? targetLanguageId;

  Map<String, Object?> toJson() => <String, Object?>{
        'taskId': taskId,
        if (sourceLanguageId != null)
          'source_language_id': sourceLanguageId,
        if (targetLanguageId != null)
          'target_language_id': targetLanguageId,
        'points': points,
        'bestScore': bestScore,
        'completed': completed,
        'mastery': mastery.name,
        'updatedAtEpochMs': updatedAtEpochMs,
      };

  static OfflineTaskProgress? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final taskId = raw['taskId'] ?? raw['task_id'];
    if (taskId is! String || !_validTaskId(taskId)) return null;

    final points = _asInt(raw['points']).clamp(0, 1000000000).toInt();
    final score =
        _asDouble(raw['bestScore']).clamp(0.0, 1.0).toDouble();
    final completed = raw['completed'] == true;
    final mastery = completed
        ? TaskMasteryStatus.mastered
        : (points > 0 || score > 0)
            ? TaskMasteryStatus.learning
            : TaskMasteryStatus.notStarted;

    return OfflineTaskProgress(
      taskId: taskId.trim(),
      points: points,
      bestScore: score,
      completed: completed,
      mastery: mastery,
      updatedAtEpochMs:
          _asInt(raw['updatedAtEpochMs']).clamp(0, 4102444800000).toInt(),
      sourceLanguageId: _optionalLanguage(raw['source_language_id']),
      targetLanguageId: _optionalLanguage(raw['target_language_id']),
    );
  }

  OfflineTaskProgress withPair(
    String sourceLanguageId,
    String targetLanguageId,
  ) =>
      OfflineTaskProgress(
        taskId: taskId,
        points: points,
        bestScore: bestScore,
        completed: completed,
        mastery: mastery,
        updatedAtEpochMs: updatedAtEpochMs,
        sourceLanguageId: _language(sourceLanguageId),
        targetLanguageId: _language(targetLanguageId),
      );
}

final class _ScopedTaskProgress {
  _ScopedTaskProgress({
    required this.sourceLanguageId,
    required this.targetLanguageId,
    required OfflineTaskProgress progress,
  }) : progress = progress.withPair(
          sourceLanguageId,
          targetLanguageId,
        );

  final String sourceLanguageId;
  final String targetLanguageId;
  final OfflineTaskProgress progress;

  String get recordKey => _progressRecordKey(
        sourceLanguageId,
        targetLanguageId,
        progress.taskId,
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'source_language_id': sourceLanguageId,
        'target_language_id': targetLanguageId,
        'task_id': progress.taskId,
        'points': progress.points,
        'bestScore': progress.bestScore,
        'completed': progress.completed,
        'mastery': progress.mastery.name,
        'updatedAtEpochMs': progress.updatedAtEpochMs,
      };
}

final class OfflineProgressSnapshot {
  OfflineProgressSnapshot._({
    required this.sourceLanguageTag,
    required this.targetLanguageTag,
    required Map<String, _ScopedTaskProgress> records,
    required this.updatedAtEpochMs,
  }) : _records = Map<String, _ScopedTaskProgress>.unmodifiable(records);

  factory OfflineProgressSnapshot.empty() => OfflineProgressSnapshot._(
        sourceLanguageTag: null,
        targetLanguageTag: null,
        records: const <String, _ScopedTaskProgress>{},
        updatedAtEpochMs: 0,
      );

  static const int schemaVersion = 2;
  static const int legacySchemaVersion = 1;
  static const int maxTasks = 50;
  static const String legacyDefaultSourceLanguageId = 'ar';
  static const String legacyDefaultTargetLanguageId = 'de';

  final String? sourceLanguageTag;
  final String? targetLanguageTag;
  final Map<String, _ScopedTaskProgress> _records;
  final int updatedAtEpochMs;

  bool get hasAnyProgress => _records.isNotEmpty;

  Map<String, OfflineTaskProgress> get tasks {
    final source = sourceLanguageTag;
    final target = targetLanguageTag;
    if (source == null || target == null) {
      return const <String, OfflineTaskProgress>{};
    }
    return tasksForPair(source, target);
  }

  String? get activePair {
    final source = sourceLanguageTag;
    final target = targetLanguageTag;
    if (source == null || target == null) return null;
    return '$source->$target';
  }

  int get completedTasks =>
      tasks.values.where((task) => task.completed).length;

  int get masteredTasks =>
      tasks.values
          .where((task) => task.mastery == TaskMasteryStatus.mastered)
          .length;

  int get totalPoints => tasks.values.fold<int>(
        0,
        (sum, task) => sum + task.points,
      );

  Map<String, OfflineTaskProgress> tasksForPair(
    String sourceLanguageId,
    String targetLanguageId,
  ) {
    final source = _language(sourceLanguageId);
    final target = _language(targetLanguageId);
    if (!_validDirectedPair(source, target)) {
      throw ArgumentError('Invalid directed language pair.');
    }

    final pairKey = _progressPairKey(source, target);
    final result = <String, OfflineTaskProgress>{};
    for (final record in _records.values) {
      if (_progressPairKey(
            record.sourceLanguageId,
            record.targetLanguageId,
          ) !=
          pairKey) {
        continue;
      }
      result[record.progress.taskId] = record.progress;
    }
    return Map<String, OfflineTaskProgress>.unmodifiable(result);
  }

  OfflineProgressSnapshot withActivePair({
    required String sourceLanguageTag,
    required String targetLanguageTag,
    required int occurredAtEpochMs,
  }) {
    final source = _language(sourceLanguageTag);
    final target = _language(targetLanguageTag);
    if (!_validDirectedPair(source, target)) {
      throw ArgumentError('Invalid directed language pair.');
    }
    return OfflineProgressSnapshot._(
      sourceLanguageTag: source,
      targetLanguageTag: target,
      records: _records,
      updatedAtEpochMs:
          _maxTimestamp(updatedAtEpochMs, occurredAtEpochMs),
    );
  }

  OfflineProgressSnapshot recordTask({
    required String taskId,
    required int pointsDelta,
    required double score,
    required bool completed,
    required int occurredAtEpochMs,
  }) {
    final normalizedId = taskId.trim();
    if (!_validTaskId(normalizedId)) {
      throw ArgumentError.value(
        taskId,
        'taskId',
        'must be 1..160 characters',
      );
    }

    final source = sourceLanguageTag ?? legacyDefaultSourceLanguageId;
    final target = targetLanguageTag ?? legacyDefaultTargetLanguageId;
    if (!_validDirectedPair(source, target)) {
      throw StateError('Offline progress requires a valid directed pair.');
    }

    final pairTasks = tasksForPair(source, target);
    if (!pairTasks.containsKey(normalizedId) &&
        pairTasks.length >= maxTasks) {
      throw StateError(
        'Offline progress is limited to 50 canonical tasks per pair.',
      );
    }

    final key = _progressRecordKey(source, target, normalizedId);
    final current = _records[key]?.progress ??
        OfflineTaskProgress(
          taskId: normalizedId,
          points: 0,
          bestScore: 0,
          completed: false,
          mastery: TaskMasteryStatus.notStarted,
          updatedAtEpochMs: 0,
        );

    final nextScore = score.clamp(0.0, 1.0).toDouble();
    final bestScore =
        nextScore > current.bestScore ? nextScore : current.bestScore;
    final isCompleted = current.completed || completed;
    final points = (current.points + pointsDelta)
        .clamp(0, 1000000000)
        .toInt();
    final mastery = isCompleted
        ? TaskMasteryStatus.mastered
        : (points > 0 || bestScore > 0)
            ? TaskMasteryStatus.learning
            : TaskMasteryStatus.notStarted;

    final nextRecords = <String, _ScopedTaskProgress>{..._records};
    final progress = OfflineTaskProgress(
      taskId: normalizedId,
      points: points,
      bestScore: bestScore,
      completed: isCompleted,
      mastery: mastery,
      updatedAtEpochMs:
          _maxTimestamp(current.updatedAtEpochMs, occurredAtEpochMs),
    );
    final scoped = _ScopedTaskProgress(
      sourceLanguageId: source,
      targetLanguageId: target,
      progress: progress,
    );
    nextRecords[scoped.recordKey] = scoped;

    return OfflineProgressSnapshot._(
      sourceLanguageTag: sourceLanguageTag ?? source,
      targetLanguageTag: targetLanguageTag ?? target,
      records: nextRecords,
      updatedAtEpochMs:
          _maxTimestamp(updatedAtEpochMs, occurredAtEpochMs),
    );
  }

  String encode() {
    final rows = _records.values.toList(growable: false)
      ..sort((left, right) => left.recordKey.compareTo(right.recordKey));
    return jsonEncode(
      <String, Object?>{
        'schemaVersion': schemaVersion,
        'sourceLanguageTag': sourceLanguageTag,
        'targetLanguageTag': targetLanguageTag,
        'updatedAtEpochMs': updatedAtEpochMs,
        'rows': rows.map((record) => record.toJson()).toList(growable: false),
        'tasks': tasks.values.map((task) => task.toJson()).toList(
              growable: false,
            ),
      },
    );
  }

  static bool requiresMigration(String? encoded) {
    if (encoded == null || encoded.trim().isEmpty) return false;
    try {
      final decoded = jsonDecode(encoded);
      return decoded is Map &&
          _asInt(decoded['schemaVersion']) == legacySchemaVersion;
    } on Object {
      return false;
    }
  }

  static OfflineProgressSnapshot decode(String? encoded) {
    if (encoded == null || encoded.trim().isEmpty) {
      return OfflineProgressSnapshot.empty();
    }

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map) return OfflineProgressSnapshot.empty();
      final version = _asInt(decoded['schemaVersion']);
      if (version == legacySchemaVersion) {
        return _decodeLegacy(decoded);
      }
      if (version != schemaVersion) {
        return OfflineProgressSnapshot.empty();
      }
      return _decodePairScoped(decoded);
    } on Object {
      return OfflineProgressSnapshot.empty();
    }
  }

  static OfflineProgressSnapshot _decodeLegacy(Map<dynamic, dynamic> decoded) {
    final source = _optionalLanguage(decoded['sourceLanguageTag']) ??
        legacyDefaultSourceLanguageId;
    final targetCandidate =
        _optionalLanguage(decoded['targetLanguageTag']) ??
            legacyDefaultTargetLanguageId;
    final target = _sameLanguage(source, targetCandidate)
        ? (_sameLanguage(source, legacyDefaultTargetLanguageId)
            ? legacyDefaultSourceLanguageId
            : legacyDefaultTargetLanguageId)
        : targetCandidate;
    final records = <String, _ScopedTaskProgress>{};
    final rawTasks = decoded['tasks'];
    if (rawTasks is List) {
      for (final raw in rawTasks.take(maxTasks)) {
        final progress = OfflineTaskProgress.fromJson(raw);
        if (progress == null) continue;
        final scoped = _ScopedTaskProgress(
          sourceLanguageId: source,
          targetLanguageId: target,
          progress: progress,
        );
        records[scoped.recordKey] = scoped;
      }
    }

    return OfflineProgressSnapshot._(
      sourceLanguageTag: source,
      targetLanguageTag: target,
      records: records,
      updatedAtEpochMs:
          _asInt(decoded['updatedAtEpochMs'])
              .clamp(0, 4102444800000)
              .toInt(),
    );
  }

  static OfflineProgressSnapshot _decodePairScoped(
    Map<dynamic, dynamic> decoded,
  ) {
    final source = _optionalLanguage(decoded['sourceLanguageTag']);
    final target = _optionalLanguage(decoded['targetLanguageTag']);
    final records = <String, _ScopedTaskProgress>{};

    final rawRows = decoded['rows'];
    if (rawRows is List) {
      for (final raw in rawRows) {
        if (raw is! Map) continue;
        final rowSource = _optionalLanguage(raw['source_language_id']);
        final rowTarget = _optionalLanguage(raw['target_language_id']);
        final progress = OfflineTaskProgress.fromJson(raw);
        if (rowSource == null ||
            rowTarget == null ||
            !_validDirectedPair(rowSource, rowTarget) ||
            progress == null) {
          continue;
        }
        final scoped = _ScopedTaskProgress(
          sourceLanguageId: rowSource,
          targetLanguageId: rowTarget,
          progress: progress,
        );
        records[scoped.recordKey] = scoped;
      }
    }

    if (records.isEmpty) {
      final rawTasks = decoded['tasks'];
      if (rawTasks is List) {
        final fallbackSource =
            source ?? legacyDefaultSourceLanguageId;
        final fallbackTargetCandidate =
            target ?? legacyDefaultTargetLanguageId;
        final fallbackTarget =
            _sameLanguage(fallbackSource, fallbackTargetCandidate)
                ? (_sameLanguage(
                    fallbackSource,
                    legacyDefaultTargetLanguageId,
                  )
                    ? legacyDefaultSourceLanguageId
                    : legacyDefaultTargetLanguageId)
                : fallbackTargetCandidate;

        for (final raw in rawTasks.take(maxTasks)) {
          final progress = OfflineTaskProgress.fromJson(raw);
          if (progress == null) continue;
          final rowSource =
              progress.sourceLanguageId ?? fallbackSource;
          final rowTarget =
              progress.targetLanguageId ?? fallbackTarget;
          if (!_validDirectedPair(rowSource, rowTarget)) continue;
          final scoped = _ScopedTaskProgress(
            sourceLanguageId: rowSource,
            targetLanguageId: rowTarget,
            progress: progress,
          );
          records[scoped.recordKey] = scoped;
        }
      }
    }

    final activeSource =
        source ?? (records.isEmpty ? null : records.values.first.sourceLanguageId);
    final activeTarget =
        target ?? (records.isEmpty ? null : records.values.first.targetLanguageId);

    return OfflineProgressSnapshot._(
      sourceLanguageTag: activeSource,
      targetLanguageTag: activeTarget,
      records: records,
      updatedAtEpochMs:
          _asInt(decoded['updatedAtEpochMs'])
              .clamp(0, 4102444800000)
              .toInt(),
    );
  }
}

final class OfflineProgressService {
  OfflineProgressService._({
    required MemoryAgentStore store,
    required OfflineProgressSnapshot initial,
  })  : _store = store,
        _snapshot = initial;

  final MemoryAgentStore _store;
  final StreamController<OfflineProgressSnapshot> _changes =
      StreamController<OfflineProgressSnapshot>.broadcast();

  OfflineProgressSnapshot _snapshot;
  Future<void> _writeQueue = Future<void>.value();
  bool _closed = false;

  static Future<OfflineProgressService> open(
    MemoryAgentStore store,
  ) async {
    String? encoded;
    try {
      encoded = await store.read();
    } on Object {
      encoded = null;
    }
    final initial = OfflineProgressSnapshot.decode(encoded);
    if (OfflineProgressSnapshot.requiresMigration(encoded)) {
      try {
        await store.write(initial.encode());
      } on Object {
        // Migration remains fail-safe: the original payload is still intact
        // in the physical store and will be retried on the next successful write.
      }
    }
    return OfflineProgressService._(
      store: store,
      initial: initial,
    );
  }

  OfflineProgressSnapshot get snapshot => _snapshot;

  Stream<OfflineProgressSnapshot> get changes => _changes.stream;

  Future<void> setActivePair({
    required String sourceLanguageTag,
    required String targetLanguageTag,
    int? occurredAtEpochMs,
  }) {
    _ensureOpen();
    final source = _language(sourceLanguageTag);
    final target = _language(targetLanguageTag);
    if (!_validDirectedPair(source, target)) {
      return Future<void>.error(
        ArgumentError('Invalid source or target directed language pair.'),
      );
    }

    if (_sameLanguage(_snapshot.sourceLanguageTag, source) &&
        _sameLanguage(_snapshot.targetLanguageTag, target)) {
      return Future<void>.value();
    }

    _snapshot = _snapshot.withActivePair(
      sourceLanguageTag: source,
      targetLanguageTag: target,
      occurredAtEpochMs:
          occurredAtEpochMs ?? DateTime.now().millisecondsSinceEpoch,
    );
    return _persistAndEmit();
  }

  Future<void> recordTaskProgress({
    required String taskId,
    required int pointsDelta,
    required double score,
    required bool completed,
    int? occurredAtEpochMs,
  }) {
    _ensureOpen();
    _snapshot = _snapshot.recordTask(
      taskId: taskId,
      pointsDelta: pointsDelta,
      score: score,
      completed: completed,
      occurredAtEpochMs:
          occurredAtEpochMs ?? DateTime.now().millisecondsSinceEpoch,
    );
    return _persistAndEmit();
  }

  Future<void> hydrateFromMemory(MemoryAgentSnapshot memory) {
    _ensureOpen();
    if (_snapshot.hasAnyProgress || memory.tasks.isEmpty) {
      return Future<void>.value();
    }

    var next = _snapshot;
    for (final record in memory.tasks.values.take(
      OfflineProgressSnapshot.maxTasks,
    )) {
      next = next.recordTask(
        taskId: record.taskId,
        pointsDelta: _legacyPoints(record),
        score: record.bestScore,
        completed: record.completed,
        occurredAtEpochMs: memory.updatedAtEpochMs,
      );
    }
    _snapshot = next;
    return _persistAndEmit();
  }

  Future<void> flush() => _writeQueue;

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await flush().catchError((_) {});
    await _changes.close();
  }

  Future<void> _persistAndEmit() {
    final encoded = _snapshot.encode();
    final emitted = _snapshot;
    _writeQueue = _writeQueue
        .catchError((_) {})
        .then<void>((_) => _store.write(encoded))
        .then<void>((_) {
      if (!_closed && !_changes.isClosed) {
        _changes.add(emitted);
      }
    });
    return _writeQueue;
  }

  void _ensureOpen() {
    if (_closed) {
      throw StateError('OfflineProgressService is closed.');
    }
  }
}

String _language(String value) =>
    value.trim().replaceAll('_', '-');

String? _optionalLanguage(Object? value) {
  if (value is! String) return null;
  final normalized = _language(value);
  return _validLanguage(normalized) ? normalized : null;
}

bool _validLanguage(String value) =>
    RegExp(r'^[A-Za-z]{2,8}(?:-[A-Za-z0-9]{1,8})*$').hasMatch(value);

bool _validDirectedPair(String source, String target) =>
    _validLanguage(source) &&
    _validLanguage(target) &&
    !_sameLanguage(source, target);

bool _sameLanguage(String? left, String? right) {
  if (left == null || right == null) return left == right;
  return left.toLowerCase() == right.toLowerCase();
}

bool _validTaskId(String value) =>
    value.trim().isNotEmpty && value.trim().length <= 160;

String _progressPairKey(String source, String target) =>
    '${_language(source).toLowerCase()}\u0000'
    '${_language(target).toLowerCase()}';

String _progressRecordKey(
  String source,
  String target,
  String taskId,
) =>
    '${_progressPairKey(source, target)}\u0000${taskId.trim()}';

int _legacyPoints(TaskMemoryRecord record) {
  final scorePoints = (record.bestScore * 100).round();
  final completionBonus = record.completed ? 25 : 0;
  return (scorePoints + completionBonus).clamp(0, 125).toInt();
}

int _asInt(Object? value) => value is num ? value.toInt() : 0;

double _asDouble(Object? value) => value is num ? value.toDouble() : 0;

int _maxTimestamp(int current, int candidate) =>
    candidate > current ? candidate : current;
