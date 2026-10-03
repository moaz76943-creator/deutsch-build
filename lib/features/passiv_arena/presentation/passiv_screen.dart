import 'dart:async';

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../application/passiv_notifier.dart';
import '../domain/passiv_models.dart';

final class PassivScreen extends StatefulWidget {
  const PassivScreen({
    required this.notifier,
    super.key,
  });

  final PassivNotifier notifier;

  @override
  State<PassivScreen> createState() => _PassivScreenState();
}

final class _PassivScreenState extends State<PassivScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.notifier.currentDrill == null &&
        !widget.notifier.isLoading) {
      unawaited(
        widget.notifier.load(type: PassivType.vorgangspassiv),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('ساحة المبني للمجهول · Passiv Arena'),
          ),
          body: ListenableBuilder(
            listenable: widget.notifier,
            builder: (context, _) {
              final notifier = widget.notifier;
              final drill = notifier.currentDrill;

              if (notifier.isLoading && drill == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (drill == null) {
                return _EmptyState(
                  onRetry: () => unawaited(
                    notifier.load(type: PassivType.vorgangspassiv),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
                children: <Widget>[
                  _TypeSelector(notifier: notifier),
                  const SizedBox(height: 14),
                  _TransformationCard(
                    drill: drill,
                    currentIndex: notifier.currentIndex,
                    total: notifier.drills.length,
                  ),
                  const SizedBox(height: 14),
                  _ChoiceSection(
                    title: '1. الفعل المساعد',
                    hint: drill.structureLabel,
                    options: notifier.auxiliaryOptions,
                    selected: notifier.selectedAuxiliary,
                    correct: drill.auxiliaryForm,
                    answered: notifier.showExplanation,
                    onSelected: notifier.selectAuxiliary,
                  ),
                  const SizedBox(height: 12),
                  _ChoiceSection(
                    title: '2. حرف الجر للفاعل الأصلي',
                    hint:
                        'von + Dativ للأشخاص · durch + Akkusativ للوسيلة أو السبب',
                    options: notifier.prepositionOptions,
                    selected: notifier.selectedPreposition,
                    correct: drill.agentPreposition,
                    answered: notifier.showExplanation,
                    onSelected: notifier.selectPreposition,
                  ),
                  const SizedBox(height: 12),
                  _ChoiceSection(
                    title: '3. Partizip II',
                    hint: 'اختر التصريف الثالث الصحيح للفعل',
                    options: notifier.partizipOptions,
                    selected: notifier.selectedPartizipII,
                    correct: drill.partizipII,
                    answered: notifier.showExplanation,
                    onSelected: notifier.selectPartizipII,
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: notifier.canCheck
                        ? () => unawaited(
                              notifier.checkTransformation(
                                auxiliaryForm:
                                    notifier.selectedAuxiliary!,
                                agentPreposition:
                                    notifier.selectedPreposition!,
                                partizipII:
                                    notifier.selectedPartizipII!,
                              ),
                            )
                        : null,
                    icon: const Icon(Icons.fact_check_outlined),
                    label: const Text('تحقق من التحويل'),
                  ),
                  if (notifier.showExplanation) ...<Widget>[
                    const SizedBox(height: 14),
                    _FeedbackCard(
                      drill: drill,
                      correct: notifier.isCorrect == true,
                    ),
                    const SizedBox(height: 14),
                    FilledButton.tonalIcon(
                      onPressed: notifier.nextDrill,
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

final class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.notifier});

  final PassivNotifier notifier;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.primary.withAlpha(90),
        glowColor: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('نوع المبني للمجهول', style: AppTypography.title),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                _TypeChip(
                  label: 'Vorgangspassiv · حدث',
                  selected:
                      notifier.activeType == PassivType.vorgangspassiv,
                  onSelected: () => unawaited(
                    notifier.switchPassivType(
                      PassivType.vorgangspassiv,
                    ),
                  ),
                ),
                _TypeChip(
                  label: 'Zustandspassiv · حالة',
                  selected:
                      notifier.activeType == PassivType.zustandspassiv,
                  onSelected: () => unawaited(
                    notifier.switchPassivType(
                      PassivType.zustandspassiv,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

final class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AppColors.primary.withAlpha(36),
        side: BorderSide(
          color: selected
              ? AppColors.primary
              : Theme.of(context).dividerColor,
        ),
        onSelected: (_) => onSelected(),
      );
}

final class _TransformationCard extends StatelessWidget {
  const _TransformationCard({
    required this.drill,
    required this.currentIndex,
    required this.total,
  });

  final PassivDrillItem drill;
  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.secondary.withAlpha(95),
        glowColor: AppColors.secondary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    drill.typeLabelAr + ' · ' + drill.tenseLabel,
                    style: AppTypography.title,
                  ),
                ),
                Text(
                  (currentIndex + 1).toString() + ' / ' + total.toString(),
                  textDirection: TextDirection.ltr,
                  style: AppTypography.label.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SentenceBlock(
              title: 'Aktiv',
              sentence: drill.activeSentence,
              color: AppColors.tertiary,
            ),
            const SizedBox(height: 16),
            const Icon(
              Icons.south_rounded,
              color: AppColors.secondary,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              'المفعول به يتحول إلى الفاعل النحوي الجديد',
              textAlign: TextAlign.center,
              style: AppTypography.label,
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: _CaseCard(
                    label: 'Akkusativ',
                    value: drill.akkusativObject,
                    color: AppColors.tertiary,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _CaseCard(
                    label: 'Nominativ',
                    value: drill.nominativSubject,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _AgentRuleCard(drill: drill),
          ],
        ),
      );
}

final class _SentenceBlock extends StatelessWidget {
  const _SentenceBlock({
    required this.title,
    required this.sentence,
    required this.color,
  });

  final String title;
  final String sentence;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: color.withAlpha(18),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                title,
                textDirection: TextDirection.ltr,
                style: AppTypography.label.copyWith(color: color),
              ),
              const SizedBox(height: 6),
              Text(
                sentence,
                textDirection: TextDirection.ltr,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      );
}

final class _CaseCard extends StatelessWidget {
  const _CaseCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(88)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: <Widget>[
              Text(
                label,
                textDirection: TextDirection.ltr,
                style: AppTypography.label.copyWith(color: color),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      );
}

final class _AgentRuleCard extends StatelessWidget {
  const _AgentRuleCard({required this.drill});

  final PassivDrillItem drill;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.achievement.withAlpha(18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.achievement.withAlpha(76),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.account_tree_outlined,
                color: AppColors.achievement,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'الفاعل الأصلي: ' +
                      drill.originalAgent +
                      ' → ' +
                      drill.agentPreposition +
                      ' + ' +
                      drill.agentCaseLabel,
                  style: AppTypography.label,
                ),
              ),
            ],
          ),
        ),
      );
}

final class _ChoiceSection extends StatelessWidget {
  const _ChoiceSection({
    required this.title,
    required this.hint,
    required this.options,
    required this.selected,
    required this.correct,
    required this.answered,
    required this.onSelected,
  });

  final String title;
  final String hint;
  final List<String> options;
  final String? selected;
  final String correct;
  final bool answered;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(title, style: AppTypography.title),
            const SizedBox(height: 4),
            Text(hint, style: AppTypography.label),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                for (final option in options)
                  _OptionCard(
                    option: option,
                    selected: selected == option,
                    correct: option == correct,
                    answered: answered,
                    onTap: answered ? null : () => onSelected(option),
                  ),
              ],
            ),
          ],
        ),
      );
}

final class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.option,
    required this.selected,
    required this.correct,
    required this.answered,
    required this.onTap,
  });

  final String option;
  final bool selected;
  final bool correct;
  final bool answered;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    final border = answered && correct
        ? AppColors.mastery
        : answered && selected && !correct
            ? error
            : selected
                ? AppColors.primary
                : Theme.of(context).dividerColor;

    return SizedBox(
      width: 118,
      child: AppGlassCard(
        onTap: onTap,
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        borderColor: border,
        glowColor: selected || (answered && correct) ? border : null,
        child: Text(
          option,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: border,
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
    );
  }
}

final class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.drill,
    required this.correct,
  });

  final PassivDrillItem drill;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    final color = correct ? AppColors.mastery : error;

    return AppGlassCard(
      borderColor: color.withAlpha(120),
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                correct
                    ? Icons.check_circle_outline
                    : Icons.info_outline,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  correct ? 'التحويل صحيح' : 'راجع تركيب الـ Passiv',
                  style: AppTypography.title.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SentenceBlock(
            title: 'Passiv',
            sentence: drill.passiveSentence,
            color: color,
          ),
          const SizedBox(height: 12),
          Text(
            drill.explanationAr,
            style: AppTypography.body,
          ),
          const SizedBox(height: 8),
          Text(
            drill.structureLabel,
            textDirection: TextDirection.ltr,
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
                  Icons.swap_horiz_rounded,
                  color: AppColors.primary,
                  size: 44,
                ),
                const SizedBox(height: 12),
                Text(
                  'لا توجد تمارين Passiv متاحة.',
                  style: AppTypography.title,
                ),
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
