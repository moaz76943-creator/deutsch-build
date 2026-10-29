import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/explainer/explainer.dart';
import '../../../core/memory.dart';
import '../../../core/quick_review/quick_review.dart';
import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart';
import '../../../features/audio/hybrid_pronunciation_service.dart';
import '../../../features/daily_drill/domain/daily_drill_repository.dart';
import 'v11_quick_review_screen.dart';

class SrsReviewHubScreen extends StatelessWidget {
  const SrsReviewHubScreen({
    required this.session,
    required this.sourceLanguageCode,
    required this.translationLanguageCode,
    required this.reviewSink,
    required this.pronunciationAudio,
    required this.explainerService,
    super.key,
  });

  final QuickReviewSession session;
  final String sourceLanguageCode;
  final String translationLanguageCode;
  final DailyDrillReviewSink reviewSink;
  final HybridPronunciationService pronunciationAudio;
  final ExplainerService explainerService;

  Future<void> _startReview(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => V11QuickReviewScreen(
          session: session,
          reviewSink: reviewSink,
          pronunciationAudio: pronunciationAudio,
          explainerService: explainerService,
          sourceLanguageCode: sourceLanguageCode,
          translationLanguageCode: translationLanguageCode,
        ),
      ),
    );
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final overdue = session.cards
        .where((card) => card.reason == MemoryReviewReason.overdue)
        .length;
    final lapses = session.cards.where((card) => card.lapses > 0).length;
    final averageInterval = session.cards.isEmpty
        ? 0
        : (session.cards.fold<int>(
                  0,
                  (sum, card) => sum + card.intervalDays,
                ) /
                session.cards.length)
            .round();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: AppDirectionalText(
            'مركز المراجعة SRS',
            languageCode: 'ar',
            style: AppTypography.title,
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: <Widget>[
              AppGlassCard(
                glowColor: AppColors.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppDirectionalText(
                      'مراجعة ذكية بدون تشتيت',
                      languageCode: 'ar',
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: 6),
                    AppDirectionalText(
                      session.isEmpty
                          ? 'لا توجد بطاقات مستحقة الآن. '
                              'سيبقى تقدمك محفوظًا محليًا.'
                          : 'هذه الجلسة مبنية من بطاقات SRS المستحقة '
                              'في الحالة المحلية الحالية فقط.',
                      languageCode: 'ar',
                      style: AppTypography.body,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _ReviewStatsGrid(
                due: session.length,
                overdue: overdue,
                lapses: lapses,
                averageInterval: averageInterval,
              ),
              const SizedBox(height: 14),
              if (session.cards.isNotEmpty) ...<Widget>[
                AppDirectionalText(
                  'بطاقات الجلسة',
                  languageCode: 'ar',
                  style: AppTypography.title,
                ),
                const SizedBox(height: 10),
                for (var index = 0;
                    index < session.cards.length && index < 5;
                    index++) ...<Widget>[
                  _DueCardPreview(
                    card: session.cards[index],
                    sourceLanguageCode: sourceLanguageCode,
                    translationLanguageCode: translationLanguageCode,
                  ),
                  const SizedBox(height: 10),
                ],
                if (session.cards.length > 5)
                  AppGlassCard(
                    opacity: .12,
                    padding: const EdgeInsets.all(12),
                    child: AppDirectionalText(
                      'و${session.cards.length - 5} بطاقات أخرى '
                      'ضمن هذه الجلسة.',
                      languageCode: 'ar',
                      style: AppTypography.label,
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 16),
              ],
              FilledButton.icon(
                key: const Key('srs-review-hub-start'),
                onPressed: session.isEmpty
                    ? null
                    : () => unawaited(_startReview(context)),
                icon: const Icon(Icons.play_circle_outline_rounded),
                label: AppDirectionalText(
                  session.isEmpty
                      ? 'لا توجد مراجعة مستحقة'
                      : 'ابدأ جلسة المراجعة',
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

class _ReviewStatsGrid extends StatelessWidget {
  const _ReviewStatsGrid({
    required this.due,
    required this.overdue,
    required this.lapses,
    required this.averageInterval,
  });

  final int due;
  final int overdue;
  final int lapses;
  final int averageInterval;

  @override
  Widget build(BuildContext context) {
    final stats = <_ReviewStat>[
      _ReviewStat(
        label: 'مستحقة الآن',
        value: '$due',
        icon: Icons.schedule_rounded,
        accent: AppColors.primary,
      ),
      _ReviewStat(
        label: 'متأخرة',
        value: '$overdue',
        icon: Icons.history_rounded,
        accent: AppColors.tertiary,
      ),
      _ReviewStat(
        label: 'تحتاج تثبيتًا',
        value: '$lapses',
        icon: Icons.refresh_rounded,
        accent: AppColors.secondary,
      ),
      _ReviewStat(
        label: 'متوسط الفاصل',
        value: '$averageInterval يوم',
        icon: Icons.calendar_month_rounded,
        accent: AppColors.mastery,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final width = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (final stat in stats)
              SizedBox(
                width: width,
                child: AppGlassCard(
                  glowColor: stat.accent,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(stat.icon, color: stat.accent),
                      const SizedBox(height: 10),
                      AppDirectionalText(
                        stat.value,
                        languageCode: 'ar',
                        style: AppTypography.title.copyWith(
                          color: stat.accent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 3),
                      AppDirectionalText(
                        stat.label,
                        languageCode: 'ar',
                        style: AppTypography.label,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DueCardPreview extends StatelessWidget {
  const _DueCardPreview({
    required this.card,
    required this.sourceLanguageCode,
    required this.translationLanguageCode,
  });

  final QuickReviewCard card;
  final String sourceLanguageCode;
  final String translationLanguageCode;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: _reasonColor(card.reason).withAlpha(100),
        glowColor: _reasonColor(card.reason),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppDirectionalText(
                    card.sourceText,
                    languageCode: sourceLanguageCode,
                    style: AppTypography.title.copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 4),
                  AppDirectionalText(
                    card.translationText,
                    languageCode: translationLanguageCode,
                    style: AppTypography.body,
                  ),
                  const SizedBox(height: 6),
                  AppDirectionalText(
                    _reasonLabel(card.reason),
                    languageCode: 'ar',
                    style: AppTypography.label.copyWith(
                      color: _reasonColor(card.reason),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AppDirectionalText(
              '${card.intervalDays}د',
              languageCode: 'ar',
              style: AppTypography.label,
            ),
          ],
        ),
      );

  Color _reasonColor(MemoryReviewReason reason) => switch (reason) {
        MemoryReviewReason.overdue => AppColors.tertiary,
        MemoryReviewReason.lapse => AppColors.secondary,
        MemoryReviewReason.consolidation => AppColors.mastery,
        MemoryReviewReason.due => AppColors.primary,
      };

  String _reasonLabel(MemoryReviewReason reason) => switch (reason) {
        MemoryReviewReason.overdue => 'متأخرة عن موعدها',
        MemoryReviewReason.lapse => 'تحتاج إعادة تثبيت',
        MemoryReviewReason.consolidation => 'تثبيت الذاكرة',
        MemoryReviewReason.due => 'مستحقة الآن',
      };
}

class _ReviewStat {
  const _ReviewStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
}
