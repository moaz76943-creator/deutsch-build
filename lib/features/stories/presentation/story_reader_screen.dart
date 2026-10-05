import 'dart:async';

import 'package:flutter/material.dart';

import '../../../design_system/app_audio_button.dart';
import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart';
import '../application/story_reader_notifier.dart';
import '../domain/story_audio_port.dart';
import '../domain/story_models.dart';

class StoryReaderScreen extends StatefulWidget {
  const StoryReaderScreen({
    required this.notifier,
    required this.storyId,
    required this.audioPort,
    required this.onDone,
    super.key,
  });

  final StoryReaderNotifier notifier;
  final String storyId;
  final StoryAudioPort audioPort;
  final VoidCallback onDone;

  @override
  State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen> {
  bool _audioBusy = false;

  @override
  void initState() {
    super.initState();
    unawaited(widget.notifier.loadStory(widget.storyId));
  }

  Future<void> _speakParagraph(StoryReaderState state) async {
    final story = state.story;
    final paragraph = state.currentParagraph;
    if (story == null || paragraph == null || _audioBusy) return;

    setState(() => _audioBusy = true);
    try {
      await widget.audioPort.speak(
        text: paragraph.textGerman,
        conceptId: 'story.${story.id}.paragraph.${state.paragraphIndex}',
      );
    } finally {
      if (mounted) {
        setState(() => _audioBusy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AnimatedBuilder(
          animation: widget.notifier,
          builder: (context, _) {
            final state = widget.notifier.state;
            final story = state.story;
            if (story == null) {
              return Scaffold(
                appBar: AppBar(
                  title: AppDirectionalText(
                    'القصة',
                    languageCode: 'ar',
                    style: AppTypography.title,
                  ),
                ),
                body: Center(
                  child: state.isLoading
                      ? const CircularProgressIndicator()
                      : AppDirectionalText(
                          state.errorMessage ?? 'تعذر فتح القصة.',
                          languageCode: 'ar',
                          style: AppTypography.body,
                          textAlign: TextAlign.center,
                        ),
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: AppDirectionalText(
                  story.titleGerman,
                  languageCode: 'de',
                  style: AppTypography.title,
                ),
              ),
              body: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
                  children: <Widget>[
                    _storyProgress(story),
                    const SizedBox(height: 14),
                    _paragraphCard(state),
                    if (state.revealedWord != null) ...<Widget>[
                      const SizedBox(height: 12),
                      _wordMeaning(state.revealedWord!),
                    ],
                    const SizedBox(height: 12),
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
        ),
      );

  Widget _storyProgress(StoryItem story) => AppGlassCard(
        glowColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              story.titleGerman,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                Expanded(
                  child: AppDirectionalText(
                    story.titleArabic,
                    languageCode: 'ar',
                    style: AppTypography.body,
                  ),
                ),
                AppDirectionalText(
                  story.level.label,
                  languageCode: 'de',
                  style: AppTypography.label,
                ),
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
          Row(
            children: <Widget>[
              Expanded(
                child: AppDirectionalText(
                  'المشهد ${state.paragraphIndex + 1}',
                  languageCode: 'ar',
                  style: AppTypography.label,
                ),
              ),
              AppAudioButton(
                onPressed:
                    _audioBusy ? null : () => _speakParagraph(state),
                semanticLabel: 'استمع إلى نص المشهد بالألمانية',
                isBusy: _audioBusy,
                activeColor: AppColors.secondary,
              ),
            ],
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
      return AppDirectionalText(
        token.displayText,
        languageCode: 'de',
        style: AppTypography.body.copyWith(fontSize: 17),
      );
    }

    final selected =
        widget.notifier.state.revealedWord?.id == interactive.id;
    return Semantics(
      button: true,
      label: 'معنى ${interactive.surface}',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => widget.notifier.toggleWordMeaning(interactive.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          child: AppDirectionalText(
            token.displayText,
            languageCode: 'de',
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
              child: AppDirectionalText(
                word.surface,
                languageCode: 'de',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.title.copyWith(
                  color: AppColors.mastery,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_back_rounded, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: AppDirectionalText(
                word.meaningArabic,
                languageCode: 'ar',
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
            label: AppDirectionalText(
              state.showParagraphTranslation
                  ? 'إخفاء ترجمة المشهد'
                  : 'إظهار ترجمة المشهد',
              languageCode: 'ar',
              style: AppTypography.label,
            ),
          ),
          if (state.showParagraphTranslation)
            AppGlassCard(
              glowColor: AppColors.tertiary,
              child: AppDirectionalText(
                state.currentParagraph!.translationArabic,
                languageCode: 'ar',
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
              label: AppDirectionalText(
                'السابق',
                languageCode: 'ar',
                style: AppTypography.label,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton.icon(
              onPressed:
                  state.isLastParagraph ? null : widget.notifier.nextParagraph,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: AppDirectionalText(
                'التالي',
                languageCode: 'ar',
                style: AppTypography.label,
              ),
            ),
          ),
        ],
      );

  Widget _comprehension(
    StoryItem story,
    StoryReaderState state,
  ) =>
      AppGlassCard(
        glowColor: AppColors.achievement,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'فهم القصة',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
            const SizedBox(height: 4),
            AppDirectionalText(
              'أجب عن الأسئلة اعتماداً على السياق الذي قرأته.',
              languageCode: 'ar',
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
                child: AppDirectionalText(
                  'نتيجة الفهم: '
                  '${widget.notifier.comprehensionScorePercent}%',
                  languageCode: 'ar',
                  textAlign: TextAlign.center,
                  style: AppTypography.title.copyWith(
                    color: AppColors.mastery,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: widget.onDone,
                icon: const Icon(Icons.done_all_rounded),
                label: AppDirectionalText(
                  'إنهاء القصة',
                  languageCode: 'ar',
                  style: AppTypography.label,
                ),
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
        AppDirectionalText(
          question.promptArabic,
          languageCode: 'ar',
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        for (final option in question.options) ...<Widget>[
          AppGlassCard(
            onTap: () =>
                widget.notifier.answerQuestion(question.id, option.id),
            borderColor: selected == option.id
                ? (correct == true
                    ? AppColors.mastery
                    : AppColors.articleDie)
                : null,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            child: AppDirectionalText(
              option.textArabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ),
          const SizedBox(height: 7),
        ],
        if (selected != null)
          AppDirectionalText(
            correct == true
                ? 'إجابة صحيحة'
                : 'راجع المشهد وحاول من السياق.',
            languageCode: 'ar',
            style: AppTypography.label.copyWith(
              color:
                  correct == true ? AppColors.mastery : AppColors.articleDie,
            ),
          ),
      ],
    );
  }
}
