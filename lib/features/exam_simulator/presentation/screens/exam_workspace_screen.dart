import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../application/exam_session_notifier.dart';
import '../../domain/exam_models.dart';

final class ExamWorkspaceScreen extends StatelessWidget {
  const ExamWorkspaceScreen({
    required this.notifier,
    this.onReportReady,
    super.key,
  });

  final ExamSessionNotifier notifier;
  final ValueChanged<ExamScoreReport>? onReportReady;

  @override
  Widget build(BuildContext context) {
    final initial = notifier.state;
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<ExamSessionState>(
          stream: notifier.changes,
          initialData: initial,
          builder: (context, snapshot) {
            final state = snapshot.data ?? initial;
            return _WorkspaceBody(
              state: state,
              notifier: notifier,
              onReportReady: onReportReady,
            );
          },
        ),
      ),
    );
  }
}

final class _WorkspaceBody extends StatelessWidget {
  const _WorkspaceBody({
    required this.state,
    required this.notifier,
    required this.onReportReady,
  });

  final ExamSessionState state;
  final ExamSessionNotifier notifier;
  final ValueChanged<ExamScoreReport>? onReportReady;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final question = state.currentQuestion;
    final selected = state.session.answers[question.id];

    return ColoredBox(
      color: dark ? AppColors.darkBackground : AppColors.lightBackground,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: _ExamTopBar(state: state, dark: dark),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: <Widget>[
                Text(
                  question.section.label,
                  style: AppTypography.label.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                AppGlassCard(
                  borderColor: dark
                      ? AppColors.glassBorderDark
                      : AppColors.glassBorderLight,
                  backgroundColor:
                      dark ? AppColors.darkSurface : AppColors.lightSurface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (question.stimulus != null) ...<Widget>[
                        Text(
                          question.stimulus!,
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(question.prompt, style: AppTypography.title),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                for (var index = 0;
                    index < question.options.length;
                    index++) ...<Widget>[
                  _ExamOptionCard(
                    label: question.options[index],
                    selected: selected == index,
                    enabled: !state.isFinished,
                    onTap: () => notifier.answerCurrent(index),
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: state.isFinished ||
                                state.session.currentQuestionIndex == 0
                            ? null
                            : () => notifier.goPrevious(),
                        icon: const Icon(Icons.chevron_left_rounded),
                        label: const Text('السابق'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: state.isFinished
                            ? null
                            : () {
                                if (!notifier.goNext()) {
                                  final report = notifier.submit(
                                    submittedAtUtc: DateTime.now().toUtc(),
                                  );
                                  onReportReady?.call(report);
                                }
                              },
                        icon: Icon(
                          state.session.currentQuestionIndex ==
                                  state.exam.questions.length - 1
                              ? Icons.check_rounded
                              : Icons.chevron_right_rounded,
                        ),
                        label: Text(
                          state.session.currentQuestionIndex ==
                                  state.exam.questions.length - 1
                              ? 'إنهاء'
                              : 'التالي',
                        ),
                      ),
                    ),
                  ],
                ),
                if (state.report != null) ...<Widget>[
                  const SizedBox(height: 14),
                  AppGlassCard(
                    glowColor: AppColors.mastery,
                    child: Text(
                      'تم إنهاء الاختبار وحساب النتيجة.',
                      style: AppTypography.body,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _ExamTopBar extends StatelessWidget {
  const _ExamTopBar({
    required this.state,
    required this.dark,
  });

  final ExamSessionState state;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final minutes = state.remainingSeconds ~/ 60;
    final seconds = state.remainingSeconds % 60;
    final timerText =
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    return AppGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderColor:
          dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Row(
        children: <Widget>[
          const Icon(Icons.timer_outlined, color: AppColors.tertiary),
          const SizedBox(width: 8),
          Text(timerText, style: AppTypography.title.copyWith(fontSize: 17)),
          const SizedBox(width: 12),
          Expanded(
            child: LinearProgressIndicator(
              value: state.progress,
              minHeight: 7,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${state.session.currentQuestionIndex + 1}/'
            '${state.exam.questions.length}',
            style: AppTypography.label,
          ),
        ],
      ),
    );
  }
}

final class _ExamOptionCard extends StatelessWidget {
  const _ExamOptionCard({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AppGlassCard(
      onTap: enabled ? onTap : null,
      borderColor: selected
          ? AppColors.primary
          : dark
              ? AppColors.glassBorderDark
              : AppColors.glassBorderLight,
      glowColor: selected ? AppColors.primary : null,
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Row(
        children: <Widget>[
          Icon(
            selected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_off_rounded,
            color: selected ? AppColors.primary : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTypography.body,
            ),
          ),
        ],
      ),
    );
  }
}
