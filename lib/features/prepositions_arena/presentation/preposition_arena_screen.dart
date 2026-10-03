import 'package:flutter/material.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart';
import '../application/preposition_arena_notifier.dart';
import '../domain/preposition_models.dart';
import 'widgets/drag_drop_case_card_widget.dart';

class PrepositionArenaScreen extends StatefulWidget {
  const PrepositionArenaScreen({
    required this.notifier,
    this.level,
    this.sessionLimit = 10,
    super.key,
  });

  final PrepositionArenaNotifier notifier;
  final String? level;
  final int sessionLimit;

  @override
  State<PrepositionArenaScreen> createState() =>
      _PrepositionArenaScreenState();
}

class _PrepositionArenaScreenState extends State<PrepositionArenaScreen> {
  @override
  void initState() {
    super.initState();
    widget.notifier.start(
      level: widget.level,
      limit: widget.sessionLimit,
    );
  }

  void _startType(PrepositionType type) {
    widget.notifier.start(
      type: type,
      level: widget.level,
      limit: widget.sessionLimit,
    );
  }

  void _submit(String answer) {
    final state = widget.notifier.state;
    if (state.hasAnsweredCurrent) return;
    widget.notifier.submit(answer);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.notifier,
      builder: (context, _) {
        final state = widget.notifier.state;
        return Scaffold(
          appBar: AppBar(
            title: const Text('ساحة حروف الجر والحالات'),
          ),
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  _CaseFilterRow(
                    selected: state.selectedType,
                    onSelected: _startType,
                  ),
                  const SizedBox(height: 14),
                  if (state.isCompleted)
                    _CompletionCard(
                      state: state,
                      onRestart: widget.notifier.restart,
                    )
                  else if (state.currentChallenge != null) ...<Widget>[
                    _ProgressCard(state: state),
                    const SizedBox(height: 14),
                    _ChallengePrompt(
                      challenge: state.currentChallenge!,
                    ),
                    const SizedBox(height: 14),
                    DragDropCaseCardWidget(
                      challenge: state.currentChallenge!,
                      selectedAnswer: state.lastResult?.selectedAnswer,
                      result: state.lastResult,
                      enabled: !state.hasAnsweredCurrent,
                      onSelected: _submit,
                    ),
                    if (state.lastResult != null) ...<Widget>[
                      const SizedBox(height: 14),
                      _AnswerExplanation(result: state.lastResult!),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: widget.notifier.next,
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('التالي'),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CaseFilterRow extends StatelessWidget {
  const _CaseFilterRow({
    required this.selected,
    required this.onSelected,
  });

  final PrepositionType? selected;
  final ValueChanged<PrepositionType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        _FilterChipCard(
          label: 'Akkusativ',
          selected: selected == PrepositionType.accusative,
          color: AppColors.articleDer,
          onTap: () => onSelected(PrepositionType.accusative),
        ),
        _FilterChipCard(
          label: 'Dativ',
          selected: selected == PrepositionType.dative,
          color: AppColors.articleDie,
          onTap: () => onSelected(PrepositionType.dative),
        ),
        _FilterChipCard(
          label: 'Two-way',
          selected: selected == PrepositionType.twoWay,
          color: AppColors.articleDas,
          onTap: () => onSelected(PrepositionType.twoWay),
        ),
      ],
    );
  }
}

class _FilterChipCard extends StatelessWidget {
  const _FilterChipCard({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      onTap: onTap,
      blur: 14,
      opacity: selected ? .18 : .09,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      borderRadius: 20,
      borderColor: color.withAlpha(selected ? 130 : 58),
      glowColor: selected ? color : null,
      child: Text(
        label,
        textDirection: TextDirection.ltr,
        style: AppTypography.label.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.state});

  final PrepositionArenaState state;

  @override
  Widget build(BuildContext context) {
    final total = state.challenges.length;
    final current = state.currentIndex + 1;
    return AppGlassCard(
      borderColor: AppColors.primary.withAlpha(68),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'التحدي $current من $total',
                  style: AppTypography.label,
                ),
              ),
              Text(
                'الدقة: ${(state.accuracy * 100).round()}%',
                style: AppTypography.label.copyWith(
                  color: AppColors.mastery,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          LinearProgressIndicator(
            value: total == 0 ? 0.0 : current / total,
            minHeight: 7,
            borderRadius: BorderRadius.circular(8),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _ChallengePrompt extends StatelessWidget {
  const _ChallengePrompt({required this.challenge});

  final PrepositionChallenge challenge;

  @override
  Widget build(BuildContext context) {
    final contextLabel = switch (challenge.spatialQuestion) {
      SpatialQuestion.wohin => 'Wohin? · حركة',
      SpatialQuestion.wo => 'Wo? · سكون',
      SpatialQuestion.none => null,
    };

    return AppGlassCard(
      glowColor: AppColors.secondary,
      borderColor: AppColors.secondary.withAlpha(72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (contextLabel != null) ...<Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.secondary.withAlpha(18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Text(
                    contextLabel,
                    textDirection: TextDirection.ltr,
                    style: AppTypography.label.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          AppDirectionalText(
            challenge.sentenceTemplate,
            languageCode: 'de',
            textAlign: TextAlign.center,
            style: AppTypography.title.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            challenge.translationAr,
            textAlign: TextAlign.center,
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}

class _AnswerExplanation extends StatelessWidget {
  const _AnswerExplanation({required this.result});

  final PrepositionAnswerResult result;

  @override
  Widget build(BuildContext context) {
    final color =
        result.isCorrect ? AppColors.mastery : AppColors.articleDie;
    final caseLabel = switch (result.grammaticalCase) {
      GermanGrammaticalCase.accusative => 'Akkusativ',
      GermanGrammaticalCase.dative => 'Dativ',
      null => '',
    };

    return AppGlassCard(
      borderColor: color.withAlpha(90),
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                result.isCorrect
                    ? Icons.check_circle_outline_rounded
                    : Icons.info_outline_rounded,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.isCorrect
                      ? 'إجابة صحيحة'
                      : 'الصحيح: ${result.expectedAnswer}',
                  style: AppTypography.title.copyWith(color: color),
                ),
              ),
              if (caseLabel.isNotEmpty)
                Text(
                  caseLabel,
                  textDirection: TextDirection.ltr,
                  style: AppTypography.label.copyWith(color: color),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            result.explanationAr,
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({
    required this.state,
    required this.onRestart,
  });

  final PrepositionArenaState state;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final percent = (state.accuracy * 100).round();
    return AppGlassCard(
      glowColor: AppColors.mastery,
      borderColor: AppColors.mastery.withAlpha(96),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.emoji_events_outlined,
            color: AppColors.mastery,
            size: 42,
          ),
          const SizedBox(height: 10),
          Text(
            'اكتملت الجولة',
            style: AppTypography.title,
          ),
          const SizedBox(height: 8),
          Text(
            '${state.correctCount}/${state.answeredCount} · $percent%',
            textDirection: TextDirection.ltr,
            style: AppTypography.display.copyWith(
              color: AppColors.mastery,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRestart,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('جولة جديدة'),
          ),
        ],
      ),
    );
  }
}
