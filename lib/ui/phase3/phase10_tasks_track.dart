import 'package:flutter/material.dart';

import '../../core/curriculum/canonical_curriculum_50.dart';
import '../../core/curriculum/curriculum_models.dart';
import '../../core/storage/offline_progress_service.dart';
import '../../design_system/app_colors.dart';
import '../../design_system/app_glass_card.dart';

typedef Phase10TaskTap = void Function(CurriculumTask task);

final class Phase10TasksTrackView extends StatelessWidget {
  const Phase10TasksTrackView({
    required this.initialSnapshot,
    required this.progressStream,
    this.onTaskTap,
    this.tasks = const <CurriculumTask>[],
    this.fallbackSourceLanguageTag,
    this.fallbackTargetLanguageTag,
    super.key,
  });

  final OfflineProgressSnapshot initialSnapshot;
  final Stream<OfflineProgressSnapshot> progressStream;
  final Phase10TaskTap? onTaskTap;
  final List<CurriculumTask> tasks;
  final String? fallbackSourceLanguageTag;
  final String? fallbackTargetLanguageTag;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OfflineProgressSnapshot>(
      stream: progressStream,
      initialData: initialSnapshot,
      builder: (context, snapshot) {
        final progress = snapshot.data ?? initialSnapshot;
        return _TrackBody(
          progress: progress,
          tasks: tasks.isEmpty ? CanonicalCurriculum50.tasks : tasks,
          onTaskTap: onTaskTap,
          fallbackSourceLanguageTag: fallbackSourceLanguageTag,
          fallbackTargetLanguageTag: fallbackTargetLanguageTag,
        );
      },
    );
  }
}

final class _TrackBody extends StatelessWidget {
  const _TrackBody({
    required this.progress,
    required this.tasks,
    required this.onTaskTap,
    required this.fallbackSourceLanguageTag,
    required this.fallbackTargetLanguageTag,
  });

  final OfflineProgressSnapshot progress;
  final List<CurriculumTask> tasks;
  final Phase10TaskTap? onTaskTap;
  final String? fallbackSourceLanguageTag;
  final String? fallbackTargetLanguageTag;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return ListView.separated(
      key: const ValueKey<String>('phase10-tasks-track'),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
      itemCount: tasks.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _ProgressHeader(
            progress: progress,
            rtl: rtl,
            fallbackSourceLanguageTag: fallbackSourceLanguageTag,
            fallbackTargetLanguageTag: fallbackTargetLanguageTag,
          );
        }

        final task = tasks[index - 1];
        return _TaskProgressCard(
          task: task,
          progress: progress.tasks[task.id],
          rtl: rtl,
          onTap: onTaskTap == null ? null : () => onTaskTap!(task),
        );
      },
    );
  }
}

final class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.progress,
    required this.rtl,
    required this.fallbackSourceLanguageTag,
    required this.fallbackTargetLanguageTag,
  });

  final OfflineProgressSnapshot progress;
  final bool rtl;
  final String? fallbackSourceLanguageTag;
  final String? fallbackTargetLanguageTag;

  @override
  Widget build(BuildContext context) {
    final storedPair = progress.activePair?.replaceAll('->', ' → ');
    final fallbackSource = fallbackSourceLanguageTag?.trim();
    final fallbackTarget = fallbackTargetLanguageTag?.trim();
    final fallbackPair = fallbackSource != null &&
            fallbackSource.isNotEmpty &&
            fallbackTarget != null &&
            fallbackTarget.isNotEmpty
        ? '$fallbackSource → $fallbackTarget'
        : '— → —';
    final pair = storedPair ?? fallbackPair;
    final title = rtl ? 'مسار التعلّم' : 'Learning Track';
    final completedLabel = rtl ? 'مكتمل' : 'completed';
    final masteredLabel = rtl ? 'متقن' : 'mastered';

    return AppGlassCard(
      key: const ValueKey<String>('phase10-track-header'),
      glowColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            pair,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _MetricChip(
                icon: Icons.task_alt_rounded,
                label: '${progress.completedTasks}/50 $completedLabel',
              ),
              _MetricChip(
                icon: Icons.workspace_premium_rounded,
                label: '${progress.masteredTasks}/50 $masteredLabel',
              ),
              _MetricChip(
                icon: Icons.bolt_rounded,
                label: '${progress.totalPoints} pts',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Chip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        visualDensity: VisualDensity.compact,
      );
}

final class _TaskProgressCard extends StatelessWidget {
  const _TaskProgressCard({
    required this.task,
    required this.progress,
    required this.rtl,
    required this.onTap,
  });

  final CurriculumTask task;
  final OfflineTaskProgress? progress;
  final bool rtl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final state = progress?.mastery ?? TaskMasteryStatus.notStarted;
    final title = rtl ? task.titleAr : task.titleDe;
    final stage = task.stage.code;
    final points = progress?.points ?? 0;
    final score = progress?.bestScore ?? 0;
    final color = _masteryColor(context, state);

    return Card(
      key: ValueKey<String>('phase10-task-${task.id}'),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: color.withAlpha(36),
                foregroundColor: color,
                child: Text('${task.order}'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$stage • ${task.skill} • '
                      '${(score * 100).round()}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  _MasteryBadge(
                    key: ValueKey<String>('phase10-mastery-${task.id}'),
                    state: state,
                    rtl: rtl,
                    color: color,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$points pts',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _masteryColor(
    BuildContext context,
    TaskMasteryStatus state,
  ) =>
      switch (state) {
        TaskMasteryStatus.mastered => AppColors.mastery,
        TaskMasteryStatus.learning => AppColors.primary,
        TaskMasteryStatus.notStarted =>
          Theme.of(context).colorScheme.outline,
      };
}

final class _MasteryBadge extends StatelessWidget {
  const _MasteryBadge({
    required this.state,
    required this.rtl,
    required this.color,
    super.key,
  });

  final TaskMasteryStatus state;
  final bool rtl;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = switch ((state, rtl)) {
      (TaskMasteryStatus.mastered, true) => 'متقن',
      (TaskMasteryStatus.mastered, false) => 'Mastered',
      (TaskMasteryStatus.learning, true) => 'قيد التعلّم',
      (TaskMasteryStatus.learning, false) => 'Learning',
      (TaskMasteryStatus.notStarted, true) => 'لم يبدأ',
      (TaskMasteryStatus.notStarted, false) => 'Not started',
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(110)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}
