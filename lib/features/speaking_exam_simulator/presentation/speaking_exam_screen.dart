import 'dart:async';

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../application/speaking_exam_notifier.dart';
import '../domain/speaking_exam_models.dart';

final class SpeakingExamScreen extends StatefulWidget {
  const SpeakingExamScreen({
    required this.notifier,
    super.key,
  });

  final SpeakingExamNotifier notifier;

  @override
  State<SpeakingExamScreen> createState() => _SpeakingExamScreenState();
}

final class _SpeakingExamScreenState extends State<SpeakingExamScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.notifier.currentScenario == null &&
        !widget.notifier.isLoading) {
      unawaited(widget.notifier.load());
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'محاكي الامتحان الشفهي · Mündliche Prüfung',
              textDirection: TextDirection.rtl,
            ),
          ),
          body: SafeArea(
            child: ListenableBuilder(
              listenable: widget.notifier,
              builder: (context, _) {
                final notifier = widget.notifier;
                final scenario = notifier.currentScenario;

                if (notifier.isLoading && scenario == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
                  child: scenario == null
                      ? _EmptyState(
                          onRetry: () => unawaited(notifier.load()),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            _FilterBar(notifier: notifier),
                            const SizedBox(height: 14),
                            _ScenarioHeader(
                              scenario: scenario,
                              notifier: notifier,
                            ),
                            const SizedBox(height: 14),
                            _TimerCard(notifier: notifier),
                            const SizedBox(height: 14),
                            _PhaseStrip(notifier: notifier),
                            const SizedBox(height: 14),
                            _PhaseGuidance(notifier: notifier),
                            const SizedBox(height: 14),
                            _PresentationCard(scenario: scenario),
                            const SizedBox(height: 14),
                            _DebateCard(
                              scenario: scenario,
                              notifier: notifier,
                            ),
                            const SizedBox(height: 14),
                            _PlanningCard(scenario: scenario),
                            const SizedBox(height: 14),
                            _PartnerQuestionsCard(scenario: scenario),
                            const SizedBox(height: 14),
                            _BottomActions(notifier: notifier),
                          ],
                        ),
                );
              },
            ),
          ),
        ),
      );
}

final class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.notifier});

  final SpeakingExamNotifier notifier;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.secondary.withAlpha(80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'نوع التدريب',
              textDirection: TextDirection.rtl,
              style: AppTypography.title,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _FilterChip(
                  label: 'Goethe B1',
                  selected:
                      notifier.providerFilter == ExamProvider.goethe &&
                      notifier.levelFilter == ExamLevel.b1,
                  onTap: () => unawaited(
                    notifier.applyFilter(
                      provider: ExamProvider.goethe,
                      level: ExamLevel.b1,
                    ),
                  ),
                ),
                _FilterChip(
                  label: 'Goethe B2',
                  selected:
                      notifier.providerFilter == ExamProvider.goethe &&
                      notifier.levelFilter == ExamLevel.b2,
                  onTap: () => unawaited(
                    notifier.applyFilter(
                      provider: ExamProvider.goethe,
                      level: ExamLevel.b2,
                    ),
                  ),
                ),
                _FilterChip(
                  label: 'telc B1',
                  selected:
                      notifier.providerFilter == ExamProvider.telc &&
                      notifier.levelFilter == ExamLevel.b1,
                  onTap: () => unawaited(
                    notifier.applyFilter(
                      provider: ExamProvider.telc,
                      level: ExamLevel.b1,
                    ),
                  ),
                ),
                _FilterChip(
                  label: 'telc B2',
                  selected:
                      notifier.providerFilter == ExamProvider.telc &&
                      notifier.levelFilter == ExamLevel.b2,
                  onTap: () => unawaited(
                    notifier.applyFilter(
                      provider: ExamProvider.telc,
                      level: ExamLevel.b2,
                    ),
                  ),
                ),
                _FilterChip(
                  label: 'الكل',
                  selected:
                      notifier.providerFilter == null &&
                      notifier.levelFilter == null,
                  onTap: () => unawaited(notifier.load()),
                ),
              ],
            ),
          ],
        ),
      );
}

final class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        onTap: onTap,
        borderRadius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        borderColor: selected
            ? AppColors.secondary
            : Theme.of(context).dividerColor,
        glowColor: selected ? AppColors.secondary : null,
        child: Text(
          label,
          textDirection: TextDirection.ltr,
          style: AppTypography.label.copyWith(
            color: selected
                ? AppColors.secondary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
}

final class _ScenarioHeader extends StatelessWidget {
  const _ScenarioHeader({
    required this.scenario,
    required this.notifier,
  });

  final SpeakingExamScenario scenario;
  final SpeakingExamNotifier notifier;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.primary.withAlpha(90),
        glowColor: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                _Badge(
                  text: scenario.providerLabel,
                  color: AppColors.primary,
                ),
                _Badge(
                  text: scenario.levelLabel,
                  color: AppColors.achievement,
                ),
                Text(
                  'سيناريو ' +
                      (notifier.scenarioIndex + 1).toString() +
                      ' / ' +
                      notifier.scenarios.length.toString(),
                  textDirection: TextDirection.rtl,
                  style: AppTypography.label,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              scenario.topicDe,
              textDirection: TextDirection.ltr,
              style: AppTypography.title.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              scenario.topicAr,
              textDirection: TextDirection.rtl,
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        borderColor: color.withAlpha(110),
        glowColor: color,
        child: Text(
          text,
          textDirection: TextDirection.ltr,
          style: AppTypography.label.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
}

final class _TimerCard extends StatelessWidget {
  const _TimerCard({required this.notifier});

  final SpeakingExamNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final phase = notifier.currentPhase;
    if (phase == null) {
      return AppGlassCard(
        borderColor: AppColors.mastery.withAlpha(100),
        glowColor: AppColors.mastery,
        child: Text(
          'اكتملت المحاكاة. راجع ملاحظاتك ثم ابدأ سيناريو جديداً.',
          textDirection: TextDirection.rtl,
          style: AppTypography.title.copyWith(
            color: AppColors.mastery,
          ),
        ),
      );
    }

    return AppGlassCard(
      borderColor: AppColors.tertiary.withAlpha(100),
      glowColor: notifier.isRunning ? AppColors.tertiary : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    phase.titleDe,
                    textDirection: TextDirection.ltr,
                    style: AppTypography.title,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    phase.titleAr,
                    textDirection: TextDirection.rtl,
                    style: AppTypography.label,
                  ),
                ],
              ),
              Text(
                notifier.formattedRemaining,
                textDirection: TextDirection.ltr,
                style: AppTypography.display.copyWith(
                  color: notifier.secondsRemaining <= 30
                      ? Theme.of(context).colorScheme.error
                      : AppColors.tertiary,
                  fontFeatures: const <FontFeature>[],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: notifier.phaseProgress,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.tertiary),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilledButton.icon(
                onPressed: notifier.isRunning
                    ? notifier.pauseTimer
                    : notifier.startTimer,
                icon: Icon(
                  notifier.isRunning
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                ),
                label: Text(
                  notifier.isRunning ? 'إيقاف مؤقت' : 'ابدأ المؤقت',
                  textDirection: TextDirection.rtl,
                ),
              ),
              OutlinedButton.icon(
                onPressed: notifier.resetCurrentPhase,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text(
                  'إعادة المرحلة',
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _PhaseStrip extends StatelessWidget {
  const _PhaseStrip({required this.notifier});

  final SpeakingExamNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final phases = notifier.currentScenario?.phases ??
        const <SpeakingPhaseConfig>[];

    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'مراحل المحاكاة',
            textDirection: TextDirection.rtl,
            style: AppTypography.title,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (var index = 0; index < phases.length; index++)
                _PhasePill(
                  phase: phases[index],
                  index: index,
                  current: index == notifier.currentPhaseIndex &&
                      !notifier.isCompleted,
                  completed: notifier.isCompleted ||
                      index < notifier.currentPhaseIndex,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _PhasePill extends StatelessWidget {
  const _PhasePill({
    required this.phase,
    required this.index,
    required this.current,
    required this.completed,
  });

  final SpeakingPhaseConfig phase;
  final int index;
  final bool current;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final accent = completed
        ? AppColors.mastery
        : current
            ? AppColors.tertiary
            : Theme.of(context).colorScheme.outline;

    return AppGlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      borderColor: accent.withAlpha(100),
      glowColor: current ? accent : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            completed
                ? Icons.check_circle_outline
                : current
                    ? Icons.timer_outlined
                    : Icons.circle_outlined,
            size: 16,
            color: accent,
          ),
          const SizedBox(width: 6),
          Text(
            (index + 1).toString() + '. ' + phase.titleDe,
            textDirection: TextDirection.ltr,
            style: AppTypography.label.copyWith(color: accent),
          ),
        ],
      ),
    );
  }
}

final class _PhaseGuidance extends StatelessWidget {
  const _PhaseGuidance({required this.notifier});

  final SpeakingExamNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final phase = notifier.currentPhase;
    if (phase == null) return const SizedBox.shrink();

    return AppGlassCard(
      borderColor: AppColors.secondary.withAlpha(90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'ماذا تفعل الآن؟',
            textDirection: TextDirection.rtl,
            style: AppTypography.title.copyWith(
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            phase.guidanceAr,
            textDirection: TextDirection.rtl,
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}

final class _PresentationCard extends StatelessWidget {
  const _PresentationCard({required this.scenario});

  final SpeakingExamScenario scenario;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.primary.withAlpha(80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _SectionTitle(
              icon: Icons.record_voice_over_outlined,
              titleAr: 'بطاقة العرض',
              accent: AppColors.primary,
            ),
            const SizedBox(height: 10),
            Text(
              scenario.presentationPromptDe,
              textDirection: TextDirection.ltr,
              style: AppTypography.title,
            ),
            const SizedBox(height: 12),
            for (var index = 0;
                index < scenario.presentationPointsDe.length;
                index++) ...<Widget>[
              _BiDiBullet(
                de: scenario.presentationPointsDe[index],
                ar: index < scenario.presentationPointsAr.length
                    ? scenario.presentationPointsAr[index]
                    : '',
              ),
              if (index != scenario.presentationPointsDe.length - 1)
                const SizedBox(height: 8),
            ],
          ],
        ),
      );
}

final class _BiDiBullet extends StatelessWidget {
  const _BiDiBullet({
    required this.de,
    required this.ar,
  });

  final String de;
  final String ar;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderRadius: 16,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              '• ' + de,
              textDirection: TextDirection.ltr,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            if (ar.isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                ar,
                textDirection: TextDirection.rtl,
                style: AppTypography.label,
              ),
            ],
          ],
        ),
      );
}

final class _DebateCard extends StatelessWidget {
  const _DebateCard({
    required this.scenario,
    required this.notifier,
  });

  final SpeakingExamScenario scenario;
  final SpeakingExamNotifier notifier;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.achievement.withAlpha(85),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _SectionTitle(
              icon: Icons.forum_outlined,
              titleAr: 'بطاقة النقاش والمناظرة',
              accent: AppColors.achievement,
            ),
            const SizedBox(height: 10),
            Text(
              scenario.debateStatementDe,
              textDirection: TextDirection.ltr,
              style: AppTypography.title.copyWith(
                color: AppColors.achievement,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              scenario.debateStatementAr,
              textDirection: TextDirection.rtl,
              style: AppTypography.body,
            ),
            const SizedBox(height: 14),
            Text(
              'اختر موقفك قبل بدء النقاش',
              textDirection: TextDirection.rtl,
              style: AppTypography.label,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _StanceButton(
                  label: 'PRO',
                  selected: notifier.selectedStance == DebateStance.pro,
                  color: AppColors.mastery,
                  onTap: () => notifier.selectStance(DebateStance.pro),
                ),
                _StanceButton(
                  label: 'CONTRA',
                  selected: notifier.selectedStance == DebateStance.contra,
                  color: AppColors.tertiary,
                  onTap: () => notifier.selectStance(DebateStance.contra),
                ),
                _StanceButton(
                  label: 'ABWÄGEN',
                  selected:
                      notifier.selectedStance == DebateStance.balanced,
                  color: AppColors.secondary,
                  onTap: () =>
                      notifier.selectStance(DebateStance.balanced),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 560;
                final pro = _ArgumentColumn(
                  title: 'Dafür',
                  arguments: scenario.proArgumentsDe,
                  accent: AppColors.mastery,
                );
                final contra = _ArgumentColumn(
                  title: 'Dagegen',
                  arguments: scenario.contraArgumentsDe,
                  accent: AppColors.tertiary,
                );

                if (!wide) {
                  return Column(
                    children: <Widget>[
                      pro,
                      const SizedBox(height: 10),
                      contra,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child: pro),
                    const SizedBox(width: 10),
                    Expanded(child: contra),
                  ],
                );
              },
            ),
          ],
        ),
      );
}

final class _StanceButton extends StatelessWidget {
  const _StanceButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        onTap: onTap,
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        borderColor: selected ? color : Theme.of(context).dividerColor,
        glowColor: selected ? color : null,
        child: Text(
          label,
          textDirection: TextDirection.ltr,
          style: AppTypography.label.copyWith(
            color: selected
                ? color
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
}

final class _ArgumentColumn extends StatelessWidget {
  const _ArgumentColumn({
    required this.title,
    required this.arguments,
    required this.accent,
  });

  final String title;
  final List<String> arguments;
  final Color accent;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderRadius: 18,
        borderColor: accent.withAlpha(90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              title,
              textDirection: TextDirection.ltr,
              style: AppTypography.title.copyWith(color: accent),
            ),
            const SizedBox(height: 8),
            for (final argument in arguments)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• ' + argument,
                  textDirection: TextDirection.ltr,
                  style: AppTypography.body,
                ),
              ),
          ],
        ),
      );
}

final class _PlanningCard extends StatelessWidget {
  const _PlanningCard({required this.scenario});

  final SpeakingExamScenario scenario;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.secondary.withAlpha(85),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _SectionTitle(
              icon: Icons.handshake_outlined,
              titleAr: 'مهمة التخطيط المشترك',
              accent: AppColors.secondary,
            ),
            const SizedBox(height: 10),
            Text(
              scenario.planningTaskDe,
              textDirection: TextDirection.ltr,
              style: AppTypography.title,
            ),
            const SizedBox(height: 8),
            Text(
              scenario.planningTaskAr,
              textDirection: TextDirection.rtl,
              style: AppTypography.body,
            ),
            const SizedBox(height: 12),
            const _PhraseBank(),
          ],
        ),
      );
}

final class _PhraseBank extends StatelessWidget {
  const _PhraseBank();

  @override
  Widget build(BuildContext context) {
    const phrases = <String>[
      'Ich schlage vor, dass …',
      'Wie wäre es, wenn …?',
      'Da stimme ich dir zu.',
      'Ich sehe das etwas anders.',
      'Könnten wir stattdessen …?',
      'Dann einigen wir uns auf …',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final phrase in phrases)
          AppGlassCard(
            borderRadius: 14,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            borderColor: AppColors.secondary.withAlpha(70),
            child: Text(
              phrase,
              textDirection: TextDirection.ltr,
              style: AppTypography.label,
            ),
          ),
      ],
    );
  }
}

final class _PartnerQuestionsCard extends StatelessWidget {
  const _PartnerQuestionsCard({required this.scenario});

  final SpeakingExamScenario scenario;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _SectionTitle(
              icon: Icons.question_answer_outlined,
              titleAr: 'أسئلة الشريك',
              accent: AppColors.tertiary,
            ),
            const SizedBox(height: 10),
            for (var index = 0;
                index < scenario.partnerQuestionsDe.length;
                index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppGlassCard(
                  borderRadius: 16,
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    (index + 1).toString() +
                        '. ' +
                        scenario.partnerQuestionsDe[index],
                    textDirection: TextDirection.ltr,
                    style: AppTypography.body,
                  ),
                ),
              ),
          ],
        ),
      );
}

final class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.titleAr,
    required this.accent,
  });

  final IconData icon;
  final String titleAr;
  final Color accent;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Icon(icon, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              titleAr,
              textDirection: TextDirection.rtl,
              style: AppTypography.title.copyWith(color: accent),
            ),
          ),
        ],
      );
}

final class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.notifier});

  final SpeakingExamNotifier notifier;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            OutlinedButton.icon(
              onPressed:
                  notifier.currentPhaseIndex > 0 && !notifier.isCompleted
                      ? notifier.previousPhase
                      : null,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text(
                'المرحلة السابقة',
                textDirection: TextDirection.rtl,
              ),
            ),
            FilledButton.icon(
              onPressed: notifier.isCompleted
                  ? notifier.nextScenario
                  : notifier.nextPhase,
              icon: Icon(
                notifier.isCompleted
                    ? Icons.skip_next_rounded
                    : Icons.arrow_back_rounded,
              ),
              label: Text(
                notifier.isCompleted
                    ? 'سيناريو جديد'
                    : 'المرحلة التالية',
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
      );
}

final class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.record_voice_over_outlined,
              size: 44,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد سيناريوهات مطابقة.',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: AppTypography.title,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text(
                'إعادة التحميل',
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
      );
}
