import 'dart:async';

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../application/comparison_notifier.dart';
import '../domain/comparison_models.dart';

final class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({
    required this.notifier,
    super.key,
  });

  final ComparisonNotifier notifier;

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

final class _ComparisonScreenState extends State<ComparisonScreen> {
  final TextEditingController _answerController = TextEditingController();
  String? _connector;

  @override
  void initState() {
    super.initState();
    if (widget.notifier.currentChallenge == null &&
        !widget.notifier.isLoading) {
      unawaited(widget.notifier.load());
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _selectDegree(ComparisonDegree degree) {
    widget.notifier.setTargetDegree(degree);
    _answerController.clear();
    setState(() => _connector = null);
  }

  void _nextChallenge() {
    widget.notifier.nextChallenge();
    _answerController.clear();
    setState(() => _connector = null);
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('المقارنة والتفضيل · Steigerung'),
          ),
          body: ListenableBuilder(
            listenable: widget.notifier,
            builder: (context, _) {
              final notifier = widget.notifier;
              final challenge = notifier.currentChallenge;

              if (notifier.isLoading && challenge == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (challenge == null) {
                return _EmptyState(
                  onRetry: () => unawaited(notifier.load()),
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
                children: <Widget>[
                  _ProgressCard(notifier: notifier),
                  const SizedBox(height: 14),
                  _DegreeScale(
                    selected: notifier.targetDegree,
                    onSelected: _selectDegree,
                  ),
                  const SizedBox(height: 14),
                  _ChallengeCard(
                    challenge: challenge,
                    degree: notifier.targetDegree,
                  ),
                  const SizedBox(height: 14),
                  _AnswerCard(
                    controller: _answerController,
                    degree: notifier.targetDegree,
                    connector: _connector,
                    answered: notifier.showExplanation,
                    onConnectorSelected: (value) {
                      setState(() => _connector = value);
                    },
                    onSubmit: () => unawaited(
                      notifier.checkComparisonAnswer(
                        form: _answerController.text,
                        connector: _connector,
                      ),
                    ),
                  ),
                  if (notifier.showExplanation) ...<Widget>[
                    const SizedBox(height: 14),
                    _FeedbackCard(
                      challenge: challenge,
                      degree: notifier.targetDegree,
                      correct: notifier.isCorrect == true,
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: _nextChallenge,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('التحدي التالي'),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      );
}

final class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.notifier});

  final ComparisonNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final total = notifier.challenges.length;
    final current = total == 0 ? 0 : notifier.currentIndex + 1;

    return AppGlassCard(
      borderColor: AppColors.primary.withAlpha(90),
      glowColor: AppColors.primary,
      child: Row(
        children: <Widget>[
          const Icon(Icons.compare_arrows_rounded, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _ruleLabel(notifier.currentChallenge!.ruleType),
              style: AppTypography.title,
            ),
          ),
          Text(
            '$current / $total',
            textDirection: TextDirection.ltr,
            style: AppTypography.label.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  static String _ruleLabel(ComparisonRuleType type) => switch (type) {
        ComparisonRuleType.regular => 'قاعدة منتظمة',
        ComparisonRuleType.umlautChange => 'تغيير Umlaut',
        ComparisonRuleType.irregular => 'صيغة شاذة',
        ComparisonRuleType.stemChange => 'تغيير في الجذر',
      };
}

final class _DegreeScale extends StatelessWidget {
  const _DegreeScale({
    required this.selected,
    required this.onSelected,
  });

  final ComparisonDegree selected;
  final ValueChanged<ComparisonDegree> onSelected;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.secondary.withAlpha(90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('ميزان المقارنة', style: AppTypography.title),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: _DegreeStep(
                    label: 'Positiv',
                    symbol: '=',
                    selected: selected == ComparisonDegree.positiv,
                    onTap: () => onSelected(ComparisonDegree.positiv),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DegreeStep(
                    label: 'Komparativ',
                    symbol: '>',
                    selected: selected == ComparisonDegree.komparativ,
                    onTap: () => onSelected(ComparisonDegree.komparativ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DegreeStep(
                    label: 'Superlativ',
                    symbol: '★',
                    selected: selected == ComparisonDegree.superlativ,
                    onTap: () => onSelected(ComparisonDegree.superlativ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

final class _DegreeStep extends StatelessWidget {
  const _DegreeStep({
    required this.label,
    required this.symbol,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String symbol;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        borderRadius: 18,
        borderColor: selected
            ? AppColors.achievement
            : Theme.of(context).dividerColor,
        glowColor: selected ? AppColors.achievement : null,
        child: Column(
          children: <Widget>[
            Text(
              symbol,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: selected
                        ? AppColors.achievement
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              style: AppTypography.label,
            ),
          ],
        ),
      );
}

final class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({
    required this.challenge,
    required this.degree,
  });

  final ComparisonChallengeItem challenge;
  final ComparisonDegree degree;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.primary.withAlpha(70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              challenge.sentenceFor(degree),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 14),
            Text(
              'الصفة الأساسية: ${challenge.positiv}',
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              style: AppTypography.title.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              challenge.translationFor(degree),
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}

final class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.controller,
    required this.degree,
    required this.connector,
    required this.answered,
    required this.onConnectorSelected,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final ComparisonDegree degree;
  final String? connector;
  final bool answered;
  final ValueChanged<String> onConnectorSelected;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final needsConnector = degree != ComparisonDegree.superlativ;

    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('اكتب الصيغة الصحيحة', style: AppTypography.title),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            enabled: !answered,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(
              hintText: 'مثال: größer / am besten',
              border: OutlineInputBorder(),
            ),
            onSubmitted: answered ? null : (_) => onSubmit(),
          ),
          if (needsConnector) ...<Widget>[
            const SizedBox(height: 12),
            Text('اختر أداة المقارنة', style: AppTypography.label),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: <Widget>[
                for (final option in const <String>['wie', 'als'])
                  ChoiceChip(
                    label: Text(
                      option,
                      textDirection: TextDirection.ltr,
                    ),
                    selected: connector == option,
                    onSelected: answered
                        ? null
                        : (selected) {
                            if (selected) onConnectorSelected(option);
                          },
                  ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: answered ? null : onSubmit,
            icon: const Icon(Icons.check_rounded),
            label: const Text('تحقق من الإجابة'),
          ),
        ],
      ),
    );
  }
}

final class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.challenge,
    required this.degree,
    required this.correct,
  });

  final ComparisonChallengeItem challenge;
  final ComparisonDegree degree;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final color = correct
        ? AppColors.mastery
        : Theme.of(context).colorScheme.error;

    return AppGlassCard(
      borderColor: color.withAlpha(110),
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                correct ? Icons.check_circle_outline : Icons.info_outline,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  correct ? 'إجابة صحيحة' : 'راجع الصيغة والأداة',
                  style: AppTypography.title.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _HighlightedGermanForm(
            value: challenge.answerFor(degree),
            color: AppColors.achievement,
          ),
          const SizedBox(height: 12),
          Text(challenge.explanationAr, style: AppTypography.body),
          const SizedBox(height: 14),
          _FormsSummary(challenge: challenge),
        ],
      ),
    );
  }
}

final class _FormsSummary extends StatelessWidget {
  const _FormsSummary({required this.challenge});

  final ComparisonChallengeItem challenge;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _FormRow(label: 'Positiv', value: challenge.positiv),
          const SizedBox(height: 6),
          _FormRow(label: 'Komparativ', value: challenge.komparativ),
          const SizedBox(height: 6),
          _FormRow(label: 'Superlativ', value: challenge.superlativ),
        ],
      );
}

final class _FormRow extends StatelessWidget {
  const _FormRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          SizedBox(
            width: 88,
            child: Text(label, style: AppTypography.label),
          ),
          Expanded(
            child: _HighlightedGermanForm(
              value: value,
              color: AppColors.achievement,
            ),
          ),
        ],
      );
}

final class _HighlightedGermanForm extends StatelessWidget {
  const _HighlightedGermanForm({
    required this.value,
    required this.color,
  });

  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => RichText(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.onSurface,
              ),
          children: <InlineSpan>[
            for (final rune in value.runes)
              TextSpan(
                text: String.fromCharCode(rune),
                style: _isUmlaut(String.fromCharCode(rune))
                    ? TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                      )
                    : null,
              ),
          ],
        ),
      );

  static bool _isUmlaut(String value) =>
      value == 'ä' ||
      value == 'ö' ||
      value == 'ü' ||
      value == 'Ä' ||
      value == 'Ö' ||
      value == 'Ü';
}

final class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AppGlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.compare_arrows_rounded,
                  size: 42,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                Text('لا توجد تحديات متاحة.', style: AppTypography.title),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('إعادة التحميل'),
                ),
              ],
            ),
          ),
        ),
      );
}
