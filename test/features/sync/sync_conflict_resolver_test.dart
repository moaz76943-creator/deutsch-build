import 'package:deutsch_bilarabi/features/sync/application/sync_conflict_resolver.dart';
import 'package:deutsch_bilarabi/features/sync/domain/sync_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final older = DateTime.utc(2026, 10, 3, 8);
  final newer = DateTime.utc(2026, 10, 3, 9);

  SyncProgressSnapshot snapshot({
    required String revision,
    required DateTime updatedAt,
    required int streak,
    required int longest,
    required int xp,
    Map<String, SyncSrsRecord> srs = const <String, SyncSrsRecord>{},
    Set<String> achievements = const <String>{},
  }) {
    return SyncProgressSnapshot(
      revision: revision,
      updatedAtUtc: updatedAt,
      currentStreak: streak,
      longestStreak: longest,
      totalXp: xp,
      srs: srs,
      achievementIds: achievements,
    );
  }

  test('last-write-wins keeps newer scalar data but never lowers streaks', () {
    final local = snapshot(
      revision: 'local-r1',
      updatedAt: older,
      streak: 12,
      longest: 20,
      xp: 400,
    );
    final remote = snapshot(
      revision: 'remote-r2',
      updatedAt: newer,
      streak: 7,
      longest: 15,
      xp: 900,
    );

    final result = const SyncConflictResolver().resolve(
      local: local,
      remote: remote,
      strategy: SyncConflictResolutionStrategy.lastWriteWinsProtectHigherStreak,
    );

    expect(result.totalXp, 900);
    expect(result.currentStreak, 12);
    expect(result.longestStreak, 20);
    expect(result.updatedAtUtc, newer);
  });

  test('SRS records resolve independently by record update time', () {
    final localCard = SyncSrsRecord(
      key: 'noun.tisch',
      updatedAtUtc: newer,
      dueAtUtc: newer.add(const Duration(days: 3)),
      repetitions: 4,
      lapses: 0,
      successes: 5,
      failures: 1,
    );
    final remoteCard = SyncSrsRecord(
      key: 'noun.tisch',
      updatedAtUtc: older,
      dueAtUtc: older.add(const Duration(days: 1)),
      repetitions: 2,
      lapses: 1,
      successes: 2,
      failures: 2,
    );

    final result = const SyncConflictResolver().resolve(
      local: snapshot(
        revision: 'local',
        updatedAt: older,
        streak: 2,
        longest: 3,
        xp: 20,
        srs: <String, SyncSrsRecord>{localCard.key: localCard},
      ),
      remote: snapshot(
        revision: 'remote',
        updatedAt: newer,
        streak: 2,
        longest: 3,
        xp: 30,
        srs: <String, SyncSrsRecord>{remoteCard.key: remoteCard},
      ),
      strategy: SyncConflictResolutionStrategy.lastWriteWinsProtectHigherStreak,
    );

    expect(result.srs['noun.tisch']?.repetitions, 4);
    expect(result.srs['noun.tisch']?.updatedAtUtc, newer);
  });

  test('merge unions achievements and preserves highest earned xp', () {
    final result = const SyncConflictResolver().resolve(
      local: snapshot(
        revision: 'local',
        updatedAt: older,
        streak: 5,
        longest: 8,
        xp: 700,
        achievements: <String>{'xp_100', 'streak_7'},
      ),
      remote: snapshot(
        revision: 'remote',
        updatedAt: newer,
        streak: 6,
        longest: 7,
        xp: 650,
        achievements: <String>{'xp_500'},
      ),
      strategy: SyncConflictResolutionStrategy.mergeProgress,
    );

    expect(result.totalXp, 700);
    expect(result.achievementIds, <String>{'xp_100', 'streak_7', 'xp_500'});
    expect(result.currentStreak, 6);
    expect(result.longestStreak, 8);
  });

  test('equal timestamps with different revisions require user resolution', () {
    final resolver = const SyncConflictResolver();
    final local = snapshot(
      revision: 'local',
      updatedAt: newer,
      streak: 2,
      longest: 2,
      xp: 100,
    );
    final remote = snapshot(
      revision: 'remote',
      updatedAt: newer,
      streak: 2,
      longest: 2,
      xp: 120,
    );

    expect(resolver.requiresUserResolution(local: local, remote: remote), isTrue);
  });
}
