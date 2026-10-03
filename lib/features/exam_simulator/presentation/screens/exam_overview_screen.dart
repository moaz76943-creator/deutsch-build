import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/exam_models.dart';

final class ExamOverviewScreen extends StatelessWidget {
  const ExamOverviewScreen({
    required this.exam,
    required this.onStart,
    super.key,
  });

  final ExamDefinition exam;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background =
        dark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text('اختبار ${exam.level.label}', style: AppTypography.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: <Widget>[
          AppGlassCard(
            glowColor: AppColors.primary,
            borderColor:
                dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
            backgroundColor:
                dark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(exam.title, style: AppTypography.title),
                const SizedBox(height: 10),
                Text(
                  'تدريب معياري مستقل يحاكي مهارات CEFR للمستوى '
                  '${exam.level.label} دون استخدام مواد امتحانات محمية.',
                  style: AppTypography.body,
                ),
                const SizedBox(height: 14),
                _OverviewFact(
                  icon: Icons.timer_outlined,
                  label: '${exam.duration.inMinutes} دقيقة',
                ),
                const SizedBox(height: 8),
                _OverviewFact(
                  icon: Icons.quiz_outlined,
                  label: '${exam.questions.length} أسئلة',
                ),
                const SizedBox(height: 8),
                const _OverviewFact(
                  icon: Icons.verified_outlined,
                  label: 'حد النجاح في هذه المحاكاة: 60 / 100',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (final section in ExamSection.values) ...<Widget>[
            AppGlassCard(
              borderColor:
                  dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
              backgroundColor:
                  dark ? AppColors.darkSurface : AppColors.lightSurface,
              child: Row(
                children: <Widget>[
                  Icon(
                    _sectionIcon(section),
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      section.label,
                      style: AppTypography.title.copyWith(fontSize: 17),
                    ),
                  ),
                  Text(
                    '${exam.questions.where((q) => q.section == section).length}',
                    style: AppTypography.label,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          AppGlassCard(
            borderColor:
                dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
            backgroundColor:
                dark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Text(
              'Independent practice tool aligned with CEFR standards. '
              'This app is not an official examination provider.',
              style: AppTypography.body,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('بدء الاختبار'),
          ),
        ],
      ),
    );
  }

  static IconData _sectionIcon(ExamSection section) => switch (section) {
        ExamSection.lesen => Icons.menu_book_outlined,
        ExamSection.hoeren => Icons.headphones_outlined,
        ExamSection.schreiben => Icons.edit_note_outlined,
      };
}

final class _OverviewFact extends StatelessWidget {
  const _OverviewFact({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 19, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body,
          ),
        ),
      ],
    );
  }
}
