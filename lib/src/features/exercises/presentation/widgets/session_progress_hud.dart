import 'package:flutter/material.dart';

/// State of current exercise session passed to HUD.
class SessionHudState {
  final int currentIndex; // 0-based
  final int totalCount;
  final int correctCount;
  final int streak;
  final double bktMasteryProbability; // 0.0 to 1.0 (from BKT engine)

  const SessionHudState({
    required this.currentIndex,
    required this.totalCount,
    this.correctCount = 0,
    this.streak = 0,
    this.bktMasteryProbability = 0.0,
  });

  double get progressRatio =>
      totalCount > 0 ? (currentIndex + 1).clamp(0, totalCount) / totalCount : 0.0;

  String get masteryLabel {
    if (bktMasteryProbability >= 0.85) return 'متقن (Mastered)';
    if (bktMasteryProbability >= 0.60) return 'متمكن (Proficient)';
    if (bktMasteryProbability >= 0.30) return 'قيد التثبيت (Acquiring)';
    return 'جديد (Introductory)';
  }

  Color get masteryColor {
    if (bktMasteryProbability >= 0.85) return Colors.green;
    if (bktMasteryProbability >= 0.60) return Colors.teal;
    if (bktMasteryProbability >= 0.30) return Colors.orange;
    return Colors.blueGrey;
  }
}

/// HUD overlay displaying progress, streak, and real-time BKT mastery.
class SessionProgressHUD extends StatelessWidget {
  final SessionHudState state;
  final VoidCallback? onExitRequested;
  final bool showMasteryBadge;

  const SessionProgressHUD({
    super.key,
    required this.state,
    this.onExitRequested,
    this.showMasteryBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withOpacity(0.1),
              width: 1.0,
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // Exit / Pause session button
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'إنهاء الجلسة',
                    onPressed: onExitRequested,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),

                  // Animated Progress Bar
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: state.progressRatio),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) {
                          return LinearProgressIndicator(
                            value: value,
                            minHeight: 10.0,
                            backgroundColor: theme.colorScheme.surfaceVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Session Counter Text
                  Text(
                    '${state.currentIndex + 1}/${state.totalCount}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Streak indicator
                  if (state.streak > 0) ...[
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department_rounded,
                            color: Colors.amber, size: 18),
                        Text(
                          '${state.streak}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),

              // BKT Mastery Probability Badge
              if (showMasteryBadge) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'مستوى الاستيعاب اللحظي:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                        fontSize: 11,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: state.masteryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: state.masteryColor.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.psychology_rounded,
                              size: 13, color: state.masteryColor),
                          const SizedBox(width: 4),
                          Text(
                            '${state.masteryLabel} (${(state.bktMasteryProbability * 100).toStringAsFixed(0)}%)',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: state.masteryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
