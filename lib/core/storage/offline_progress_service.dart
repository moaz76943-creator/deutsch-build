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
  });

  final String taskId;
  final int points;
  final double bestScore;
  final bool completed;
  final TaskMasteryStatus mastery;
  final int updatedAtEpochMs;

  Map<String, Object?> toJson() => <String, Object?>{
        'taskId': taskId,
        'points': points,
        'bestScore': bestScore,
        'completed': completed,
        'mastery': mastery.name,
        'updatedAtEpochMs': updatedAtEpochMs,
      };

  static OfflineTaskProgress? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final taskId = raw['taskId'];
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
    );
  }
}

final class OfflineProgressSnapshot {
  OfflineProgressSnapshot._({
    required this.sourceLanguageTag,
    required this.targetLanguageTag,
    required Map<String, OfflineTaskProgress> tasks,
    required this.updatedAtEpochMs,
  }) : tasks = Map<String, OfflineTaskProgress>.unmodifiable(tasks);

  factory OfflineProgressSnapshot.empty() => OfflineProgressSnapshot._(
        sourceLanguageTag: null,
        targetLanguageTag: null,
        tasks: const <String, OfflineTaskProgress>{},
        updatedAtEpochMs: 0,
      );

  static const int schemaVersion = 1;
  static const int maxTasks = 50;

  final String? sourceLanguageTag;
  final String? targetLanguageTag;
  final Map<String, OfflineTaskProgress> tasks;
  final int updatedAtEpochMs;

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

  OfflineProgressSnapshot withActivePair({
    required String sourceLanguageTag,
    required String targetLanguageTag,
    required int occurredAtEpochMs,
  }) =>
      OfflineProgressSnapshot._(
        sourceLanguageTag: _language(sourceLanguageTag),
        targetLanguageTag: _language(targetLanguageTag),
        tasks: tasks,
        updatedAtEpochMs:
            _maxTimestamp(updatedAtEpochMs, occurredAtEpochMs),
      );

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
    if (!tasks.containsKey(normalizedId) && tasks.length >= maxTasks) {
      throw StateError('Offline progress is limited to 50 canonical tasks.');
    }

    final current = tasks[normalizedId] ??
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

    final nextTasks = <String, OfflineTaskProgress>{...tasks};
    nextTasks[normalizedId] = OfflineTaskProgress(
      taskId: normalizedId,
      points: points,
      bestScore: bestScore,
      completed: isCompleted,
      mastery: mastery,
      updatedAtEpochMs:
          _maxTimestamp(current.updatedAtEpochMs, occurredAtEpochMs),
    );

    return OfflineProgressSnapshot._(
      sourceLanguageTag: sourceLanguageTag,
      targetLanguageTag: targetLanguageTag,
      tasks: nextTasks,
      updatedAtEpochMs:
          _maxTimestamp(updatedAtEpochMs, occurredAtEpochMs),
    );
  }

  String encode() => jsonEncode(
        <String, Object?>{
          'schemaVersion': schemaVersion,
          'sourceLanguageTag': sourceLanguageTag,
          'targetLanguageTag': targetLanguageTag,
          'updatedAtEpochMs': updatedAtEpochMs,
          'tasks': tasks.values.map((task) => task.toJson()).toList(),
        },
      );

  static OfflineProgressSnapshot decode(String? encoded) {
    if (encoded == null || encoded.trim().isEmpty) {
      return OfflineProgressSnapshot.empty();
    }

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map ||
          _asInt(decoded['schemaVersion']) != schemaVersion) {
        return OfflineProgressSnapshot.empty();
      }

      final source = _optionalLanguage(decoded['sourceLanguageTag']);
      final target = _optionalLanguage(decoded['targetLanguageTag']);
      final tasks = <String, OfflineTaskProgress>{};
      final rawTasks = decoded['tasks'];
      if (rawTasks is List) {
        for (final raw in rawTasks.take(maxTasks)) {
          final task = OfflineTaskProgress.fromJson(raw);
          if (task != null) tasks[task.taskId] = task;
        }
      }

      return OfflineProgressSnapshot._(
        sourceLanguageTag: source,
        targetLanguageTag: target,
        tasks: tasks,
        updatedAtEpochMs:
            _asInt(decoded['updatedAtEpochMs'])
                .clamp(0, 4102444800000)
                .toInt(),
      );
    } on Object {
      return OfflineProgressSnapshot.empty();
    }
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
    return OfflineProgressService._(
      store: store,
      initial: OfflineProgressSnapshot.decode(encoded),
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
    if (!_validLanguage(source) || !_validLanguage(target)) {
      return Future<void>.error(
        ArgumentError('Invalid source or target language tag.'),
      );
    }

    if (_snapshot.sourceLanguageTag == source &&
        _snapshot.targetLanguageTag == target) {
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
    if (_snapshot.tasks.isNotEmpty || memory.tasks.isEmpty) {
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

bool _validTaskId(String value) =>
    value.trim().isNotEmpty && value.trim().length <= 160;

int _legacyPoints(TaskMemoryRecord record) {
  final scorePoints = (record.bestScore * 100).round();
  final completionBonus = record.completed ? 25 : 0;
  return (scorePoints + completionBonus).clamp(0, 125).toInt();
}

int _asInt(Object? value) => value is num ? value.toInt() : 0;

double _asDouble(Object? value) => value is num ? value.toDouble() : 0;

int _maxTimestamp(int current, int candidate) =>
    candidate > current ? candidate : current;
