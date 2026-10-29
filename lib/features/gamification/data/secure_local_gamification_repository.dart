import '../../../core/infrastructure/storage/local_storage_repository.dart';
import '../domain/gamification_models.dart';
import '../gamification_engine.dart';
import '../gamification_repository.dart';

final class SecureLocalGamificationRepository implements GamificationRepository {
  SecureLocalGamificationRepository(this._storage);

  static final int _maxRememberedReviewIds = 256;

  final LocalStorageRepository _storage;
  bool _closed = false;

  @override
  Future<void> recordReview(GamificationReviewEvent event) async {
    if (_closed) return;
    final reviewId = event.reviewId.trim();
    if (reviewId.isEmpty || reviewId.length > 160) return;

    final record = await _loadRecord();
    if (record.reviewIds.contains(reviewId)) return;

    final unlockedIds = record.snapshot.unlockedBadgeIds;
    final transition = GamificationEngine.apply(
      record.snapshot.profile,
      event,
      alreadyUnlocked: unlockedIds,
    );

    final unlocked = <UnlockedMilestone>[
      ...record.snapshot.unlocked,
      for (final badge in transition.newlyUnlocked)
        UnlockedMilestone(
          badgeId: badge.id,
          unlockedAtUtc: event.occurredAtUtc.toUtc(),
        ),
    ];
    final reviewIds = <String>[...record.reviewIds, reviewId];
    final trimmedIds = reviewIds.length <= _maxRememberedReviewIds
        ? reviewIds
        : reviewIds.sublist(reviewIds.length - _maxRememberedReviewIds);

    await _storage.save(
      StorageBucket.gamification,
      _encode(
        GamificationSnapshot(
          profile: transition.profile,
          unlocked: List<UnlockedMilestone>.unmodifiable(unlocked),
          badges: GamificationMilestones.defaults,
        ),
        trimmedIds,
      ),
    );
  }

  @override
  Future<GamificationSnapshot> loadSnapshot() async {
    if (_closed) return _emptySnapshot;
    return (await _loadRecord()).snapshot;
  }

  @override
  Future<void> clearGamification() async {
    if (_closed) return;
    await _storage.delete(StorageBucket.gamification);
  }

  @override
  Future<void> close() async {
    _closed = true;
  }

  Future<_StoredGamificationRecord> _loadRecord() async {
    final payload = await _storage.load(StorageBucket.gamification);
    if (payload == null) {
      return _StoredGamificationRecord(
        snapshot: _emptySnapshot,
        reviewIds: const <String>[],
      );
    }

    final rawProfile = payload['profile'];
    final rawUnlocked = payload['unlocked'];
    final rawReviewIds = payload['review_ids'];

    final snapshot = GamificationSnapshot(
      profile: rawProfile is Map
          ? _decodeProfile(Map<Object?, Object?>.from(rawProfile))
          : GamificationProfile(),
      unlocked: _decodeUnlocked(rawUnlocked),
      badges: GamificationMilestones.defaults,
    );

    final reviewIds = <String>[];
    if (rawReviewIds is List) {
      for (final raw in rawReviewIds) {
        final id = raw?.toString().trim() ?? '';
        if (id.isEmpty || id.length > 160 || reviewIds.contains(id)) continue;
        reviewIds.add(id);
      }
    }
    if (reviewIds.length > _maxRememberedReviewIds) {
      reviewIds.removeRange(0, reviewIds.length - _maxRememberedReviewIds);
    }
    return _StoredGamificationRecord(
      snapshot: snapshot,
      reviewIds: List<String>.unmodifiable(reviewIds),
    );
  }

  static Map<String, Object?> _encode(
    GamificationSnapshot snapshot,
    List<String> reviewIds,
  ) {
    final profile = snapshot.profile;
    return <String, Object?>{
      'schema_version': 1,
      'profile': <String, Object?>{
        'total_xp': profile.totalXp,
        'current_streak': profile.currentStreak,
        'longest_streak': profile.longestStreak,
        'last_review_utc': profile.lastReviewAtUtc?.toIso8601String(),
        'last_local_day': profile.lastLocalDay,
        'last_timezone_offset_minutes': profile.lastTimezoneOffsetMinutes,
        'last_monotonic_elapsed_ms':
            profile.lastMonotonicElapsedMilliseconds,
        'last_boot_count': profile.lastBootCount,
        'clock_anomaly_detected': profile.clockAnomalyDetected,
        'streak_freeze_available': profile.streakFreezeAvailable,
      },
      'unlocked': <Map<String, Object?>>[
        for (final item in snapshot.unlocked)
          <String, Object?>{
            'badge_id': item.badgeId,
            'unlocked_at_utc': item.unlockedAtUtc.toUtc().toIso8601String(),
          },
      ],
      'review_ids': List<String>.unmodifiable(reviewIds),
    };
  }

  static GamificationProfile _decodeProfile(Map<Object?, Object?> raw) {
    int safeInt(Object? value, {int max = 100000000}) {
      final parsed = value is num
          ? value.toInt()
          : int.tryParse(value?.toString() ?? '') ?? 0;
      return parsed.clamp(0, max).toInt();
    }

    final offsetRaw = raw['last_timezone_offset_minutes'];
    final offset = offsetRaw == null
        ? null
        : (offsetRaw is num
            ? offsetRaw.toInt()
            : int.tryParse(offsetRaw.toString()))
            ?.clamp(-840, 840)
            .toInt();
    final localDayRaw = raw['last_local_day']?.toString().trim();
    final localDay = _safeDay(localDayRaw);

    return GamificationProfile(
      totalXp: safeInt(raw['total_xp']),
      currentStreak: safeInt(raw['current_streak'], max: 10000),
      longestStreak: safeInt(raw['longest_streak'], max: 10000),
      lastReviewAtUtc: DateTime.tryParse(
        raw['last_review_utc']?.toString() ?? '',
      )?.toUtc(),
      lastLocalDay: localDay,
      lastTimezoneOffsetMinutes: offset,
      lastMonotonicElapsedMilliseconds:
          _safeNullableNonNegativeInt(raw['last_monotonic_elapsed_ms']),
      lastBootCount:
          _safeNullableNonNegativeInt(raw['last_boot_count']),
      clockAnomalyDetected: raw['clock_anomaly_detected'] == true,
      streakFreezeAvailable: raw['streak_freeze_available'] != false,
    );
  }

  static int? _safeNullableNonNegativeInt(Object? raw) {
    if (raw == null) return null;
    final parsed = raw is num
        ? raw.toInt()
        : int.tryParse(raw.toString());
    if (parsed == null || parsed < 0) return null;
    return parsed;
  }

  static List<UnlockedMilestone> _decodeUnlocked(Object? raw) {
    if (raw is! List) return const <UnlockedMilestone>[];
    final unlocked = <UnlockedMilestone>[];
    final seen = <String>{};
    for (final item in raw) {
      if (item is! Map) continue;
      final id = item['badge_id']?.toString().trim() ?? '';
      final at = DateTime.tryParse(
        item['unlocked_at_utc']?.toString() ?? '',
      )?.toUtc();
      if (id.isEmpty || id.length > 120 || at == null || !seen.add(id)) {
        continue;
      }
      unlocked.add(UnlockedMilestone(badgeId: id, unlockedAtUtc: at));
    }
    return List<UnlockedMilestone>.unmodifiable(unlocked);
  }

  static String? _safeDay(String? value) {
    if (value == null || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      return null;
    }
    return DateTime.tryParse('${value}T00:00:00Z') == null ? null : value;
  }

  static final GamificationSnapshot _emptySnapshot = GamificationSnapshot(
    profile: GamificationProfile(),
    unlocked: <UnlockedMilestone>[],
    badges: GamificationMilestones.defaults,
  );
}

final class _StoredGamificationRecord {
  const _StoredGamificationRecord({
    required this.snapshot,
    required this.reviewIds,
  });

  final GamificationSnapshot snapshot;
  final List<String> reviewIds;
}
