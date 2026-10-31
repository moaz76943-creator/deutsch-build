import 'dart:async';

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../application/placement_notifier.dart';
import '../domain/placement_models.dart';

final class PlacementScreen extends StatefulWidget {
  const PlacementScreen({
    required this.notifier,
    super.key,
  });

  final PlacementNotifier notifier;

  @override
  State<PlacementScreen> createState() => _PlacementScreenState();
}

final class _PlacementScreenState extends State<PlacementScreen> {
  int? _selectedOptionIndex;

  PlacementNotifier get notifier => widget.notifier;

  @override
  void initState() {
    super.initState();
    notifier.addListener(_refresh);
    if (notifier.currentQuestion == null && !notifier.isCompleted) {
      unawaited(notifier.restartAssessment());
    }
  }

  @override
  void didUpdateWidget(covariant PlacementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifier == notifier) return;
    oldWidget.notifier.removeListener(_refresh);
    notifier.addListener(_refresh);
    _selectedOptionIndex = null;
  }

  @override
  void dispose() {
    notifier.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _submitSelected() async {
    final selected = _selectedOptionIndex;
    if (selected == null || notifier.isBusy) return;
    await notifier.submitAnswer(selected);
    if (!mounted) return;
    setState(() => _selectedOptionIndex = null);
  }

  Future<void> _restart() async {
    setState(() => _selectedOptionIndex = null);
    await notifier.restartAssessment();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface =
        dark ? AppColors.darkSurface : AppColors.lightSurface;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            dark ? AppColors.darkBackground : AppColors.lightBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _HeaderCard(
                  dark: dark,
                  surface: surface,
                  estimatedLevel: notifier.currentEstimatedLevel,
                ),
                const SizedBox(height: 12),
                _ProgressCard(
                  progress: notifier.progress,
                  answered: notifier.answers.length,
                  total: notifier.maxQuestions,
                  dark: dark,
                  surface: surface,
                ),
                const SizedBox(height: 14),
                if (notifier.isCompleted && notifier.result != null)
                  _ResultCard(
                    result: notifier.result!,
                    dark: dark,
                    surface: surface,
                    onRestart: () => unawaited(_restart()),
                  )
                else if (notifier.currentQuestion != null)
                  _QuestionSection(
                    question: notifier.currentQuestion!,
                    selectedOptionIndex: _selectedOptionIndex,
                    enabled: !notifier.isBusy,
                    dark: dark,
                    surface: surface,
                    onSelect: (index) {
                      setState(() => _selectedOptionIndex = index);
                    },
                    onSubmit: () => unawaited(_submitSelected()),
                  )
                else
                  _LoadingCard(
                    dark: dark,
                    surface: surface,
                    isBusy: notifier.isBusy,
                    onRetry: () =>
                        unawaited(notifier.restartAssessment()),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.dark,
    required this.surface,
    required this.estimatedLevel,
  });

  final bool dark;
  final Color surface;
  final CefrLevel estimatedLevel;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor:
            dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
        glowColor: AppColors.primary,
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.analytics_rounded,
              color: AppColors.primary,
              size: 34,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _ArabicText(
                    'اختبار تحديد المستوى التكيفي',
                    style: AppTypography.title,
                  ),
                  SizedBox(height: 3),
                  _ArabicText(
                    'A1 → B2 · قواعد · مفردات · قراءة · سياق عملي',
                    style: AppTypography.label,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _LevelBadge(level: estimatedLevel),
          ],
        ),
      );
}

final class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.progress,
    required this.answered,
    required this.total,
    required this.dark,
    required this.surface,
  });

  final double progress;
  final int answered;
  final int total;
  final bool dark;
  final Color surface;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor:
            dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: _ArabicText(
                    'الاقتراب من تثبيت المستوى',
                    style: AppTypography.label,
                  ),
                ),
                _ArabicText(
                  '$answered / $total',
                  style: AppTypography.label.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 9,
                backgroundColor: dark
                    ? AppColors.glassBorderDark
                    : AppColors.glassBorderLight,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      );
}

final class _QuestionSection extends StatelessWidget {
  const _QuestionSection({
    required this.question,
    required this.selectedOptionIndex,
    required this.enabled,
    required this.dark,
    required this.surface,
    required this.onSelect,
    required this.onSubmit,
  });

  final PlacementQuestionItem question;
  final int? selectedOptionIndex;
  final bool enabled;
  final bool dark;
  final Color surface;
  final ValueChanged<int> onSelect;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppGlassCard(
            backgroundColor: surface,
            borderColor: AppColors.tertiary.withAlpha(84),
            glowColor: AppColors.tertiary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _InfoTag(
                      text: question.targetLevel.label,
                      color: AppColors.primary,
                    ),
                    _InfoTag(
                      text: question.skill.arabicLabel,
                      color: AppColors.secondary,
                    ),
                    _InfoTag(
                      text:
                          'وزن ${question.difficultyWeight.toStringAsFixed(2)}',
                      color: AppColors.tertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _GermanText(
                  question.question,
                  style: AppTypography.title,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (var index = 0;
              index < question.options.length;
              index += 1) ...<Widget>[
            AppGlassCard(
              onTap: enabled ? () => onSelect(index) : null,
              backgroundColor: surface,
              borderColor: selectedOptionIndex == index
                  ? AppColors.primary
                  : (dark
                      ? AppColors.glassBorderDark
                      : AppColors.glassBorderLight),
              glowColor:
                  selectedOptionIndex == index ? AppColors.primary : null,
              child: Row(
                textDirection: TextDirection.ltr,
                children: <Widget>[
                  _OptionIndex(
                    index: index,
                    selected: selectedOptionIndex == index,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GermanText(
                      question.options[index],
                      style: AppTypography.body,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    selectedOptionIndex == index
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: selectedOptionIndex == index
                        ? AppColors.primary
                        : AppColors.glassBorderDark,
                  ),
                ],
              ),
            ),
            if (index != question.options.length - 1)
              const SizedBox(height: 8),
          ],
          const SizedBox(height: 14),
          AppGlassCard(
            onTap: enabled && selectedOptionIndex != null ? onSubmit : null,
            backgroundColor: surface,
            borderColor: selectedOptionIndex != null
                ? AppColors.mastery
                : AppColors.glassBorderDark,
            glowColor:
                selectedOptionIndex != null ? AppColors.mastery : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.check_circle_rounded,
                  color: selectedOptionIndex != null
                      ? AppColors.mastery
                      : AppColors.glassBorderDark,
                ),
                const SizedBox(width: 8),
                _ArabicText(
                  'تثبيت الإجابة',
                  style: AppTypography.title.copyWith(
                    color: selectedOptionIndex != null
                        ? AppColors.mastery
                        : AppColors.glassBorderDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

final class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.result,
    required this.dark,
    required this.surface,
    required this.onRestart,
  });

  final PlacementResult result;
  final bool dark;
  final Color surface;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppGlassCard(
            backgroundColor: surface,
            borderColor: AppColors.mastery,
            glowColor: AppColors.mastery,
            child: Column(
              children: <Widget>[
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.mastery,
                  size: 42,
                ),
                const SizedBox(height: 8),
                _ArabicText(
                  'المستوى المقدر',
                  style: AppTypography.label,
                ),
                const SizedBox(height: 4),
                _GermanText(
                  result.finalLevel.label,
                  style: AppTypography.display.copyWith(
                    color: AppColors.mastery,
                  ),
                ),
                const SizedBox(height: 6),
                _ArabicText(
                  'الدرجة المعيارية للمشروع: '
                  '${result.standardizedScore.toStringAsFixed(1)} / 100',
                  style: AppTypography.body,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppGlassCard(
            backgroundColor: surface,
            borderColor:
                dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _ArabicText(
                  'الدقة حسب المهارة',
                  style: AppTypography.title,
                ),
                const SizedBox(height: 10),
                for (final skill in AssessmentSkillCategory.values) ...<Widget>[
                  _SkillAccuracyRow(
                    skill: skill,
                    accuracy: result.skillAccuracy[skill] ?? 0,
                    dark: dark,
                  ),
                  if (skill != AssessmentSkillCategory.values.last)
                    const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppGlassCard(
            backgroundColor: surface,
            borderColor: AppColors.primary.withAlpha(84),
            glowColor: AppColors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _ArabicText(
                  'خطة التعلم المقترحة',
                  style: AppTypography.title,
                ),
                const SizedBox(height: 8),
                for (final recommendation in result.learningPlan)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: _ArabicText(
                            recommendation,
                            style: AppTypography.body,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppGlassCard(
            onTap: onRestart,
            backgroundColor: surface,
            borderColor: AppColors.secondary,
            glowColor: AppColors.secondary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.restart_alt_rounded,
                  color: AppColors.secondary,
                ),
                SizedBox(width: 8),
                _ArabicText(
                  'إعادة الاختبار',
                  style: AppTypography.title,
                ),
              ],
            ),
          ),
        ],
      );
}

final class _SkillAccuracyRow extends StatelessWidget {
  const _SkillAccuracyRow({
    required this.skill,
    required this.accuracy,
    required this.dark,
  });

  final AssessmentSkillCategory skill;
  final double accuracy;
  final bool dark;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _ArabicText(
                  skill.arabicLabel,
                  style: AppTypography.label,
                ),
              ),
              _ArabicText(
                '${(accuracy * 100).round()}%',
                style: AppTypography.label.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: accuracy,
              minHeight: 7,
              backgroundColor: dark
                  ? AppColors.glassBorderDark
                  : AppColors.glassBorderLight,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.secondary,
              ),
            ),
          ),
        ],
      );
}

final class _LoadingCard extends StatelessWidget {
  const _LoadingCard({
    required this.dark,
    required this.surface,
    required this.isBusy,
    required this.onRetry,
  });

  final bool dark;
  final Color surface;
  final bool isBusy;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        onTap: isBusy ? null : onRetry,
        backgroundColor: surface,
        borderColor:
            dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
        child: Column(
          children: <Widget>[
            if (isBusy)
              const CircularProgressIndicator(color: AppColors.primary)
            else
              const Icon(
                Icons.refresh_rounded,
                color: AppColors.primary,
                size: 34,
              ),
            const SizedBox(height: 10),
            _ArabicText(
              isBusy
                  ? 'يتم تجهيز السؤال التكيفي...'
                  : 'لا يوجد سؤال متاح. اضغط لإعادة المحاولة.',
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}

final class _InfoTag extends StatelessWidget {
  const _InfoTag({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: color.withAlpha(20),
          border: Border.all(color: color.withAlpha(72)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          child: _ArabicText(
            text,
            style: AppTypography.label.copyWith(color: color),
          ),
        ),
      );
}

final class _OptionIndex extends StatelessWidget {
  const _OptionIndex({
    required this.index,
    required this.selected,
  });

  final int index;
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (selected ? AppColors.primary : AppColors.secondary)
              .withAlpha(24),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.secondary,
          ),
        ),
        child: Text(
          '${index + 1}',
          textDirection: TextDirection.ltr,
          style: AppTypography.label.copyWith(
            color: selected ? AppColors.primary : AppColors.secondary,
          ),
        ),
      );
}

final class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});

  final CefrLevel level;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.primary.withAlpha(22),
          border: Border.all(color: AppColors.primary.withAlpha(82)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: _GermanText(
            level.label,
            style: AppTypography.title.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      );
}

final class _GermanText extends StatelessWidget {
  const _GermanText(
    this.text, {
    required this.style,
  }) : textAlign = null;

  final String text;
  final TextStyle style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          text,
          style: style,
          textAlign: textAlign,
        ),
      );
}

final class _ArabicText extends StatelessWidget {
  _ArabicText(
    this.text, {
    required this.style,
    this.textAlign,
  });

  final String text;
  final TextStyle style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          text,
          style: style,
          textAlign: textAlign,
        ),
      );
}
