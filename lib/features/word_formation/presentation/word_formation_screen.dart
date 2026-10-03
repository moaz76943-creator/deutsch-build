import 'dart:async';

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../application/word_formation_notifier.dart';
import '../domain/word_formation_models.dart';

final class WordFormationScreen extends StatefulWidget {
  const WordFormationScreen({
    required this.notifier,
    super.key,
  });

  final WordFormationNotifier notifier;

  @override
  State<WordFormationScreen> createState() => _WordFormationScreenState();
}

final class _WordFormationScreenState extends State<WordFormationScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.notifier.currentDrill == null &&
        !widget.notifier.isLoading) {
      unawaited(widget.notifier.load());
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'اشتقاق الكلمات · Wortbildung',
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

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: drill == null
                    ? _EmptyState(
                        onRetry: () => unawaited(notifier.load()),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _HeaderCard(notifier: notifier),
                          const SizedBox(height: 14),
                          _CategoryFilters(notifier: notifier),
                          const SizedBox(height: 14),
                          const _GoldenRuleCard(),
                          const SizedBox(height: 14),
                          _DerivationWorkbench(
                            drill: drill,
                            notifier: notifier,
                          ),
                          if (notifier.showExplanation) ...<Widget>[
                            const SizedBox(height: 14),
                            _FeedbackCard(
                              drill: drill,
                              notifier: notifier,
                            ),
                            const SizedBox(height: 14),
                            FilledButton.icon(
                              onPressed: notifier.nextDrill,
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
      );
}

final class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.notifier});

  final WordFormationNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final total = notifier.drills.length;
    final current = total == 0 ? 0 : notifier.currentIndex + 1;

    return AppGlassCard(
      borderColor: AppColors.primary.withAlpha(90),
      glowColor: AppColors.primary,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: <Widget>[
          const Icon(
            Icons.account_tree_outlined,
            color: AppColors.primary,
          ),
          Text(
            'حلّل الجذر ثم اختر اللاحقة أو البادئة المناسبة',
            textDirection: TextDirection.rtl,
            style: AppTypography.title,
          ),
          Text(
            '$current / $total',
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

final class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({required this.notifier});

  final WordFormationNotifier notifier;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'نوع الاشتقاق',
              textDirection: TextDirection.rtl,
              style: AppTypography.title,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _FilterButton(
                  label: 'أسماء',
                  selected:
                      notifier.activeCategory == SuffixCategory.nounSuffix,
                  onTap: () => unawaited(
                    notifier.filterByCategory(SuffixCategory.nounSuffix),
                  ),
                ),
                _FilterButton(
                  label: 'صفات',
                  selected: notifier.activeCategory ==
                      SuffixCategory.adjectiveSuffix,
                  onTap: () => unawaited(
                    notifier.filterByCategory(
                      SuffixCategory.adjectiveSuffix,
                    ),
                  ),
                ),
                _FilterButton(
                  label: 'أفعال ببادئة',
                  selected: notifier.activeCategory ==
                      SuffixCategory.verbPrefixDerivation,
                  onTap: () => unawaited(
                    notifier.filterByCategory(
                      SuffixCategory.verbPrefixDerivation,
                    ),
                  ),
                ),
                _FilterButton(
                  label: 'الكل',
                  selected: notifier.activeCategory == null,
                  onTap: () => unawaited(
                    notifier.clearCategoryFilter(),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

final class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        onTap: onTap,
        borderRadius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        borderColor: selected
            ? AppColors.secondary
            : Theme.of(context).dividerColor,
        glowColor: selected ? AppColors.secondary : null,
        child: Text(
          label,
          textDirection: TextDirection.rtl,
          style: AppTypography.label.copyWith(
            color: selected
                ? AppColors.secondary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
}

final class _GoldenRuleCard extends StatelessWidget {
  const _GoldenRuleCard();

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.achievement.withAlpha(100),
        glowColor: AppColors.achievement,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.auto_awesome_outlined,
                  color: AppColors.achievement,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'القاعدة الذهبية',
                    textDirection: TextDirection.rtl,
                    style: AppTypography.title.copyWith(
                      color: AppColors.achievement,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '-ung · -heit · -keit · -schaft → die',
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              style: AppTypography.title.copyWith(
                color: AppColors.articleDie,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'الأسماء المشتقة بهذه اللواحق مؤنثة، لذلك أداة التعريف هي die.',
              textDirection: TextDirection.rtl,
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _DerivationWorkbench extends StatelessWidget {
  const _DerivationWorkbench({
    required this.drill,
    required this.notifier,
  });

  final WordDerivationItem drill;
  final WordFormationNotifier notifier;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.primary.withAlpha(80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              drill.exercisePromptAr,
              textDirection: TextDirection.rtl,
              style: AppTypography.title,
            ),
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                _GermanToken(
                  label: drill.rootWord,
                  accent: AppColors.primary,
                ),
                Icon(
                  drill.isPrefixDerivation
                      ? Icons.arrow_back_rounded
                      : Icons.add_rounded,
                  color: AppColors.secondary,
                ),
                _GermanToken(
                  label: notifier.selectedSuffix ?? '?',
                  accent: AppColors.secondary,
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.achievement,
                ),
                _GermanToken(
                  label: notifier.formedWord ?? '…',
                  accent: AppColors.achievement,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'الجذر: ${drill.rootWord} · النوع: ${drill.rootWordType}',
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              style: AppTypography.label,
            ),
            const SizedBox(height: 16),
            Text(
              drill.isPrefixDerivation
                  ? 'اختر البادئة'
                  : 'اختر اللاحقة',
              textDirection: TextDirection.rtl,
              style: AppTypography.label,
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final suffix in notifier.availableSuffixes)
                  _SuffixChoice(
                    suffix: suffix,
                    selected: notifier.selectedSuffix == suffix,
                    disabled: notifier.showExplanation,
                    onTap: () => unawaited(
                      notifier.combineSuffix(suffix),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
}

final class _GermanToken extends StatelessWidget {
  const _GermanToken({
    required this.label,
    required this.accent,
  });

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderRadius: 16,
        borderColor: accent.withAlpha(100),
        glowColor: accent,
        child: Text(
          label,
          textDirection: TextDirection.ltr,
          style: AppTypography.title.copyWith(
            color: accent,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
}

final class _SuffixChoice extends StatelessWidget {
  const _SuffixChoice({
    required this.suffix,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  final String suffix;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        onTap: disabled ? null : onTap,
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        borderColor: selected
            ? AppColors.tertiary
            : Theme.of(context).dividerColor,
        glowColor: selected ? AppColors.tertiary : null,
        child: Text(
          suffix,
          textDirection: TextDirection.ltr,
          style: AppTypography.title.copyWith(
            color: selected
                ? AppColors.tertiary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
}

final class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.drill,
    required this.notifier,
  });

  final WordDerivationItem drill;
  final WordFormationNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final correct = notifier.isCorrect == true;
    final feedbackColor =
        correct ? AppColors.mastery : Theme.of(context).colorScheme.error;

    return AppGlassCard(
      borderColor: feedbackColor.withAlpha(110),
      glowColor: feedbackColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              Icon(
                correct
                    ? Icons.check_circle_outline
                    : Icons.info_outline,
                color: feedbackColor,
              ),
              Text(
                correct ? 'اشتقاق صحيح' : 'راجع اللاحقة والتحول',
                textDirection: TextDirection.rtl,
                style: AppTypography.title.copyWith(
                  color: feedbackColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              if (drill.article != null)
                Text(
                  drill.article!,
                  textDirection: TextDirection.ltr,
                  style: AppTypography.title.copyWith(
                    color: AppColors.articleDie,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              Text(
                drill.derivedWord,
                textDirection: TextDirection.ltr,
                style: AppTypography.title.copyWith(
                  color: AppColors.achievement,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            drill.arabicMeaning,
            textDirection: TextDirection.rtl,
            style: AppTypography.title,
          ),
          const SizedBox(height: 8),
          Text(
            drill.semanticShiftAr,
            textDirection: TextDirection.rtl,
            style: AppTypography.body,
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
  Widget build(BuildContext context) => AppGlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.account_tree_outlined,
              color: AppColors.primary,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد تمارين اشتقاق متاحة.',
              textDirection: TextDirection.rtl,
              style: AppTypography.title,
              textAlign: TextAlign.center,
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
      );
}
