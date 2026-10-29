import 'dart:async';

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../application/buergeramt_notifier.dart';
import '../domain/buergeramt_models.dart';

final class BuergeramtHubScreen extends StatefulWidget {
  const BuergeramtHubScreen({
    required this.notifier,
    super.key,
  });

  final BuergeramtNotifier notifier;

  @override
  State<BuergeramtHubScreen> createState() => _BuergeramtHubScreenState();
}

final class _BuergeramtHubScreenState extends State<BuergeramtHubScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.notifier.situations.isEmpty &&
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
              'المعاملات اليومية · Alltag & Behörden',
              textDirection: TextDirection.rtl,
            ),
          ),
          body: SafeArea(
            child: ListenableBuilder(
              listenable: widget.notifier,
              builder: (context, _) {
                final notifier = widget.notifier;

                if (notifier.isLoading && notifier.situations.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (notifier.situations.isEmpty) {
                  return _EmptyState(
                    onRetry: () => unawaited(notifier.load()),
                  );
                }

                final scenario = notifier.activeScenario;
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _SituationSelector(notifier: notifier),
                      if (scenario != null) ...<Widget>[
                        const SizedBox(height: 14),
                        _ScenarioHeader(scenario: scenario),
                        const SizedBox(height: 14),
                        _DocumentPanel(scenario: scenario),
                      ],
                      const SizedBox(height: 14),
                      _DialoguePanel(notifier: notifier),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
}

final class _SituationSelector extends StatelessWidget {
  const _SituationSelector({required this.notifier});

  final BuergeramtNotifier notifier;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.primary,
        borderColor: AppColors.primary.withAlpha(92),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'اختر الموقف',
              textDirection: TextDirection.rtl,
              style: AppTypography.title,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                for (final situation in notifier.situations)
                  ChoiceChip(
                    label: Text(
                      _situationLabel(situation.type),
                      textDirection: TextDirection.ltr,
                    ),
                    selected:
                        notifier.activeScenario?.type == situation.type,
                    selectedColor: AppColors.primary.withAlpha(34),
                    side: BorderSide(
                      color: notifier.activeScenario?.type == situation.type
                          ? AppColors.primary
                          : Theme.of(context).dividerColor,
                    ),
                    onSelected: notifier.isLoading
                        ? null
                        : (_) => unawaited(
                              notifier.switchSituation(situation.type),
                            ),
                  ),
              ],
            ),
          ],
        ),
      );

  static String _situationLabel(BureaucracySituation type) => switch (type) {
        BureaucracySituation.buergeramt => 'Bürgeramt',
        BureaucracySituation.bank => 'Bank',
        BureaucracySituation.anmeldung => 'Anmeldung',
      };
}

final class _ScenarioHeader extends StatelessWidget {
  const _ScenarioHeader({required this.scenario});

  final BureaucracyScenario scenario;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.secondary,
        borderColor: AppColors.secondary.withAlpha(88),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.location_city_outlined,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    scenario.titleDe,
                    textDirection: TextDirection.ltr,
                    style: AppTypography.title,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              scenario.titleAr,
              textDirection: TextDirection.rtl,
              style: AppTypography.body.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              scenario.goalAr,
              textDirection: TextDirection.rtl,
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _DocumentPanel extends StatelessWidget {
  const _DocumentPanel({required this.scenario});

  final BureaucracyScenario scenario;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.achievement,
        borderColor: AppColors.achievement.withAlpha(84),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.badge_outlined,
                  color: AppColors.achievement,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'المستندات · Dokumente',
                    textDirection: TextDirection.rtl,
                    style: AppTypography.title,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                for (final document in scenario.documents)
                  _OfficialDocumentBadge(document: document),
              ],
            ),
          ],
        ),
      );
}

final class _OfficialDocumentBadge extends StatelessWidget {
  const _OfficialDocumentBadge({required this.document});

  final OfficialDocumentBadge document;

  @override
  Widget build(BuildContext context) {
    final accent =
        document.required ? AppColors.primary : AppColors.secondary;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 245),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withAlpha(105)),
          color: accent.withAlpha(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                document.required
                    ? Icons.verified_outlined
                    : Icons.description_outlined,
                color: accent,
                size: 21,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      document.labelDe,
                      textDirection: TextDirection.ltr,
                      style: AppTypography.label.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      document.labelAr,
                      textDirection: TextDirection.rtl,
                      style: AppTypography.label,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      document.required ? 'مطلوب' : 'قد يُطلب',
                      textDirection: TextDirection.rtl,
                      style: AppTypography.label.copyWith(color: accent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _DialoguePanel extends StatelessWidget {
  const _DialoguePanel({required this.notifier});

  final BuergeramtNotifier notifier;

  @override
  Widget build(BuildContext context) {
    if (notifier.isLoading && notifier.dialogue.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final turn = notifier.currentTurn;
    if (turn == null) {
      return AppGlassCard(
        child: Text(
          'لا يوجد حوار لهذا الموقف.',
          textDirection: TextDirection.rtl,
          style: AppTypography.body,
        ),
      );
    }

    return AppGlassCard(
      glowColor: AppColors.tertiary,
      borderColor: AppColors.tertiary.withAlpha(80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.forum_outlined,
                color: AppColors.tertiary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'المحادثة · Gespräch',
                  textDirection: TextDirection.rtl,
                  style: AppTypography.title,
                ),
              ),
              Text(
                (notifier.currentTurnIndex + 1).toString() +
                    ' / ' +
                    notifier.dialogue.length.toString(),
                textDirection: TextDirection.ltr,
                style: AppTypography.label.copyWith(
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var index = 0;
              index <= notifier.currentTurnIndex &&
                  index < notifier.dialogue.length;
              index++) ...<Widget>[
            _DialogueBubble(
              turn: notifier.dialogue[index],
              active: index == notifier.currentTurnIndex,
            ),
            const SizedBox(height: 10),
          ],
          if (turn.choices.isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              'اختر ردك',
              textDirection: TextDirection.rtl,
              style: AppTypography.title,
            ),
            const SizedBox(height: 10),
            for (final choice in turn.choices) ...<Widget>[
              _ChoiceCard(
                choice: choice,
                selected: notifier.selectedChoiceId == choice.id,
                answered: notifier.showExplanation,
                onTap: () => unawaited(
                  notifier.selectResponse(choice.id),
                ),
              ),
              if (choice != turn.choices.last) const SizedBox(height: 9),
            ],
          ],
          if (notifier.showExplanation) ...<Widget>[
            const SizedBox(height: 12),
            _FeedbackCard(
              correct: notifier.isCorrect == true,
              feedbackAr: notifier.feedbackAr,
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              FilledButton.icon(
                onPressed: _canAdvance(notifier) ? notifier.nextTurn : null,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text(
                  'التالي',
                  textDirection: TextDirection.rtl,
                ),
              ),
              OutlinedButton.icon(
                onPressed: notifier.restartDialogue,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text(
                  'إعادة الحوار',
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static bool _canAdvance(BuergeramtNotifier notifier) {
    final turn = notifier.currentTurn;
    if (turn == null || notifier.isLastTurn) return false;
    return turn.choices.isEmpty || notifier.showExplanation;
  }
}

final class _DialogueBubble extends StatelessWidget {
  const _DialogueBubble({
    required this.turn,
    required this.active,
  });

  final BureaucracyDialogueTurn turn;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final official = turn.speaker == DialogueSpeaker.official;
    final accent = official ? AppColors.secondary : AppColors.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accent.withAlpha(active ? 120 : 65),
        ),
        color: accent.withAlpha(active ? 22 : 12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              official ? 'Mitarbeiter/in' : 'Sie',
              textDirection: TextDirection.ltr,
              style: AppTypography.label.copyWith(
                color: accent,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              turn.textDe,
              textDirection: TextDirection.ltr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 7),
            Text(
              turn.translationAr,
              textDirection: TextDirection.rtl,
              style: AppTypography.body,
            ),
          ],
        ),
      ),
    );
  }
}

final class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.choice,
    required this.selected,
    required this.answered,
    required this.onTap,
  });

  final DialogueChoice choice;
  final bool selected;
  final bool answered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border =
        selected ? AppColors.primary : Theme.of(context).dividerColor;

    return AppGlassCard(
      onTap: answered ? null : onTap,
      borderRadius: 20,
      borderColor: border,
      glowColor: selected ? AppColors.primary : null,
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            choice.textDe,
            textDirection: TextDirection.ltr,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            choice.translationAr,
            textDirection: TextDirection.rtl,
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}

final class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.correct,
    required this.feedbackAr,
  });

  final bool correct;
  final String feedbackAr;

  @override
  Widget build(BuildContext context) {
    final accent = correct ? AppColors.mastery : AppColors.articleDie;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withAlpha(105)),
        color: accent.withAlpha(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              correct
                  ? Icons.check_circle_outline_rounded
                  : Icons.info_outline_rounded,
              color: accent,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                feedbackAr,
                textDirection: TextDirection.rtl,
                style: AppTypography.body.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: AppGlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.account_balance_outlined,
                color: AppColors.primary,
                size: 44,
              ),
              const SizedBox(height: 12),
              Text(
                'لا توجد مواقف تدريبية متاحة.',
                textDirection: TextDirection.rtl,
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
        ),
      );
}
