import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:deutsch_bilarabi/core/srs_facets.dart';
import 'package:deutsch_bilarabi/features/gamification/domain/gamification_models.dart';
import 'package:deutsch_bilarabi/features/gamification/sqlite_gamification_repository.dart';

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

  test('duplicate review id is idempotent and cannot double-award XP', () async {
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
  });

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
}
