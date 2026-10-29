import 'package:flutter/material.dart';

import '../../../../design_system/app_colors.dart';
import '../../../../design_system/app_glass_card.dart';
import '../../../../design_system/app_typography.dart';
import '../../domain/daily_drill_models.dart';

class DrillCompletionSummaryWidget extends StatelessWidget {
  const DrillCompletionSummaryWidget({
    required this.summary,
    this.onDone,
    super.key,
  });

  final DrillResultSummary summary;
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    final percent = (summary.accuracy * 100).round();

    return AppGlassCard(
      glowColor: AppColors.mastery,
      borderColor: AppColors.mastery.withAlpha(100),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.auto_awesome_rounded,
            size: 42,
            color: AppColors.mastery,
          ),
          const SizedBox(height: 10),
          Text(
            summary.reviewedCards == 0
                ? 'لا توجد بطاقات مستحقة الآن'
                : 'اكتملت مراجعة اليوم',
            textAlign: TextAlign.center,
            style: AppTypography.title,
          ),
          const SizedBox(height: 18),
          _AccuracyRing(percent: percent),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _MetricChip(
                icon: Icons.check_circle_outline_rounded,
                label: 'صحيح',
                value:
                    '${summary.correctCards}/${summary.reviewedCards}',
                color: AppColors.mastery,
              ),
              _MetricChip(
                icon: Icons.timer_outlined,
                label: 'المعدل',
                value:
                    '${summary.averageSecondsPerCard.toStringAsFixed(1)} ث',
                color: AppColors.primary,
              ),
              _MetricChip(
                icon: Icons.local_fire_department_rounded,
                label: 'السلسلة',
                value: '${summary.currentStreak} يوم',
                color: AppColors.streak,
              ),
              _MetricChip(
                icon: Icons.bolt_rounded,
                label: 'XP',
                value: '+${summary.sessionXp}',
                color: AppColors.xp,
              ),
            ],
          ),
          if (onDone != null) ...<Widget>[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onDone,
              icon: const Icon(Icons.done_rounded),
              label: const Text('تم'),
            ),
          ],
        ],
      ),
    );
  }
}

class _AccuracyRing extends StatelessWidget {
  const _AccuracyRing({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final safe = percent.clamp(0, 100);
    return SizedBox.square(
      dimension: 112,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CircularProgressIndicator(
            value: safe / 100,
            strokeWidth: 9,
            color: AppColors.mastery,
            backgroundColor: AppColors.mastery.withAlpha(28),
          ),
          Center(
            child: Text(
              '$safe%',
              style: AppTypography.title.copyWith(
                color: AppColors.mastery,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 6),
            Text(
              '$label: $value',
              style: AppTypography.label.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
