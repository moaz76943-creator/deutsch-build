import 'package:flutter/material.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart';
import '../application/alltagssprache_notifier.dart';
import '../domain/alltagssprache_models.dart';

class AlltagsspracheScreen extends StatelessWidget {
  const AlltagsspracheScreen({
    required this.notifier,
    super.key,
  });

  final AlltagsspracheNotifier notifier;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: AppDirectionalText(
            'Alltagssprache & Umgangsformen',
            languageCode: 'de',
            style: AppTypography.title,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: AnimatedBuilder(
              animation: notifier,
              builder: (context, _) {
                final item = notifier.current;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const _IntroCard(),
                    const SizedBox(height: 14),
                    _TopicCard(
                      selected: notifier.topic,
                      onSelected: notifier.filterByTopic,
                    ),
                    const SizedBox(height: 14),
                    _SituationCard(item: item),
                    const SizedBox(height: 14),
                    _PracticeCard(
                      item: item,
                      notifier: notifier,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.primary,
        borderColor: AppColors.primary.withAlpha(78),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Höflich, klar, alltagstauglich',
              languageCode: 'de',
              style: AppTypography.title.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            AppDirectionalText(
              'تدرّب على عبارات يومية مهذبة وسلوكيات اجتماعية عملية في ألمانيا دون تعميمات جامدة.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.selected,
    required this.onSelected,
  });

  final AlltagTopic? selected;
  final ValueChanged<AlltagTopic?> onSelected;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.secondary,
        borderColor: AppColors.secondary.withAlpha(72),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Thema wählen',
              languageCode: 'de',
              style: AppTypography.label.copyWith(color: AppColors.secondary),
            ),
            const SizedBox(height: 10),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _TopicChip(
                    labelDe: 'Alle',
                    selected: selected == null,
                    onTap: () => onSelected(null),
                  ),
                  for (final topic in AlltagTopic.values)
                    _TopicChip(
                      labelDe: topic.labelDe,
                      selected: selected == topic,
                      onTap: () => onSelected(topic),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({
    required this.labelDe,
    required this.selected,
    required this.onTap,
  });

  final String labelDe;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ChoiceChip(
        label: AppDirectionalText(
          labelDe,
          languageCode: 'de',
          style: AppTypography.label,
        ),
        selected: selected,
        selectedColor: AppColors.primary.withAlpha(30),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.secondary,
        ),
        onSelected: (_) => onTap(),
      );
}

class _SituationCard extends StatelessWidget {
  const _SituationCard({required this.item});

  final AlltagScenario item;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.achievement,
        borderColor: AppColors.achievement.withAlpha(72),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              item.topic.labelDe,
              languageCode: 'de',
              style: AppTypography.label.copyWith(
                color: AppColors.achievement,
              ),
            ),
            const SizedBox(height: 8),
            AppDirectionalText(
              item.contextDe,
              languageCode: 'de',
              style: AppTypography.body,
            ),
            const SizedBox(height: 8),
            AppDirectionalText(
              item.promptAr,
              languageCode: 'ar',
              style: AppTypography.title,
            ),
          ],
        ),
      );
}

class _PracticeCard extends StatelessWidget {
  const _PracticeCard({
    required this.item,
    required this.notifier,
  });

  final AlltagScenario item;
  final AlltagsspracheNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final checked = notifier.checked;
    final correct = notifier.isCorrect == true;

    return AppGlassCard(
      glowColor: checked
          ? (correct ? AppColors.mastery : AppColors.tertiary)
          : AppColors.secondary,
      borderColor: checked
          ? (correct
              ? AppColors.mastery.withAlpha(84)
              : AppColors.tertiary.withAlpha(84))
          : AppColors.secondary.withAlpha(72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'Welche Antwort passt am besten?',
            languageCode: 'de',
            style: AppTypography.title,
          ),
          const SizedBox(height: 12),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (var index = 0; index < item.optionsDe.length; index++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _AnswerCard(
                      text: item.optionsDe[index],
                      selected: notifier.selectedIndex == index,
                      checked: checked,
                      correct: index == item.correctIndex,
                      onTap: checked ? null : () => notifier.selectChoice(index),
                    ),
                  ),
              ],
            ),
          ),
          if (!checked) ...<Widget>[
            const SizedBox(height: 4),
            FilledButton.icon(
              onPressed: notifier.selectedIndex == null
                  ? null
                  : notifier.checkSelection,
              icon: const Icon(Icons.check_rounded),
              label: AppDirectionalText(
                'تحقق',
                languageCode: 'ar',
                style: AppTypography.label,
              ),
            ),
          ] else ...<Widget>[
            const SizedBox(height: 6),
            _FeedbackCard(
              item: item,
              correct: correct,
              feedbackAr: notifier.feedbackAr,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: notifier.nextScenario,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: AppDirectionalText(
                'الموقف التالي',
                languageCode: 'ar',
                style: AppTypography.label,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.text,
    required this.selected,
    required this.checked,
    required this.correct,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final bool checked;
  final bool correct;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = checked && correct
        ? AppColors.mastery
        : selected
            ? AppColors.primary
            : AppColors.secondary;

    return AppGlassCard(
      onTap: onTap,
      blur: 12,
      opacity: selected ? .16 : .08,
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderColor: accent.withAlpha(selected || (checked && correct) ? 100 : 48),
      glowColor: selected || (checked && correct) ? accent : null,
      child: AppDirectionalText(
        text,
        languageCode: 'de',
        style: AppTypography.body.copyWith(color: accent),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.item,
    required this.correct,
    required this.feedbackAr,
  });

  final AlltagScenario item;
  final bool correct;
  final String feedbackAr;

  @override
  Widget build(BuildContext context) {
    final accent = correct ? AppColors.mastery : AppColors.tertiary;
    return AppGlassCard(
      blur: 12,
      opacity: .10,
      borderRadius: 20,
      borderColor: accent.withAlpha(88),
      glowColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            correct ? 'Passend.' : 'Besser so:',
            languageCode: 'de',
            style: AppTypography.label.copyWith(color: accent),
          ),
          const SizedBox(height: 6),
          AppDirectionalText(
            item.correctAnswer,
            languageCode: 'de',
            style: AppTypography.title.copyWith(color: accent),
          ),
          const SizedBox(height: 6),
          AppDirectionalText(
            item.meaningAr,
            languageCode: 'ar',
            style: AppTypography.body,
          ),
          const SizedBox(height: 6),
          AppDirectionalText(
            item.etiquetteAr,
            languageCode: 'ar',
            style: AppTypography.body,
          ),
          const SizedBox(height: 6),
          AppDirectionalText(
            feedbackAr,
            languageCode: 'ar',
            style: AppTypography.label,
          ),
        ],
      ),
    );
  }
}
