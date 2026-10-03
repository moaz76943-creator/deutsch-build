import 'package:flutter/material.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart';
import '../../../domain/adaptive_agent/adaptive_srs_agent.dart';

class LearnerDashboardView extends StatelessWidget {
  const LearnerDashboardView({
    required this.analytics,
    this.languageCode = 'ar',
    this.onStartQuickReview,
    super.key,
  });

  final LearnerDashboardAnalytics analytics;
  final String languageCode;
  final ValueChanged<List<String>>? onStartQuickReview;

  @override
  Widget build(BuildContext context) {
    final strings = _DashboardStrings.forLanguageCode(languageCode);
    final direction = AppTextDirection.forLanguageCode(languageCode);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background =
        dark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = dark ? Colors.white : const Color(0xFF172033);
    final secondaryText =
        dark ? Colors.white.withAlpha(184) : const Color(0xFF667085);

    return Directionality(
      textDirection: direction,
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: Text(strings.dashboardTitle),
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontal = constraints.maxWidth >= 720 ? 28.0 : 16.0;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(
                      analytics: analytics,
                      strings: strings,
                      textColor: textColor,
                      secondaryText: secondaryText,
                    ),
                    const SizedBox(height: 18),
                    _StatsGrid(
                      analytics: analytics,
                      strings: strings,
                      availableWidth:
                          constraints.maxWidth - (horizontal * 2),
                      textColor: textColor,
                      secondaryText: secondaryText,
                    ),
                    const SizedBox(height: 18),
                    _ProgressCard(
                      analytics: analytics,
                      strings: strings,
                      textColor: textColor,
                      secondaryText: secondaryText,
                    ),
                    const SizedBox(height: 18),
                    _ErrorBankCard(
                      analytics: analytics,
                      strings: strings,
                      textColor: textColor,
                      secondaryText: secondaryText,
                      onStartQuickReview: onStartQuickReview,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.analytics,
    required this.strings,
    required this.textColor,
    required this.secondaryText,
  });

  final LearnerDashboardAnalytics analytics;
  final _DashboardStrings strings;
  final Color textColor;
  final Color secondaryText;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      glowColor: AppColors.primary,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.progressTitle,
                  style: AppTypography.title.copyWith(color: textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  analytics.dailyReview.isEmpty
                      ? strings.noDueItems
                      : strings.dueItems(analytics.dailyReview.length),
                  style: AppTypography.body.copyWith(color: secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.analytics,
    required this.strings,
    required this.availableWidth,
    required this.textColor,
    required this.secondaryText,
  });

  final LearnerDashboardAnalytics analytics;
  final _DashboardStrings strings;
  final double availableWidth;
  final Color textColor;
  final Color secondaryText;

  @override
  Widget build(BuildContext context) {
    const gap = 12.0;
    final columns = availableWidth >= 840 ? 4 : 2;
    final width = (availableWidth - gap * (columns - 1)) / columns;
    final items = <_StatData>[
      _StatData(
        label: strings.retention,
        value: '${(analytics.retentionRate * 100).round()}%',
        icon: Icons.memory_rounded,
        accent: AppColors.secondary,
      ),
      _StatData(
        label: strings.masteredWords,
        value: '${analytics.masteredWords}',
        icon: Icons.verified_rounded,
        accent: AppColors.mastery,
      ),
      _StatData(
        label: strings.streakDays,
        value: '${analytics.currentStreakDays}',
        icon: Icons.local_fire_department_rounded,
        accent: AppColors.streak,
      ),
      _StatData(
        label: strings.progressBand,
        value: analytics.progressBand,
        icon: Icons.route_rounded,
        accent: AppColors.achievement,
      ),
    ];

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        for (final item in items)
          SizedBox(
            width: width,
            child: AppGlassCard(
              glowColor: item.accent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.icon, color: item.accent),
                  const SizedBox(height: 14),
                  Text(
                    item.value,
                    style: AppTypography.title.copyWith(
                      color: textColor,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    style: AppTypography.label.copyWith(color: secondaryText),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.analytics,
    required this.strings,
    required this.textColor,
    required this.secondaryText,
  });

  final LearnerDashboardAnalytics analytics;
  final _DashboardStrings strings;
  final Color textColor;
  final Color secondaryText;

  @override
  Widget build(BuildContext context) {
    final percent = (analytics.a1ToB1Progress * 100).round();
    return AppGlassCard(
      glowColor: AppColors.mastery,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.curriculumProgress,
                  style: AppTypography.title.copyWith(color: textColor),
                ),
              ),
              Text(
                '$percent%',
                style: AppTypography.label.copyWith(color: AppColors.mastery),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: analytics.a1ToB1Progress,
              minHeight: 10,
              backgroundColor: AppColors.mastery.withAlpha(28),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.mastery),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            strings.progressSummary(
              analytics.progressBand,
              analytics.trackedItems,
              (analytics.masteryIndex * 100).round(),
            ),
            style: AppTypography.body.copyWith(color: secondaryText),
          ),
        ],
      ),
    );
  }
}

class _ErrorBankCard extends StatelessWidget {
  const _ErrorBankCard({
    required this.analytics,
    required this.strings,
    required this.textColor,
    required this.secondaryText,
    required this.onStartQuickReview,
  });

  final LearnerDashboardAnalytics analytics;
  final _DashboardStrings strings;
  final Color textColor;
  final Color secondaryText;
  final ValueChanged<List<String>>? onStartQuickReview;

  @override
  Widget build(BuildContext context) {
    final queue = analytics.dailyReview;
    final ids = queue.map((item) => item.itemId).toList(growable: false);
    return AppGlassCard(
      glowColor: AppColors.tertiary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.tertiary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  strings.errorBank,
                  style: AppTypography.title.copyWith(color: textColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            queue.isEmpty ? strings.noStrugglingWords : strings.priorityNote,
            style: AppTypography.body.copyWith(color: secondaryText),
          ),
          if (queue.isNotEmpty) ...[
            const SizedBox(height: 14),
            for (final item in queue.take(5)) ...[
              _ReviewRow(
                item: item,
                strings: strings,
                textColor: textColor,
                secondaryText: secondaryText,
                onTap: onStartQuickReview == null
                    ? null
                    : () => onStartQuickReview!([item.itemId]),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 4),
            FilledButton.icon(
              onPressed: onStartQuickReview == null
                  ? null
                  : () => onStartQuickReview!(ids),
              icon: const Icon(Icons.bolt_rounded),
              label: Text(strings.quickReview),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                textStyle: AppTypography.label,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.item,
    required this.strings,
    required this.textColor,
    required this.secondaryText,
    this.onTap,
  });

  final AdaptiveReviewItem item;
  final _DashboardStrings strings;
  final Color textColor;
  final Color secondaryText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final priority = item.priority.round();
    return AppGlassCard(
      onTap: onTap,
      blur: 10,
      opacity: .08,
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  strings.reviewRow(priority, item.reviewIntervalDays),
                  style: AppTypography.label.copyWith(color: secondaryText),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.primary,
              size: 20,
            ),
        ],
      ),
    );
  }
}

final class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  const _StatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });
}

final class _DashboardStrings {
  final String dashboardTitle;
  final String progressTitle;
  final String noDueItems;
  final String retention;
  final String masteredWords;
  final String streakDays;
  final String progressBand;
  final String curriculumProgress;
  final String errorBank;
  final String noStrugglingWords;
  final String priorityNote;
  final String quickReview;
  final String Function(int) dueItems;
  final String Function(String, int, int) progressSummary;
  final String Function(int, int) reviewRow;

  const _DashboardStrings({
    required this.dashboardTitle,
    required this.progressTitle,
    required this.noDueItems,
    required this.retention,
    required this.masteredWords,
    required this.streakDays,
    required this.progressBand,
    required this.curriculumProgress,
    required this.errorBank,
    required this.noStrugglingWords,
    required this.priorityNote,
    required this.quickReview,
    required this.dueItems,
    required this.progressSummary,
    required this.reviewRow,
  });

  static _DashboardStrings forLanguageCode(String languageCode) {
    final code =
        languageCode.trim().toLowerCase().split(RegExp('[-_]')).first;
    if (code == 'ar') return _arabic;
    if (code == 'de') return _german;
    return _english;
  }

  static final _arabic = _DashboardStrings(
    dashboardTitle: 'لوحة المتعلم',
    progressTitle: 'لوحة تقدّمك',
    noDueItems: 'لا توجد عناصر متعثرة مستحقة الآن.',
    retention: 'معدل الاحتفاظ',
    masteredWords: 'الكلمات المتقنة',
    streakDays: 'أيام السلسلة',
    progressBand: 'نطاق المنهج',
    curriculumProgress: 'تغطية المنهج من A1 إلى B1',
    errorBank: 'بنك الأخطاء',
    noStrugglingWords: 'لا توجد كلمات متعثرة مستحقة اليوم.',
    priorityNote: 'مرتبة حسب الأولوية من العناصر المستحقة اليوم فقط.',
    quickReview: 'ابدأ مراجعة سريعة',
    dueItems: (count) => 'لديك $count عناصر ذات أولوية للمراجعة اليوم.',
    progressSummary: (band, tracked, mastery) =>
        'نطاق المنهج الحالي: $band · $tracked عنصرًا متابعًا · مؤشر الإتقان $mastery%',
    reviewRow: (priority, interval) =>
        'أولوية $priority · الفاصل التالي بعد المراجعة: $interval يوم',
  );

  static final _german = _DashboardStrings(
    dashboardTitle: 'Lernübersicht',
    progressTitle: 'Dein Lernfortschritt',
    noDueItems: 'Heute sind keine schwierigen Elemente fällig.',
    retention: 'Behaltensrate',
    masteredWords: 'Gemeisterte Wörter',
    streakDays: 'Lerntage',
    progressBand: 'Curriculum-Band',
    curriculumProgress: 'Curriculum-Abdeckung A1 bis B1',
    errorBank: 'Fehlerbank',
    noStrugglingWords: 'Heute sind keine schwierigen Wörter fällig.',
    priorityNote: 'Nur heute fällige Elemente, nach Priorität sortiert.',
    quickReview: 'Schnellwiederholung starten',
    dueItems: (count) => '$count priorisierte Elemente sind heute fällig.',
    progressSummary: (band, tracked, mastery) =>
        'Aktuelles Curriculum-Band: $band · $tracked Elemente verfolgt · Beherrschung $mastery%',
    reviewRow: (priority, interval) =>
        'Priorität $priority · nächstes Intervall nach Review: $interval Tage',
  );

  static final _english = _DashboardStrings(
    dashboardTitle: 'Learner dashboard',
    progressTitle: 'Your learning progress',
    noDueItems: 'No struggling items are due now.',
    retention: 'Retention rate',
    masteredWords: 'Mastered words',
    streakDays: 'Streak days',
    progressBand: 'Curriculum band',
    curriculumProgress: 'A1 to B1 curriculum coverage',
    errorBank: 'Error bank',
    noStrugglingWords: 'No struggling words are due today.',
    priorityNote: 'Only items due today, ordered by priority.',
    quickReview: 'Start quick review',
    dueItems: (count) => '$count priority items are due for review today.',
    progressSummary: (band, tracked, mastery) =>
        'Current curriculum band: $band · $tracked tracked items · mastery index $mastery%',
    reviewRow: (priority, interval) =>
        'Priority $priority · next interval after review: $interval days',
  );
}
