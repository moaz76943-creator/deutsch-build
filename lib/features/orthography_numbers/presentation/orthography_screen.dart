import 'package:flutter/material.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart';
import '../application/orthography_notifier.dart';
import '../domain/orthography_models.dart';

class OrthographyScreen extends StatefulWidget {
  const OrthographyScreen({required this.notifier, super.key});

  final OrthographyNotifier notifier;

  @override
  State<OrthographyScreen> createState() => _OrthographyScreenState();
}

class _OrthographyScreenState extends State<OrthographyScreen> {
  String _draft = '';

  void _selectTopic(OrthographyTopic topic) {
    _draft = '';
    widget.notifier.filterByTopic(topic);
  }

  void _next() {
    _draft = '';
    widget.notifier.nextExercise();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: AppDirectionalText(
            'Kommaregeln & Rechtschreibung',
            languageCode: 'de',
            style: AppTypography.title,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: AnimatedBuilder(
              animation: widget.notifier,
              builder: (context, _) {
                final state = widget.notifier.state;
                final exercise = state.current;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TopicFilterCard(
                      selected: state.filter,
                      onSelected: _selectTopic,
                    ),
                    const SizedBox(height: 14),
                    _PromptCard(exercise: exercise),
                    const SizedBox(height: 14),
                    if (exercise.isCommaPlacement)
                      _CommaPlacementCard(
                        state: state,
                        onToggle: widget.notifier.toggleCommaAfter,
                        onCheck: widget.notifier.checkCommaPlacement,
                        onNext: _next,
                      )
                    else
                      _TextEntryCard(
                        state: state,
                        draft: _draft,
                        onChanged: (value) => _draft = value,
                        onCheck: () =>
                            widget.notifier.checkTextAnswer(_draft),
                        onNext: _next,
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      );
}

class _TopicFilterCard extends StatelessWidget {
  const _TopicFilterCard({
    required this.selected,
    required this.onSelected,
  });

  final OrthographyTopic? selected;
  final ValueChanged<OrthographyTopic> onSelected;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDirectionalText(
              'اختر نوع التدريب',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final topic in OrthographyTopic.values)
                  ChoiceChip(
                    label: AppDirectionalText(
                      topic.labelDe,
                      languageCode: 'de',
                      style: AppTypography.label,
                    ),
                    selected: selected == topic,
                    selectedColor: AppColors.primary.withAlpha(30),
                    side: BorderSide(
                      color: selected == topic
                          ? AppColors.primary
                          : AppColors.secondary,
                    ),
                    onSelected: (_) => onSelected(topic),
                  ),
              ],
            ),
          ],
        ),
      );
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.exercise});

  final OrthographyExercise exercise;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.secondary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDirectionalText(
              exercise.topic.labelDe,
              languageCode: 'de',
              style: AppTypography.label.copyWith(
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 8),
            AppDirectionalText(
              exercise.promptDe,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: 8),
            AppDirectionalText(
              exercise.instructionAr,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

class _CommaPlacementCard extends StatelessWidget {
  const _CommaPlacementCard({
    required this.state,
    required this.onToggle,
    required this.onCheck,
    required this.onNext,
  });

  final OrthographyState state;
  final ValueChanged<int> onToggle;
  final VoidCallback onCheck;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final exercise = state.current;
    return AppGlassCard(
      glowColor: state.checked
          ? (state.correct ? AppColors.mastery : AppColors.tertiary)
          : AppColors.achievement,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppDirectionalText(
            'اضغط على الكلمة التي تريد وضع فاصلة بعدها',
            languageCode: 'ar',
            style: AppTypography.body,
          ),
          const SizedBox(height: 12),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var index = 0;
                    index < exercise.tokens.length;
                    index++)
                  _CommaTokenButton(
                    token: exercise.tokens[index],
                    showComma: state.selectedCommaGaps.contains(index),
                    enabled:
                        !state.checked && index < exercise.tokens.length - 1,
                    onPressed: () => onToggle(index),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppDirectionalText(
            _renderSentence(exercise, state.selectedCommaGaps),
            languageCode: 'de',
            style: AppTypography.body,
          ),
          const SizedBox(height: 12),
          if (!state.checked)
            FilledButton.icon(
              onPressed: onCheck,
              icon: const Icon(Icons.check_rounded),
              label: AppDirectionalText(
                'تحقق من الفواصل',
                languageCode: 'ar',
                style: AppTypography.label,
              ),
            )
          else ...[
            _FeedbackPanel(state: state),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: AppDirectionalText(
                'التمرين التالي',
                languageCode: 'ar',
                style: AppTypography.label,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _renderSentence(
    OrthographyExercise exercise,
    Set<int> selectedGaps,
  ) {
    final parts = <String>[];
    for (var index = 0; index < exercise.tokens.length; index++) {
      final suffix = selectedGaps.contains(index) ? ',' : '';
      parts.add('${exercise.tokens[index]}$suffix');
    }
    return parts.join(' ');
  }
}

class _CommaTokenButton extends StatelessWidget {
  const _CommaTokenButton({
    required this.token,
    required this.showComma,
    required this.enabled,
    required this.onPressed,
  });

  final String token;
  final bool showComma;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final accent = showComma ? AppColors.achievement : AppColors.primary;
    return OutlinedButton(
      onPressed: enabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        backgroundColor: accent.withAlpha(18),
        side: BorderSide(color: accent),
      ),
      child: AppDirectionalText(
        showComma ? '$token,' : token,
        languageCode: 'de',
        style: AppTypography.body,
      ),
    );
  }
}

class _TextEntryCard extends StatelessWidget {
  const _TextEntryCard({
    required this.state,
    required this.draft,
    required this.onChanged,
    required this.onCheck,
    required this.onNext,
  });

  final OrthographyState state;
  final String draft;
  final ValueChanged<String> onChanged;
  final VoidCallback onCheck;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: state.checked
            ? (state.correct ? AppColors.mastery : AppColors.tertiary)
            : AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: ValueKey<String>(
                '${state.current.id}-${state.currentIndex}',
              ),
              initialValue: draft,
              enabled: !state.checked,
              textDirection: TextDirection.ltr,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: onChanged,
              onFieldSubmitted: state.checked ? null : (_) => onCheck(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Antwort',
              ),
            ),
            const SizedBox(height: 12),
            if (!state.checked)
              FilledButton.icon(
                onPressed: onCheck,
                icon: const Icon(Icons.check_rounded),
                label: AppDirectionalText(
                  'تحقق',
                  languageCode: 'ar',
                  style: AppTypography.label,
                ),
              )
            else ...[
              _FeedbackPanel(state: state),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: AppDirectionalText(
                  'التمرين التالي',
                  languageCode: 'ar',
                  style: AppTypography.label,
                ),
              ),
            ],
          ],
        ),
      );
}

class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel({required this.state});

  final OrthographyState state;

  @override
  Widget build(BuildContext context) {
    final accent = state.correct ? AppColors.mastery : AppColors.tertiary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withAlpha(90)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: AppDirectionalText(
          state.feedbackAr,
          languageCode: 'ar',
          style: AppTypography.body.copyWith(color: accent),
        ),
      ),
    );
  }
}
