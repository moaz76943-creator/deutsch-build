import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/core/srs_facets.dart';
import 'package:deutsch_bilarabi/features/gamification/application/gamification_notifier.dart';
import 'package:deutsch_bilarabi/features/gamification/domain/gamification_models.dart';
import 'package:deutsch_bilarabi/features/gamification/gamification_engine.dart';
import 'package:deutsch_bilarabi/features/gamification/gamification_repository.dart';

final class _MemoryGamificationRepository implements GamificationRepository {
  _MemoryGamificationRepository([GamificationSnapshot? initial])
      : _snapshot = initial ??
            const GamificationSnapshot(
              profile: GamificationProfile(),
              unlocked: <UnlockedMilestone>[],
              badges: GamificationMilestones.defaults,
            );

  GamificationSnapshot _snapshot;
  final Set<String> _reviewIds = <String>{};

  @override
  Future<void> recordReview(GamificationReviewEvent event) async {
    if (!_reviewIds.add(event.reviewId)) return;
    final transition = GamificationEngine.apply(
      _snapshot.profile,
      event,
      alreadyUnlocked: _snapshot.unlockedBadgeIds,
    );
    _snapshot = GamificationSnapshot(
      profile: transition.profile,
      unlocked: <UnlockedMilestone>[
        ..._snapshot.unlocked,
        for (final badge in transition.newlyUnlocked)
          UnlockedMilestone(
            badgeId: badge.id,
            unlockedAtUtc: event.occurredAtUtc.toUtc(),
          ),
      ],
      badges: GamificationMilestones.defaults,
    );
  }

  @override
  Future<GamificationSnapshot> loadSnapshot() async => _snapshot;

  @override
  Future<void> clearGamification() async {
    _reviewIds.clear();
    _snapshot = const GamificationSnapshot(
      profile: GamificationProfile(),
      unlocked: <UnlockedMilestone>[],
      badges: GamificationMilestones.defaults,
    );
  }

  @override
  Future<void> close() async {}
}

void main() {
  test('completing sessions updates XP and local-calendar streak', () async {
    final notifier = GamificationNotifier(_MemoryGamificationRepository());
    addTearDown(notifier.dispose);
    await notifier.initialize();

    await notifier.completeSession(
      sessionId: 's1',
      completedAtUtc: DateTime.utc(2026, 10, 2, 7),
      earnedXp: 10,
      timezoneOffsetMinutes: 180,
    );
    final result = await notifier.completeSession(
      sessionId: 's2',
      completedAtUtc: DateTime.utc(2026, 10, 3, 7),
      earnedXp: 15,
      timezoneOffsetMinutes: 180,
    );

    expect(result.state.streak.currentDays, 2);
    expect(result.state.streak.longestDays, 2);
    expect(result.state.progress.xp, 25);
  });

  test('one-day excused absence consumes freeze and emits event', () async {
    final repository = _MemoryGamificationRepository(
      GamificationSnapshot(
        profile: GamificationProfile(
          currentStreak: 3,
          longestStreak: 3,
          lastReviewAtUtc: DateTime.utc(2026, 10, 1, 7),
          lastLocalDay: '2026-10-01',
          lastTimezoneOffsetMinutes: 180,
        ),
        unlocked: const <UnlockedMilestone>[],
        badges: GamificationMilestones.defaults,
      ),
    );
    final notifier = GamificationNotifier(repository);
    addTearDown(notifier.dispose);
    await notifier.initialize();

    final result = await notifier.completeSession(
      sessionId: 'freeze_session',
      completedAtUtc: DateTime.utc(2026, 10, 3, 7),
      earnedXp: 10,
      timezoneOffsetMinutes: 180,
      useStreakFreeze: true,
    );

    expect(result.state.streak.currentDays, 4);
    expect(result.state.streak.freezeAvailable, isFalse);
    expect(
      result.events.map((event) => event.type),
      contains(GamificationUiEventType.streakFreezeUsed),
    );
  });

  test('crossing badge threshold unlocks achievement and emits badge event',
      () async {
    final repository = _MemoryGamificationRepository(
      GamificationSnapshot(
        profile: GamificationProfile(
          totalXp: 95,
          currentStreak: 1,
          longestStreak: 1,
          lastReviewAtUtc: DateTime.utc(2026, 10, 2, 7),
          lastLocalDay: '2026-10-02',
          lastTimezoneOffsetMinutes: 180,
        ),
        unlocked: const <UnlockedMilestone>[],
        badges: GamificationMilestones.defaults,
      ),
    );
    final notifier = GamificationNotifier(repository);
    addTearDown(notifier.dispose);
    await notifier.initialize();

    final result = await notifier.completeSession(
      sessionId: 'badge_session',
      completedAtUtc: DateTime.utc(2026, 10, 2, 8),
      earnedXp: 10,
      timezoneOffsetMinutes: 180,
      facetType: ReviewFacetType.listening,
    );

    expect(
      result.state.badges
          .firstWhere((badge) => badge.id == 'xp_100')
          .isUnlocked,
      isTrue,
    );
    expect(
      result.events
          .where((event) => event.type == GamificationUiEventType.badgeUnlocked)
          .map((event) => event.badge?.id),
      contains('xp_100'),
    );
  });

  test('crossing 250 XP emits deterministic level-up event', () async {
    final repository = _MemoryGamificationRepository(
      GamificationSnapshot(
        profile: GamificationProfile(
          totalXp: 245,
          currentStreak: 1,
          longestStreak: 1,
          lastReviewAtUtc: DateTime.utc(2026, 10, 2, 7),
          lastLocalDay: '2026-10-02',
          lastTimezoneOffsetMinutes: 180,
        ),
        unlocked: const <UnlockedMilestone>[],
        badges: GamificationMilestones.defaults,
      ),
    );
    final notifier = GamificationNotifier(repository);
    addTearDown(notifier.dispose);
    await notifier.initialize();

    final result = await notifier.completeSession(
      sessionId: 'level_session',
      completedAtUtc: DateTime.utc(2026, 10, 2, 8),
      earnedXp: 10,
      timezoneOffsetMinutes: 180,
    );

    expect(result.state.progress.currentLevel, 2);
    final levelEvent = result.events.singleWhere(
      (event) => event.type == GamificationUiEventType.levelUp,
    );
    expect(levelEvent.fromLevel, 1);
    expect(levelEvent.toLevel, 2);
  });

  test('exercise and card completion award XP through the canonical notifier path', () async {
    final notifier = GamificationNotifier(_MemoryGamificationRepository());
    addTearDown(notifier.dispose);
    await notifier.initialize();

    await notifier.completeExercise(
      activityId: 'exercise_1',
      completedAtUtc: DateTime.utc(2026, 10, 2, 7),
      earnedXp: 12,
      timezoneOffsetMinutes: 180,
    );
    final result = await notifier.completeCardReview(
      activityId: 'card_1',
      completedAtUtc: DateTime.utc(2026, 10, 3, 7),
      earnedXp: 8,
      timezoneOffsetMinutes: 180,
    );

    expect(result.state.progress.totalXp, 20);
    expect(result.state.streak.currentDays, 2);
  });
}
