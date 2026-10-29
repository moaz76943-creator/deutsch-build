import 'package:flutter/material.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart';
import '../application/reflexive_notifier.dart';
import '../domain/reflexive_models.dart';

class ReflexiveScreen extends StatelessWidget {
  const ReflexiveScreen({required this.notifier, super.key});

  final ReflexiveNotifier notifier;

  static const List<String> _pronounChoices = <String>[
    'mich',
    'mir',
    'dich',
    'dir',
    'sich',
    'uns',
    'euch',
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Reflexive Verben Arena',
            textDirection: TextDirection.ltr,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: AnimatedBuilder(
              animation: notifier,
              builder: (context, _) {
                final state = notifier.state;
                final item = state.current;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CaseFilterCard(
                      selected: state.filter,
                      onSelected: notifier.filterByCase,
                    ),
                    const SizedBox(height: 14),
                    _GrammarClueCard(item: item),
                    const SizedBox(height: 14),
                    _ContextCard(item: item),
                    const SizedBox(height: 14),
                    AppGlassCard(
                      glowColor: state.checked
                          ? (state.correct
                              ? AppColors.mastery
                              : AppColors.tertiary)
                          : AppColors.primary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'اختر الضمير الانعكاسي المناسب',
                            textDirection: TextDirection.rtl,
                            style: AppTypography.title,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final pronoun in _pronounChoices)
                                _PronounButton(
                                  pronoun: pronoun,
                                  selected: state.selectedPronoun == pronoun,
                                  checked: state.checked,
                                  isCorrectOption:
                                      item.reflexivePronoun == pronoun,
                                  onPressed: state.checked
                                      ? null
                                      : () => notifier
                                          .checkReflexivePronoun(pronoun),
                                ),
                            ],
                          ),
                          if (state.checked) ...[
                            const SizedBox(height: 14),
                            _FeedbackPanel(state: state),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: notifier.nextDrill,
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: Text(
                                'التمرين التالي',
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
}

class _CaseFilterCard extends StatelessWidget {
  const _CaseFilterCard({
    required this.selected,
    required this.onSelected,
  });

  final ReflexiveCase? selected;
  final ValueChanged<ReflexiveCase> onSelected;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'تدريب حسب الحالة',
              textDirection: TextDirection.rtl,
              style: AppTypography.title,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final reflexCase in ReflexiveCase.values)
                  ChoiceChip(
                    label: Text(
                      reflexCase.labelDe,
                      textDirection: TextDirection.ltr,
                    ),
                    selected: selected == reflexCase,
                    selectedColor: AppColors.primary.withAlpha(32),
                    side: BorderSide(
                      color: selected == reflexCase
                          ? AppColors.primary
                          : AppColors.secondary,
                    ),
                    onSelected: (_) => onSelected(reflexCase),
                  ),
              ],
            ),
          ],
        ),
      );
}

class _GrammarClueCard extends StatelessWidget {
  const _GrammarClueCard({required this.item});

  final ReflexiveDrillItem item;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor:
            item.hasAdditionalObject ? AppColors.achievement : AppColors.secondary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              item.infinitiveWithSich,
              textDirection: TextDirection.ltr,
              style: AppTypography.display.copyWith(fontSize: 27),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _GrammarPill(
                  labelAr: 'الفاعل',
                  valueDe: item.subjectPronoun,
                  accent: AppColors.primary,
                ),
                _GrammarPill(
                  labelAr: 'النوع',
                  valueDe: item.reflexiveType.labelAr,
                  accent: AppColors.secondary,
                  valueIsArabic: true,
                ),
                if (item.hasAdditionalObject)
                  _GrammarPill(
                    labelAr: 'مفعول إضافي',
                    valueDe: item.additionalObject!,
                    accent: AppColors.achievement,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.hasAdditionalObject
                  ? 'وجود مفعول مباشر إضافي علامة قوية للبحث عن Dativ.'
                  : 'لا يوجد مفعول مباشر إضافي ظاهر؛ افحص قاعدة الفعل والضمير.',
              textDirection: TextDirection.rtl,
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({required this.item});

  final ReflexiveDrillItem item;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.secondary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'السياق',
              textDirection: TextDirection.rtl,
              style: AppTypography.title,
            ),
            const SizedBox(height: 8),
            Text(
              item.contextSentence,
              textDirection: TextDirection.ltr,
              style: AppTypography.body.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              item.translationAr,
              textDirection: TextDirection.rtl,
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

class _GrammarPill extends StatelessWidget {
  const _GrammarPill({
    required this.labelAr,
    required this.valueDe,
    required this.accent,
    this.valueIsArabic = false,
  });

  final String labelAr;
  final String valueDe;
  final Color accent;
  final bool valueIsArabic;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: accent.withAlpha(22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withAlpha(92)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                labelAr,
                textDirection: TextDirection.rtl,
                style: AppTypography.label.copyWith(color: accent),
              ),
              const SizedBox(height: 2),
              Text(
                valueDe,
                textDirection:
                    valueIsArabic ? TextDirection.rtl : TextDirection.ltr,
                style: AppTypography.body,
              ),
            ],
          ),
        ),
      );
}

class _PronounButton extends StatelessWidget {
  const _PronounButton({
    required this.pronoun,
    required this.selected,
    required this.checked,
    required this.isCorrectOption,
    required this.onPressed,
  });

  final String pronoun;
  final bool selected;
  final bool checked;
  final bool isCorrectOption;
  final VoidCallback? onPressed;

  Color get _accent {
    if (!checked) return selected ? AppColors.primary : AppColors.secondary;
    if (isCorrectOption) return AppColors.mastery;
    if (selected) return AppColors.tertiary;
    return AppColors.secondary;
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        backgroundColor: accent.withAlpha(18),
        side: BorderSide(color: accent),
      ),
      child: Text(
        pronoun,
        textDirection: TextDirection.ltr,
      ),
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel({required this.state});

  final ReflexiveState state;

  @override
  Widget build(BuildContext context) {
    final item = state.current;
    final accent = state.correct ? AppColors.mastery : AppColors.tertiary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withAlpha(20),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withAlpha(90)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              state.correct ? 'إجابة صحيحة' : 'راجع الضمير والحالة',
              textDirection: TextDirection.rtl,
              style: AppTypography.label.copyWith(color: accent),
            ),
            const SizedBox(height: 6),
            Text(
              '${item.subjectPronoun} → ${item.reflexivePronoun} · ${item.reflexiveCase.labelDe}',
              textDirection: TextDirection.ltr,
              style: AppTypography.title,
            ),
            const SizedBox(height: 8),
            Text(
              item.caseReasonAr,
              textDirection: TextDirection.rtl,
              style: AppTypography.body,
            ),
            const SizedBox(height: 6),
            Text(
              state.feedbackAr,
              textDirection: TextDirection.rtl,
              style: AppTypography.body,
            ),
          ],
        ),
      ),
    );
  }
}
