import 'package:flutter/material.dart';

import '../../../../core/explain_why/deterministic_explain_why_engine.dart';
import '../../../../design_system/app_audio_button.dart';
import '../../../../design_system/app_colors.dart';
import '../../../../design_system/app_glass_card.dart';
import '../../../../design_system/app_typography.dart';
import '../../application/grammar_drill_notifier.dart';
import '../../domain/grammar_drill_models.dart';
import '../../../error_pattern_agent/domain/error_diagnostic_repository.dart';
import '../widgets/explain_why_feedback_card.dart';
import '../widgets/interactive_sentence_builder_widget.dart';

class GrammarDrillScreen extends StatefulWidget {
  const GrammarDrillScreen({
    required this.exercises,
    required this.levelLabel,
    required this.explainWhyEngine,
    required this.targetLanguageCode,
    required this.onSpeakGerman,
    this.errorDiagnosticSink,
    super.key,
  });

  final List<GrammarDrill> exercises;
  final String levelLabel;
  final ExplainWhyEngine explainWhyEngine;
  final String targetLanguageCode;
  final void Function(String text, String conceptId) onSpeakGerman;
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
      explainWhyEngine: widget.explainWhyEngine,
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
            title: AppDirectionalText(
              'تدريب القواعد · ${widget.levelLabel}',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
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
                children: <Widget>[
                  _ProgressHeader(state: state),
                  const SizedBox(height: 14),
                  AppGlassCard(
                    glowColor: AppColors.achievement,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        AppDirectionalText(
                          exercise.titleAr,
                          languageCode: 'ar',
                          style: AppTypography.title,
                        ),
                        const SizedBox(height: 5),
                        AppDirectionalText(
                          exercise.instructionAr,
                          languageCode: 'ar',
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
                    targetLanguageCode: widget.targetLanguageCode,
                    onSpeakGerman: widget.onSpeakGerman,
                  ),
                  const SizedBox(height: 14),
                  if (state.isAnswered)
                    ExplainWhyFeedbackCard(
                      explanation: state.feedbackAr,
                      reasonCode: state.feedbackReasonCode ?? 'unknown',
                      correct: state.lastAnswerCorrect,
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
                    label: AppDirectionalText(
                      state.isAnswered
                          ? (state.lastAnswerCorrect
                              ? 'التمرين التالي'
                              : 'حاول مرة أخرى')
                          : 'تحقق من الإجابة',
                      languageCode: 'ar',
                      style: AppTypography.label,
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
        children: <Widget>[
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
    required this.targetLanguageCode,
    required this.onSpeakGerman,
  });

  final GrammarDrill exercise;
  final GrammarDrillState state;
  final GrammarDrillNotifier notifier;
  final String targetLanguageCode;
  final void Function(String text, String conceptId) onSpeakGerman;

  @override
  Widget build(BuildContext context) {
    return switch (exercise) {
      SentenceReorderExercise sentence => InteractiveSentenceBuilderWidget(
          exercise: sentence,
          orderedTokenIds: state.orderedTokenIds,
          onAddToken: notifier.addSentenceToken,
          onRemoveToken: notifier.removeSentenceToken,
          enabled: !state.isAnswered,
          targetLanguageCode: targetLanguageCode,
          onSpeakSentence: state.isAnswered && state.lastAnswerCorrect
              ? () => onSpeakGerman(
                    _correctSentence(sentence),
                    'grammar.drill.${sentence.id}.answer',
                  )
              : null,
        ),
      VerbConjugationDrill verb => _VerbConjugationCard(
          exercise: verb,
          value: state.selectedAnswer,
          enabled: !state.isAnswered,
          targetLanguageCode: targetLanguageCode,
          onChanged: notifier.setAnswer,
          onSpeakGerman: onSpeakGerman,
        ),
      CaseSelectionDrill grammarCase => _CaseSelectionCard(
          exercise: grammarCase,
          value: state.selectedAnswer,
          enabled: !state.isAnswered,
          targetLanguageCode: targetLanguageCode,
          onChanged: notifier.setAnswer,
          onSpeakGerman: onSpeakGerman,
        ),
    };
  }
}

class _VerbConjugationCard extends StatelessWidget {
  const _VerbConjugationCard({
    required this.exercise,
    required this.value,
    required this.enabled,
    required this.targetLanguageCode,
    required this.onChanged,
    required this.onSpeakGerman,
  });

  final VerbConjugationDrill exercise;
  final String value;
  final bool enabled;
  final String targetLanguageCode;
  final ValueChanged<String> onChanged;
  final void Function(String text, String conceptId) onSpeakGerman;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: AppDirectionalText(
                    '${exercise.pronoun} · ${exercise.infinitive}',
                    languageCode: targetLanguageCode,
                    style: AppTypography.title,
                  ),
                ),
                const SizedBox(width: 10),
                AppAudioButton(
                  onPressed: () => onSpeakGerman(
                    exercise.infinitive,
                    'grammar.drill.${exercise.id}.infinitive',
                  ),
                  semanticLabel: 'استمع إلى الفعل ${exercise.infinitive}',
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppDirectionalText(
              '${exercise.sentencePrefix} ___ ${exercise.sentenceSuffix}',
              languageCode: targetLanguageCode,
              style: AppTypography.body.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 14),
            TextFormField(
              key: ValueKey('${exercise.id}-$enabled'),
              enabled: enabled,
              initialValue: value,
              onChanged: onChanged,
              textDirection: TextDirection.ltr,
              style: AppTypography.body,
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
    required this.targetLanguageCode,
    required this.onChanged,
    required this.onSpeakGerman,
  });

  final CaseSelectionDrill exercise;
  final String value;
  final bool enabled;
  final String targetLanguageCode;
  final ValueChanged<String> onChanged;
  final void Function(String text, String conceptId) onSpeakGerman;

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
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.rule_rounded, color: caseColor),
              const SizedBox(width: 8),
              Expanded(
                child: AppDirectionalText(
                  exercise.targetCase.label,
                  languageCode: targetLanguageCode,
                  style: AppTypography.label.copyWith(color: caseColor),
                ),
              ),
              AppAudioButton(
                onPressed: () => onSpeakGerman(
                  exercise.noun,
                  'grammar.drill.${exercise.id}.noun',
                ),
                semanticLabel: 'استمع إلى الاسم ${exercise.noun}',
                activeColor: caseColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppDirectionalText(
            '${exercise.sentenceBefore} ___ ${exercise.noun} '
            '${exercise.sentenceAfter}',
            languageCode: targetLanguageCode,
            style: AppTypography.title,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final option in exercise.options)
                ChoiceChip(
                  label: AppDirectionalText(
                    option,
                    languageCode: targetLanguageCode,
                    style: AppTypography.label,
                  ),
                  selected: value == option,
                  selectedColor: _articleColor(option).withAlpha(48),
                  side: BorderSide(color: _articleColor(option)),
                  onSelected: enabled ? (_) => onChanged(option) : null,
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
            children: <Widget>[
              const Icon(
                Icons.emoji_events_rounded,
                color: AppColors.mastery,
                size: 52,
              ),
              const SizedBox(height: 12),
              AppDirectionalText(
                'أكملت الجولة',
                languageCode: 'ar',
                style: AppTypography.title,
              ),
              const SizedBox(height: 8),
              AppDirectionalText(
                'الدقة $accuracy% · XP ${state.points}',
                languageCode: 'ar',
                style: AppTypography.body,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRestart,
                icon: const Icon(Icons.replay_rounded),
                label: AppDirectionalText(
                  'ابدأ جولة جديدة',
                  languageCode: 'ar',
                  style: AppTypography.label,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _correctSentence(SentenceReorderExercise exercise) {
  final byId = <String, String>{
    for (final token in exercise.tokens) token.id: token.text,
  };
  return exercise.correctTokenIds
      .map((id) => byId[id])
      .whereType<String>()
      .join(' ');
}
