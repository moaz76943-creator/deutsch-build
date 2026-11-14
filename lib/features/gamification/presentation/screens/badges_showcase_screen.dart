import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../../design_system/app_colors.dart';
import '../../../../design_system/app_glass_card.dart';
import '../../application/gamification_notifier.dart';
import '../../domain/achievement_models.dart';

class BadgesShowcaseScreen extends StatelessWidget {
  const BadgesShowcaseScreen({
    required this.state,
    super.key,
  });

  final GamificationViewState state;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          dark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('شارات الإنجاز', style: AppTypography.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: state.badges.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
            mainAxisExtent: 276,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
          ),
          itemBuilder: (context, index) {
            final badge = state.badges[index];
            return _BadgeGlassTile(
              badge: badge,
              progress: state.badgeProgress[badge.id] ?? 0,
              dark: dark,
            );
          },
        ),
      ),
    );
  }
}

final class _BadgeGlassTile extends StatelessWidget {
  const _BadgeGlassTile({
    required this.badge,
    required this.progress,
    required this.dark,
  });

  final AchievementBadge badge;
  final double progress;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final unlocked = badge.isUnlocked;
    final accent = unlocked ? AppColors.achievement : Colors.grey;
    return AppGlassCard(
      padding: const EdgeInsets.all(14),
      glowColor: unlocked ? AppColors.achievement : null,
      borderColor:
          dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withAlpha(unlocked ? 34 : 20),
                ),
                child: Icon(
                  _iconData(badge.icon),
                  color: accent,
                  size: 26,
                ),
              ),
              const Spacer(),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: accent.withAlpha(24),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  child: Text(
                    unlocked ? 'مكتسب' : 'مغلق',
                    style: AppTypography.label.copyWith(color: accent),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            badge.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.title.copyWith(
              fontSize: 16,
              color: dark ? Colors.white : AppColors.darkSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            badge.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body.copyWith(
              color: dark
                  ? Colors.white.withAlpha(190)
                  : AppColors.darkSurface.withAlpha(190),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            badge.unlockCondition,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label.copyWith(
              color: dark ? AppColors.primaryDark : AppColors.primary,
            ),
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0).toDouble(),
              minHeight: 7,
              backgroundColor: accent.withAlpha(22),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            unlocked
                ? 'تم فتح الشارة'
                : 'التقدم ${(progress.clamp(0.0, 1.0) * 100).round()}%',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label.copyWith(color: accent),
          ),
        ],
      ),
    );
  }

  static IconData _iconData(String name) => switch (name) {
        'local_fire_department' => Icons.local_fire_department_rounded,
        'workspace_premium' => Icons.workspace_premium_rounded,
        'military_tech' => Icons.military_tech_rounded,
        _ => Icons.emoji_events_rounded,
      };
}
