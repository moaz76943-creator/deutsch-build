import 'package:flutter/material.dart';

import '../../../../design_system/app_colors.dart';
import '../../../../design_system/app_glass_card.dart';
import '../../../../design_system/app_typography.dart';
import '../../application/sync_coordinator_notifier.dart';
import '../../domain/sync_models.dart';

class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({
    required this.state,
    this.onTap,
    super.key,
  });

  final SyncCoordinatorState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final visual = _visualFor(state.status);
    final pending = state.pendingCount;

    return AppGlassCard(
      onTap: onTap,
      blur: 14,
      opacity: .10,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      borderRadius: 20,
      borderColor: visual.color.withAlpha(76),
      glowColor: visual.color,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (state.status == SyncStatus.syncing)
            SizedBox.square(
              dimension: 15,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: visual.color,
              ),
            )
          else
            Icon(visual.icon, size: 16, color: visual.color),
          const SizedBox(width: 7),
          Text(
            pending > 0 ? '${visual.label} · $pending' : visual.label,
            style: AppTypography.label.copyWith(
              color: visual.color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  _SyncVisual _visualFor(SyncStatus status) => switch (status) {
        SyncStatus.upToDate => const _SyncVisual(
            label: 'متزامن',
            icon: Icons.cloud_done_outlined,
            color: AppColors.mastery,
          ),
        SyncStatus.syncing => const _SyncVisual(
            label: 'قيد المزامنة',
            icon: Icons.sync_rounded,
            color: AppColors.primary,
          ),
        SyncStatus.offline => const _SyncVisual(
            label: 'غير متصل',
            icon: Icons.cloud_off_outlined,
            color: AppColors.tertiary,
          ),
        SyncStatus.conflictDetected => const _SyncVisual(
            label: 'تعارض',
            icon: Icons.compare_arrows_rounded,
            color: AppColors.articleDie,
          ),
      };
}

final class _SyncVisual {
  const _SyncVisual({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}
