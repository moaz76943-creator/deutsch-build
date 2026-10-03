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
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontal = constraints.maxWidth >= 720 ? 28.0 : 16.0;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(horizontal, 20, horizontal, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(
                      analytics: analytics,
                      textColor: textColor,
                      secondaryText: secondaryText,
                    ),
                    const SizedBox(height: 18),
                    _StatsGrid(
                      analytics: analytics,
                      availableWidth:
                          constraints.maxWidth - (horizontal * 2),
                      textColor: textColor,
                      secondaryText: secondaryText,
                    ),
                    const SizedBox(height: 18),
                    _ProgressCard(
                      analytics: analytics,
                      textColor: textColor,
                      secondaryText: secondaryText,
                    ),
                    const SizedBox(height: 18),
                    _ErrorBankCard(
                      analytics: analytics,
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
    required this.textColor,
    required this.secondaryText,
  });

  final LearnerDashboardAnalytics analytics;
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
                  'لوحة تقدّمك',
                  style: AppTypography.title.copyWith(color: textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  analytics.dailyReview.isEmpty
                      ? 'لا توجد عناصر متعثرة مستحقة الآن.'
                      : 'لديك ${analytics.dailyReview.length} عناصر ذات أولوية للمراجعة.',
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
    required this.availableWidth,
    required this.textColor,
    required this.secondaryText,
  });

  final LearnerDashboardAnalytics analytics;
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
        label: 'معدل الحفظ',
        value: '${(analytics.retentionRate * 100).round()}%',
        icon: Icons.memory_rounded,
        accent: AppColors.secondary,
      ),
      _StatData(
        label: 'الكلمات المتقنة',
        value: '${analytics.masteredWords}',
        icon: Icons.verified_rounded,
        accent: AppColors.mastery,
      ),
      _StatData(
        label: 'أيام السلسلة',
        value: '${analytics.currentStreakDays}',
        icon: Icons.local_fire_department_rounded,
        accent: AppColors.streak,
      ),
      _StatData(
        label: 'مرحلة التقدم',
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
    required this.textColor,
    required this.secondaryText,
  });

  final LearnerDashboardAnalytics analytics;
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
                  'التقدم من A1 إلى B1',
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
            'مؤشر الإتقان الحالي: ${analytics.progressBand} · '
            '${analytics.trackedItems} عنصرًا متابعًا',
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
    required this.textColor,
    required this.secondaryText,
    required this.onStartQuickReview,
  });

  final LearnerDashboardAnalytics analytics;
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
                  'بنك الأخطاء',
                  style: AppTypography.title.copyWith(color: textColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            queue.isEmpty
                ? 'لا توجد كلمات متعثرة ضمن قائمة اليوم.'
                : 'مرتبة تلقائيًا حسب الأولوية ومؤشر الإتقان.',
            style: AppTypography.body.copyWith(color: secondaryText),
          ),
          if (queue.isNotEmpty) ...[
            const SizedBox(height: 14),
            for (final item in queue.take(5)) ...[
              _ReviewRow(
                item: item,
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
              label: const Text('ابدأ مراجعة سريعة'),
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
    required this.textColor,
    required this.secondaryText,
    this.onTap,
  });

  final AdaptiveReviewItem item;
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
                  'أولوية $priority · مراجعة خلال '
                  '${item.reviewIntervalDays} يوم',
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
