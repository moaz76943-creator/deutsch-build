import 'package:flutter/material.dart';

import '../../../../design_system/app_colors.dart';
import '../../../../design_system/app_glass_card.dart';
import '../../../../design_system/app_typography.dart';
import '../../domain/cognitive_load_models.dart';

class SmartPacingToast extends StatelessWidget {
  const SmartPacingToast({
    required this.recommendation,
    this.onHint,
    this.onBreak,
    super.key,
  });

  final PacingRecommendation recommendation;
  final VoidCallback? onHint;
  final VoidCallback? onBreak;

  @override
  Widget build(BuildContext context) {
    if (recommendation.action == PacingAction.keepPace) {
      return const SizedBox.shrink();
    }

    final accent = recommendation.suggestShortBreak
        ? AppColors.tertiary
        : AppColors.secondary;
    final icon = recommendation.suggestShortBreak
        ? Icons.pause_circle_outline_rounded
        : Icons.lightbulb_outline_rounded;

    return Semantics(
      liveRegion: true,
      child: AppGlassCard(
        blur: 20,
        opacity: .14,
        borderColor: accent.withAlpha(84),
        glowColor: accent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: accent, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    recommendation.suggestShortBreak
                        ? 'اقتراح وتيرة'
                        : 'مساعدة ذكية',
                    style: AppTypography.label.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recommendation.messageAr,
                    style: AppTypography.body,
                  ),
                  if (recommendation.showSupportHint && onHint != null) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: onHint,
                      icon: const Icon(Icons.lightbulb_outline_rounded),
                      label: const Text('أظهر تلميحًا'),
                    ),
                  ],
                  if (recommendation.suggestShortBreak &&
                      onBreak != null) ...[
                    const SizedBox(height: 4),
                    OutlinedButton.icon(
                      onPressed: onBreak,
                      icon: const Icon(Icons.timer_outlined),
                      label: const Text('وقفة قصيرة'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
