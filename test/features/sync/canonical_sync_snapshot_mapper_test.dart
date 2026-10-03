import 'package:deutsch_bilarabi/core/srs_facets.dart';
import 'package:deutsch_bilarabi/features/gamification/domain/gamification_models.dart';
import 'package:deutsch_bilarabi/features/sync/data/canonical_sync_snapshot_mapper.dart';
import 'package:deutsch_bilarabi/models/learner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('canonical mapper round-trips SRS facets and gamification achievements', () {
    final now = DateTime.utc(2026, 10, 3, 10);
    final key = ReviewFacetKey(
      conceptId: 'noun.tisch',
      facetType: ReviewFacetType.pronunciation,
      variantKey: 'de',
    );
    final state = LearnerState(
      xp: 420,
      streak: 6,
      updatedAt: now,
      reviewCards: <String, ReviewCard>{
        key.storageKey: ReviewCard(
          itemId: 'noun.tisch',
          facetType: ReviewFacetType.pronunciation,
          variantKey: 'de',
          repetitions: 4,
          intervalDays: 8,
          lapses: 1,
          successes: 5,
          failures: 2,
          difficulty: 1.4,
          stabilityDays: 7.5,
          dueAt: now.add(const Duration(days: 4)),
          lastReviewedAt: now,
        ),
      },
    );
    const profile = GamificationProfile(
      totalXp: 500,
      currentStreak: 7,
      longestStreak: 12,
    );
    final gamification = GamificationSnapshot(
      profile: profile,
      unlocked: <UnlockedMilestone>[
        UnlockedMilestone(
          badgeId: 'xp_100',
          unlockedAtUtc: now,
        ),
      ],
      badges: GamificationMilestones.defaults,
    );

    final snapshot = CanonicalSyncSnapshotMapper.fromCanonicalState(
      learner: state,
      gamification: gamification,
      revision: 'local-r1',
    );

    expect(snapshot.totalXp, 500);
    expect(snapshot.currentStreak, 7);
    expect(snapshot.longestStreak, 12);
    expect(snapshot.achievementIds, contains('xp_100'));
    expect(snapshot.srs[key.storageKey]?.intervalDays, 8);
    expect(snapshot.srs[key.storageKey]?.facetTypeWire, 'pronunciation');

    final restored = CanonicalSyncSnapshotMapper.applyToLearnerState(
      local: LearnerState(updatedAt: now),
      snapshot: snapshot,
    );
    final restoredCard = restored.reviewCards[key.storageKey];

    expect(restored.xp, 500);
    expect(restored.streak, 7);
    expect(restoredCard?.facetType, ReviewFacetType.pronunciation);
    expect(restoredCard?.variantKey, 'de');
    expect(restoredCard?.stabilityDays, 7.5);
    expect(restoredCard?.lastReviewedAt, now);
  });
}
