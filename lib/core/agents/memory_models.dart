import 'dart:convert';

abstract interface class MemoryAgentStore {
  Future<String?> read();
  Future<void> write(String encoded);
}

final class TaskMemoryRecord {
  const TaskMemoryRecord({
    required this.taskId,
    required this.visits,
    required this.completed,
    required this.bestScore,
    required this.attempts,
  });

  final String taskId;
  final int visits;
  final bool completed;
  final double bestScore;
  final int attempts;

  TaskMemoryRecord recordVisit() => TaskMemoryRecord(
        taskId: taskId,
        visits: (visits + 1).clamp(0, 1000000).toInt(),
        completed: completed,
        bestScore: bestScore,
        attempts: attempts,
      );

  TaskMemoryRecord recordProgress({
    required double score,
    required bool isCompleted,
    required int attemptCount,
  }) =>
      TaskMemoryRecord(
        taskId: taskId,
        visits: visits,
        completed: completed || isCompleted,
        bestScore: score > bestScore ? score : bestScore,
        attempts: (attempts + attemptCount).clamp(0, 1000000).toInt(),
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'taskId': taskId,
        'visits': visits,
        'completed': completed,
        'bestScore': bestScore,
        'attempts': attempts,
      };

  static TaskMemoryRecord? fromJson(Object? value) {
    if (value is! Map) return null;
    final taskId = value['taskId'];
    if (taskId is! String || taskId.trim().isEmpty) return null;
    return TaskMemoryRecord(
      taskId: taskId.trim(),
      visits: _int(value['visits']).clamp(0, 1000000).toInt(),
      completed: value['completed'] == true,
      bestScore: _double(value['bestScore']).clamp(0.0, 1.0).toDouble(),
      attempts: _int(value['attempts']).clamp(0, 1000000).toInt(),
    );
  }
}

final class WeaknessMemoryRecord {
  const WeaknessMemoryRecord({
    required this.weaknessKey,
    required this.taskId,
    required this.weight,
    required this.occurrences,
    required this.lastSeenEpochMs,
  });

  final String weaknessKey;
  final String taskId;
  final int weight;
  final int occurrences;
  final int lastSeenEpochMs;

  WeaknessMemoryRecord add({
    required String nextTaskId,
    required int addedWeight,
    required int seenAtEpochMs,
  }) =>
      WeaknessMemoryRecord(
        weaknessKey: weaknessKey,
        taskId: nextTaskId.trim().isEmpty ? taskId : nextTaskId.trim(),
        weight: (weight + addedWeight).clamp(0, 1000000).toInt(),
        occurrences: (occurrences + 1).clamp(0, 1000000).toInt(),
        lastSeenEpochMs:
            seenAtEpochMs > lastSeenEpochMs ? seenAtEpochMs : lastSeenEpochMs,
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'weaknessKey': weaknessKey,
        'taskId': taskId,
        'weight': weight,
        'occurrences': occurrences,
        'lastSeenEpochMs': lastSeenEpochMs,
      };

  static WeaknessMemoryRecord? fromJson(Object? value) {
    if (value is! Map) return null;
    final weaknessKey = value['weaknessKey'];
    final taskId = value['taskId'];
    if (weaknessKey is! String ||
        weaknessKey.trim().isEmpty ||
        taskId is! String ||
        taskId.trim().isEmpty) {
      return null;
    }
    return WeaknessMemoryRecord(
      weaknessKey: weaknessKey.trim(),
      taskId: taskId.trim(),
      weight: _int(value['weight']).clamp(0, 1000000).toInt(),
      occurrences: _int(value['occurrences']).clamp(0, 1000000).toInt(),
      lastSeenEpochMs: _int(value['lastSeenEpochMs']).clamp(0, 4102444800000).toInt(),
    );
  }
}

final class MemoryReviewPriority {
  const MemoryReviewPriority({
    required this.weaknessKey,
    required this.taskId,
    required this.weight,
    required this.occurrences,
    required this.lastSeenEpochMs,
  });

  final String weaknessKey;
  final String taskId;
  final int weight;
  final int occurrences;
  final int lastSeenEpochMs;
}

final class MemoryAgentSnapshot {
  MemoryAgentSnapshot._({
    required Map<String, TaskMemoryRecord> tasks,
    required Map<String, WeaknessMemoryRecord> weaknesses,
    required this.updatedAtEpochMs,
  })  : tasks = Map<String, TaskMemoryRecord>.unmodifiable(tasks),
        weaknesses =
            Map<String, WeaknessMemoryRecord>.unmodifiable(weaknesses);

  factory MemoryAgentSnapshot.empty() => MemoryAgentSnapshot._(
        tasks: const <String, TaskMemoryRecord>{},
        weaknesses: const <String, WeaknessMemoryRecord>{},
        updatedAtEpochMs: 0,
      );

  static const int schemaVersion = 1;
  static const int maxTaskRecords = 100;
  static const int maxWeaknessRecords = 200;

  final Map<String, TaskMemoryRecord> tasks;
  final Map<String, WeaknessMemoryRecord> weaknesses;
  final int updatedAtEpochMs;

  List<MemoryReviewPriority> get reviewPriorities {
    final ranked = weaknesses.values
        .map(
          (record) => MemoryReviewPriority(
            weaknessKey: record.weaknessKey,
            taskId: record.taskId,
            weight: record.weight,
            occurrences: record.occurrences,
            lastSeenEpochMs: record.lastSeenEpochMs,
          ),
        )
        .toList(growable: false)
      ..sort((a, b) {
        final byWeight = b.weight.compareTo(a.weight);
        if (byWeight != 0) return byWeight;
        final byOccurrences = b.occurrences.compareTo(a.occurrences);
        if (byOccurrences != 0) return byOccurrences;
        final byRecency = b.lastSeenEpochMs.compareTo(a.lastSeenEpochMs);
        if (byRecency != 0) return byRecency;
        return a.weaknessKey.compareTo(b.weaknessKey);
      });
    return List<MemoryReviewPriority>.unmodifiable(ranked);
  }

  MemoryAgentSnapshot recordVisit(
    String rawTaskId, {
    required int occurredAtEpochMs,
  }) {
    final taskId = _validatedId(rawTaskId, 'taskId');
    final nextTasks = <String, TaskMemoryRecord>{...tasks};
    final current = nextTasks[taskId] ??
        TaskMemoryRecord(
          taskId: taskId,
          visits: 0,
          completed: false,
          bestScore: 0,
          attempts: 0,
        );
    nextTasks[taskId] = current.recordVisit();
    return _copy(
      tasks: _boundedTasks(nextTasks),
      weaknesses: weaknesses,
      updatedAtEpochMs: _maxTimestamp(updatedAtEpochMs, occurredAtEpochMs),
    );
  }

  MemoryAgentSnapshot recordProgress({
    required String rawTaskId,
    required double score,
    required bool completed,
    required int attempts,
    required int occurredAtEpochMs,
  }) {
    final taskId = _validatedId(rawTaskId, 'taskId');
    final safeScore = score.clamp(0.0, 1.0).toDouble();
    final safeAttempts = attempts.clamp(0, 1000000).toInt();
    final nextTasks = <String, TaskMemoryRecord>{...this.tasks};
    final current = nextTasks[taskId] ??
        TaskMemoryRecord(
          taskId: taskId,
          visits: 0,
          completed: false,
          bestScore: 0,
          attempts: 0,
        );
    nextTasks[taskId] = current.recordProgress(
      score: safeScore,
      isCompleted: completed,
      attemptCount: safeAttempts,
    );
    return _copy(
      tasks: _boundedTasks(nextTasks),
      weaknesses: weaknesses,
      updatedAtEpochMs: _maxTimestamp(updatedAtEpochMs, occurredAtEpochMs),
    );
  }

  MemoryAgentSnapshot recordWeakness({
    required String rawTaskId,
    required String rawWeaknessKey,
    required int weight,
    required int occurredAtEpochMs,
  }) {
    final taskId = _validatedId(rawTaskId, 'taskId');
    final weaknessKey = _validatedId(rawWeaknessKey, 'weaknessKey');
    final safeWeight = weight.clamp(1, 1000).toInt();
    final nextWeaknesses = <String, WeaknessMemoryRecord>{...weaknesses};
    final current = nextWeaknesses[weaknessKey];
    nextWeaknesses[weaknessKey] = current == null
        ? WeaknessMemoryRecord(
            weaknessKey: weaknessKey,
            taskId: taskId,
            weight: safeWeight,
            occurrences: 1,
            lastSeenEpochMs: occurredAtEpochMs,
          )
        : current.add(
            nextTaskId: taskId,
            addedWeight: safeWeight,
            seenAtEpochMs: occurredAtEpochMs,
          );

    return _copy(
      tasks: tasks,
      weaknesses: _boundedWeaknesses(nextWeaknesses),
      updatedAtEpochMs: _maxTimestamp(updatedAtEpochMs, occurredAtEpochMs),
    );
  }

  String encode() => jsonEncode(
        <String, Object?>{
          'schemaVersion': schemaVersion,
          'updatedAtEpochMs': updatedAtEpochMs,
          'tasks': tasks.values.map((record) => record.toJson()).toList(),
          'weaknesses':
              weaknesses.values.map((record) => record.toJson()).toList(),
        },
      );

  static MemoryAgentSnapshot fromDecoded(Object? decoded) {
    if (decoded is! Map ||
        _int(decoded['schemaVersion']) != schemaVersion) {
      return MemoryAgentSnapshot.empty();
    }

    final tasks = <String, TaskMemoryRecord>{};
    final rawTasks = decoded['tasks'];
    if (rawTasks is List) {
      for (final raw in rawTasks.take(maxTaskRecords)) {
        final record = TaskMemoryRecord.fromJson(raw);
        if (record != null) tasks[record.taskId] = record;
      }
    }

    final weaknesses = <String, WeaknessMemoryRecord>{};
    final rawWeaknesses = decoded['weaknesses'];
    if (rawWeaknesses is List) {
      for (final raw in rawWeaknesses.take(maxWeaknessRecords)) {
        final record = WeaknessMemoryRecord.fromJson(raw);
        if (record != null) weaknesses[record.weaknessKey] = record;
      }
    }

    return MemoryAgentSnapshot._(
      tasks: tasks,
      weaknesses: weaknesses,
      updatedAtEpochMs:
          _int(decoded['updatedAtEpochMs'])
              .clamp(0, 4102444800000)
              .toInt(),
    );
  }

  MemoryAgentSnapshot _copy({
    required Map<String, TaskMemoryRecord> tasks,
    required Map<String, WeaknessMemoryRecord> weaknesses,
    required int updatedAtEpochMs,
  }) =>
      MemoryAgentSnapshot._(
        tasks: tasks,
        weaknesses: weaknesses,
        updatedAtEpochMs: updatedAtEpochMs,
      );

  static Map<String, TaskMemoryRecord> _boundedTasks(
    Map<String, TaskMemoryRecord> source,
  ) {
    if (source.length <= maxTaskRecords) return source;
    final keys = source.keys.toList(growable: false)..sort();
    final keep = keys.skip(keys.length - maxTaskRecords).toSet();
    return <String, TaskMemoryRecord>{
      for (final entry in source.entries)
        if (keep.contains(entry.key)) entry.key: entry.value,
    };
  }

  static Map<String, WeaknessMemoryRecord> _boundedWeaknesses(
    Map<String, WeaknessMemoryRecord> source,
  ) {
    if (source.length <= maxWeaknessRecords) return source;
    final ranked = source.values.toList(growable: false)
      ..sort((a, b) {
        final byWeight = b.weight.compareTo(a.weight);
        if (byWeight != 0) return byWeight;
        return b.lastSeenEpochMs.compareTo(a.lastSeenEpochMs);
      });
    return <String, WeaknessMemoryRecord>{
      for (final record in ranked.take(maxWeaknessRecords))
        record.weaknessKey: record,
    };
  }
}

int _int(Object? value) => value is num ? value.toInt() : 0;

double _double(Object? value) => value is num ? value.toDouble() : 0;

int _maxTimestamp(int current, int candidate) =>
    candidate > current ? candidate : current;

String _validatedId(String raw, String field) {
  final value = raw.trim();
  if (value.isEmpty || value.length > 160) {
    throw ArgumentError.value(raw, field, '$field must be 1..160 characters.');
  }
  return value;
}
