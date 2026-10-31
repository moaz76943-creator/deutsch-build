import 'dart:async';

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../application/adjective_declension_notifier.dart';
import '../domain/adjective_declension_models.dart';

final class AdjectiveDeclensionScreen extends StatefulWidget {
  const AdjectiveDeclensionScreen({
    required this.notifier,
    super.key,
  });

  final AdjectiveDeclensionNotifier notifier;

  @override
  State<AdjectiveDeclensionScreen> createState() =>
      _AdjectiveDeclensionScreenState();
}

final class _AdjectiveDeclensionScreenState
    extends State<AdjectiveDeclensionScreen> {
  static const List<String> _endingOptions = <String>[
    '-e',
    '-en',
    '-er',
    '-es',
    '-em',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.notifier.currentExercise == null &&
        !widget.notifier.isLoading) {
      unawaited(widget.notifier.load());
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('نهايات الصفات · Adjektivendungen'),
          ),
          body: ListenableBuilder(
            listenable: widget.notifier,
            builder: (context, _) {
              final notifier = widget.notifier;
              final exercise = notifier.currentExercise;

              if (notifier.isLoading && exercise == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (exercise == null) {
                return _EmptyState(
                  onRetry: () => unawaited(notifier.load()),
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
                children: <Widget>[
                  _ProgressHeader(notifier: notifier),
                  const SizedBox(height: 14),
                  _ExerciseCard(exercise: exercise),
                  const SizedBox(height: 14),
                  _EndingOptions(
                    notifier: notifier,
                    options: _endingOptions,
                  ),
                  if (notifier.showExplanation) ...<Widget>[
                    const SizedBox(height: 14),
                    _ExplanationCard(
                      exercise: exercise,
                      correct: notifier.isCorrect == true,
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: notifier.nextExercise,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('التمرين التالي'),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      );
}

final class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.notifier});

  final AdjectiveDeclensionNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final total = notifier.exercises.length;
    final position = total == 0 ? 0 : notifier.currentIndex + 1;

    return AppGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderColor: AppColors.primary.withAlpha(90),
      glowColor: AppColors.primary,
      child: Row(
        children: <Widget>[
          const Icon(Icons.school_outlined, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'اختر نهاية الصفة الصحيحة',
              style: AppTypography.title,
            ),
          ),
          Text(
            '$position / $total',
            textDirection: TextDirection.ltr,
            style: AppTypography.label.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

final class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise});

  final AdjectiveExerciseItem exercise;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.secondary.withAlpha(90),
        glowColor: AppColors.secondary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _GrammarBadge(
                  label: _declensionLabel(exercise.declensionType),
                  color: AppColors.primary,
                ),
                _GrammarBadge(
                  label: _caseLabel(exercise.grammaticalCase),
                  color: AppColors.secondary,
                ),
                _GrammarBadge(
                  label: _genderLabel(exercise.grammaticalGender),
                  color: AppColors.achievement,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              exercise.sentenceWithBlank,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'الصفة: ${exercise.baseAdjective}',
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              style: AppTypography.title.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      );

  static String _declensionLabel(DeclensionType type) => switch (type) {
        DeclensionType.weak => 'ضعيف · weak',
        DeclensionType.mixed => 'مختلط · mixed',
        DeclensionType.strong => 'قوي · strong',
      };

  static String _caseLabel(GrammaticalCase grammaticalCase) =>
      switch (grammaticalCase) {
        GrammaticalCase.nominativ => 'Nominativ',
        GrammaticalCase.akkusativ => 'Akkusativ',
        GrammaticalCase.dativ => 'Dativ',
        GrammaticalCase.genitiv => 'Genitiv',
      };

  static String _genderLabel(GrammaticalGender gender) => switch (gender) {
        GrammaticalGender.maskulin => 'مذكر',
        GrammaticalGender.feminin => 'مؤنث',
        GrammaticalGender.neutral => 'محايد',
        GrammaticalGender.plural => 'جمع',
      };
}

final class _EndingOptions extends StatelessWidget {
  const _EndingOptions({
    required this.notifier,
    required this.options,
  });

  final AdjectiveDeclensionNotifier notifier;
  final List<String> options;

  @override
  Widget build(BuildContext context) {
    final answered = notifier.showExplanation;
    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('اختر النهاية', style: AppTypography.title),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              for (final ending in options)
                _EndingChoiceCard(
                  ending: ending,
                  selected: notifier.selectedEnding == ending,
                  answered: answered,
                  correct: notifier.currentExercise?.correctEnding == ending,
                  onTap: answered
                      ? null
                      : () => unawaited(notifier.selectEnding(ending)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _EndingChoiceCard extends StatelessWidget {
  const _EndingChoiceCard({
    required this.ending,
    required this.selected,
    required this.answered,
    required this.correct,
    required this.onTap,
  });

  final String ending;
  final bool selected;
  final bool answered;
  final bool correct;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;
    final borderColor = answered && correct
        ? AppColors.mastery
        : answered && selected && !correct
            ? errorColor
            : selected
                ? AppColors.primary
                : Theme.of(context).dividerColor;
    final glowColor = selected || (answered && correct) ? borderColor : null;

    return SizedBox(
      width: 92,
      child: AppGlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        borderRadius: 20,
        borderColor: borderColor,
        glowColor: glowColor,
        child: Center(
          child: Text(
            ending,
            textDirection: TextDirection.ltr,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: borderColor,
                ),
          ),
        ),
      ),
    );
  }
}

final class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({
    required this.exercise,
    required this.correct,
  });

  final AdjectiveExerciseItem exercise;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;
    final color = correct ? AppColors.mastery : errorColor;

    return AppGlassCard(
      borderColor: color.withAlpha(120),
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                correct ? Icons.check_circle_outline : Icons.info_outline,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  correct ? 'إجابة صحيحة' : 'راجع القاعدة',
                  style: AppTypography.title.copyWith(color: color),
                ),
              ),
              Text(
                exercise.correctEnding,
                textDirection: TextDirection.ltr,
                style: AppTypography.title.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(exercise.explanationAr, style: AppTypography.body),
          const SizedBox(height: 10),
          Text(
            exercise.renderCompletedSentence(),
            textDirection: TextDirection.ltr,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

final class _GrammarBadge extends StatelessWidget {
  const _GrammarBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: color.withAlpha(22),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withAlpha(90)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(
            label,
            style: AppTypography.label.copyWith(color: color),
          ),
        ),
      );
}

final class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AppGlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.menu_book_outlined,
                  color: AppColors.primary,
                  size: 42,
                ),
                const SizedBox(height: 12),
                Text('لا توجد تمارين متاحة.', style: AppTypography.title),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('إعادة التحميل'),
                ),
              ],
            ),
          ),
        ),
      );
}
