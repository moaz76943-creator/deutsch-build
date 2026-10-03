import 'dart:async';

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
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
  final TextEditingController _replacementController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    unawaited(widget.notifier.nextChallenge());
  }

  @override
  void dispose() {
    _replacementController.dispose();
    super.dispose();
  }

  Future<void> _selectVerb(String verb) async {
    if (widget.notifier.showExplanation || widget.notifier.isBusy) return;
    await widget.notifier.checkPair(verb);
  }

  Future<void> _checkReplacement() async {
    if (widget.notifier.showReplacementExplanation ||
        widget.notifier.isBusy) {
      return;
    }
    final answer = _replacementController.text.trim();
    if (answer.isEmpty) return;
    await widget.notifier.checkReplacement(answer);
  }

  void _setDirection(ReplacementDirection direction) {
    widget.notifier.setReplacementDirection(direction);
    _replacementController.clear();
  }

  Future<void> _filterContext(NvvContext context) async {
    await widget.notifier.filterByContext(context);
    _replacementController.clear();
  }

  Future<void> _clearFilters() async {
    await widget.notifier.clearFilters();
    _replacementController.clear();
  }

  Future<void> _nextChallenge() async {
    await widget.notifier.nextChallenge();
    _replacementController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.notifier,
      builder: (context, _) {
        final notifier = widget.notifier;
        final challenge = notifier.currentChallenge;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'B2 Nomen-Verb-Verbindungen',
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
                    _ContextFilter(
                      activeContext: notifier.activeContext,
                      busy: notifier.isBusy,
                      onContext: _filterContext,
                      onAll: _clearFilters,
                    ),
                    const SizedBox(height: 14),
                    if (notifier.isBusy && challenge == null)
                      const Center(child: CircularProgressIndicator())
                    else if (challenge == null)
                      AppGlassCard(
                        child: AppDirectionalText(
                          'لا توجد تراكيب متاحة لهذا التصنيف.',
                          languageCode: 'ar',
                          textAlign: TextAlign.center,
                          style: AppTypography.body,
                        ),
                      )
                    else ...<Widget>[
                      _ChallengeCard(challenge: challenge),
                      const SizedBox(height: 14),
                      _ReplacementTrainerCard(
                        challenge: challenge,
                        notifier: notifier,
                        controller: _replacementController,
                        onDirectionChanged: _setDirection,
                        onCheck: _checkReplacement,
                      ),
                      const SizedBox(height: 14),
                      _VerbPairCard(
                        challenge: challenge,
                        notifier: notifier,
                        onSelected: _selectVerb,
                      ),
                      if (notifier.showExplanation) ...<Widget>[
                        const SizedBox(height: 14),
                        _PairExplanationCard(
                          challenge: challenge,
                          isCorrect: notifier.isCorrect == true,
                          selectedVerb: notifier.selectedVerb!,
                        ),
                      ],
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed:
                            notifier.isBusy ? null : _nextChallenge,
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const AppDirectionalText(
                          'التحدي التالي',
                          languageCode: 'ar',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ContextFilter extends StatelessWidget {
  const _ContextFilter({
    required this.activeContext,
    required this.busy,
    required this.onContext,
    required this.onAll,
  });

  final NvvContext? activeContext;
  final bool busy;
  final ValueChanged<NvvContext> onContext;
  final VoidCallback onAll;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      borderColor: AppColors.primary.withAlpha(72),
      glowColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'سياق B2 المهني',
            languageCode: 'ar',
            style: AppTypography.title,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final item in NvvContext.values)
                _FilterPill(
                  label: _contextLabel(item),
                  selected: activeContext == item,
                  enabled: !busy,
                  onTap: () => onContext(item),
                ),
              _FilterPill(
                label: 'الكل',
                selected: activeContext == null,
                enabled: !busy,
                onTap: onAll,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _contextLabel(NvvContext context) => switch (context) {
        NvvContext.office => 'العمل',
        NvvContext.academics => 'الدراسة',
        NvvContext.healthcare => 'الصحة',
        NvvContext.constructiveFeedback => 'ملاحظات بنّاءة',
      };
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.secondary : AppColors.primary;
    return AppGlassCard(
      onTap: enabled ? onTap : null,
      blur: 12,
      opacity: selected ? .16 : .08,
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      borderColor: color.withAlpha(selected ? 110 : 48),
      glowColor: selected ? color : null,
      child: AppDirectionalText(
        label,
        languageCode: 'ar',
        style: AppTypography.label.copyWith(color: color),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge});

  final NvvChallengeItem challenge;

  @override
  Widget build(BuildContext context) {
    final hint = challenge.grammarHint;

    return AppGlassCard(
      blur: 22,
      opacity: .14,
      borderColor: AppColors.secondary.withAlpha(84),
      glowColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              AppGlassCard(
                borderRadius: 14,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                borderColor: AppColors.achievement.withAlpha(72),
                child: AppDirectionalText(
                  challenge.level,
                  languageCode: 'de',
                  style: AppTypography.label.copyWith(
                    color: AppColors.achievement,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppDirectionalText(
                  challenge.arabicTranslation,
                  languageCode: 'ar',
                  style: AppTypography.body,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppDirectionalText(
            challenge.trainingSentence,
            languageCode: 'de',
            textAlign: TextAlign.center,
            style: AppTypography.title,
          ),
          if (hint != null) ...<Widget>[
            const SizedBox(height: 10),
            AppDirectionalText(
              hint,
              languageCode: 'de',
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

class _ReplacementTrainerCard extends StatelessWidget {
  const _ReplacementTrainerCard({
    required this.challenge,
    required this.notifier,
    required this.controller,
    required this.onDirectionChanged,
    required this.onCheck,
  });

  final NvvChallengeItem challenge;
  final NvvNotifier notifier;
  final TextEditingController controller;
  final ValueChanged<ReplacementDirection> onDirectionChanged;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final direction = notifier.replacementDirection;
    final prompt = challenge.replacementPrompt(direction);

    return AppGlassCard(
      borderColor: AppColors.achievement.withAlpha(82),
      glowColor: AppColors.achievement,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'Replacement Trainer',
            languageCode: 'de',
            style: AppTypography.title.copyWith(
              color: AppColors.achievement,
            ),
          ),
          const SizedBox(height: 6),
          AppDirectionalText(
            'حوّل بين الفعل البسيط والتركيب الاسمي الفعلي دون تغيير المعنى.',
            languageCode: 'ar',
            style: AppTypography.body,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _DirectionPill(
                label: 'einfach → NVV',
                selected:
                    direction == ReplacementDirection.simpleToNvv,
                onTap: () => onDirectionChanged(
                  ReplacementDirection.simpleToNvv,
                ),
              ),
              _DirectionPill(
                label: 'NVV → einfach',
                selected:
                    direction == ReplacementDirection.nvvToSimple,
                onTap: () => onDirectionChanged(
                  ReplacementDirection.nvvToSimple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppGlassCard(
            borderRadius: 18,
            borderColor: AppColors.primary.withAlpha(64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppDirectionalText(
                  'Ausgangsform',
                  languageCode: 'de',
                  style: AppTypography.label.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                AppDirectionalText(
                  prompt,
                  languageCode: 'de',
                  style: AppTypography.title,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            enabled: !notifier.isBusy &&
                !notifier.showReplacementExplanation,
            textDirection: TextDirection.ltr,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Deutsche Ersatzform',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => onCheck(),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: notifier.isBusy ||
                    notifier.showReplacementExplanation
                ? null
                : onCheck,
            icon: const Icon(Icons.swap_horiz_rounded),
            label: const AppDirectionalText(
              'تحقق من الاستبدال',
              languageCode: 'ar',
            ),
          ),
          if (notifier.showReplacementExplanation) ...<Widget>[
            const SizedBox(height: 12),
            _ReplacementFeedback(
              challenge: challenge,
              notifier: notifier,
            ),
          ],
        ],
      ),
    );
  }
}

class _DirectionPill extends StatelessWidget {
  const _DirectionPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.achievement : AppColors.secondary;
    return AppGlassCard(
      onTap: onTap,
      blur: 12,
      opacity: selected ? .16 : .08,
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      borderColor: color.withAlpha(selected ? 110 : 48),
      glowColor: selected ? color : null,
      child: AppDirectionalText(
        label,
        languageCode: 'de',
        style: AppTypography.label.copyWith(color: color),
      ),
    );
  }
}

class _ReplacementFeedback extends StatelessWidget {
  const _ReplacementFeedback({
    required this.challenge,
    required this.notifier,
  });

  final NvvChallengeItem challenge;
  final NvvNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final correct = notifier.replacementCorrect == true;
    final color = correct ? AppColors.mastery : AppColors.articleDie;
    final expected = challenge.replacementAnswer(
      notifier.replacementDirection,
    );

    return AppGlassCard(
      borderRadius: 18,
      borderColor: color.withAlpha(92),
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            correct ? 'إجابة صحيحة' : 'راجع الاستبدال',
            languageCode: 'ar',
            style: AppTypography.title.copyWith(color: color),
          ),
          const SizedBox(height: 8),
          AppDirectionalText(
            expected,
            languageCode: 'de',
            textAlign: TextAlign.center,
            style: AppTypography.title.copyWith(color: color),
          ),
          const SizedBox(height: 8),
          AppDirectionalText(
            challenge.arabicUsageExplanation,
            languageCode: 'ar',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}

class _VerbPairCard extends StatelessWidget {
  const _VerbPairCard({
    required this.challenge,
    required this.notifier,
    required this.onSelected,
  });

  final NvvChallengeItem challenge;
  final NvvNotifier notifier;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      borderColor: AppColors.tertiary.withAlpha(72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'Pair Trainer',
            languageCode: 'de',
            style: AppTypography.title.copyWith(
              color: AppColors.tertiary,
            ),
          ),
          const SizedBox(height: 6),
          AppDirectionalText(
            challenge.nominalPart,
            languageCode: 'de',
            textAlign: TextAlign.center,
            style: AppTypography.title,
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 520 ? 4 : 2;
              final width =
                  (constraints.maxWidth - (columns - 1) * 8) / columns;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: notifier.displayedOptions
                    .map(
                      (verb) => SizedBox(
                        width: width,
                        child: _VerbOption(
                          verb: verb,
                          selected: notifier.selectedVerb == verb,
                          correct: notifier.showExplanation &&
                              challenge.correctVerb == verb,
                          enabled: !notifier.isBusy &&
                              !notifier.showExplanation,
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

class _VerbOption extends StatelessWidget {
  const _VerbOption({
    required this.verb,
    required this.selected,
    required this.correct,
    required this.enabled,
    required this.onTap,
  });

  final String verb;
  final bool selected;
  final bool correct;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = correct
        ? AppColors.mastery
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
        style: AppTypography.label.copyWith(color: color),
      ),
    );
  }
}

class _PairExplanationCard extends StatelessWidget {
  const _PairExplanationCard({
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

    return AppGlassCard(
      borderColor: color.withAlpha(92),
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            isCorrect
                ? 'إجابة صحيحة'
                : 'الفعل الصحيح: ' +
                    challenge.correctVerb +
                    ' — اختيارك: ' +
                    selectedVerb,
            languageCode: 'ar',
            style: AppTypography.title.copyWith(color: color),
          ),
          const SizedBox(height: 10),
          AppDirectionalText(
            challenge.nvvPhrase,
            languageCode: 'de',
            textAlign: TextAlign.center,
            style: AppTypography.title.copyWith(color: color),
          ),
          const SizedBox(height: 8),
          AppDirectionalText(
            challenge.arabicUsageExplanation,
            languageCode: 'ar',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}
