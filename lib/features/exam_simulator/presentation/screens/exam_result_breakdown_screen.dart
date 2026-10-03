import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/exam_models.dart';

final class ExamResultBreakdownScreen extends StatelessWidget {
  const ExamResultBreakdownScreen({
    required this.report,
    super.key,
  });

  final ExamScoreReport report;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final scoreColor =
        report.passed ? AppColors.mastery : AppColors.tertiary;

    return Scaffold(
      backgroundColor:
          dark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('نتيجة المحاكاة', style: AppTypography.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: <Widget>[
          AppGlassCard(
            glowColor: scoreColor,
            borderColor:
                dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
            backgroundColor:
                dark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Column(
              children: <Widget>[
                Text(
                  '${report.totalScore} / 100',
                  style: AppTypography.display.copyWith(color: scoreColor),
                ),
                const SizedBox(height: 6),
                Text(
                  report.passed
                      ? 'اجتاز حد هذه المحاكاة'
                      : 'أقل من حد هذه المحاكاة',
                  style: AppTypography.title,
                ),
                const SizedBox(height: 6),
                Text(
                  'CEFR ${report.level.label} • الحد ${report.passThreshold}%',
                  style: AppTypography.label,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (final section in ExamSection.values) ...<Widget>[
            _SectionScoreCard(
              score: report.sections[section]!,
              dark: dark,
            ),
            const SizedBox(height: 10),
          ],
          AppGlassCard(
            borderColor:
                dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
            backgroundColor:
                dark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Text(
              'النتيجة خاصة بأداة تدريب مستقلة متوافقة مع مهارات CEFR '
              'ولا تمثل شهادة أو نتيجة امتحان رسمي.',
              style: AppTypography.body,
            ),
          ),
        ],
      ),
    );
  }
}

final class _SectionScoreCard extends StatelessWidget {
  const _SectionScoreCard({
    required this.score,
    required this.dark,
  });

  final ExamSectionScore score;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      borderColor:
          dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  score.section.label,
                  style: AppTypography.title.copyWith(fontSize: 17),
                ),
              ),
              Text(
                '${score.earnedPoints}/${score.possiblePoints}',
                style: AppTypography.label,
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: score.percentage / 100,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 6),
          Text('${score.percentage}%', style: AppTypography.label),
        ],
      ),
    );
  }
}
