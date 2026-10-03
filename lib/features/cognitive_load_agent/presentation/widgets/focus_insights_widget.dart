import 'package:flutter/material.dart';

import '../../../../design_system/app_colors.dart';
import '../../../../design_system/app_glass_card.dart';
import '../../../../design_system/app_typography.dart';
import '../../application/cognitive_load_agent_notifier.dart';
import '../../domain/cognitive_load_models.dart';

class FocusInsightsWidget extends StatelessWidget {
  const FocusInsightsWidget({
    required this.state,
    super.key,
  });

  final CognitiveLoadAgentState state;

  @override
  Widget build(BuildContext context) {
    final visual = _visualFor(state.cognitiveState);
    final focusPercent = (state.focusIndex * 100).round();
    final pacePercent = (state.comprehensionPace * 100).round();

    return AppGlassCard(
      blur: 20,
      opacity: .13,
      borderColor: visual.color.withAlpha(76),
      glowColor: visual.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(visual.icon, color: visual.color),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'مؤشرات التركيز أثناء الجلسة',
                  style: AppTypography.title,
                ),
              ),
              Text(
                visual.label,
                style: AppTypography.label.copyWith(
                  color: visual.color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InsightMeter(
            label: 'التركيز',
            value: state.focusIndex,
            percent: focusPercent,
            color: visual.color,
          ),
          const SizedBox(height: 12),
          _InsightMeter(
            label: 'سرعة الاستيعاب',
            value: state.comprehensionPace,
            percent: pacePercent,
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),
          Text(
            state.samples == 0
                ? 'تظهر المؤشرات بعد بدء التفاعل مع التمارين.'
                : 'محسوبة من آخر ${state.samples} تفاعلات في هذه الجلسة.',
            style: AppTypography.label,
          ),
        ],
      ),
    );
  }

  _FocusVisual _visualFor(CognitiveState value) => switch (value) {
        CognitiveState.optimal => const _FocusVisual(
            label: 'مستقر',
            icon: Icons.center_focus_strong_rounded,
            color: AppColors.mastery,
          ),
        CognitiveState.fatigue => const _FocusVisual(
            label: 'يحتاج تخفيفًا',
            icon: Icons.speed_rounded,
            color: AppColors.secondary,
          ),
        CognitiveState.overwhelmed => const _FocusVisual(
            label: 'وتيرة مرتفعة',
            icon: Icons.hourglass_bottom_rounded,
            color: AppColors.tertiary,
          ),
      };
}

class _InsightMeter extends StatelessWidget {
  const _InsightMeter({
    required this.label,
    required this.value,
    required this.percent,
    required this.color,
  });

  final String label;
  final double value;
  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(label, style: AppTypography.label),
            ),
            Text(
              '$percent%',
              textDirection: TextDirection.ltr,
              style: AppTypography.label.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: value.clamp(0.0, 1.0).toDouble(),
          minHeight: 7,
          borderRadius: BorderRadius.circular(8),
          color: color,
        ),
      ],
    );
  }
}

final class _FocusVisual {
  const _FocusVisual({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}
