import '../../../core/srs_facets.dart';
import '../../../features/gamification/domain/gamification_models.dart';
import '../../../models/learner.dart';
import '../domain/sync_models.dart';

abstract final class CanonicalSyncSnapshotMapper {
  static SyncProgressSnapshot fromCanonicalState({
    required LearnerState learner,
    required GamificationSnapshot gamification,
    required String revision,
  }) {
    final srs = <String, SyncSrsRecord>{};
    for (final entry in learner.reviewCards.entries) {
      final card = entry.value;
      final updatedAt =
          card.lastReviewedAt?.toUtc() ?? learner.updatedAt.toUtc();
      srs[entry.key] = SyncSrsRecord(
        key: entry.key,
        updatedAtUtc: updatedAt,
        dueAtUtc: card.dueAt.toUtc(),
        repetitions: card.repetitions,
        intervalDays: card.intervalDays,
        lapses: card.lapses,
        successes: card.successes,
        failures: card.failures,
        difficulty: card.difficulty,
        stabilityDays: card.stabilityDays,
        lastReviewedAtUtc: card.lastReviewedAt?.toUtc(),
      );
    }

    final profile = gamification.profile;
    final currentStreak = learner.streak > profile.currentStreak
        ? learner.streak
        : profile.currentStreak;
    final longestStreak = profile.longestStreak > currentStreak
        ? profile.longestStreak
        : currentStreak;
    final xp = learner.xp > profile.totalXp ? learner.xp : profile.totalXp;

    return SyncProgressSnapshot(
      revision: revision,
      updatedAtUtc: learner.updatedAt.toUtc(),
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalXp: xp,
      srs: srs,
      achievementIds: gamification.unlockedBadgeIds,
    );
  }

  static LearnerState applyToLearnerState({
    required LearnerState local,
    required SyncProgressSnapshot snapshot,
  }) {
    final reviewCards = <String, ReviewCard>{...local.reviewCards};

    for (final entry in snapshot.srs.entries) {
      final key = ReviewFacetKey.fromStorageKey(entry.key);
      if (!key.isValid) continue;
      final record = entry.value;
      reviewCards[entry.key] = ReviewCard(
        itemId: key.conceptId,
        facetType: key.facetType,
        variantKey: key.normalizedVariantKey,
        repetitions: record.repetitions,
        intervalDays: record.intervalDays,
        lapses: record.lapses,
        successes: record.successes,
        failures: record.failures,
        difficulty: record.difficulty,
        stabilityDays: record.stabilityDays,
        dueAt: record.dueAtUtc,
        lastReviewedAt: record.lastReviewedAtUtc,
      );
    }

    return local.copyWith(
      xp: snapshot.totalXp,
      streak: snapshot.currentStreak,
      reviewCards: reviewCards,
    );
  }
}
