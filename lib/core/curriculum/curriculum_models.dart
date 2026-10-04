enum CurriculumStage {
  foundation,
  everydayA1,
  a2Bridge,
  functionalB1,
  integration,
}

extension CurriculumStageLabel on CurriculumStage {
  String get code => switch (this) {
        CurriculumStage.foundation => 'foundation',
        CurriculumStage.everydayA1 => 'everyday-a1',
        CurriculumStage.a2Bridge => 'a2-bridge',
        CurriculumStage.functionalB1 => 'functional-b1',
        CurriculumStage.integration => 'integration',
      };
}

enum CurriculumTaskKind {
  orientation,
  vocabulary,
  grammar,
  listening,
  reading,
  writing,
  speaking,
  transfer,
  checkpoint,
}

final class CurriculumTask {
  CurriculumTask({
    required this.id,
    required this.order,
    required this.stage,
    required this.kind,
    required this.titleDe,
    required this.titleAr,
    required this.skill,
    required this.topic,
    List<String> prerequisiteIds = const <String>[],
    this.targetItemCount = 8,
    this.masteryThreshold = 0.8,
  }) : prerequisiteIds = List<String>.unmodifiable(
          prerequisiteIds.map((id) => id.trim()),
        ) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Task id must not be empty.');
    }
    if (order < 1 || order > 50) {
      throw ArgumentError.value(order, 'order', 'Task order must be 1..50.');
    }
    if (titleDe.trim().isEmpty || titleAr.trim().isEmpty) {
      throw ArgumentError('Task titles must not be empty.');
    }
    if (skill.trim().isEmpty || topic.trim().isEmpty) {
      throw ArgumentError('Task skill/topic must not be empty.');
    }
    if (targetItemCount < 1) {
      throw ArgumentError.value(
        targetItemCount,
        'targetItemCount',
        'Task item count must be positive.',
      );
    }
    if (masteryThreshold <= 0 || masteryThreshold > 1) {
      throw ArgumentError.value(
        masteryThreshold,
        'masteryThreshold',
        'Mastery threshold must be in (0, 1].',
      );
    }
    if (this.prerequisiteIds.any((value) => value.isEmpty)) {
      throw ArgumentError('Prerequisite ids must not be empty.');
    }
    if (this.prerequisiteIds.toSet().length != this.prerequisiteIds.length) {
      throw ArgumentError('Prerequisite ids must be unique.');
    }
    if (this.prerequisiteIds.contains(id)) {
      throw ArgumentError('A task cannot depend on itself.');
    }
  }

  final String id;
  final int order;
  final CurriculumStage stage;
  final CurriculumTaskKind kind;
  final String titleDe;
  final String titleAr;
  final String skill;
  final String topic;
  final List<String> prerequisiteIds;
  final int targetItemCount;
  final double masteryThreshold;

  bool get isCheckpoint => kind == CurriculumTaskKind.checkpoint;
}

final class CurriculumTaskOutcome {
  const CurriculumTaskOutcome({
    required this.taskId,
    required this.score,
    required this.completed,
    required this.attempts,
  })  : assert(taskId != ''),
        assert(score >= 0 && score <= 1),
        assert(attempts > 0);

  final String taskId;
  final double score;
  final bool completed;
  final int attempts;
}

final class CurriculumTaskProgress {
  const CurriculumTaskProgress({
    required this.taskId,
    required this.bestScore,
    required this.completed,
    required this.attempts,
  });

  final String taskId;
  final double bestScore;
  final bool completed;
  final int attempts;

  CurriculumTaskProgress merge(CurriculumTaskOutcome outcome) {
    if (outcome.taskId != taskId) {
      throw ArgumentError('Outcome task id does not match progress task id.');
    }
    return CurriculumTaskProgress(
      taskId: taskId,
      bestScore: outcome.score > bestScore ? outcome.score : bestScore,
      completed: completed || outcome.completed,
      attempts: attempts + outcome.attempts,
    );
  }
}

final class CurriculumProgress {
  CurriculumProgress._(Map<String, CurriculumTaskProgress> entries)
      : entries = Map<String, CurriculumTaskProgress>.unmodifiable(entries);

  factory CurriculumProgress.empty() =>
      CurriculumProgress._(<String, CurriculumTaskProgress>{});

  final Map<String, CurriculumTaskProgress> entries;

  CurriculumTaskProgress? forTask(String taskId) => entries[taskId];

  bool isCompleted(String taskId) => entries[taskId]?.completed ?? false;

  int get completedCount =>
      entries.values.where((item) => item.completed).length;

  CurriculumProgress record(CurriculumTaskOutcome outcome) {
    final next = <String, CurriculumTaskProgress>{...entries};
    final current = next[outcome.taskId];
    next[outcome.taskId] = current == null
        ? CurriculumTaskProgress(
            taskId: outcome.taskId,
            bestScore: outcome.score,
            completed: outcome.completed,
            attempts: outcome.attempts,
          )
        : current.merge(outcome);
    return CurriculumProgress._(next);
  }
}

final class CurriculumRecommendation {
  const CurriculumRecommendation({
    required this.task,
    required this.unlocked,
    required this.reason,
    required this.missingPrerequisiteIds,
  });

  final CurriculumTask task;
  final bool unlocked;
  final String reason;
  final List<String> missingPrerequisiteIds;
}

final class CurriculumGraphValidation {
  const CurriculumGraphValidation({
    required this.errors,
  });

  final List<String> errors;

  bool get isValid => errors.isEmpty;
}
