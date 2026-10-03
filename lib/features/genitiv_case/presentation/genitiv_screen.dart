import 'package:flutter/material.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart';
import '../application/genitiv_notifier.dart';
import '../domain/genitiv_models.dart';

class GenitivScreen extends StatefulWidget {
  const GenitivScreen({
    required this.notifier,
    super.key,
  });

  final GenitivNotifier notifier;

  @override
  State<GenitivScreen> createState() => _GenitivScreenState();
}

class _GenitivScreenState extends State<GenitivScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(widget.notifier.nextChallenge);
  }

  Future<void> _submit() async {
    final notifier = widget.notifier;
    final challenge = notifier.currentChallenge;
    final article = notifier.selectedArticle;
    final suffix = notifier.selectedNounSuffix;

    if (challenge == null || article == null || suffix == null) return;

    if (challenge.type == GenitivDrillType.genitivPrepositions &&
        notifier.selectedPreposition == null) {
      return;
    }

    await notifier.checkGenitivAnswer(
      article,
      suffix,
      chosenPreposition: notifier.selectedPreposition,
    );
  }

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
              'Genitiv Arena',
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
                        'لا توجد تمارين Genitiv متاحة حاليًا.',
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: AppTypography.body,
                      ),
                    )
                  else ...<Widget>[
                    _ContextCard(challenge: challenge),
                    const SizedBox(height: 14),
                    _RelationshipCard(
                      challenge: challenge,
                      selectedArticle: notifier.selectedArticle,
                      selectedSuffix: notifier.selectedNounSuffix,
                      revealed: notifier.showExplanation,
                    ),
                    const SizedBox(height: 14),
                    _ArticleChoices(
                      selected: notifier.selectedArticle,
                      enabled: !notifier.showExplanation,
                      onSelected: notifier.selectArticle,
                    ),
                    const SizedBox(height: 14),
                    _SuffixChoices(
                      selected: notifier.selectedNounSuffix,
                      enabled: !notifier.showExplanation,
                      onSelected: notifier.selectNounSuffix,
                    ),
                    if (challenge.type ==
                        GenitivDrillType.genitivPrepositions) ...<Widget>[
                      const SizedBox(height: 14),
                      _PrepositionChoices(
                        selected: notifier.selectedPreposition,
                        enabled: !notifier.showExplanation,
                        onSelected: notifier.selectPreposition,
                      ),
                    ],
                    const SizedBox(height: 14),
                    if (!notifier.showExplanation)
                      FilledButton.icon(
                        onPressed: notifier.isBusy ||
                                notifier.selectedArticle == null ||
                                notifier.selectedNounSuffix == null ||
                                (challenge.type ==
                                        GenitivDrillType.genitivPrepositions &&
                                    notifier.selectedPreposition == null)
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

class _TypeFilter extends StatelessWidget {
  const _TypeFilter({
    required this.selected,
    required this.busy,
    required this.onSelected,
  });

  final GenitivDrillType? selected;
  final bool busy;
  final Future<void> Function(GenitivDrillType type) onSelected;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      borderColor: AppColors.primary.withAlpha(72),
      glowColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'نوع التدريب',
            textDirection: TextDirection.rtl,
            style: AppTypography.title,
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              ChoiceChip(
                label: Text(
                  'الملكية والإضافة',
                  textDirection: TextDirection.rtl,
                  style: AppTypography.label,
                ),
                selected:
                    selected == GenitivDrillType.possessionArticle,
                onSelected: busy
                    ? null
                    : (_) => onSelected(
                          GenitivDrillType.possessionArticle,
                        ),
              ),
              ChoiceChip(
                label: Text(
                  'حروف جر Genitiv',
                  textDirection: TextDirection.rtl,
                  style: AppTypography.label,
                ),
                selected:
                    selected == GenitivDrillType.genitivPrepositions,
                onSelected: busy
                    ? null
                    : (_) => onSelected(
                          GenitivDrillType.genitivPrepositions,
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({required this.challenge});

  final GenitivChallengeItem challenge;

  @override
  Widget build(BuildContext context) {
    final accent = challenge.type == GenitivDrillType.possessionArticle
        ? AppColors.primary
        : AppColors.secondary;

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
              Icon(
                challenge.type == GenitivDrillType.possessionArticle
                    ? Icons.link_rounded
                    : Icons.route_rounded,
                color: accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  challenge.type == GenitivDrillType.possessionArticle
                      ? 'علاقة المضاف والمضاف إليه'
                      : 'Genitiv بعد حرف الجر',
                  textDirection: TextDirection.rtl,
                  style: AppTypography.title.copyWith(color: accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            challenge.sentenceContext,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: AppTypography.title,
          ),
          const SizedBox(height: 10),
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
                  challenge.genderLabelDe,
                  textDirection: TextDirection.ltr,
                  style: AppTypography.label.copyWith(color: accent),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RelationshipCard extends StatelessWidget {
  const _RelationshipCard({
    required this.challenge,
    required this.selectedArticle,
    required this.selectedSuffix,
    required this.revealed,
  });

  final GenitivChallengeItem challenge;
  final String? selectedArticle;
  final String? selectedSuffix;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final article = revealed ? challenge.correctArticle : selectedArticle;
    final suffix = revealed ? challenge.correctNounSuffix : selectedSuffix;
    final nounAccent =
        challenge.takesNounEnding ? AppColors.tertiary : AppColors.secondary;

    return AppGlassCard(
      borderColor: nounAccent.withAlpha(78),
      glowColor: revealed ? nounAccent : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'المضاف إليه',
            textDirection: TextDirection.rtl,
            style: AppTypography.title,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                article ?? '___',
                textDirection: TextDirection.ltr,
                style: AppTypography.title.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: RichText(
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTypography.title.copyWith(
                      color: AppColors.secondary,
                    ),
                    children: <InlineSpan>[
                      TextSpan(text: challenge.targetNoun),
                      TextSpan(
                        text: suffix == null
                            ? '___'
                            : suffix.isEmpty
                                ? ''
                                : suffix,
                        style: AppTypography.title.copyWith(
                          color: nounAccent,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            challenge.takesNounEnding
                ? 'المذكر والمحايد يأخذان عادةً -s أو -es في هذا النوع من الأمثلة.'
                : 'المؤنث والجمع هنا لا يأخذان -s أو -es؛ التغيير الأساسي في الأداة.',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: AppTypography.label.copyWith(color: nounAccent),
          ),
        ],
      ),
    );
  }
}

class _ArticleChoices extends StatelessWidget {
  const _ArticleChoices({
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

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
            'اختر أداة Genitiv',
            textDirection: TextDirection.rtl,
            style: AppTypography.title,
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: _TokenButton(
                  token: 'des',
                  selected: selected == 'des',
                  enabled: enabled,
                  accent: AppColors.primary,
                  onTap: () => onSelected('des'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TokenButton(
                  token: 'der',
                  selected: selected == 'der',
                  enabled: enabled,
                  accent: AppColors.secondary,
                  onTap: () => onSelected('der'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuffixChoices extends StatelessWidget {
  const _SuffixChoices({
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final String? selected;
  final bool enabled;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      borderColor: AppColors.tertiary.withAlpha(70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'اختر لاحقة الاسم',
            textDirection: TextDirection.rtl,
            style: AppTypography.title,
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: _TokenButton(
                  token: 'بدون',
                  selected: selected == '',
                  enabled: enabled,
                  accent: AppColors.secondary,
                  tokenDirection: TextDirection.rtl,
                  onTap: () => onSelected(''),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TokenButton(
                  token: '-s',
                  selected: selected == 's',
                  enabled: enabled,
                  accent: AppColors.tertiary,
                  onTap: () => onSelected('s'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TokenButton(
                  token: '-es',
                  selected: selected == 'es',
                  enabled: enabled,
                  accent: AppColors.tertiary,
                  onTap: () => onSelected('es'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrepositionChoices extends StatelessWidget {
  const _PrepositionChoices({
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final String? selected;
  final bool enabled;
  final ValueChanged<String> onSelected;

  static const List<String> _prepositions = <String>[
    'wegen',
    'während',
    'trotz',
    'anstatt',
  ];

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      borderColor: AppColors.secondary.withAlpha(70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'اختر حرف الجر',
            textDirection: TextDirection.rtl,
            style: AppTypography.title,
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: _prepositions
                .map(
                  (preposition) => ChoiceChip(
                    label: Text(
                      preposition,
                      textDirection: TextDirection.ltr,
                      style: AppTypography.label,
                    ),
                    selected: selected == preposition,
                    onSelected: enabled
                        ? (_) => onSelected(preposition)
                        : null,
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _TokenButton extends StatelessWidget {
  const _TokenButton({
    required this.token,
    required this.selected,
    required this.enabled,
    required this.accent,
    required this.onTap,
    this.tokenDirection = TextDirection.ltr,
  });

  final String token;
  final bool selected;
  final bool enabled;
  final Color accent;
  final VoidCallback onTap;
  final TextDirection tokenDirection;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      onTap: enabled ? onTap : null,
      blur: 12,
      opacity: selected ? .2 : .08,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      borderRadius: 20,
      borderColor: accent.withAlpha(selected ? 150 : 62),
      glowColor: selected ? accent : null,
      child: Text(
        token,
        textDirection: tokenDirection,
        textAlign: TextAlign.center,
        style: AppTypography.title.copyWith(
          color: accent,
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
    required this.explanationAr,
  });

  final GenitivChallengeItem challenge;
  final bool isCorrect;
  final String explanationAr;

  @override
  Widget build(BuildContext context) {
    final accent = isCorrect ? AppColors.mastery : AppColors.tertiary;

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
                  isCorrect ? 'إجابة صحيحة' : 'راجع قاعدة Genitiv',
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
          const SizedBox(height: 8),
          Text(
            challenge.suffixReasonAr,
            textDirection: TextDirection.rtl,
            style: AppTypography.label.copyWith(
              color: AppColors.tertiary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            challenge.type == GenitivDrillType.genitivPrepositions
                ? '${challenge.genitivPreposition} ${challenge.correctArticle} ${challenge.inflectedNoun}'
                : '${challenge.correctArticle} ${challenge.inflectedNoun}',
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
