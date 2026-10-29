import 'dart:async';

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../application/prefix_notifier.dart';
import '../domain/prefix_models.dart';

final class PrefixArenaScreen extends StatefulWidget {
  const PrefixArenaScreen({
    required this.notifier,
    super.key,
  });

  final PrefixNotifier notifier;

  @override
  State<PrefixArenaScreen> createState() => _PrefixArenaScreenState();
}

final class _PrefixArenaScreenState extends State<PrefixArenaScreen> {
  late final TextEditingController _answerController;

  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
    if (widget.notifier.drills.isEmpty && !widget.notifier.isLoading) {
      unawaited(widget.notifier.load());
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'ساحة سوابق الأفعال · Präfix-Arena',
              textDirection: TextDirection.rtl,
            ),
          ),
          body: SafeArea(
            child: ListenableBuilder(
              listenable: widget.notifier,
              builder: (context, _) {
                final notifier = widget.notifier;
                final drill = notifier.currentDrill;

                if (notifier.isLoading && drill == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (drill == null) {
                  return _EmptyState(
                    onRetry: () => unawaited(notifier.load()),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _ClassSelector(
                        notifier: notifier,
                        onChanged: _clearInput,
                      ),
                      const SizedBox(height: 14),
                      _ProgressCard(notifier: notifier),
                      const SizedBox(height: 14),
                      _VerbMapCard(drill: drill),
                      const SizedBox(height: 14),
                      _ExerciseCard(
                        drill: drill,
                        controller: _answerController,
                        notifier: notifier,
                      ),
                      if (notifier.showExplanation) ...<Widget>[
                        const SizedBox(height: 14),
                        _FeedbackCard(
                          drill: drill,
                          correct: notifier.isCorrect == true,
                          feedbackAr: notifier.feedbackAr,
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          onPressed: () {
                            notifier.nextDrill();
                            _clearInput();
                          },
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text(
                            'التمرين التالي',
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

  void _clearInput() {
    _answerController.clear();
  }
}

final class _ClassSelector extends StatelessWidget {
  const _ClassSelector({
    required this.notifier,
    required this.onChanged,
  });

  final PrefixNotifier notifier;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.primary,
        borderColor: AppColors.primary.withAlpha(90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'اختر نوع السابقة',
              textDirection: TextDirection.rtl,
              style: AppTypography.title,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: <Widget>[
                ChoiceChip(
                  label: const Text(
                    'Alle',
                    textDirection: TextDirection.ltr,
                  ),
                  selected: notifier.activeClass == null,
                  selectedColor: AppColors.primary.withAlpha(34),
                  side: BorderSide(
                    color: notifier.activeClass == null
                        ? AppColors.primary
                        : Theme.of(context).dividerColor,
                  ),
                  onSelected: (_) {
                    onChanged();
                    unawaited(notifier.showAllClasses());
                  },
                ),
                for (final verbClass in VerbPrefixClass.values)
                  ChoiceChip(
                    label: Text(
                      _classLabel(verbClass),
                      textDirection: TextDirection.ltr,
                    ),
                    selected: notifier.activeClass == verbClass,
                    selectedColor: AppColors.primary.withAlpha(34),
                    side: BorderSide(
                      color: notifier.activeClass == verbClass
                          ? AppColors.primary
                          : Theme.of(context).dividerColor,
                    ),
                    onSelected: (_) {
                      onChanged();
                      unawaited(notifier.switchVerbClass(verbClass));
                    },
                  ),
              ],
            ),
          ],
        ),
      );

  static String _classLabel(VerbPrefixClass value) => switch (value) {
        VerbPrefixClass.trennbar => 'Trennbar',
        VerbPrefixClass.untrennbar => 'Untrennbar',
        VerbPrefixClass.doppeldeutig => 'Doppeldeutig',
      };
}

final class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.notifier});

  final PrefixNotifier notifier;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.secondary.withAlpha(84),
        glowColor: AppColors.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.route_outlined,
              color: AppColors.secondary,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                'ابنِ الجملة حسب معنى السابقة',
                textDirection: TextDirection.rtl,
                style: AppTypography.title,
              ),
            ),
            Text(
              (notifier.currentIndex + 1).toString() +
                  ' / ' +
                  notifier.drills.length.toString(),
              textDirection: TextDirection.ltr,
              style: AppTypography.label.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
}

final class _VerbMapCard extends StatelessWidget {
  const _VerbMapCard({required this.drill});

  final PrefixDrillItem drill;

  @override
  Widget build(BuildContext context) {
    final accent = _contextColor(drill.context);

    return AppGlassCard(
      borderColor: accent.withAlpha(90),
      glowColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _Badge(
                label: drill.classLabelDe,
                color: AppColors.primary,
              ),
              _Badge(
                label: drill.contextLabelAr,
                color: accent,
                rtl: true,
              ),
              _Badge(
                label: drill.isSeparableInContext
                    ? 'trennbar im Kontext'
                    : 'nicht trennbar im Kontext',
                color: AppColors.achievement,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            drill.infinitive,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 10),
          _PrefixDiagram(drill: drill),
          const SizedBox(height: 12),
          Text(
            'Partizip II: ' + drill.partizipII,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: AppTypography.title.copyWith(
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  static Color _contextColor(PrefixContext context) => switch (context) {
        PrefixContext.travel => AppColors.tertiary,
        PrefixContext.technology => AppColors.secondary,
        PrefixContext.literature => AppColors.achievement,
        PrefixContext.engineering => AppColors.primary,
      };
}

final class _PrefixDiagram extends StatelessWidget {
  const _PrefixDiagram({required this.drill});

  final PrefixDrillItem drill;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Expanded(
            child: _TokenBox(
              title: 'Präfix',
              value: drill.prefix,
              color: AppColors.tertiary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              drill.isSeparableInContext
                  ? Icons.call_split_rounded
                  : Icons.link_rounded,
              color: AppColors.primary,
            ),
          ),
          Expanded(
            child: _TokenBox(
              title: 'Stamm',
              value: drill.stem,
              color: AppColors.secondary,
            ),
          ),
        ],
      );
}

final class _TokenBox extends StatelessWidget {
  const _TokenBox({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: color.withAlpha(18),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withAlpha(86)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: <Widget>[
              Text(
                title,
                textDirection: TextDirection.ltr,
                style: AppTypography.label.copyWith(color: color),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                textDirection: TextDirection.ltr,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
        ),
      );
}

final class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.drill,
    required this.controller,
    required this.notifier,
  });

  final PrefixDrillItem drill;
  final TextEditingController controller;
  final PrefixNotifier notifier;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.glassBorderLight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'أكمل الجملة',
              textDirection: TextDirection.rtl,
              style: AppTypography.title,
            ),
            const SizedBox(height: 10),
            Text(
              drill.sentencePrompt,
              textDirection: TextDirection.ltr,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              drill.translationAr,
              textDirection: TextDirection.rtl,
              style: AppTypography.body,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              enabled: !notifier.showExplanation,
              textDirection: TextDirection.ltr,
              textCapitalization: TextCapitalization.sentences,
              onChanged: notifier.updateAnswer,
              onSubmitted: notifier.showExplanation
                  ? null
                  : (value) => unawaited(notifier.checkAnswer(value)),
              decoration: InputDecoration(
                labelText: 'Deutscher Satz',
                hintText: drill.sentencePrompt,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: notifier.canCheck
                  ? () => unawaited(
                        notifier.checkAnswer(controller.text),
                      )
                  : null,
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text(
                'تحقق',
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
      );
}

final class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.drill,
    required this.correct,
    required this.feedbackAr,
  });

  final PrefixDrillItem drill;
  final bool correct;
  final String feedbackAr;

  @override
  Widget build(BuildContext context) {
    final accent = correct ? AppColors.mastery : AppColors.articleDie;

    return AppGlassCard(
      borderColor: accent.withAlpha(105),
      glowColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                correct
                    ? Icons.check_circle_outline_rounded
                    : Icons.info_outline_rounded,
                color: accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  feedbackAr,
                  textDirection: TextDirection.rtl,
                  style: AppTypography.body.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            drill.correctSentence,
            textDirection: TextDirection.ltr,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            drill.explanationAr,
            textDirection: TextDirection.rtl,
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}

final class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    this.rtl = false,
  });

  final String label;
  final Color color;
  final bool rtl;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: color.withAlpha(18),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withAlpha(82)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(
            label,
            textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
            style: AppTypography.label.copyWith(color: color),
          ),
        ),
      );
}

final class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: AppGlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.extension_outlined,
                color: AppColors.primary,
                size: 44,
              ),
              const SizedBox(height: 12),
              Text(
                'لا توجد تمارين سوابق متاحة.',
                textDirection: TextDirection.rtl,
                style: AppTypography.title,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: onRetry,
                child: const Text(
                  'إعادة التحميل',
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
        ),
      );
}
