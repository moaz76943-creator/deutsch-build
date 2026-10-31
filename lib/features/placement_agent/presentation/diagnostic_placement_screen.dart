import 'dart:async';

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../application/placement_agent_notifier.dart';
import '../domain/placement_agent_models.dart';

final class DiagnosticPlacementScreen extends StatefulWidget {
  const DiagnosticPlacementScreen({
    required this.notifier,
    super.key,
  });

  final PlacementAgentNotifier notifier;

  @override
  State<DiagnosticPlacementScreen> createState() =>
      _DiagnosticPlacementScreenState();
}

final class _DiagnosticPlacementScreenState
    extends State<DiagnosticPlacementScreen> {
  PlacementAgentNotifier get notifier => widget.notifier;

  @override
  void initState() {
    super.initState();
    notifier.addListener(_refresh);
    if (notifier.currentQuestion == null && !notifier.isCompleted) {
      unawaited(notifier.resetAssessment());
    }
  }

  @override
  void didUpdateWidget(covariant DiagnosticPlacementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifier == notifier) return;
    oldWidget.notifier.removeListener(_refresh);
    notifier.addListener(_refresh);
  }

  @override
  void dispose() {
    notifier.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            dark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          title: Text('التقييم التشخيصي', style: AppTypography.title),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          top: false,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: notifier.isCompleted
                ? _ResultView(
                    key: const ValueKey<String>('placement-result'),
                    result: notifier.result!,
                    onReset: () => unawaited(notifier.resetAssessment()),
                  )
                : _QuestionView(
                    key: ValueKey<String>(
                      notifier.currentQuestion?.id ?? 'loading',
                    ),
                    notifier: notifier,
                  ),
          ),
        ),
      ),
    );
  }
}

final class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.notifier,
    super.key,
  });

  final PlacementAgentNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final question = notifier.currentQuestion;
    if (question == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final dark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: <Widget>[
        AppGlassCard(
          borderColor:
              dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
          backgroundColor:
              dark ? AppColors.darkSurface : AppColors.lightSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'تقدم الاختبار',
                      style: AppTypography.label.copyWith(
                        color:
                            dark ? AppColors.primaryDark : AppColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    '${(notifier.progress * 100).round()}%',
                    style: AppTypography.label.copyWith(
                      color: AppColors.mastery,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: notifier.progress,
                  minHeight: 8,
                  backgroundColor: AppColors.primary.withAlpha(28),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppGlassCard(
          glowColor: AppColors.primary,
          borderColor:
              dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
          backgroundColor:
              dark ? AppColors.darkSurface : AppColors.lightSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _InfoChip(
                    text: 'الصعوبة ${question.difficulty}/5',
                    color: AppColors.tertiary,
                  ),
                  _InfoChip(
                    text: question.focus == PlacementQuestionFocus.grammar
                        ? 'قواعد'
                        : 'مفردات',
                    color: AppColors.secondary,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              AppDirectionalText(
                question.questionText,
                languageCode: 'de',
                textAlign: TextAlign.start,
                style: AppTypography.title.copyWith(
                  color: dark ? Colors.white : AppColors.darkSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        for (var index = 0; index < question.options.length; index += 1) ...[
          AppGlassCard(
            onTap: notifier.isBusy
                ? null
                : () => unawaited(notifier.submitAnswer(index)),
            borderColor: AppColors.primary.withAlpha(72),
            backgroundColor:
                dark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Row(
              children: <Widget>[
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withAlpha(26),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: AppTypography.label.copyWith(
                      color:
                          dark ? AppColors.primaryDark : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppDirectionalText(
                    question.options[index],
                    languageCode: _optionLanguage(question.options[index]),
                    style: AppTypography.body.copyWith(
                      color: dark ? Colors.white : AppColors.darkSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (index != question.options.length - 1)
            const SizedBox(height: 10),
        ],
      ],
    );
  }

  static String _optionLanguage(String value) =>
      RegExp(r'[\u0600-\u06FF]').hasMatch(value) ? 'ar' : 'de';
}

final class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.result,
    required this.onReset,
    super.key,
  });

  final PlacementAssessmentResult result;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: <Widget>[
        AppGlassCard(
          glowColor: AppColors.mastery,
          borderColor:
              dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
          backgroundColor:
              dark ? AppColors.darkSurface : AppColors.lightSurface,
          child: Column(
            children: <Widget>[
              const Icon(
                Icons.analytics_rounded,
                color: AppColors.mastery,
                size: 42,
              ),
              const SizedBox(height: 10),
              Text(
                'مستواك التشخيصي',
                style: AppTypography.title.copyWith(
                  color: dark ? Colors.white : AppColors.darkSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result.inferredLevel.label,
                style: AppTypography.display.copyWith(
                  color: AppColors.mastery,
                ),
              ),
              Text(
                'الدقة ${(result.accuracy * 100).round()}%',
                style: AppTypography.label.copyWith(
                  color: dark ? Colors.white70 : AppColors.darkSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _RecommendationCard(
          title: 'مهارات متقنة',
          items: result.masteredSkills,
          emptyText: 'سيظهر هنا ما يتم إثباته خلال الاختبار.',
          color: AppColors.mastery,
        ),
        const SizedBox(height: 12),
        _RecommendationCard(
          title: 'مهارات تحتاج تقوية',
          items: result.skillsToStrengthen,
          emptyText: 'لا توجد فجوات واضحة في العينة الحالية.',
          color: AppColors.tertiary,
        ),
        const SizedBox(height: 16),
        AppGlassCard(
          onTap: onReset,
          glowColor: AppColors.primary,
          child: Center(
            child: Text(
              'إعادة التقييم',
              style: AppTypography.title.copyWith(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

final class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.title,
    required this.items,
    required this.emptyText,
    required this.color,
  });

  final String title;
  final List<String> items;
  final String emptyText;
  final Color color;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: color.withAlpha(72),
        glowColor: color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              title,
              style: AppTypography.title.copyWith(color: color),
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              Text(emptyText, style: AppTypography.body)
            else
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('• $item', style: AppTypography.body),
                ),
          ],
        ),
      );
}

final class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: color.withAlpha(22),
          border: Border.all(color: color.withAlpha(72)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            text,
            style: AppTypography.label.copyWith(color: color),
          ),
        ),
      );
}
