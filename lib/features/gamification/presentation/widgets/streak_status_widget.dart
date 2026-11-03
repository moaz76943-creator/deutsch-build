import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../../design_system/app_colors.dart';
import '../../../../design_system/app_glass_card.dart';
import '../../domain/achievement_models.dart';

final class StreakStatusWidget extends StatelessWidget {
  const StreakStatusWidget({
    required this.streak,
    this.onTap,
    this.referenceDate,
    super.key,
  });

  final UserStreak streak;
  final VoidCallback? onTap;
  final DateTime? referenceDate;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final recentDays = streak.recentSevenDayActivityAt(
      referenceDate ?? DateTime.now(),
    );

    return AppGlassCard(
      onTap: onTap,
      glowColor: AppColors.streak,
      borderColor:
          dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: .92, end: 1),
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.streak.withAlpha(28),
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColors.streak,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '${streak.currentDays}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.display.copyWith(
                        color: dark ? Colors.white : AppColors.darkSurface,
                      ),
                    ),
                    Text(
                      'يوم متتالٍ · الأفضل ${streak.longestDays}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label.copyWith(
                        color:
                            dark ? AppColors.primaryDark : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _FreezeIndicator(
                count: streak.streakFreezesAvailable,
                dark: dark,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'آخر 7 أيام',
            style: AppTypography.label.copyWith(
              color: dark ? Colors.white70 : AppColors.darkSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              for (var index = 0; index < recentDays.length; index += 1)
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      end: index == recentDays.length - 1 ? 0 : 6,
                    ),
                    child: _DayIndicator(
                      key: ValueKey<String>('streak-day-$index'),
                      active: recentDays[index],
                      dark: dark,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _DayIndicator extends StatelessWidget {
  const _DayIndicator({
    required this.active,
    required this.dark,
    super.key,
  });

  final bool active;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.streak : Colors.grey;
    return Semantics(
      label: active ? 'يوم تعلم مكتمل' : 'لا يوجد نشاط تعلم مسجل',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 10,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: color.withAlpha(active ? 210 : (dark ? 52 : 38)),
        ),
      ),
    );
  }
}

final class _FreezeIndicator extends StatelessWidget {
  const _FreezeIndicator({
    required this.count,
    required this.dark,
  });

  final int count;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final available = count > 0;
    final color = available ? AppColors.secondary : Colors.grey;
    return Semantics(
      label: available
          ? 'أيام حماية السلسلة المتاحة: $count'
          : 'لا توجد أيام حماية سلسلة متاحة',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: color.withAlpha(dark ? 34 : 22),
          border: Border.all(color: color.withAlpha(90)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              available ? Icons.ac_unit_rounded : Icons.lock_outline_rounded,
              color: color,
              size: 17,
            ),
            const SizedBox(width: 4),
            Text(
              '×$count',
              style: AppTypography.label.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
