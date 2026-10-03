import 'dart:async';

import 'package:flutter/material.dart';

import '../../../design_system/app_audio_button.dart';
import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart';
import '../application/placement_test_notifier.dart';
import '../domain/placement_models.dart';
import 'placement_result_screen.dart';

class PlacementTestScreen extends StatefulWidget {
  const PlacementTestScreen({
    required this.notifier,
    required this.onStartLearning,
    super.key,
  });

  final PlacementTestNotifier notifier;
  final VoidCallback onStartLearning;

  @override
  State<PlacementTestScreen> createState() => _PlacementTestScreenState();
}

class _PlacementTestScreenState extends State<PlacementTestScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(widget.notifier.start());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.notifier,
      builder: (context, _) {
        final state = widget.notifier.state;
        final result = state.result;
        if (result != null) {
          return PlacementResultScreen(
            result: result,
            isApplyingResult: state.isApplyingResult,
            onStartLearning: widget.onStartLearning,
          );
        }

        final question = state.currentQuestion;
        return Scaffold(
          appBar: AppBar(title: const Text('اختبار تحديد المستوى')),
          body: SafeArea(
            child: question == null
                ? _buildEmptyState(state)
                : _buildQuestion(context, state, question),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(PlacementTestState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          state.errorMessage ?? 'لا توجد أسئلة تشخيصية متاحة.',
          textAlign: TextAlign.center,
          style: AppTypography.body,
        ),
      ),
    );
  }

  Widget _buildQuestion(
    BuildContext context,
    PlacementTestState state,
    PlacementQuestion question,
  ) {
    final session = state.session!;
    final number = session.answers.length + 1;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: <Widget>[
        AppGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          glowColor: AppColors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'السؤال $number',
                      style: AppTypography.label,
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(24),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Text(
                        question.level.label,
                        style: AppTypography.label.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: ((session.answers.length + 1) / session.maxQuestions)
                    .clamp(0.0, 1.0)
                    .toDouble(),
                minHeight: 7,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppGlassCard(
          glowColor: _patternColor(question.pattern),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                question.promptArabic,
                textDirection: TextDirection.rtl,
                style: AppTypography.title,
              ),
              if (question.hasAudio) ...<Widget>[
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    AppAudioButton(
                      onPressed: state.isPlayingAudio
                          ? null
                          : () => unawaited(
                                widget.notifier.replayCurrentAudio(),
                              ),
                      semanticLabel: 'إعادة الاستماع',
                      isBusy: state.isPlayingAudio,
                      activeColor: AppColors.secondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.audioUnavailable
                            ? 'الصوت غير متاح حالياً؛ يمكنك متابعة السؤال نصياً.'
                            : 'يمكنك إعادة الاستماع قبل اختيار الإجابة.',
                        textDirection: TextDirection.rtl,
                        style: AppTypography.body,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        for (final option in question.options) ...<Widget>[
          AppGlassCard(
            onTap: state.isLoading || state.isApplyingResult
                ? null
                : () => unawaited(
                      widget.notifier.submitOption(option.id),
                    ),
            glowColor: AppColors.secondary,
            borderColor: AppColors.secondary.withAlpha(55),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    option.text,
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (state.isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: LinearProgressIndicator(minHeight: 2),
          ),
        if (state.errorMessage != null) ...<Widget>[
          const SizedBox(height: 10),
          Text(
            state.errorMessage!,
            textDirection: TextDirection.rtl,
            style: AppTypography.label.copyWith(color: AppColors.articleDie),
          ),
        ],
      ],
    );
  }

  Color _patternColor(PlacementQuestionPattern pattern) => switch (pattern) {
        PlacementQuestionPattern.listening => AppColors.secondary,
        PlacementQuestionPattern.grammar => AppColors.achievement,
        PlacementQuestionPattern.translation => AppColors.primary,
        PlacementQuestionPattern.multipleChoice => AppColors.tertiary,
      };
}
