import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:deutsch_bilarabi/core/srs_facets.dart';
import 'package:deutsch_bilarabi/features/gamification/domain/gamification_clock_integrity_source.dart';
import 'package:deutsch_bilarabi/features/gamification/domain/gamification_models.dart';
import 'package:deutsch_bilarabi/features/gamification/sqlite_gamification_repository.dart';



final class _ClockSource implements GamificationClockIntegritySource {
  _ClockSource(this._stamps);

  final List<GamificationClockIntegrityStamp> _stamps;
  int _index = 0;

  @override
  Future<GamificationClockIntegrityStamp?> read() async {
    if (_index >= _stamps.length) return null;
    return _stamps[_index++];
  }
}

void main() {
  setUpAll(sqfliteFfiInit);

  test('stores XP streak events and badges only in local SQLite', () async {
    final repository = await SqliteGamificationRepository.openWithFactory(
      databaseFactoryFfi,
      inMemoryDatabasePath,
    );
    addTearDown(repository.close);

    await repository.recordReview(
      GamificationReviewEvent(
        reviewId: 'review_1',
        facetType: ReviewFacetType.meaningRecall,
        correct: true,
        hinted: false,
        requestedXp: 100,
        occurredAtUtc: DateTime.utc(2026, 10, 2, 8),
        timezoneOffsetMinutes: 180,
      ),
    );

    final snapshot = await repository.loadSnapshot();
    expect(snapshot.profile.totalXp, 100);
    expect(snapshot.profile.currentStreak, 1);
    expect(snapshot.unlockedBadgeIds, contains('xp_100'));
  });

  test(
    'duplicate review id is idempotent and cannot double-award XP',
    () async {
      final repository = await SqliteGamificationRepository.openWithFactory(
        databaseFactoryFfi,
        inMemoryDatabasePath,
      );
      addTearDown(repository.close);
      final event = GamificationReviewEvent(
        reviewId: 'same_review',
        facetType: ReviewFacetType.listening,
        correct: true,
        hinted: false,
        requestedXp: 10,
        occurredAtUtc: DateTime.utc(2026, 10, 2, 8),
        timezoneOffsetMinutes: 180,
      );

      await repository.recordReview(event);
      await repository.recordReview(event);

      expect((await repository.loadSnapshot()).profile.totalXp, 10);
    },
  );

  test('clear removes gamification events badges and profile totals', () async {
    final repository = await SqliteGamificationRepository.openWithFactory(
      databaseFactoryFfi,
      inMemoryDatabasePath,
    );
    addTearDown(repository.close);

    await repository.recordReview(
      GamificationReviewEvent(
        reviewId: 'review_clear',
        facetType: ReviewFacetType.listening,
        correct: true,
        hinted: false,
        requestedXp: 100,
        occurredAtUtc: DateTime.utc(2026, 10, 2, 8),
        timezoneOffsetMinutes: 180,
      ),
    );
    await repository.clearGamification();

    final snapshot = await repository.loadSnapshot();
    expect(snapshot.profile.totalXp, 0);
    expect(snapshot.profile.currentStreak, 0);
    expect(snapshot.unlocked, isEmpty);
  });
  test('migrates legacy streak and XP only into a pristine database', () async {
    final repository = await SqliteGamificationRepository.openWithFactory(
      databaseFactoryFfi,
      inMemoryDatabasePath,
    );
    addTearDown(repository.close);

    final migrated = await repository.migrateLegacyProfileIfPristine(
      totalXp: 640,
      currentStreak: 12,
      lastReviewAtUtc: DateTime.utc(2026, 10, 4, 20),
      timezoneOffsetMinutes: 180,
    );

    expect(migrated, isTrue);
    final snapshot = await repository.loadSnapshot();
    expect(snapshot.profile.totalXp, 640);
    expect(snapshot.profile.currentStreak, 12);
    expect(snapshot.profile.longestStreak, 12);
    expect(snapshot.profile.lastLocalDay, '2026-10-04');
    expect(snapshot.profile.lastMonotonicElapsedMilliseconds, isNull);
    expect(snapshot.profile.lastBootCount, isNull);
    expect(
      snapshot.unlockedBadgeIds,
      containsAll(<String>['xp_100', 'xp_500', 'streak_7']),
    );

    final second = await repository.migrateLegacyProfileIfPristine(
      totalXp: 9999,
      currentStreak: 99,
      lastReviewAtUtc: DateTime.utc(2026, 10, 5, 20),
      timezoneOffsetMinutes: 180,
    );
    expect(second, isFalse);
    expect((await repository.loadSnapshot()).profile.totalXp, 640);
  });

  test('same-boot forward wall-clock jump is rejected by repository source', () async {
    final source = _ClockSource(<GamificationClockIntegrityStamp>[
      const GamificationClockIntegrityStamp(
        elapsedRealtimeMilliseconds: 1000000,
        bootCount: 5,
      ),
      const GamificationClockIntegrityStamp(
        elapsedRealtimeMilliseconds: 1060000,
        bootCount: 5,
      ),
    ]);
    final repository = await SqliteGamificationRepository.openWithFactory(
      databaseFactoryFfi,
      inMemoryDatabasePath,
      clockIntegritySource: source,
    );
    addTearDown(repository.close);

    await repository.recordReview(
      GamificationReviewEvent(
        reviewId: 'clock_1',
        facetType: ReviewFacetType.meaningRecall,
        correct: true,
        hinted: false,
        requestedXp: 10,
        occurredAtUtc: DateTime.utc(2026, 10, 2, 8),
        timezoneOffsetMinutes: 180,
      ),
    );
    await repository.recordReview(
      GamificationReviewEvent(
        reviewId: 'clock_2',
        facetType: ReviewFacetType.meaningRecall,
        correct: true,
        hinted: false,
        requestedXp: 10,
        occurredAtUtc: DateTime.utc(2026, 10, 3, 8),
        timezoneOffsetMinutes: 180,
      ),
    );

    final snapshot = await repository.loadSnapshot();
    expect(snapshot.profile.totalXp, 10);
    expect(snapshot.profile.currentStreak, 1);
    expect(snapshot.profile.clockAnomalyDetected, isTrue);
    expect(snapshot.profile.lastMonotonicElapsedMilliseconds, 1000000);
    expect(snapshot.profile.lastBootCount, 5);
  });

}
