import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../design_system/app_colors.dart';
import '../../../../design_system/app_glass_card.dart';
import '../../../../design_system/app_typography.dart';
import '../../application/verb_drill_notifier.dart';

class RapidConjugationDrillWidget extends StatefulWidget {
  const RapidConjugationDrillWidget({required this.notifier, super.key});

  final VerbDrillNotifier notifier;

  @override
  State<RapidConjugationDrillWidget> createState() =>
      _RapidConjugationDrillWidgetState();
}

class _RapidConjugationDrillWidgetState
    extends State<RapidConjugationDrillWidget> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => widget.notifier.tick(),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: widget.notifier,
        builder: (context, _) {
          final notifier = widget.notifier;
          if (!notifier.started) {
            return _StartArenaCard(onStart: () => notifier.start());
          }
          if (notifier.completed) {
            return _ArenaSummary(notifier: notifier);
          }
          final question = notifier.currentQuestion;
          if (question == null) return const SizedBox.shrink();

          return AppGlassCard(
            glowColor: notifier.remainingSeconds <= 4
                ? AppColors.tertiary
                : AppColors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ArenaHeader(notifier: notifier),
                const SizedBox(height: 16),
                Text(
                  '${question.pronoun.label} · ${question.verb.infinitive}',
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  style: AppTypography.display.copyWith(fontSize: 26),
                ),
                const SizedBox(height: 4),
                Text(
                  '${question.tense.label} · ${question.verb.meaningAr}',
                  textAlign: TextAlign.center,
                  style: AppTypography.body,
                ),
                const SizedBox(height: 18),
                if (question.mode == VerbDrillMode.multipleChoice)
                  _MultipleChoiceBody(
                    notifier: notifier,
                    options: question.options,
                  )
                else
                  _LetterOrderBody(notifier: notifier),
                const SizedBox(height: 14),
                if (notifier.answered)
                  _AnswerFeedback(notifier: notifier),
                const SizedBox(height: 12),
                if (notifier.answered)
                  FilledButton.icon(
                    onPressed: notifier.next,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('التالي'),
                  ),
              ],
            ),
          );
        },
      );
}

class _StartArenaCard extends StatelessWidget {
  const _StartArenaCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.streak,
        child: Column(
          children: [
            const Icon(
              Icons.bolt_rounded,
              color: AppColors.streak,
              size: 46,
            ),
            const SizedBox(height: 8),
            Text('ساحة التصريف السريع', style: AppTypography.title),
            const SizedBox(height: 6),
            Text(
              '10 أسئلة · اختيار متعدد وترتيب حروف · نقاط أعلى للإجابة الأسرع.',
              textAlign: TextAlign.center,
              style: AppTypography.body,
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('ابدأ التحدي'),
            ),
          ],
        ),
      );
}

class _ArenaHeader extends StatelessWidget {
  const _ArenaHeader({required this.notifier});

  final VerbDrillNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final timerValue =
        notifier.remainingSeconds / notifier.secondsPerQuestion;
    return Column(
      children: [
        Row(
          children: [
            Text(
              '${notifier.questionIndex + 1}/${notifier.totalQuestions}',
              style: AppTypography.label,
            ),
            const Spacer(),
            Text(
              '⚡ ${notifier.score}',
              style: AppTypography.label,
            ),
            const SizedBox(width: 12),
            Text(
              '${notifier.remainingSeconds}s',
              textDirection: TextDirection.ltr,
              style: AppTypography.label.copyWith(
                color: notifier.remainingSeconds <= 4
                    ? AppColors.tertiary
                    : AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: timerValue.clamp(0.0, 1.0).toDouble(),
          minHeight: 8,
          borderRadius: BorderRadius.circular(12),
          valueColor: AlwaysStoppedAnimation<Color>(
            notifier.remainingSeconds <= 4
                ? AppColors.tertiary
                : AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _MultipleChoiceBody extends StatelessWidget {
  const _MultipleChoiceBody({
    required this.notifier,
    required this.options,
  });

  final VerbDrillNotifier notifier;
  final List<String> options;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          for (final option in options)
            OutlinedButton(
              onPressed:
                  notifier.answered ? null : () => notifier.submit(option),
              child: Text(
                option,
                textDirection: TextDirection.ltr,
              ),
            ),
        ],
      );
}

class _LetterOrderBody extends StatelessWidget {
  const _LetterOrderBody({required this.notifier});

  final VerbDrillNotifier notifier;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 54),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withAlpha(90),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primary.withAlpha(80),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              notifier.letterAnswer.isEmpty
                  ? 'رتّب الحروف'
                  : notifier.letterAnswer,
              textDirection: TextDirection.ltr,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            alignment: WrapAlignment.center,
            children: [
              for (final tile in notifier.availableLetterTiles)
                ActionChip(
                  onPressed: notifier.answered
                      ? null
                      : () => notifier.chooseLetter(tile.id),
                  label: Text(
                    tile.letter,
                    textDirection: TextDirection.ltr,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: notifier.answered
                    ? null
                    : notifier.removeLastLetter,
                icon: const Icon(Icons.backspace_outlined),
                label: const Text('تراجع'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed:
                    notifier.answered ? null : notifier.clearLetters,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('مسح'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed:
                    notifier.answered || notifier.letterAnswer.isEmpty
                        ? null
                        : notifier.submitLetterAnswer,
                child: const Text('تحقق'),
              ),
            ],
          ),
        ],
      );
}

class _AnswerFeedback extends StatelessWidget {
  const _AnswerFeedback({required this.notifier});

  final VerbDrillNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final question = notifier.currentQuestion!;
    final color =
        notifier.lastCorrect ? AppColors.mastery : AppColors.tertiary;
    final label = notifier.timedOut
        ? 'انتهى الوقت'
        : notifier.lastCorrect
            ? 'صحيح · سرعة ممتازة'
            : 'الإجابة تحتاج مراجعة';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              label,
              style: AppTypography.label.copyWith(color: color),
            ),
            const SizedBox(height: 5),
            Text(
              question.correctAnswer,
              textDirection: TextDirection.ltr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArenaSummary extends StatelessWidget {
  const _ArenaSummary({required this.notifier});

  final VerbDrillNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final accuracy = (notifier.accuracy * 100).round();
    final averageMs = notifier.averageResponseTime.inMilliseconds;
    return AppGlassCard(
      glowColor: AppColors.mastery,
      child: Column(
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: AppColors.mastery,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text('انتهت الجولة', style: AppTypography.title),
          const SizedBox(height: 8),
          Text(
            'النقاط ${notifier.score} · الدقة $accuracy% · متوسط السرعة ${averageMs}ms',
            textAlign: TextAlign.center,
            style: AppTypography.body,
          ),
          const SizedBox(height: 8),
          Text(
            'أخطاء تحتاج تكرار: ${notifier.repeatedMistakes.length}',
            style: AppTypography.label,
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => notifier.start(),
            icon: const Icon(Icons.replay_rounded),
            label: const Text('جولة جديدة'),
          ),
        ],
      ),
    );
  }
}
