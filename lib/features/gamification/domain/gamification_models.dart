import '../../../core/srs_facets.dart';
import 'gamification_clock_integrity_source.dart';

final class XpProgress {
  const XpProgress({
    required this.totalXp,
    required this.level,
    required this.levelFloorXp,
    required this.nextLevelXp,
  });

  final int totalXp;
  final int level;
  final int levelFloorXp;
  final int nextLevelXp;

  double get progressToNextLevel {
    final span = nextLevelXp - levelFloorXp;
    if (span <= 0) return 1;
    return ((totalXp - levelFloorXp) / span).clamp(0.0, 1.0).toDouble();
  }

  factory XpProgress.fromTotalXp(int rawXp) {
    final xp = rawXp.clamp(0, 100000000).toInt();
    final level = (xp ~/ 250) + 1;
    final floor = (level - 1) * 250;
    return XpProgress(
      totalXp: xp,
      level: level,
      levelFloorXp: floor,
      nextLevelXp: level * 250,
    );
  }
}

final class DailyStreak {
  const DailyStreak({
    required this.current,
    required this.longest,
    required this.lastLocalDay,
    required this.clockAnomalyDetected,
  });

  final int current;
  final int longest;
  final String? lastLocalDay;
  final bool clockAnomalyDetected;
}

final class MilestoneBadge {
  const MilestoneBadge({
    required this.id,
    required this.titleAr,
    required this.descriptionAr,
    this.xpThreshold,
    this.streakThreshold,
  });

  final String id;
  final String titleAr;
  final String descriptionAr;
  final int? xpThreshold;
  final int? streakThreshold;

  bool isReached(GamificationProfile profile) {
    final xp = xpThreshold;
    if (xp != null && profile.totalXp < xp) return false;
    final streak = streakThreshold;
    if (streak != null && profile.currentStreak < streak) return false;
    return xp != null || streak != null;
  }
}

abstract final class GamificationMilestones {
  static const List<MilestoneBadge> defaults = <MilestoneBadge>[
    MilestoneBadge(
      id: 'xp_100',
      titleAr: 'أول 100 XP',
      descriptionAr: 'أكمل مراجعات SRS واجمع 100 نقطة خبرة.',
      xpThreshold: 100,
    ),
    MilestoneBadge(
      id: 'xp_500',
      titleAr: '500 XP',
      descriptionAr: 'استمر بالمراجعة حتى 500 نقطة خبرة.',
      xpThreshold: 500,
    ),
    MilestoneBadge(
      id: 'streak_7',
      titleAr: 'أسبوع متواصل',
      descriptionAr: 'راجع في سبعة أيام محلية متتالية.',
      streakThreshold: 7,
    ),
    MilestoneBadge(
      id: 'xp_1000',
      titleAr: '1000 XP',
      descriptionAr: 'وصل إلى 1000 نقطة خبرة محلية.',
      xpThreshold: 1000,
    ),
    MilestoneBadge(
      id: 'streak_30',
      titleAr: '30 يومًا',
      descriptionAr: 'حافظ على سلسلة مراجعة لمدة 30 يومًا.',
      streakThreshold: 30,
    ),
  ];
}

final class GamificationProfile {
  const GamificationProfile({
    this.totalXp = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastReviewAtUtc,
    this.lastLocalDay,
    this.lastTimezoneOffsetMinutes,
    this.lastMonotonicElapsedMilliseconds,
    this.lastBootCount,
    this.clockAnomalyDetected = false,
    this.streakFreezeAvailable = true,
  });

  final int totalXp;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastReviewAtUtc;
  final String? lastLocalDay;
  final int? lastTimezoneOffsetMinutes;
  final int? lastMonotonicElapsedMilliseconds;
  final int? lastBootCount;
  final bool clockAnomalyDetected;
  final bool streakFreezeAvailable;

  XpProgress get xpProgress => XpProgress.fromTotalXp(totalXp);

  DailyStreak get streak => DailyStreak(
        current: currentStreak,
        longest: longestStreak,
        lastLocalDay: lastLocalDay,
        clockAnomalyDetected: clockAnomalyDetected,
      );
}

final class GamificationReviewEvent {
  const GamificationReviewEvent({
    required this.reviewId,
    required this.facetType,
    required this.correct,
    required this.hinted,
    required this.requestedXp,
    required this.occurredAtUtc,
    required this.timezoneOffsetMinutes,
    this.useStreakFreeze = false,
    this.clockIntegrityStamp,
  });

  final String reviewId;
  final ReviewFacetType facetType;
  final bool correct;
  final bool hinted;
  final int requestedXp;
  final DateTime occurredAtUtc;
  final int timezoneOffsetMinutes;
  final bool useStreakFreeze;
  final GamificationClockIntegrityStamp? clockIntegrityStamp;
}

final class UnlockedMilestone {
  const UnlockedMilestone({required this.badgeId, required this.unlockedAtUtc});

  final String badgeId;
  final DateTime unlockedAtUtc;
}

final class GamificationSnapshot {
  const GamificationSnapshot({
    required this.profile,
    required this.unlocked,
    required this.badges,
  });

  final GamificationProfile profile;
  final List<UnlockedMilestone> unlocked;
  final List<MilestoneBadge> badges;

  Set<String> get unlockedBadgeIds =>
      unlocked.map((item) => item.badgeId).toSet();

  MilestoneBadge? get nextMilestone {
    final unlockedIds = unlockedBadgeIds;
    for (final badge in badges) {
      if (!unlockedIds.contains(badge.id)) return badge;
    }
    return null;
  }
}

final class GamificationTransition {
  const GamificationTransition({
    required this.profile,
    required this.awardedXp,
    required this.clockAnomaly,
    required this.newlyUnlocked,
    this.streakFreezeUsed = false,
  });

  final GamificationProfile profile;
  final int awardedXp;
  final bool clockAnomaly;
  final List<MilestoneBadge> newlyUnlocked;
  final bool streakFreezeUsed;
}
