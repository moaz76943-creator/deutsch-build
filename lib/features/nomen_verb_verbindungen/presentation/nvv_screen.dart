import 'package:flutter/material.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart';
import '../application/nvv_notifier.dart';
import '../domain/nvv_models.dart';

class NvvScreen extends StatefulWidget {
  const NvvScreen({
    required this.notifier,
    super.key,
  });

  final NvvNotifier notifier;

  @override
  State<NvvScreen> createState() => _NvvScreenState();
}

class _NvvScreenState extends State<NvvScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(widget.notifier.nextChallenge);
  }

  Future<void> _selectVerb(String verb) async {
    if (widget.notifier.showExplanation || widget.notifier.isBusy) return;
    await widget.notifier.checkPair(verb);
  }

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
              'تدريب Nomen-Verb-Verbindungen',
              style: AppTypography.title,
            ),
          ),
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  _RegisterFilter(notifier: notifier),
                  const SizedBox(height: 14),
                  if (notifier.isBusy && challenge == null)
                    const Center(child: CircularProgressIndicator())
                  else if (challenge == null)
                    AppGlassCard(
                      child: Text(
                        'لا توجد تراكيب متاحة لهذا التصنيف.',
                        textAlign: TextAlign.center,
                        style: AppTypography.body,
                      ),
                    )
                  else ...<Widget>[
                    _ChallengeCard(challenge: challenge),
                    const SizedBox(height: 14),
                    _SimpleMeaningCard(challenge: challenge),
                    const SizedBox(height: 14),
                    _VerbOptions(
                      options: notifier.displayedOptions,
                      selectedVerb: notifier.selectedVerb,
                      correctVerb: challenge.correctVerb,
                      revealed: notifier.showExplanation,
                      enabled: !notifier.isBusy &&
                          !notifier.showExplanation,
                      onSelected: _selectVerb,
                    ),
                    if (notifier.showExplanation) ...<Widget>[
                      const SizedBox(height: 14),
                      _ExplanationCard(
                        challenge: challenge,
                        isCorrect: notifier.isCorrect == true,
                        selectedVerb: notifier.selectedVerb!,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed:
                            notifier.isBusy ? null : notifier.nextChallenge,
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('التحدي التالي'),
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

class _RegisterFilter extends StatelessWidget {
  const _RegisterFilter({required this.notifier});

  final NvvNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      borderColor: AppColors.primary.withAlpha(72),
      glowColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('اختر مستوى الاستعمال', style: AppTypography.title),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: NvvRegister.values
                .map(
                  (register) => ChoiceChip(
                    label: Text(_registerLabel(register)),
                    selected: notifier.activeRegister == register,
                    onSelected: notifier.isBusy
                        ? null
                        : (_) => notifier.filterByRegister(register),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  String _registerLabel(NvvRegister register) => switch (register) {
        NvvRegister.everyday => 'يومي',
        NvvRegister.formalWorkplace => 'رسمي / عمل',
        NvvRegister.academicOfficial => 'أكاديمي / رسمي',
      };
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge});

  final NvvChallengeItem challenge;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      blur: 22,
      opacity: .14,
      borderColor: AppColors.secondary.withAlpha(84),
      glowColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'أكمل التركيب بالفعل المناسب',
            style: AppTypography.label.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          AppDirectionalText(
            challenge.nominalPart,
            languageCode: 'de',
            textAlign: TextAlign.center,
            style: AppTypography.title.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          AppDirectionalText(
            challenge.trainingSentence,
            languageCode: 'de',
            textAlign: TextAlign.center,
            style: AppTypography.title,
          ),
        ],
      ),
    );
  }
}

class _SimpleMeaningCard extends StatelessWidget {
  const _SimpleMeaningCard({required this.challenge});

  final NvvChallengeItem challenge;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      borderColor: AppColors.tertiary.withAlpha(72),
      glowColor: AppColors.tertiary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('معناها ببساطة', style: AppTypography.label),
          const SizedBox(height: 6),
          AppDirectionalText(
            challenge.simpleEquivalent,
            languageCode: 'de',
            textAlign: TextAlign.center,
            style: AppTypography.title.copyWith(
              color: AppColors.tertiary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            challenge.arabicTranslation,
            textAlign: TextAlign.center,
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}

class _VerbOptions extends StatelessWidget {
  const _VerbOptions({
    required this.options,
    required this.selectedVerb,
    required this.correctVerb,
    required this.revealed,
    required this.enabled,
    required this.onSelected,
  });

  final List<String> options;
  final String? selectedVerb;
  final String correctVerb;
  final bool revealed;
  final bool enabled;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('اختر الفعل المتلازم', style: AppTypography.title),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 520 ? 4 : 2;
              final width =
                  (constraints.maxWidth - (columns - 1) * 8) / columns;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options
                    .map(
                      (verb) => SizedBox(
                        width: width,
                        child: _VerbOptionCard(
                          verb: verb,
                          selected: selectedVerb == verb,
                          correct: revealed && correctVerb == verb,
                          revealed: revealed,
                          enabled: enabled,
                          onTap: () => onSelected(verb),
                        ),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _VerbOptionCard extends StatelessWidget {
  const _VerbOptionCard({
    required this.verb,
    required this.selected,
    required this.correct,
    required this.revealed,
    required this.enabled,
    required this.onTap,
  });

  final String verb;
  final bool selected;
  final bool correct;
  final bool revealed;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = correct
        ? AppColors.mastery
        : selected && revealed
            ? AppColors.articleDie
            : selected
                ? AppColors.primary
                : AppColors.secondary;

    return AppGlassCard(
      onTap: enabled ? onTap : null,
      blur: 12,
      opacity: selected || correct ? .18 : .08,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      borderRadius: 20,
      borderColor: color.withAlpha(selected || correct ? 130 : 54),
      glowColor: selected || correct ? color : null,
      child: AppDirectionalText(
        verb,
        languageCode: 'de',
        textAlign: TextAlign.center,
        style: AppTypography.label.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({
    required this.challenge,
    required this.isCorrect,
    required this.selectedVerb,
  });

  final NvvChallengeItem challenge;
  final bool isCorrect;
  final String selectedVerb;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.mastery : AppColors.articleDie;
    final hint = challenge.grammarHint;

    return AppGlassCard(
      borderColor: color.withAlpha(92),
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                isCorrect
                    ? Icons.check_circle_outline_rounded
                    : Icons.info_outline_rounded,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isCorrect
                      ? 'إجابة صحيحة'
                      : 'الصحيح: ${challenge.correctVerb} — اخترت: $selectedVerb',
                  style: AppTypography.title.copyWith(color: color),
                ),
              ),
            ],
          ),
          if (hint != null) ...<Widget>[
            const SizedBox(height: 10),
            AppGlassCard(
              blur: 10,
              opacity: .08,
              borderRadius: 20,
              borderColor: AppColors.tertiary.withAlpha(62),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              child: Text(
                'ملاحظة إعرابية سريعة: $hint',
                style: AppTypography.label,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            challenge.arabicUsageExplanation,
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}
