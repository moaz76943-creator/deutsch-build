import 'package:flutter/material.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart';
import '../application/conjunctions_notifier.dart';
import '../domain/conjunctions_models.dart';

class ConjunctionsArenaScreen extends StatefulWidget {
  const ConjunctionsArenaScreen({
    required this.notifier,
    super.key,
  });

  final ConjunctionsNotifier notifier;

  @override
  State<ConjunctionsArenaScreen> createState() =>
      _ConjunctionsArenaScreenState();
}

class _ConjunctionsArenaScreenState extends State<ConjunctionsArenaScreen> {
  String? _chosenConnector;
  int? _chosenVerbPosition;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(widget.notifier.nextDrill);
  }

  Future<void> _submit() async {
    final connector = _chosenConnector;
    final position = _chosenVerbPosition;
    if (connector == null || position == null) return;
    await widget.notifier.checkAnswer(connector, position);
  }

  Future<void> _next() async {
    setState(() {
      _chosenConnector = null;
      _chosenVerbPosition = null;
    });
    await widget.notifier.nextDrill();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.notifier,
      builder: (context, _) {
        final notifier = widget.notifier;
        final drill = notifier.currentDrill;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'ساحة أدوات الربط والجمل الجانبية',
              style: AppTypography.title,
            ),
          ),
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  _ScoreCard(notifier: notifier),
                  const SizedBox(height: 14),
                  if (notifier.isBusy && drill == null)
                    const Center(child: CircularProgressIndicator())
                  else if (drill == null)
                    AppGlassCard(
                      child: Text(
                        'لا توجد تمارين متاحة حاليًا.',
                        style: AppTypography.body,
                        textAlign: TextAlign.center,
                      ),
                    )
                  else ...<Widget>[
                    _ClauseCard(drill: drill),
                    const SizedBox(height: 14),
                    _ConnectorOptions(
                      options: notifier.connectorOptions,
                      selected: _chosenConnector,
                      enabled: !notifier.showExplanation,
                      onSelected: (value) {
                        setState(() => _chosenConnector = value);
                      },
                    ),
                    const SizedBox(height: 14),
                    _VerbPositionIndicator(
                      selectedPosition: _chosenVerbPosition,
                      expectedPosition: notifier.showExplanation
                          ? drill.correctVerbPosition
                          : null,
                      enabled: !notifier.showExplanation,
                      onSelected: (value) {
                        setState(() => _chosenVerbPosition = value);
                      },
                    ),
                    const SizedBox(height: 14),
                    if (!notifier.showExplanation)
                      FilledButton.icon(
                        onPressed: notifier.isBusy ||
                                _chosenConnector == null ||
                                _chosenVerbPosition == null
                            ? null
                            : _submit,
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('تحقق من الإجابة'),
                      )
                    else ...<Widget>[
                      _ExplanationCard(
                        drill: drill,
                        isCorrect: notifier.isCorrect == true,
                        verdict: notifier.verbPositionVerdict,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: notifier.isBusy ? null : _next,
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

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.notifier});

  final ConjunctionsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final accuracy = (notifier.accuracy * 100).round();
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
              style: AppTypography.label,
            ),
          ),
          Text(
            '$accuracy%',
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

class _ClauseCard extends StatelessWidget {
  const _ClauseCard({required this.drill});

  final ConjunctionDrillItem drill;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      blur: 22,
      opacity: .14,
      borderColor: AppColors.secondary.withAlpha(78),
      glowColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
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
                  _categoryLabel(drill.category),
                  style: AppTypography.label.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          AppDirectionalText(
            drill.mainClause,
            languageCode: 'de',
            textAlign: TextAlign.center,
            style: AppTypography.title,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Icon(
              Icons.add_link_rounded,
              color: AppColors.primary,
            ),
          ),
          AppDirectionalText(
            drill.linkedClause,
            languageCode: 'de',
            textAlign: TextAlign.center,
            style: AppTypography.title,
          ),
          const SizedBox(height: 12),
          Text(
            drill.arabicTranslation,
            textAlign: TextAlign.center,
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }

  String _categoryLabel(ConjunctionCategory category) => switch (category) {
        ConjunctionCategory.coordinatingADUSO => 'ADUSO · Position 0',
        ConjunctionCategory.subordinatingNebensatz =>
          'Nebensatz · Verb am Ende',
        ConjunctionCategory.adverbialInversion =>
          'Adverbial · Inversion',
      };
}

class _ConnectorOptions extends StatelessWidget {
  const _ConnectorOptions({
    required this.options,
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final List<String> options;
  final String? selected;
  final bool enabled;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('اختر أداة الربط', style: AppTypography.title),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options
                .map(
                  (option) => ChoiceChip(
                    label: Text(
                      option,
                      textDirection: TextDirection.ltr,
                    ),
                    selected: selected == option,
                    onSelected: enabled
                        ? (_) => onSelected(option)
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

class _VerbPositionIndicator extends StatelessWidget {
  const _VerbPositionIndicator({
    required this.selectedPosition,
    required this.expectedPosition,
    required this.enabled,
    required this.onSelected,
  });

  final int? selectedPosition;
  final int? expectedPosition;
  final bool enabled;
  final ValueChanged<int> onSelected;

  static const List<int> _positions = <int>[
    ConjunctionDrillItem.positionZero,
    ConjunctionDrillItem.positionOne,
    ConjunctionDrillItem.positionEnd,
  ];

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      borderColor: AppColors.tertiary.withAlpha(70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Verb Position Indicator',
            textDirection: TextDirection.ltr,
            style: AppTypography.title,
          ),
          const SizedBox(height: 6),
          Text(
            'اختر تأثير أداة الربط على موقع الفعل.',
            style: AppTypography.body,
          ),
          const SizedBox(height: 12),
          Row(
            children: _positions
                .map(
                  (position) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _PositionNode(
                        position: position,
                        selected: selectedPosition == position,
                        expected: expectedPosition == position,
                        enabled: enabled,
                        onTap: () => onSelected(position),
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _PositionNode extends StatelessWidget {
  const _PositionNode({
    required this.position,
    required this.selected,
    required this.expected,
    required this.enabled,
    required this.onTap,
  });

  final int position;
  final bool selected;
  final bool expected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = expected
        ? AppColors.mastery
        : selected
            ? AppColors.primary
            : AppColors.secondary;

    return AppGlassCard(
      onTap: enabled ? onTap : null,
      blur: 12,
      opacity: selected || expected ? .18 : .08,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      borderRadius: 20,
      borderColor: color.withAlpha(selected || expected ? 130 : 56),
      glowColor: selected || expected ? color : null,
      child: Column(
        children: <Widget>[
          Icon(
            expected
                ? Icons.check_circle_outline_rounded
                : Icons.horizontal_rule_rounded,
            color: color,
          ),
          const SizedBox(height: 5),
          Text(
            ConjunctionDrillItem.verbPositionLabel(position),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: AppTypography.label.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({
    required this.drill,
    required this.isCorrect,
    required this.verdict,
  });

  final ConjunctionDrillItem drill;
  final bool isCorrect;
  final VerbPositionVerdict verdict;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.mastery : AppColors.articleDie;
    final positionText = switch (verdict) {
      VerbPositionVerdict.correct => 'موقع الفعل صحيح.',
      VerbPositionVerdict.incorrect => 'موقع الفعل يحتاج تصحيحًا.',
      VerbPositionVerdict.idle => '',
    };

    return AppGlassCard(
      borderColor: color.withAlpha(88),
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
                  isCorrect ? 'إجابة صحيحة' : 'راجع الأداة أو موقع الفعل',
                  style: AppTypography.title.copyWith(color: color),
                ),
              ),
            ],
          ),
          if (positionText.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(positionText, style: AppTypography.label),
          ],
          const SizedBox(height: 8),
          Text(
            drill.verbPositionExplanationAr,
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}
