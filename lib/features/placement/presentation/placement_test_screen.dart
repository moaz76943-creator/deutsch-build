import 'dart:async';

import 'package:flutter/material.dart';

import '../../../design_system/app_audio_button.dart';
import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart';
import '../../learning/presentation/widgets/smart_orb.dart';
import '../application/placement_test_notifier.dart';
import '../domain/placement_models.dart';
import 'placement_result_screen.dart';

class PlacementTestScreen extends StatelessWidget {
  const PlacementTestScreen({
    required this.notifier,
    required this.onStartLearning,
    super.key,
  });

  final PlacementTestNotifier notifier;
  final VoidCallback onStartLearning;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: notifier,
      builder: (context, _) {
        final state = notifier.state;
        final result = state.result;
        if (result != null) {
          return PlacementResultScreen(
            result: result,
            resultPersisted: state.resultPersisted,
            isApplyingResult: state.isApplyingResult,
            errorMessage: state.errorMessage,
            onRetryPersist: () => unawaited(notifier.retry()),
            onStartLearning: onStartLearning,
          );
        }

        if (!state.hasStarted) {
          return _buildOnboarding(context, state);
        }

        final question = state.currentQuestion;
        return Scaffold(
          appBar: AppBar(title: const Text('اختبار تحديد المستوى')),
          body: SafeArea(
            child: question == null
                ? _buildEmptyState(
                    state,
                    onRetry: () => unawaited(notifier.retry()),
                  )
                : _buildQuestion(context, state, question),
          ),
        );
      },
    );
  }

  Widget _buildOnboarding(
    BuildContext context,
    PlacementTestState state,
  ) {
    final selected = state.learningGoal;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
          children: <Widget>[
            Center(
              child: SmartOrb(
                state: SmartOrbDomainState(
                  feedback: selected == null
                      ? SmartOrbFeedback.neutral
                      : SmartOrbFeedback.guidance,
                ),
                size: 118,
                semanticsLabel: 'مرشد تحديد المستوى',
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'ابدأ من المستوى المناسب لك',
              textAlign: TextAlign.center,
              style: AppTypography.display,
            ),
            const SizedBox(height: 8),
            Text(
              'اختر هدفك أولاً. بعدها سنطرح اختباراً قصيراً متكيّفاً من A1 إلى B2.',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: AppTypography.body,
            ),
            const SizedBox(height: 18),
            for (final goal in const <PlacementLearningGoal>[
              PlacementLearningGoal.dailyLife,
              PlacementLearningGoal.work,
              PlacementLearningGoal.studyExam,
              PlacementLearningGoal.travel,
            ]) ...<Widget>[
              AppGlassCard(
                onTap: state.isLoading ? null : () => notifier.selectGoal(goal),
                glowColor: selected == goal
                    ? AppColors.primary
                    : AppColors.secondary,
                borderColor: selected == goal
                    ? AppColors.primary
                    : AppColors.secondary.withAlpha(48),
                child: Row(
                  children: <Widget>[
                    Icon(
                      _goalIcon(goal),
                      color: selected == goal
                          ? AppColors.primary
                          : AppColors.secondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _goalLabel(goal),
                        style: AppTypography.title,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    if (selected == goal)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: selected == null || state.isLoading
                  ? null
                  : () => unawaited(notifier.start()),
              icon: state.isLoading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(
                state.isLoading
                    ? 'جاري تجهيز الأسئلة…'
                    : state.errorMessage == null
                        ? 'ابدأ الاختبار السريع'
                        : 'إعادة المحاولة',
              ),
            ),
            if (state.errorMessage != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: AppTypography.label.copyWith(
                  color: AppColors.articleDie,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    PlacementTestState state, {
    required VoidCallback onRetry,
  }) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              state.errorMessage ?? 'لا توجد أسئلة تشخيصية متاحة.',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: AppTypography.body,
            ),
            if (state.errorMessage != null) ...<Widget>[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('متابعة الاختبار'),
              ),
            ],
          ],
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
        Center(
          child: SmartOrb(
            state: SmartOrbDomainState(
              isSpeaking: state.isPlayingAudio,
              feedback: _orbFeedback(state),
            ),
            size: 104,
            semanticsLabel: 'مرشد السؤال الحالي',
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _orbGuidance(state),
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: AppTypography.label,
        ),
        const SizedBox(height: 14),
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
                          : () => unawaited(notifier.replayCurrentAudio()),
                      semanticLabel: 'إعادة الاستماع',
                      isBusy: state.isPlayingAudio,
                      activeColor: AppColors.secondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.audioUnavailable
                            ? 'الصوت غير متاح حالياً؛ تابع بقية الاختبار.'
                            : 'استمع ثم اختر الإجابة الأقرب.',
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
                : () => unawaited(notifier.submitOption(option.id)),
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

  SmartOrbFeedback _orbFeedback(PlacementTestState state) {
    if (state.lastAnswerCorrect == true) return SmartOrbFeedback.success;
    if (state.lastAnswerCorrect == false) return SmartOrbFeedback.incorrect;
    return SmartOrbFeedback.guidance;
  }

  String _orbGuidance(PlacementTestState state) {
    if (state.isPlayingAudio) return 'استمع الآن؛ لا حاجة للاستعجال.';
    if (state.lastAnswerCorrect == true) {
      return 'إجابة جيدة. سنرفع الصعوبة تدريجياً.';
    }
    if (state.lastAnswerCorrect == false) {
      return 'سنكيّف السؤال التالي مع مستواك.';
    }
    return 'اختر الإجابة الأقرب لما تعرفه الآن.';
  }

  String _goalLabel(PlacementLearningGoal goal) => switch (goal) {
        PlacementLearningGoal.dailyLife => 'الحياة اليومية والتواصل',
        PlacementLearningGoal.work => 'العمل والمسار المهني',
        PlacementLearningGoal.studyExam => 'الدراسة والاستعداد للامتحانات',
        PlacementLearningGoal.travel => 'السفر والمواقف العملية',
        PlacementLearningGoal.general => 'تعلّم عام',
      };

  IconData _goalIcon(PlacementLearningGoal goal) => switch (goal) {
        PlacementLearningGoal.dailyLife => Icons.forum_outlined,
        PlacementLearningGoal.work => Icons.work_outline_rounded,
        PlacementLearningGoal.studyExam => Icons.school_outlined,
        PlacementLearningGoal.travel => Icons.luggage_outlined,
        PlacementLearningGoal.general => Icons.language_rounded,
      };

  Color _patternColor(PlacementQuestionPattern pattern) => switch (pattern) {
        PlacementQuestionPattern.listening => AppColors.secondary,
        PlacementQuestionPattern.grammar => AppColors.achievement,
        PlacementQuestionPattern.translation => AppColors.primary,
        PlacementQuestionPattern.multipleChoice => AppColors.tertiary,
      };
}
