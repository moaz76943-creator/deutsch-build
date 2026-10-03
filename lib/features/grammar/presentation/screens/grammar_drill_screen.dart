import 'package:flutter/material.dart';

import '../../../../design_system/app_colors.dart';
import '../../../../design_system/app_glass_card.dart';
import '../../../../design_system/app_typography.dart';
import '../../application/grammar_drill_notifier.dart';
import '../../domain/grammar_drill_models.dart';
import '../../../error_pattern_agent/domain/error_diagnostic_repository.dart';
import '../widgets/interactive_sentence_builder_widget.dart';

class GrammarDrillScreen extends StatefulWidget {
  const GrammarDrillScreen({
    required this.exercises,
    required this.levelLabel,
    this.errorDiagnosticSink,
    super.key,
  });

  final List<GrammarDrill> exercises;
  final String levelLabel;
  final ErrorDiagnosticSink? errorDiagnosticSink;

  @override
  State<GrammarDrillScreen> createState() => _GrammarDrillScreenState();
}

class _GrammarDrillScreenState extends State<GrammarDrillScreen> {
  late final GrammarDrillNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = GrammarDrillNotifier(
      widget.exercises,
      errorDiagnosticSink:
          widget.errorDiagnosticSink ?? const NoopErrorDiagnosticSink(),
    );
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text('تدريب القواعد · ${widget.levelLabel}'),
          ),
          body: AnimatedBuilder(
            animation: _notifier,
            builder: (context, _) {
              final state = _notifier.state;
              if (state.completed) {
                return _CompletionView(
                  state: state,
                  onRestart: _notifier.restart,
                );
              }
              final exercise = state.currentExercise;
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  _ProgressHeader(state: state),
                  const SizedBox(height: 14),
                  AppGlassCard(
                    glowColor: AppColors.achievement,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.titleAr,
                          style: AppTypography.title,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          exercise.instructionAr,
                          style: AppTypography.body,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ExerciseBody(
                    exercise: exercise,
                    state: state,
                    notifier: _notifier,
                  ),
                  const SizedBox(height: 14),
                  if (state.isAnswered)
                    AppGlassCard(
                      glowColor: state.lastAnswerCorrect
                          ? AppColors.mastery
                          : AppColors.tertiary,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            state.lastAnswerCorrect
                                ? Icons.check_circle_rounded
                                : Icons.refresh_rounded,
                            color: state.lastAnswerCorrect
                                ? AppColors.mastery
                                : AppColors.tertiary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              state.feedbackAr,
                              style: AppTypography.body,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: state.isAnswered
                        ? (state.lastAnswerCorrect
                            ? _notifier.next
                            : _notifier.retry)
                        : _notifier.checkAnswer,
                    icon: Icon(
                      state.isAnswered && !state.lastAnswerCorrect
                          ? Icons.refresh_rounded
                          : Icons.check_rounded,
                    ),
                    label: Text(
                      state.isAnswered
                          ? (state.lastAnswerCorrect
                              ? 'التمرين التالي'
                              : 'حاول مرة أخرى')
                          : 'تحقق من الإجابة',
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.state});

  final GrammarDrillState state;

  @override
  Widget build(BuildContext context) {
    final total = state.exercises.length;
    final current = state.currentIndex + 1;
    return AppGlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: current / total,
              minHeight: 8,
              borderRadius: BorderRadius.circular(12),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Text('$current/$total', style: AppTypography.label),
          const SizedBox(width: 14),
          Text('XP ${state.points}', style: AppTypography.label),
        ],
      ),
    );
  }
}

class _ExerciseBody extends StatelessWidget {
  const _ExerciseBody({
    required this.exercise,
    required this.state,
    required this.notifier,
  });

  final GrammarDrill exercise;
  final GrammarDrillState state;
  final GrammarDrillNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return switch (exercise) {
      SentenceReorderExercise sentence => InteractiveSentenceBuilderWidget(
          exercise: sentence,
          orderedTokenIds: state.orderedTokenIds,
          onAddToken: notifier.addSentenceToken,
          onRemoveToken: notifier.removeSentenceToken,
          enabled: !state.isAnswered,
        ),
      VerbConjugationDrill verb => _VerbConjugationCard(
          exercise: verb,
          value: state.selectedAnswer,
          enabled: !state.isAnswered,
          onChanged: notifier.setAnswer,
        ),
      CaseSelectionDrill grammarCase => _CaseSelectionCard(
          exercise: grammarCase,
          value: state.selectedAnswer,
          enabled: !state.isAnswered,
          onChanged: notifier.setAnswer,
        ),
    };
  }
}

class _VerbConjugationCard extends StatelessWidget {
  const _VerbConjugationCard({
    required this.exercise,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final VerbConjugationDrill exercise;
  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${exercise.pronoun} · ${exercise.infinitive}',
              textDirection: TextDirection.ltr,
              style: AppTypography.title,
            ),
            const SizedBox(height: 12),
            Text(
              '${exercise.sentencePrefix} ___ ${exercise.sentenceSuffix}',
              textDirection: TextDirection.ltr,
              style: AppTypography.body.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 14),
            TextFormField(
              key: ValueKey('${exercise.id}-$enabled'),
              enabled: enabled,
              initialValue: value,
              onChanged: onChanged,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'التصريف الصحيح',
              ),
            ),
          ],
        ),
      );
}

class _CaseSelectionCard extends StatelessWidget {
  const _CaseSelectionCard({
    required this.exercise,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final CaseSelectionDrill exercise;
  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final caseColor = switch (exercise.targetCase) {
      GrammarCase.nominative => AppColors.primary,
      GrammarCase.accusative => AppColors.tertiary,
      GrammarCase.dative => AppColors.secondary,
      GrammarCase.genitive => AppColors.achievement,
    };
    return AppGlassCard(
      glowColor: caseColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.rule_rounded, color: caseColor),
              const SizedBox(width: 8),
              Text(
                exercise.targetCase.label,
                style: AppTypography.label.copyWith(color: caseColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${exercise.sentenceBefore} ___ ${exercise.noun} '
            '${exercise.sentenceAfter}',
            textDirection: TextDirection.ltr,
            style: AppTypography.title,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in exercise.options)
                ChoiceChip(
                  label: Text(option, textDirection: TextDirection.ltr),
                  selected: value == option,
                  selectedColor: _articleColor(option).withAlpha(48),
                  side: BorderSide(color: _articleColor(option)),
                  onSelected:
                      enabled ? (_) => onChanged(option) : null,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _articleColor(String article) => switch (article.toLowerCase()) {
        'der' => AppColors.articleDer,
        'die' => AppColors.articleDie,
        'das' => AppColors.articleDas,
        'den' => AppColors.tertiary,
        'dem' => AppColors.secondary,
        _ => AppColors.articleOther,
      };
}

class _CompletionView extends StatelessWidget {
  const _CompletionView({
    required this.state,
    required this.onRestart,
  });

  final GrammarDrillState state;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final accuracy = (state.accuracy * 100).round();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AppGlassCard(
          glowColor: AppColors.mastery,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: AppColors.mastery,
                size: 52,
              ),
              const SizedBox(height: 12),
              Text('أكملت الجولة', style: AppTypography.title),
              const SizedBox(height: 8),
              Text(
                'الدقة $accuracy% · XP ${state.points}',
                style: AppTypography.body,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRestart,
                icon: const Icon(Icons.replay_rounded),
                label: const Text('ابدأ جولة جديدة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
