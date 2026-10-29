import 'package:flutter/material.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart';
import '../application/infinitiv_notifier.dart';
import '../domain/infinitiv_models.dart';

class InfinitivKonstruktionenScreen extends StatefulWidget {
  const InfinitivKonstruktionenScreen({
    required this.notifier,
    super.key,
  });

  final InfinitivNotifier notifier;

  @override
  State<InfinitivKonstruktionenScreen> createState() =>
      _InfinitivKonstruktionenScreenState();
}

class _InfinitivKonstruktionenScreenState
    extends State<InfinitivKonstruktionenScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(widget.notifier.nextChallenge);
  }

  Future<void> _submit() => widget.notifier.checkAnswer();

  Future<void> _next() => widget.notifier.nextChallenge();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.notifier,
      builder: (context, _) {
        final notifier = widget.notifier;
        final challenge = notifier.currentChallenge;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Infinitiv mit zu',
              textDirection: TextDirection.ltr,
              style: AppTypography.title,
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _ScoreCard(notifier: notifier),
                  const SizedBox(height: 12),
                  _TypeFilter(
                    selected: notifier.filter,
                    busy: notifier.isBusy,
                    onSelected: notifier.filterByType,
                  ),
                  const SizedBox(height: 14),
                  if (notifier.isBusy && challenge == null)
                    const Center(child: CircularProgressIndicator())
                  else if (challenge == null)
                    AppGlassCard(
                      child: Text(
                        'لا توجد تمارين متاحة حاليًا.',
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: AppTypography.body,
                      ),
                    )
                  else ...<Widget>[
                    _ChallengeCard(challenge: challenge),
                    const SizedBox(height: 14),
                    _AnswerOptions(
                      challenge: challenge,
                      selected: notifier.selectedAnswer,
                      enabled:
                          !notifier.showExplanation && !notifier.isBusy,
                      onSelected: notifier.selectAnswer,
                    ),
                    const SizedBox(height: 14),
                    if (!notifier.showExplanation)
                      FilledButton.icon(
                        onPressed:
                            notifier.selectedAnswer == null || notifier.isBusy
                                ? null
                                : _submit,
                        icon: const Icon(Icons.check_rounded),
                        label: Text(
                          'تحقق من الإجابة',
                          textDirection: TextDirection.rtl,
                          style: AppTypography.label,
                        ),
                      )
                    else ...<Widget>[
                      _ExplanationCard(
                        challenge: challenge,
                        isCorrect: notifier.isCorrect == true,
                        explanationAr: notifier.explanationAr,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: notifier.isBusy ? null : _next,
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: Text(
                          'التحدي التالي',
                          textDirection: TextDirection.rtl,
                          style: AppTypography.label,
                        ),
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

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.notifier});

  final InfinitivNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final percent = (notifier.accuracy * 100).round();

    return AppGlassCard(
      borderColor: AppColors.primary.withAlpha(72),
      glowColor: AppColors.primary,
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.track_changes_rounded,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'النتيجة: ${notifier.correctCount}/${notifier.answeredCount}',
              textDirection: TextDirection.rtl,
              style: AppTypography.label,
            ),
          ),
          Text(
            '$percent%',
            textDirection: TextDirection.ltr,
            style: AppTypography.title.copyWith(
              color: AppColors.mastery,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeFilter extends StatelessWidget {
  const _TypeFilter({
    required this.selected,
    required this.busy,
    required this.onSelected,
  });

  final InfinitivClauseType? selected;
  final bool busy;
  final Future<void> Function(InfinitivClauseType type) onSelected;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      borderColor: AppColors.secondary.withAlpha(70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'نوع البناء',
            textDirection: TextDirection.rtl,
            style: AppTypography.title,
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: InfinitivClauseType.values
                .map(
                  (type) => ChoiceChip(
                    label: Text(
                      type.marker,
                      textDirection: TextDirection.ltr,
                      style: AppTypography.label,
                    ),
                    selected: selected == type,
                    onSelected:
                        busy ? null : (_) => onSelected(type),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge});

  final InfinitivChallengeItem challenge;

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(challenge.type);

    return AppGlassCard(
      blur: 22,
      opacity: .14,
      borderColor: accent.withAlpha(82),
      glowColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.account_tree_outlined, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  challenge.type.labelAr,
                  textDirection: TextDirection.rtl,
                  style: AppTypography.title.copyWith(color: accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            challenge.mainClause,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: AppTypography.title,
          ),
          const SizedBox(height: 8),
          Text(
            challenge.infinitivePhrase,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            challenge.arabicTranslation,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: AppTypography.body,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.center,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: accent.withAlpha(18),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: accent.withAlpha(72)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Text(
                  challenge.marker,
                  textDirection: TextDirection.ltr,
                  style: AppTypography.label.copyWith(color: accent),
                ),
              ),
            ),
          ),
          if (challenge.type !=
              InfinitivClauseType.infinitivMitZu) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              challenge.requiresSameSubject
                  ? 'الفاعل في الجملة الرئيسية وعبارة المصدر هو نفسه.'
                  : 'قد يختلف الفاعل حسب السياق.',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: AppTypography.label.copyWith(
                color: AppColors.tertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnswerOptions extends StatelessWidget {
  const _AnswerOptions({
    required this.challenge,
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final InfinitivChallengeItem challenge;
  final String? selected;
  final bool enabled;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'اختر التركيب الصحيح',
            textDirection: TextDirection.rtl,
            style: AppTypography.title,
          ),
          const SizedBox(height: 10),
          ...challenge.answerOptions.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AnswerTile(
                option: option,
                selected: selected == option,
                enabled: enabled,
                onTap: () => onSelected(option),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    required this.option,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String option;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent =
        selected ? AppColors.primary : AppColors.secondary;

    return AppGlassCard(
      onTap: enabled ? onTap : null,
      blur: 12,
      opacity: selected ? .18 : .08,
      borderRadius: 18,
      borderColor: accent.withAlpha(selected ? 140 : 54),
      glowColor: selected ? accent : null,
      child: Text(
        option,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.start,
        style: AppTypography.body.copyWith(
          color: accent,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({
    required this.challenge,
    required this.isCorrect,
    required this.explanationAr,
  });

  final InfinitivChallengeItem challenge;
  final bool isCorrect;
  final String explanationAr;

  @override
  Widget build(BuildContext context) {
    final accent =
        isCorrect ? AppColors.mastery : AppColors.tertiary;

    return AppGlassCard(
      borderColor: accent.withAlpha(92),
      glowColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                isCorrect
                    ? Icons.check_circle_outline_rounded
                    : Icons.info_outline_rounded,
                color: accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isCorrect ? 'إجابة صحيحة' : 'راجع موضع zu',
                  textDirection: TextDirection.rtl,
                  style: AppTypography.title.copyWith(color: accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            explanationAr,
            textDirection: TextDirection.rtl,
            style: AppTypography.body,
          ),
          const SizedBox(height: 10),
          Text(
            challenge.correctConstruction,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: AppTypography.title.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

Color _accentFor(InfinitivClauseType type) => switch (type) {
      InfinitivClauseType.infinitivMitZu => AppColors.primary,
      InfinitivClauseType.umZu => AppColors.mastery,
      InfinitivClauseType.ohneZu => AppColors.secondary,
      InfinitivClauseType.anstattZu => AppColors.tertiary,
    };
