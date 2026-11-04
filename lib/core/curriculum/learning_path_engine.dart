import 'curriculum_models.dart';

final class LearningPathEngine {
  LearningPathEngine(List<CurriculumTask> tasks)
      : _tasks = List<CurriculumTask>.unmodifiable(
          <CurriculumTask>[...tasks]..sort((a, b) => a.order.compareTo(b.order)),
        ),
        _byId = <String, CurriculumTask>{
          for (final task in tasks) task.id: task,
        } {
    final validation = validateGraph();
    if (!validation.isValid) {
      throw ArgumentError(
        'Invalid curriculum graph: ${validation.errors.join('; ')}',
      );
    }
  }

  final List<CurriculumTask> _tasks;
  final Map<String, CurriculumTask> _byId;

  List<CurriculumTask> get tasks => _tasks;

  CurriculumTask taskById(String taskId) {
    final task = _byId[taskId];
    if (task == null) {
      throw ArgumentError.value(taskId, 'taskId', 'Unknown curriculum task.');
    }
    return task;
  }

  CurriculumGraphValidation validateGraph() {
    final errors = <String>[];
    final ids = <String>{};
    final orders = <int>{};

    for (final task in _tasks) {
      if (!ids.add(task.id)) {
        errors.add('Duplicate task id: ${task.id}');
      }
      if (!orders.add(task.order)) {
        errors.add('Duplicate task order: ${task.order}');
      }
    }

    for (final task in _tasks) {
      for (final prerequisiteId in task.prerequisiteIds) {
        final prerequisite = _byId[prerequisiteId];
        if (prerequisite == null) {
          errors.add(
            '${task.id} references missing prerequisite $prerequisiteId',
          );
          continue;
        }
        if (prerequisite.order >= task.order) {
          errors.add(
            '${task.id} depends on non-earlier prerequisite $prerequisiteId',
          );
        }
      }
    }

    final states = <String, int>{};
    bool visit(String taskId, List<String> stack) {
      final state = states[taskId] ?? 0;
      if (state == 1) {
        errors.add('Cycle detected: ${[...stack, taskId].join(' -> ')}');
        return false;
      }
      if (state == 2) return true;

      states[taskId] = 1;
      final task = _byId[taskId];
      if (task != null) {
        for (final prerequisiteId in task.prerequisiteIds) {
          if (_byId.containsKey(prerequisiteId)) {
            visit(prerequisiteId, <String>[...stack, taskId]);
          }
        }
      }
      states[taskId] = 2;
      return true;
    }

    for (final task in _tasks) {
      visit(task.id, const <String>[]);
    }

    return CurriculumGraphValidation(
      errors: List<String>.unmodifiable(errors.toSet()),
    );
  }

  CurriculumProgress recordOutcome(
    CurriculumProgress progress,
    CurriculumTaskOutcome outcome,
  ) {
    final task = taskById(outcome.taskId);
    if (outcome.score < 0 || outcome.score > 1) {
      throw ArgumentError.value(
        outcome.score,
        'score',
        'Score must be between 0 and 1.',
      );
    }
    if (outcome.attempts < 1) {
      throw ArgumentError.value(
        outcome.attempts,
        'attempts',
        'Attempts must be positive.',
      );
    }

    final prerequisitesMet = _prerequisitesMet(task, progress);
    if (!prerequisitesMet && !progress.isCompleted(task.id)) {
      throw StateError(
        'Cannot record ${task.id} before its prerequisites are completed.',
      );
    }

    final normalized = CurriculumTaskOutcome(
      taskId: outcome.taskId,
      score: outcome.score,
      completed: outcome.completed && outcome.score >= task.masteryThreshold,
      attempts: outcome.attempts,
    );
    return progress.record(normalized);
  }

  CurriculumTask? nextRequired(CurriculumProgress progress) {
    for (final task in _tasks) {
      if (progress.isCompleted(task.id)) continue;
      if (_prerequisitesMet(task, progress)) return task;
    }
    return null;
  }

  List<CurriculumTask> unlockedTasks(CurriculumProgress progress) =>
      List<CurriculumTask>.unmodifiable(
        _tasks.where(
          (task) =>
              !progress.isCompleted(task.id) &&
              _prerequisitesMet(task, progress),
        ),
      );

  List<CurriculumRecommendation> recommend(
    CurriculumProgress progress, {
    int limit = 5,
  }) {
    if (limit < 1) {
      throw ArgumentError.value(limit, 'limit', 'Limit must be positive.');
    }

    final firstIncompleteIndex = _tasks.indexWhere(
      (task) => !progress.isCompleted(task.id),
    );
    if (firstIncompleteIndex < 0) {
      return const <CurriculumRecommendation>[];
    }

    final end = (firstIncompleteIndex + limit)
        .clamp(0, _tasks.length)
        .toInt();
    return List<CurriculumRecommendation>.unmodifiable(
      _tasks
          .sublist(firstIncompleteIndex, end)
          .map((task) => _recommendationFor(task, progress)),
    );
  }

  double progressRatio(CurriculumProgress progress) {
    if (_tasks.isEmpty) return 1;
    final completed = _tasks
        .where((task) => progress.isCompleted(task.id))
        .length;
    return completed / _tasks.length;
  }

  CurriculumStage? activeStage(CurriculumProgress progress) =>
      nextRequired(progress)?.stage;

  bool isComplete(CurriculumProgress progress) =>
      _tasks.every((task) => progress.isCompleted(task.id));

  CurriculumRecommendation _recommendationFor(
    CurriculumTask task,
    CurriculumProgress progress,
  ) {
    final missing = <String>[
      for (final prerequisiteId in task.prerequisiteIds)
        if (!progress.isCompleted(prerequisiteId)) prerequisiteId,
    ];
    final unlocked = missing.isEmpty;
    final existing = progress.forTask(task.id);

    final reason = !unlocked
        ? 'بانتظار إكمال: ${missing.join(', ')}'
        : existing != null && !existing.completed
            ? 'إعادة موجّهة بعد ${existing.attempts} محاولة؛ أفضل نتيجة '
                '${(existing.bestScore * 100).round()}%.'
            : task.isCheckpoint
                ? 'نقطة تحقق لقياس نقل المعرفة قبل المرحلة التالية.'
                : 'المهمة التالية المتاحة حسب تسلسل المنهج.';

    return CurriculumRecommendation(
      task: task,
      unlocked: unlocked,
      reason: reason,
      missingPrerequisiteIds: List<String>.unmodifiable(missing),
    );
  }

  bool _prerequisitesMet(
    CurriculumTask task,
    CurriculumProgress progress,
  ) =>
      task.prerequisiteIds.every(progress.isCompleted);
}
