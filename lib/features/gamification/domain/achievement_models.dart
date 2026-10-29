import 'gamification_models.dart';

final class UserStreak {
  const UserStreak({
    required this.currentDays,
    required this.longestDays,
    required this.lastActivityDate,
    bool? freezeAvailable,
    int? streakFreezesAvailable,
  })  : assert(
          streakFreezesAvailable == null || streakFreezesAvailable >= 0,
          'streakFreezesAvailable cannot be negative',
        ),
        streakFreezesAvailable = streakFreezesAvailable ??
            (freezeAvailable == true ? 1 : 0),
        freezeAvailable = freezeAvailable ??
            ((streakFreezesAvailable ?? 0) > 0);

  final int currentDays;
  final int longestDays;
  final DateTime? lastActivityDate;
  final bool freezeAvailable;
  final int streakFreezesAvailable;

  List<bool> get recentSevenDayActivity =>
      recentSevenDayActivityAt(lastActivityDate ?? DateTime.utc(1970));

  List<bool> recentSevenDayActivityAt(DateTime referenceDate) {
    final last = lastActivityDate;
    if (last == null || currentDays <= 0) {
      return List<bool>.unmodifiable(List<bool>.filled(7, false));
    }

    final referenceDay = DateTime.utc(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );
    final lastDay = DateTime.utc(last.year, last.month, last.day);
    final firstActiveDay = lastDay.subtract(
      Duration(days: currentDays.clamp(1, 10000).toInt() - 1),
    );

    return List<bool>.unmodifiable(
      List<bool>.generate(7, (index) {
        final day = referenceDay.subtract(Duration(days: 6 - index));
        return !day.isBefore(firstActiveDay) && !day.isAfter(lastDay);
      }),
    );
  }

  factory UserStreak.fromProfile(GamificationProfile profile) {
    final day = profile.lastLocalDay;
    return UserStreak(
      currentDays: profile.currentStreak,
      longestDays: profile.longestStreak,
      lastActivityDate: day == null
          ? null
          : DateTime.tryParse('${day}T00:00:00Z')?.toUtc(),
      streakFreezesAvailable: profile.streakFreezeAvailable ? 1 : 0,
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
    this.unlockCondition = '',
  });

  final String id;
  final String name;
  final String description;
  final String icon;
  final String unlockCondition;
  final DateTime? unlockedAt;

  bool get isUnlocked => unlockedAt != null;
}

class UserProgressLevel {
  const UserProgressLevel({
    required this.totalXp,
    required this.currentLevel,
    required this.levelFloorXp,
    required this.nextLevelXp,
    required this.progressToNextLevel,
  });

  final int totalXp;
  final int currentLevel;
  final int levelFloorXp;
  final int nextLevelXp;
  final double progressToNextLevel;

  int get xp => totalXp;

  factory UserProgressLevel.fromProfile(GamificationProfile profile) {
    final progress = profile.xpProgress;
    return UserProgressLevel(
      totalXp: progress.totalXp,
      currentLevel: progress.level,
      levelFloorXp: progress.levelFloorXp,
      nextLevelXp: progress.nextLevelXp,
      progressToNextLevel: progress.progressToNextLevel,
    );
  }
}

final class UserXpRecord extends UserProgressLevel {
  const UserXpRecord({
    required super.totalXp,
    required super.currentLevel,
    required super.levelFloorXp,
    required super.nextLevelXp,
    required super.progressToNextLevel,
  });

  factory UserXpRecord.fromProfile(GamificationProfile profile) {
    final progress = profile.xpProgress;
    return UserXpRecord(
      totalXp: progress.totalXp,
      currentLevel: progress.level,
      levelFloorXp: progress.levelFloorXp,
      nextLevelXp: progress.nextLevelXp,
      progressToNextLevel: progress.progressToNextLevel,
    );
  }
}

extension GamificationSnapshotProjection on GamificationSnapshot {
  UserStreak get userStreak => UserStreak.fromProfile(profile);

  UserXpRecord get userXpRecord => UserXpRecord.fromProfile(profile);

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
          unlockCondition: _unlockCondition(badge),
          unlockedAt: unlockedById[badge.id],
        ),
      ),
    );
  }
}

String _unlockCondition(MilestoneBadge badge) {
  final conditions = <String>[];
  final xp = badge.xpThreshold;
  if (xp != null) conditions.add('اجمع $xp XP');
  final streak = badge.streakThreshold;
  if (streak != null) conditions.add('حافظ على سلسلة $streak أيام');
  return conditions.isEmpty ? 'أكمل إنجاز التعلم المحدد' : conditions.join(' و ');
}

String _iconForBadge(String id) {
  if (id.startsWith('streak_')) return 'local_fire_department';
  if (id.startsWith('xp_1000')) return 'workspace_premium';
  if (id.startsWith('xp_')) return 'military_tech';
  return 'emoji_events';
}
