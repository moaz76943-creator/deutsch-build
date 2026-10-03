import 'package:flutter/material.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart';
import '../application/error_pattern_notifier.dart';
import '../domain/error_pattern_models.dart';

class BlindSpotRadarView extends StatelessWidget {
  const BlindSpotRadarView({
    required this.notifier,
    super.key,
  });

  final ErrorPatternNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: notifier,
      builder: (context, _) {
        final summary = notifier.summary;
        final loading = notifier.state == ErrorPatternState.loading;

        return AppGlassCard(
          blur: 22,
          opacity: .14,
          borderColor: _accent(summary?.topCategory).withAlpha(82),
          glowColor: _accent(summary?.topCategory),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.radar_rounded,
                    color: _accent(summary?.topCategory),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'النقاط العمياء الأكثر تكرارًا',
                      style: AppTypography.title,
                    ),
                  ),
                  if (loading)
                    const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (summary == null)
                Text(
                  loading
                      ? 'جاري تحليل نمط الأخطاء...'
                      : 'لا توجد بيانات كافية بعد. سيظهر النمط المتكرر هنا بعد تسجيل الأخطاء.',
                  style: AppTypography.body,
                )
              else ...<Widget>[
                _CategoryHeader(summary: summary),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (summary.frequencyPercentage / 100)
                      .clamp(0.0, 1.0)
                      .toDouble(),
                  minHeight: 9,
                  borderRadius: BorderRadius.circular(999),
                  color: _accent(summary.topCategory),
                ),
                const SizedBox(height: 8),
                Text(
                  'يمثل هذا النمط ${summary.frequencyPercentage.toStringAsFixed(1)}% من الأخطاء المسجلة.',
                  style: AppTypography.label,
                ),
                const SizedBox(height: 14),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: _accent(summary.topCategory).withAlpha(16),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _accent(summary.topCategory).withAlpha(54),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: _accent(summary.topCategory),
                          size: 20,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            summary.adviceAr,
                            style: AppTypography.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _accent(ErrorCategory? category) => switch (category) {
        ErrorCategory.genderConfusion => AppColors.articleDie,
        ErrorCategory.caseMismatch => AppColors.articleDer,
        ErrorCategory.wordOrderDrift => AppColors.primary,
        ErrorCategory.prepositionError => AppColors.articleDas,
        null => AppColors.secondary,
      };
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.summary});

  final BlindSpotSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 10,
          height: 34,
          decoration: BoxDecoration(
            color: _color(summary.topCategory),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            _label(summary.topCategory),
            style: AppTypography.title.copyWith(
              color: _color(summary.topCategory),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          '${summary.frequencyPercentage.toStringAsFixed(1)}%',
          textDirection: TextDirection.ltr,
          style: AppTypography.title.copyWith(
            color: _color(summary.topCategory),
          ),
        ),
      ],
    );
  }

  String _label(ErrorCategory category) => switch (category) {
        ErrorCategory.genderConfusion => 'التباس أدوات الأسماء',
        ErrorCategory.caseMismatch => 'أخطاء الحالة الإعرابية',
        ErrorCategory.wordOrderDrift => 'انحراف ترتيب الكلمات',
        ErrorCategory.prepositionError => 'أخطاء حروف الجر',
      };

  Color _color(ErrorCategory category) => switch (category) {
        ErrorCategory.genderConfusion => AppColors.articleDie,
        ErrorCategory.caseMismatch => AppColors.articleDer,
        ErrorCategory.wordOrderDrift => AppColors.primary,
        ErrorCategory.prepositionError => AppColors.articleDas,
      };
}
