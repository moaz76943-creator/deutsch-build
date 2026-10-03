import 'package:flutter/material.dart';

import '../../../../design_system/app_colors.dart';
import '../../../../design_system/app_glass_card.dart';
import '../../../../design_system/app_typography.dart';
import '../../application/listening_session_notifier.dart';
import '../../domain/listening_models.dart';
import '../widgets/audio_wave_glass_card.dart';
import '../widgets/interactive_pronunciation_card.dart';

class ListeningPracticeScreen extends StatefulWidget {
  const ListeningPracticeScreen({
    required this.notifier,
    super.key,
  });

  final ListeningSessionNotifier notifier;

  @override
  State<ListeningPracticeScreen> createState() =>
      _ListeningPracticeScreenState();
}

class _ListeningPracticeScreenState extends State<ListeningPracticeScreen> {
  final TextEditingController _dictationController = TextEditingController();

  @override
  void dispose() {
    _dictationController.dispose();
    super.dispose();
  }

  Future<void> _recordPronunciation() async {
    await widget.notifier.evaluatePronunciation();
  }

  void _submitDictation() {
    if (widget.notifier.canAdvance) return;
    widget.notifier.submitDictation(_dictationController.text);
  }

  void _next() {
    if (widget.notifier.isComplete) return;
    widget.notifier.next();
    _dictationController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.notifier,
      builder: (context, _) {
        final notifier = widget.notifier;
        final drill = notifier.currentDrill;
        final answer = notifier.lastAnswer;
        return Scaffold(
          appBar: AppBar(
            title: const Text('تدريب الاستماع والنطق'),
          ),
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  _ProgressHeader(notifier: notifier),
                  const SizedBox(height: 12),
                  AudioWaveGlassCard(
                    isBusy: notifier.isPlaying,
                    onPlayNormal: () async {
                      await notifier.playCurrent();
                    },
                    onPlaySlow: () async {
                      await notifier.playCurrent(ListeningPlaybackSpeed.slow);
                    },
                  ),
                  const SizedBox(height: 12),
                  AppGlassCard(
                    child: Text(
                      drill.promptArabic,
                      style: AppTypography.title,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (drill.type == ListeningDrillType.multipleChoice)
                    _MultipleChoicePanel(
                      drill: drill,
                      enabled: !notifier.canAdvance,
                      onSelected: notifier.submitOption,
                    )
                  else
                    _DictationPanel(
                      controller: _dictationController,
                      enabled: !notifier.canAdvance,
                      onSubmit: _submitDictation,
                    ),
                  if (answer != null) ...<Widget>[
                    const SizedBox(height: 12),
                    _AnswerFeedback(answer: answer),
                  ],
                  const SizedBox(height: 12),
                  InteractivePronunciationCard(
                    feedback: notifier.pronunciationFeedback,
                    isRecording: notifier.isRecording,
                    onRecord:
                        notifier.isRecording ? null : _recordPronunciation,
                  ),
                  const SizedBox(height: 12),
                  if (notifier.canAdvance && !notifier.isComplete)
                    FilledButton(
                      onPressed: _next,
                      child: const Text('السؤال التالي'),
                    ),
                  if (notifier.isComplete)
                    AppGlassCard(
                      glowColor: AppColors.mastery,
                      borderColor: AppColors.mastery.withAlpha(100),
                      child: Text(
                        'اكتمل التدريب — النقاط ${notifier.score}',
                        style: AppTypography.title.copyWith(
                          color: AppColors.mastery,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.notifier});

  final ListeningSessionNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      borderColor: AppColors.secondary.withAlpha(80),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              'السؤال ${notifier.currentIndex + 1} من ${notifier.totalDrills}',
              style: AppTypography.label,
            ),
          ),
          Text(
            '${notifier.score} نقطة',
            style: AppTypography.label.copyWith(color: AppColors.secondary),
          ),
        ],
      ),
    );
  }
}

class _MultipleChoicePanel extends StatelessWidget {
  const _MultipleChoicePanel({
    required this.drill,
    required this.enabled,
    required this.onSelected,
  });

  final ListeningDrill drill;
  final bool enabled;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: drill.options
          .map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppGlassCard(
                key: ValueKey<String>('listening-option-${option.id}'),
                onTap: enabled ? () => onSelected(option.id) : null,
                borderColor: AppColors.primary.withAlpha(64),
                child: AppDirectionalText(
                  option.text,
                  languageCode: drill.languageCode,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _DictationPanel extends StatelessWidget {
  const _DictationPanel({
    required this.controller,
    required this.enabled,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      borderColor: AppColors.primary.withAlpha(64),
      child: Column(
        children: <Widget>[
          Directionality(
            textDirection: TextDirection.ltr,
            child: TextField(
              controller: controller,
              enabled: enabled,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'اكتب ما سمعته بالألمانية',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: enabled ? onSubmit : null,
              child: const Text('تحقق'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerFeedback extends StatelessWidget {
  const _AnswerFeedback({required this.answer});

  final ListeningAnswerResult answer;

  @override
  Widget build(BuildContext context) {
    final color = answer.correct ? AppColors.mastery : AppColors.articleDie;
    return AppGlassCard(
      borderColor: color.withAlpha(90),
      glowColor: color,
      child: Row(
        children: <Widget>[
          Icon(
            answer.correct
                ? Icons.check_circle_outline_rounded
                : Icons.refresh_rounded,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              answer.correct
                  ? 'إجابة صحيحة +${answer.pointsAwarded}'
                  : 'الإجابة غير مطابقة. أعد الاستماع قبل الانتقال.',
              style: AppTypography.body.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
