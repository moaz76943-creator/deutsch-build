import 'gamification_models.dart';

final class UserStreak {
  const UserStreak({
    required this.currentDays,
    required this.longestDays,
    required this.lastActivityDate,
    required this.freezeAvailable,
  });

  final int currentDays;
  final int longestDays;
  final DateTime? lastActivityDate;
  final bool freezeAvailable;

  factory UserStreak.fromProfile(GamificationProfile profile) {
    final day = profile.lastLocalDay;
    return UserStreak(
      currentDays: profile.currentStreak,
      longestDays: profile.longestStreak,
      lastActivityDate: day == null
          ? null
          : DateTime.tryParse('${day}T00:00:00Z')?.toUtc(),
      freezeAvailable: profile.streakFreezeAvailable,
    );
  }
}

final class AchievementBadge {
  const AchievementBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.unlockedAt,
  });

  final String id;
  final String name;
  final String description;
  final String icon;
  final DateTime? unlockedAt;

  bool get isUnlocked => unlockedAt != null;
}

final class UserProgressLevel {
  const UserProgressLevel({
    required this.xp,
    required this.currentLevel,
    required this.levelFloorXp,
    required this.nextLevelXp,
    required this.progressToNextLevel,
  });

  final int xp;
  final int currentLevel;
  final int levelFloorXp;
  final int nextLevelXp;
  final double progressToNextLevel;

  factory UserProgressLevel.fromProfile(GamificationProfile profile) {
    final progress = profile.xpProgress;
    return UserProgressLevel(
      xp: progress.totalXp,
      currentLevel: progress.level,
      levelFloorXp: progress.levelFloorXp,
      nextLevelXp: progress.nextLevelXp,
      progressToNextLevel: progress.progressToNextLevel,
    );
  }
}

extension GamificationSnapshotProjection on GamificationSnapshot {
  UserStreak get userStreak => UserStreak.fromProfile(profile);

  UserProgressLevel get userProgressLevel =>
      UserProgressLevel.fromProfile(profile);

  List<AchievementBadge> get achievementBadges {
    final unlockedById = <String, DateTime>{
      for (final item in unlocked) item.badgeId: item.unlockedAtUtc,
    };
    return List<AchievementBadge>.unmodifiable(
      badges.map(
        (badge) => AchievementBadge(
          id: badge.id,
          name: badge.titleAr,
          description: badge.descriptionAr,
          icon: _iconForBadge(badge.id),
          unlockedAt: unlockedById[badge.id],
        ),
      ),
    );
  }
}

String _iconForBadge(String id) {
  if (id.startsWith('streak_')) return 'local_fire_department';
  if (id.startsWith('xp_1000')) return 'workspace_premium';
  if (id.startsWith('xp_')) return 'military_tech';
  return 'emoji_events';
}
