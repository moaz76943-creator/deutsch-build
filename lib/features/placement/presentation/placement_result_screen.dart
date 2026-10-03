import 'package:flutter/material.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart';
import '../domain/placement_models.dart';

class PlacementResultScreen extends StatelessWidget {
  const PlacementResultScreen({
    required this.result,
    required this.onStartLearning,
    this.isApplyingResult = false,
    super.key,
  });

  final PlacementResult result;
  final VoidCallback onStartLearning;
  final bool isApplyingResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('نتيجة تحديد المستوى')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: <Widget>[
            AppGlassCard(
              glowColor: AppColors.mastery,
              borderColor: AppColors.mastery.withAlpha(90),
              child: Column(
                children: <Widget>[
                  const Icon(
                    Icons.workspace_premium_rounded,
                    size: 52,
                    color: AppColors.mastery,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'المستوى المقترح',
                    style: AppTypography.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    result.level.label,
                    style: AppTypography.display.copyWith(
                      color: AppColors.mastery,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'درجة الكفاءة: ${result.proficiencyScore.round()}%',
                    style: AppTypography.title,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ثقة التقدير: ${(result.confidence * 100).round()}%',
                    style: AppTypography.label,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppGlassCard(
              glowColor: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text('التوصيات', style: AppTypography.title),
                  const SizedBox(height: 10),
                  for (final recommendation in result.recommendations)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Icon(
                              Icons.check_circle_outline_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              recommendation,
                              textDirection: TextDirection.rtl,
                              style: AppTypography.body,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppGlassCard(
              glowColor: AppColors.secondary,
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.autorenew_rounded,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'بدأت تهيئة SRS بفاصل أولي ${result.initialReviewIntervalDays} يوم '
                      'للعناصر التي احتاجت مراجعة.',
                      textDirection: TextDirection.rtl,
                      style: AppTypography.body,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: isApplyingResult ? null : onStartLearning,
              icon: isApplyingResult
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(
                isApplyingResult ? 'جاري حفظ النتيجة…' : 'ابدأ التعلم الآن',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
