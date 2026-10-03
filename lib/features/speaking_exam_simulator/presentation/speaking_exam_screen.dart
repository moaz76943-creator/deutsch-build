import 'dart:async';
import 'package:flutter/material.dart';
import '../../../design_system/design_system.dart';
import '../application/speaking_exam_notifier.dart';
import '../domain/speaking_exam_models.dart';
final class SpeakingExamScreen extends StatefulWidget {
  const SpeakingExamScreen({required this.notifier, super.key});
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
                            _GuidanceCard(notifier: notifier),
                            const SizedBox(height: 14),
                            _PresentationCard(scenario: scenario),
                            const SizedBox(height: 14),
                            _DebateCard(
                              scenario: scenario,
                              notifier: notifier,
                            ),
                            const SizedBox(height: 14),
                            _PlanningAndQuestionsCard(scenario: scenario),
                            const SizedBox(height: 14),
                            _NavigationCard(notifier: notifier),
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
                _FilterButton(
                  label: 'Goethe B1',
                  selected: notifier.providerFilter == ExamProvider.goethe &&
                      notifier.levelFilter == ExamLevel.b1,
                  onTap: () => unawaited(notifier.applyFilter(
                    provider: ExamProvider.goethe,
                    level: ExamLevel.b1,
                  )),
                ),
                _FilterButton(
                  label: 'Goethe B2',
                  selected: notifier.providerFilter == ExamProvider.goethe &&
                      notifier.levelFilter == ExamLevel.b2,
                  onTap: () => unawaited(notifier.applyFilter(
                    provider: ExamProvider.goethe,
                    level: ExamLevel.b2,
                  )),
                ),
                _FilterButton(
                  label: 'telc B1',
                  selected: notifier.providerFilter == ExamProvider.telc &&
                      notifier.levelFilter == ExamLevel.b1,
                  onTap: () => unawaited(notifier.applyFilter(
                    provider: ExamProvider.telc,
                    level: ExamLevel.b1,
                  )),
                ),
                _FilterButton(
                  label: 'telc B2',
                  selected: notifier.providerFilter == ExamProvider.telc &&
                      notifier.levelFilter == ExamLevel.b2,
                  onTap: () => unawaited(notifier.applyFilter(
                    provider: ExamProvider.telc,
                    level: ExamLevel.b2,
                  )),
                ),
                _FilterButton(
                  label: 'الكل',
                  selected: notifier.providerFilter == null &&
                      notifier.levelFilter == null,
                  onTap: () => unawaited(notifier.load()),
                ),
              ],
            ),
          ],
        ),
      );
}
final class _FilterButton extends StatelessWidget {
  const _FilterButton({
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
        borderColor:
            selected ? AppColors.secondary : Theme.of(context).dividerColor,
        glowColor: selected ? AppColors.secondary : null,
        child: Text(
          label,
          textDirection: label == 'الكل'
              ? TextDirection.rtl
              : TextDirection.ltr,
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
                _Badge(text: scenario.providerLabel, color: AppColors.primary),
                _Badge(text: scenario.levelLabel, color: AppColors.achievement),
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
              style: AppTypography.title.copyWith(color: AppColors.primary),
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
  const _Badge({required this.text, required this.color});
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
          'اكتملت المحاكاة. انتقل إلى سيناريو جديد أو راجع إجاباتك.',
          textDirection: TextDirection.rtl,
          style: AppTypography.title.copyWith(color: AppColors.mastery),
        ),
      );
    }
    final timerColor = notifier.secondsRemaining <= 30
        ? Theme.of(context).colorScheme.error
        : AppColors.tertiary;
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
                style: AppTypography.display.copyWith(color: timerColor),
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
                onPressed:
                    notifier.isRunning ? notifier.pauseTimer : notifier.startTimer,
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
    final phases =
        notifier.currentScenario?.phases ?? const <SpeakingPhaseConfig>[];
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
                  label: (index + 1).toString() + '. ' + phases[index].titleDe,
                  current: index == notifier.currentPhaseIndex &&
                      !notifier.isCompleted,
                  completed:
                      notifier.isCompleted || index < notifier.currentPhaseIndex,
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
    required this.label,
    required this.current,
    required this.completed,
  });
  final String label;
  final bool current;
  final bool completed;
  @override
  Widget build(BuildContext context) {
    final color = completed
        ? AppColors.mastery
        : current
            ? AppColors.tertiary
            : Theme.of(context).colorScheme.outline;
    return AppGlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      borderColor: color.withAlpha(100),
      glowColor: current ? color : null,
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
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            textDirection: TextDirection.ltr,
            style: AppTypography.label.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
final class _GuidanceCard extends StatelessWidget {
  const _GuidanceCard({required this.notifier});
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
            style: AppTypography.title.copyWith(color: AppColors.secondary),
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
            const _SectionTitle(
              icon: Icons.record_voice_over_outlined,
              title: 'بطاقة العرض',
              color: AppColors.primary,
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
              AppGlassCard(
                borderRadius: 16,
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      '• ' + scenario.presentationPointsDe[index],
                      textDirection: TextDirection.ltr,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (index < scenario.presentationPointsAr.length) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(
                        scenario.presentationPointsAr[index],
                        textDirection: TextDirection.rtl,
                        style: AppTypography.label,
                      ),
                    ],
                  ],
                ),
              ),
              if (index != scenario.presentationPointsDe.length - 1)
                const SizedBox(height: 8),
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
            const _SectionTitle(
              icon: Icons.forum_outlined,
              title: 'بطاقة النقاش والمناظرة',
              color: AppColors.achievement,
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
            const SizedBox(height: 12),
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
                final pro = _ArgumentList(
                  title: 'Dafür',
                  items: scenario.proArgumentsDe,
                  color: AppColors.mastery,
                );
                final contra = _ArgumentList(
                  title: 'Dagegen',
                  items: scenario.contraArgumentsDe,
                  color: AppColors.tertiary,
                );
                if (constraints.maxWidth < 560) {
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
            color:
                selected ? color : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
}
final class _ArgumentList extends StatelessWidget {
  const _ArgumentList({
    required this.title,
    required this.items,
    required this.color,
  });
  final String title;
  final List<String> items;
  final Color color;
  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderRadius: 18,
        borderColor: color.withAlpha(90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              title,
              textDirection: TextDirection.ltr,
              style: AppTypography.title.copyWith(color: color),
            ),
            const SizedBox(height: 8),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• ' + item,
                  textDirection: TextDirection.ltr,
                  style: AppTypography.body,
                ),
              ),
          ],
        ),
      );
}
final class _PlanningAndQuestionsCard extends StatelessWidget {
  const _PlanningAndQuestionsCard({required this.scenario});
  final SpeakingExamScenario scenario;
  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.secondary.withAlpha(85),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const _SectionTitle(
              icon: Icons.handshake_outlined,
              title: 'التخطيط المشترك',
              color: AppColors.secondary,
            ),
            const SizedBox(height: 10),
            Text(
              scenario.planningTaskDe,
              textDirection: TextDirection.ltr,
              style: AppTypography.title,
            ),
            const SizedBox(height: 6),
            Text(
              scenario.planningTaskAr,
              textDirection: TextDirection.rtl,
              style: AppTypography.body,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final phrase in const <String>[
                  'Ich schlage vor, dass …',
                  'Wie wäre es, wenn …?',
                  'Da stimme ich dir zu.',
                  'Ich sehe das etwas anders.',
                  'Könnten wir stattdessen …?',
                  'Dann einigen wir uns auf …',
                ])
                  _GermanPill(text: phrase),
              ],
            ),
            const SizedBox(height: 16),
            const _SectionTitle(
              icon: Icons.question_answer_outlined,
              title: 'أسئلة الشريك',
              color: AppColors.tertiary,
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
final class _GermanPill extends StatelessWidget {
  const _GermanPill({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        borderColor: AppColors.secondary.withAlpha(70),
        child: Text(
          text,
          textDirection: TextDirection.ltr,
          style: AppTypography.label,
        ),
      );
}
final class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.color,
  });
  final IconData icon;
  final String title;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              textDirection: TextDirection.rtl,
              style: AppTypography.title.copyWith(color: color),
            ),
          ),
        ],
      );
}
final class _NavigationCard extends StatelessWidget {
  const _NavigationCard({required this.notifier});
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
              onPressed:
                  notifier.isCompleted ? notifier.nextScenario : notifier.nextPhase,
              icon: Icon(
                notifier.isCompleted
                    ? Icons.skip_next_rounded
                    : Icons.arrow_back_rounded,
              ),
              label: Text(
                notifier.isCompleted ? 'سيناريو جديد' : 'المرحلة التالية',
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
