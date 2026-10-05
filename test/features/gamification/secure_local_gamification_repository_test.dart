import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/core/infrastructure/storage/local_storage_repository.dart';
import 'package:deutsch_bilarabi/core/srs_facets.dart';
import 'package:deutsch_bilarabi/features/gamification/data/secure_local_gamification_repository.dart';
import 'package:deutsch_bilarabi/features/gamification/domain/gamification_clock_integrity_source.dart';
import 'package:deutsch_bilarabi/features/gamification/domain/gamification_models.dart';

final class _MemoryLocalStorage implements LocalStorageRepository {
  final Map<StorageBucket, Map<String, Object?>> values =
      <StorageBucket, Map<String, Object?>>{};

  @override
  Future<void> save(
    StorageBucket bucket,
    Map<String, Object?> payload,
  ) async {
    values[bucket] = Map<String, Object?>.from(payload);
  }

  @override
  Future<Map<String, Object?>?> load(StorageBucket bucket) async {
    final value = values[bucket];
    return value == null ? null : Map<String, Object?>.from(value);
  }

  @override
  Future<void> delete(StorageBucket bucket) async {
    values.remove(bucket);
  }

  @override
  Future<void> dispose() async {}
}

GamificationReviewEvent _event(
  String id,
  DateTime at, {
  int xp = 10,
  bool freeze = false,
}) =>
    GamificationReviewEvent(
      reviewId: id,
      facetType: ReviewFacetType.meaningRecall,
      correct: true,
      hinted: false,
      requestedXp: xp,
      occurredAtUtc: at,
      timezoneOffsetMinutes: 180,
      useStreakFreeze: freeze,
    );

void main() {
  test('secure local repository persists offline state and unlocked badges',
      () async {
    final storage = _MemoryLocalStorage();
    final repository = SecureLocalGamificationRepository(storage);

    await repository.recordReview(
      _event('review_1', DateTime.utc(2026, 10, 2, 7), xp: 100),
    );

    final snapshot = await repository.loadSnapshot();
    expect(snapshot.profile.totalXp, 100);
    expect(snapshot.profile.currentStreak, 1);
    expect(snapshot.unlockedBadgeIds, contains('xp_100'));
    expect(storage.values, contains(StorageBucket.gamification));
  });

  test('duplicate session id cannot double-award XP', () async {
    final storage = _MemoryLocalStorage();
    final repository = SecureLocalGamificationRepository(storage);
    final event = _event('same_session', DateTime.utc(2026, 10, 2, 7));

    await repository.recordReview(event);
    await repository.recordReview(event);

    expect((await repository.loadSnapshot()).profile.totalXp, 10);
  });

  test('monotonic integrity anchors survive repository recreation', () async {
    final storage = _MemoryLocalStorage();
    final first = SecureLocalGamificationRepository(storage);

    await first.recordReview(
      GamificationReviewEvent(
        reviewId: 'clock_anchor',
        facetType: ReviewFacetType.meaningRecall,
        correct: true,
        hinted: false,
        requestedXp: 10,
        occurredAtUtc: DateTime.utc(2026, 10, 2, 7),
        timezoneOffsetMinutes: 180,
        clockIntegrityStamp: const GamificationClockIntegrityStamp(
          elapsedRealtimeMilliseconds: 456000,
          bootCount: 9,
        ),
      ),
    );

    final recreated = SecureLocalGamificationRepository(storage);
    final profile = (await recreated.loadSnapshot()).profile;
    expect(profile.lastMonotonicElapsedMilliseconds, 456000);
    expect(profile.lastBootCount, 9);
  });

  test('consumed streak freeze survives repository recreation', () async {
    final storage = _MemoryLocalStorage();
    final first = SecureLocalGamificationRepository(storage);

    await first.recordReview(
      _event('day_1', DateTime.utc(2026, 10, 1, 7)),
    );
    await first.recordReview(
      _event(
        'day_3',
        DateTime.utc(2026, 10, 3, 7),
        freeze: true,
      ),
    );

    final recreated = SecureLocalGamificationRepository(storage);
    final snapshot = await recreated.loadSnapshot();
    expect(snapshot.profile.currentStreak, 2);
    expect(snapshot.profile.streakFreezeAvailable, isFalse);
  });
}
