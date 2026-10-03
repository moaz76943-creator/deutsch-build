import 'package:flutter/material.dart';

import '../../../../design_system/app_colors.dart';
import '../../../../design_system/app_glass_card.dart';
import '../../../../design_system/app_typography.dart';
import '../../domain/sync_models.dart';

class SyncConflictResolutionSheet extends StatelessWidget {
  const SyncConflictResolutionSheet({
    required this.conflict,
    required this.onResolve,
    super.key,
  });

  final SyncConflict conflict;
  final ValueChanged<SyncConflictResolutionStrategy> onResolve;

  @override
  Widget build(BuildContext context) {
    final local = conflict.local;
    final remote = conflict.remote;
    final newerIsRemote = remote.updatedAtUtc.isAfter(local.updatedAtUtc);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: AppGlassCard(
          blur: 24,
          opacity: .16,
          borderColor: AppColors.primary.withAlpha(82),
          glowColor: AppColors.primary,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.compare_arrows_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'يوجد تعارض في التقدم',
                      style: AppTypography.title,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'لم يتم حذف أي نسخة. يمكنك اعتماد الأحدث مع حماية أعلى Streak، '
                'أو دمج تقدم SRS والإنجازات.',
                style: AppTypography.body,
              ),
              const SizedBox(height: 16),
              _ConflictSnapshotRow(
                title: 'المحلي',
                snapshot: local,
                highlighted: !newerIsRemote,
              ),
              const SizedBox(height: 8),
              _ConflictSnapshotRow(
                title: 'السحابي',
                snapshot: remote,
                highlighted: newerIsRemote,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => onResolve(
                  SyncConflictResolutionStrategy
                      .lastWriteWinsProtectHigherStreak,
                ),
                icon: const Icon(Icons.schedule_rounded),
                label: const Text('اعتماد النسخة الأحدث'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => onResolve(
                  SyncConflictResolutionStrategy.mergeProgress,
                ),
                icon: const Icon(Icons.merge_type_rounded),
                label: const Text('دمج التقدم بأمان'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<T?> show<T>(
    BuildContext context, {
    required SyncConflict conflict,
    required ValueChanged<SyncConflictResolutionStrategy> onResolve,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(72),
      builder: (_) => SyncConflictResolutionSheet(
        conflict: conflict,
        onResolve: onResolve,
      ),
    );
  }
}

class _ConflictSnapshotRow extends StatelessWidget {
  const _ConflictSnapshotRow({
    required this.title,
    required this.snapshot,
    required this.highlighted,
  });

  final String title;
  final SyncProgressSnapshot snapshot;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? AppColors.primary : AppColors.secondary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withAlpha(16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(62)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 8,
          spacing: 12,
          children: <Widget>[
            Text(
              title,
              style: AppTypography.label.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'XP ${snapshot.totalXp}',
              style: AppTypography.label,
            ),
            Text(
              'Streak ${snapshot.currentStreak}',
              style: AppTypography.label,
            ),
            Text(
              'SRS ${snapshot.srs.length}',
              style: AppTypography.label,
            ),
            Text(
              'إنجازات ${snapshot.achievementIds.length}',
              style: AppTypography.label,
            ),
          ],
        ),
      ),
    );
  }
}
