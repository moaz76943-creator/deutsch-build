import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/achievement_models.dart';

final class StreakFlameGlassWidget extends StatelessWidget {
  const StreakFlameGlassWidget({
    required this.streak,
    super.key,
  });

  final UserStreak streak;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AppGlassCard(
      glowColor: AppColors.streak,
      borderColor:
          dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Row(
        children: <Widget>[
          Container(
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
                  'يوم متتالٍ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label.copyWith(
                    color: dark ? AppColors.primaryDark : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _FreezeIndicator(
            available: streak.freezeAvailable,
            dark: dark,
          ),
        ],
      ),
    );
  }
}

final class _FreezeIndicator extends StatelessWidget {
  const _FreezeIndicator({
    required this.available,
    required this.dark,
  });

  final bool available;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final color = available ? AppColors.secondary : Colors.grey;
    return Semantics(
      label: available
          ? 'حماية السلسلة متاحة ليوم غياب واحد'
          : 'تم استخدام حماية السلسلة',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
            const SizedBox(width: 5),
            Text(
              available ? 'Freeze' : 'Used',
              style: AppTypography.label.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
