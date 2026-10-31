import '../domain/sync_models.dart';

final class SyncConflictResolver {
  const SyncConflictResolver();

  bool requiresUserResolution({
    required SyncProgressSnapshot local,
    required SyncProgressSnapshot remote,
  }) {
    if (local.revision == remote.revision) return false;
    return local.updatedAtUtc.isAtSameMomentAs(remote.updatedAtUtc);
  }

  SyncProgressSnapshot resolve({
    required SyncProgressSnapshot local,
    required SyncProgressSnapshot remote,
    required SyncConflictResolutionStrategy strategy,
  }) {
    final newer = remote.updatedAtUtc.isAfter(local.updatedAtUtc) ? remote : local;

    final mergedSrs = _mergeSrs(local.srs, remote.srs);
    final mergedAchievements = <String>{
      ...local.achievementIds,
      ...remote.achievementIds,
    };
    final protectedCurrent =
        local.currentStreak > remote.currentStreak
            ? local.currentStreak
            : remote.currentStreak;
    final protectedLongest =
        local.longestStreak > remote.longestStreak
            ? local.longestStreak
            : remote.longestStreak;
    final safeLongest =
        protectedLongest < protectedCurrent ? protectedCurrent : protectedLongest;

    return switch (strategy) {
      SyncConflictResolutionStrategy.lastWriteWinsProtectHigherStreak =>
        newer.copyWith(
          currentStreak: protectedCurrent,
          longestStreak: safeLongest,
          srs: mergedSrs,
          achievementIds: mergedAchievements,
        ),
      SyncConflictResolutionStrategy.mergeProgress => newer.copyWith(
          currentStreak: protectedCurrent,
          longestStreak: safeLongest,
          totalXp: local.totalXp > remote.totalXp
              ? local.totalXp
              : remote.totalXp,
          srs: mergedSrs,
          achievementIds: mergedAchievements,
        ),
      SyncConflictResolutionStrategy.keepLocal => local.copyWith(
          currentStreak: protectedCurrent,
          longestStreak: safeLongest,
        ),
      SyncConflictResolutionStrategy.keepRemote => remote.copyWith(
          currentStreak: protectedCurrent,
          longestStreak: safeLongest,
        ),
    };
  }

  Map<String, SyncSrsRecord> _mergeSrs(
    Map<String, SyncSrsRecord> local,
    Map<String, SyncSrsRecord> remote,
  ) {
    final keys = <String>{...local.keys, ...remote.keys};
    final result = <String, SyncSrsRecord>{};
    for (final key in keys) {
      final left = local[key];
      final right = remote[key];
      if (left == null) {
        result[key] = right!;
        continue;
      }
      if (right == null) {
        result[key] = left;
        continue;
      }
      if (right.updatedAtUtc.isAfter(left.updatedAtUtc)) {
        result[key] = right;
      } else if (left.updatedAtUtc.isAfter(right.updatedAtUtc)) {
        result[key] = left;
      } else {
        result[key] = _tieBreak(left, right);
      }
    }
    return Map<String, SyncSrsRecord>.unmodifiable(result);
  }

  SyncSrsRecord _tieBreak(SyncSrsRecord left, SyncSrsRecord right) {
    final leftEvidence = left.successes + left.failures + left.repetitions;
    final rightEvidence = right.successes + right.failures + right.repetitions;
    if (rightEvidence > leftEvidence) return right;
    if (leftEvidence > rightEvidence) return left;
    return right.dueAtUtc.isAfter(left.dueAtUtc) ? right : left;
  }
}
