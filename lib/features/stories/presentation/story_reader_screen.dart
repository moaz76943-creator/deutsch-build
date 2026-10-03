import 'dart:async';

import 'package:flutter/material.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart';
import '../application/story_reader_notifier.dart';
import '../domain/story_models.dart';

class StoryReaderScreen extends StatefulWidget {
  const StoryReaderScreen({
    required this.notifier,
    required this.storyId,
    required this.onDone,
    super.key,
  });

  final StoryReaderNotifier notifier;
  final String storyId;
  final VoidCallback onDone;

  @override
  State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(widget.notifier.loadStory(widget.storyId));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.notifier,
      builder: (context, _) {
        final state = widget.notifier.state;
        final story = state.story;
        if (story == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('القصة')),
            body: Center(
              child: state.isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      state.errorMessage ?? 'تعذر فتح القصة.',
                      style: AppTypography.body,
                    ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(story.titleGerman)),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: <Widget>[
                _storyProgress(story, state),
                const SizedBox(height: 14),
                _paragraphCard(state),
                const SizedBox(height: 12),
                if (state.revealedWord != null) _wordMeaning(state.revealedWord!),
                if (state.revealedWord != null) const SizedBox(height: 12),
                _translationCard(state),
                const SizedBox(height: 14),
                _navigation(state),
                if (state.isLastParagraph) ...<Widget>[
                  const SizedBox(height: 22),
                  _comprehension(story, state),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _storyProgress(StoryItem story, StoryReaderState state) => AppGlassCard(
        glowColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    story.titleArabic,
                    textDirection: TextDirection.rtl,
                    style: AppTypography.title,
                  ),
                ),
                Text(story.level.label, style: AppTypography.label),
              ],
            ),
            const SizedBox(height: 9),
            LinearProgressIndicator(
              value: widget.notifier.completionFraction,
              minHeight: 7,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
      );

  Widget _paragraphCard(StoryReaderState state) {
    final paragraph = state.currentParagraph!;
    return AppGlassCard(
      glowColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'الفقرة ${state.paragraphIndex + 1}',
            textDirection: TextDirection.rtl,
            style: AppTypography.label,
          ),
          const SizedBox(height: 12),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Wrap(
              spacing: 6,
              runSpacing: 10,
              children: <Widget>[
                for (final token in paragraph.tokens) _wordToken(token),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _wordToken(StoryWordToken token) {
    final interactive = token.interactiveWord;
    if (interactive == null) {
      return Text(token.displayText, style: AppTypography.body.copyWith(fontSize: 17));
    }
    final selected = widget.notifier.state.revealedWord?.id == interactive.id;
    return Semantics(
      button: true,
      label: 'معنى ${interactive.surface}',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => widget.notifier.toggleWordMeaning(interactive.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          child: Text(
            token.displayText,
            style: AppTypography.body.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: selected ? AppColors.secondary : AppColors.primary,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dotted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _wordMeaning(StoryInteractiveWord word) => AppGlassCard(
        glowColor: AppColors.mastery,
        borderColor: AppColors.mastery.withAlpha(75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: <Widget>[
            Flexible(
              child: Text(
                word.surface,
                textDirection: TextDirection.ltr,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.title.copyWith(color: AppColors.mastery),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_back_rounded, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                word.meaningArabic,
                textDirection: TextDirection.rtl,
                style: AppTypography.body,
              ),
            ),
          ],
        ),
      );

  Widget _translationCard(StoryReaderState state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextButton.icon(
            onPressed: widget.notifier.toggleParagraphTranslation,
            icon: Icon(
              state.showParagraphTranslation
                  ? Icons.visibility_off_outlined
                  : Icons.translate_rounded,
            ),
            label: Text(
              state.showParagraphTranslation
                  ? 'إخفاء ترجمة الفقرة'
                  : 'إظهار ترجمة الفقرة',
            ),
          ),
          if (state.showParagraphTranslation)
            AppGlassCard(
              glowColor: AppColors.tertiary,
              child: Text(
                state.currentParagraph!.translationArabic,
                textDirection: TextDirection.rtl,
                style: AppTypography.body,
              ),
            ),
        ],
      );

  Widget _navigation(StoryReaderState state) => Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: state.paragraphIndex == 0
                  ? null
                  : widget.notifier.previousParagraph,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('السابق'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton.icon(
              onPressed: state.isLastParagraph ? null : widget.notifier.nextParagraph,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('التالي'),
            ),
          ),
        ],
      );

  Widget _comprehension(StoryItem story, StoryReaderState state) => AppGlassCard(
        glowColor: AppColors.achievement,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('فهم القصة', style: AppTypography.title),
            const SizedBox(height: 4),
            Text(
              'أجب عن الأسئلة اعتماداً على السياق الذي قرأته.',
              textDirection: TextDirection.rtl,
              style: AppTypography.body,
            ),
            const SizedBox(height: 14),
            for (final question in story.questions) ...<Widget>[
              _questionBlock(question, state),
              const SizedBox(height: 16),
            ],
            if (widget.notifier.comprehensionComplete) ...<Widget>[
              AppGlassCard(
                glowColor: AppColors.mastery,
                child: Text(
                  'نتيجة الفهم: ${widget.notifier.comprehensionScorePercent}%',
                  textAlign: TextAlign.center,
                  style: AppTypography.title.copyWith(color: AppColors.mastery),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: widget.onDone,
                icon: const Icon(Icons.done_all_rounded),
                label: const Text('إنهاء القصة'),
              ),
            ],
          ],
        ),
      );

  Widget _questionBlock(
    StoryComprehensionQuestion question,
    StoryReaderState state,
  ) {
    final selected = state.answers[question.id];
    final correct = state.answerCorrectness[question.id];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          question.promptArabic,
          textDirection: TextDirection.rtl,
          style: AppTypography.body.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        for (final option in question.options) ...<Widget>[
          AppGlassCard(
            onTap: () => widget.notifier.answerQuestion(question.id, option.id),
            borderColor: selected == option.id
                ? (correct == true ? AppColors.mastery : AppColors.articleDie)
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Text(
              option.textArabic,
              textDirection: TextDirection.rtl,
              style: AppTypography.body,
            ),
          ),
          const SizedBox(height: 7),
        ],
        if (selected != null)
          Text(
            correct == true ? 'إجابة صحيحة' : 'راجع الفقرة وحاول من السياق.',
            textDirection: TextDirection.rtl,
            style: AppTypography.label.copyWith(
              color: correct == true ? AppColors.mastery : AppColors.articleDie,
            ),
          ),
      ],
    );
  }
}
