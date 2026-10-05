import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common/sqlite_api.dart'
    show
        ConflictAlgorithm,
        Database,
        DatabaseExecutor,
        DatabaseFactory,
        OpenDatabaseOptions;

import 'domain/gamification_clock_integrity_source.dart';
import 'domain/gamification_models.dart';
import 'gamification_engine.dart';
import 'gamification_repository.dart';

final class SqliteGamificationRepository implements GamificationRepository {
  SqliteGamificationRepository._(
    this._database,
    this._clockIntegritySource,
  );

  final Database _database;
  final GamificationClockIntegritySource _clockIntegritySource;
  bool _closed = false;

  static Future<SqliteGamificationRepository> open(
    String databasePath, {
    GamificationClockIntegritySource clockIntegritySource =
        const UnavailableGamificationClockIntegritySource(),
  }) =>
      openWithFactory(
        sqflite.databaseFactory,
        databasePath,
        clockIntegritySource: clockIntegritySource,
      );

  static Future<SqliteGamificationRepository> openWithFactory(
    DatabaseFactory factory,
    String databasePath, {
    GamificationClockIntegritySource clockIntegritySource =
        const UnavailableGamificationClockIntegritySource(),
  }) async {
    final database = await factory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 3,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE gamification_profile (
              id INTEGER PRIMARY KEY CHECK (id = 1),
              total_xp INTEGER NOT NULL,
              current_streak INTEGER NOT NULL,
              longest_streak INTEGER NOT NULL,
              last_review_utc TEXT,
              last_local_day TEXT,
              last_timezone_offset_minutes INTEGER,
              last_monotonic_elapsed_ms INTEGER,
              last_boot_count INTEGER,
              clock_anomaly_detected INTEGER NOT NULL,
              streak_freeze_available INTEGER NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE gamification_review_events (
              event_id TEXT PRIMARY KEY,
              facet_type TEXT NOT NULL,
              correct INTEGER NOT NULL,
              hinted INTEGER NOT NULL,
              requested_xp INTEGER NOT NULL,
              awarded_xp INTEGER NOT NULL,
              reviewed_at_utc TEXT NOT NULL,
              timezone_offset_minutes INTEGER NOT NULL,
              monotonic_elapsed_ms INTEGER,
              boot_count INTEGER,
              clock_anomaly INTEGER NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE gamification_badges (
              badge_id TEXT PRIMARY KEY,
              unlocked_at_utc TEXT NOT NULL
            )
          ''');
          await _resetProfile(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute(
              'ALTER TABLE gamification_profile ADD COLUMN streak_freeze_available INTEGER NOT NULL DEFAULT 1',
            );
          }
          if (oldVersion < 3) {
            await db.execute(
              'ALTER TABLE gamification_profile ADD COLUMN last_monotonic_elapsed_ms INTEGER',
            );
            await db.execute(
              'ALTER TABLE gamification_profile ADD COLUMN last_boot_count INTEGER',
            );
            await db.execute(
              'ALTER TABLE gamification_review_events ADD COLUMN monotonic_elapsed_ms INTEGER',
            );
            await db.execute(
              'ALTER TABLE gamification_review_events ADD COLUMN boot_count INTEGER',
            );
          }
        },
      ),
    );
    return SqliteGamificationRepository._(
      database,
      clockIntegritySource,
    );
  }

  Future<bool> migrateLegacyProfileIfPristine({
    required int totalXp,
    required int currentStreak,
    required DateTime? lastReviewAtUtc,
    required int? timezoneOffsetMinutes,
  }) async {
    if (_closed) return false;

    final safeXp = totalXp.clamp(0, 100000000).toInt();
    final safeStreak = currentStreak.clamp(0, 10000).toInt();
    if (safeXp == 0 && safeStreak == 0) return false;

    final safeReviewAt = lastReviewAtUtc?.toUtc();
    final safeOffset = timezoneOffsetMinutes == null
        ? null
        : timezoneOffsetMinutes.clamp(-840, 840).toInt();
    final localDay = safeReviewAt != null && safeOffset != null
        ? _dayKey(safeReviewAt, safeOffset)
        : null;

    return _database.transaction((txn) async {
      final current = await _readProfile(txn);
      final events = await txn.query(
        'gamification_review_events',
        columns: const <String>['event_id'],
        limit: 1,
      );
      final badges = await txn.query(
        'gamification_badges',
        columns: const <String>['badge_id'],
        limit: 1,
      );
      final isPristine = current.totalXp == 0 &&
          current.currentStreak == 0 &&
          current.longestStreak == 0 &&
          current.lastReviewAtUtc == null &&
          current.lastLocalDay == null &&
          current.lastMonotonicElapsedMilliseconds == null &&
          current.lastBootCount == null &&
          events.isEmpty &&
          badges.isEmpty;
      if (!isPristine) return false;

      final migrated = GamificationProfile(
        totalXp: safeXp,
        currentStreak: safeStreak,
        longestStreak: safeStreak,
        lastReviewAtUtc: safeReviewAt,
        lastLocalDay: localDay,
        lastTimezoneOffsetMinutes: safeReviewAt == null ? null : safeOffset,
      );
      await txn.update(
        'gamification_profile',
        <String, Object?>{
          'total_xp': migrated.totalXp,
          'current_streak': migrated.currentStreak,
          'longest_streak': migrated.longestStreak,
          'last_review_utc': migrated.lastReviewAtUtc?.toIso8601String(),
          'last_local_day': migrated.lastLocalDay,
          'last_timezone_offset_minutes':
              migrated.lastTimezoneOffsetMinutes,
          'last_monotonic_elapsed_ms': null,
          'last_boot_count': null,
          'clock_anomaly_detected': 0,
          'streak_freeze_available': 1,
        },
        where: 'id = 1',
      );

      final unlockedAt = safeReviewAt ?? DateTime.now().toUtc();
      for (final badge in GamificationMilestones.defaults) {
        if (!badge.isReached(migrated)) continue;
        await txn.insert(
          'gamification_badges',
          <String, Object?>{
            'badge_id': badge.id,
            'unlocked_at_utc': unlockedAt.toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      return true;
    });
  }

  @override
  Future<void> recordReview(GamificationReviewEvent event) async {
    if (_closed) return;
    final id = event.reviewId.trim();
    if (id.isEmpty || id.length > 160) return;

    var clockStamp = event.clockIntegrityStamp;
    if (clockStamp == null) {
      try {
        clockStamp = await _clockIntegritySource.read();
      } on Object {
        clockStamp = null;
      }
    }

    await _database.transaction((txn) async {
      final duplicate = await txn.query(
        'gamification_review_events',
        columns: const <String>['event_id'],
        where: 'event_id = ?',
        whereArgs: <Object?>[id],
        limit: 1,
      );
      if (duplicate.isNotEmpty) return;

      final current = await _readProfile(txn);
      final unlocked = await _readUnlocked(txn);
      final unlockedIds = unlocked.map((item) => item.badgeId).toSet();
      final transition = GamificationEngine.apply(
        current,
        GamificationReviewEvent(
          reviewId: id,
          facetType: event.facetType,
          correct: event.correct,
          hinted: event.hinted,
          requestedXp: event.requestedXp,
          occurredAtUtc: event.occurredAtUtc,
          timezoneOffsetMinutes: event.timezoneOffsetMinutes,
          useStreakFreeze: event.useStreakFreeze,
          clockIntegrityStamp: clockStamp,
        ),
        alreadyUnlocked: unlockedIds,
      );

      await txn.insert(
          'gamification_review_events',
          <String, Object?>{
            'event_id': id,
            'facet_type': event.facetType.wireName,
            'correct': event.correct ? 1 : 0,
            'hinted': event.hinted ? 1 : 0,
            'requested_xp': event.requestedXp.clamp(0, 100).toInt(),
            'awarded_xp': transition.awardedXp,
            'reviewed_at_utc': event.occurredAtUtc.toUtc().toIso8601String(),
            'timezone_offset_minutes':
                event.timezoneOffsetMinutes.clamp(-840, 840).toInt(),
            'monotonic_elapsed_ms':
                clockStamp?.elapsedRealtimeMilliseconds,
            'boot_count': clockStamp?.bootCount,
            'clock_anomaly': transition.clockAnomaly ? 1 : 0,
          },
          conflictAlgorithm: ConflictAlgorithm.abort);

      final profile = transition.profile;
      await txn.update(
          'gamification_profile',
          <String, Object?>{
            'total_xp': profile.totalXp,
            'current_streak': profile.currentStreak,
            'longest_streak': profile.longestStreak,
            'last_review_utc': profile.lastReviewAtUtc?.toIso8601String(),
            'last_local_day': profile.lastLocalDay,
            'last_timezone_offset_minutes': profile.lastTimezoneOffsetMinutes,
            'last_monotonic_elapsed_ms':
                profile.lastMonotonicElapsedMilliseconds,
            'last_boot_count': profile.lastBootCount,
            'clock_anomaly_detected': profile.clockAnomalyDetected ? 1 : 0,
            'streak_freeze_available': profile.streakFreezeAvailable ? 1 : 0,
          },
          where: 'id = 1');

      for (final badge in transition.newlyUnlocked) {
        await txn.insert(
            'gamification_badges',
            <String, Object?>{
              'badge_id': badge.id,
              'unlocked_at_utc': event.occurredAtUtc.toUtc().toIso8601String(),
            },
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    });
  }

  @override
  Future<void> clearGamification() async {
    if (_closed) return;
    await _database.transaction((txn) async {
      await txn.delete('gamification_review_events');
      await txn.delete('gamification_badges');
      await txn.delete('gamification_profile');
      await _resetProfile(txn);
    });
  }

  @override
  Future<GamificationSnapshot> loadSnapshot() async {
    if (_closed) {
      return GamificationSnapshot(
        profile: GamificationProfile(),
        unlocked: <UnlockedMilestone>[],
        badges: GamificationMilestones.defaults,
      );
    }
    final profile = await _readProfile(_database);
    final unlocked = await _readUnlocked(_database);
    return GamificationSnapshot(
      profile: profile,
      unlocked: unlocked,
      badges: GamificationMilestones.defaults,
    );
  }

  static Future<void> _resetProfile(DatabaseExecutor db) async {
    await db.insert(
        'gamification_profile',
        <String, Object?>{
          'id': 1,
          'total_xp': 0,
          'current_streak': 0,
          'longest_streak': 0,
          'clock_anomaly_detected': 0,
          'streak_freeze_available': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<GamificationProfile> _readProfile(DatabaseExecutor db) async {
    final rows = await db.query(
      'gamification_profile',
      where: 'id = 1',
      limit: 1,
    );
    if (rows.isEmpty) return GamificationProfile();
    final row = rows.first;

    int safeInt(String key, {int max = 100000000}) {
      final value = row[key];
      final parsed = value is num
          ? value.toInt()
          : int.tryParse(value?.toString() ?? '') ?? 0;
      return parsed.clamp(0, max).toInt();
    }

    final rawOffset = row['last_timezone_offset_minutes'];
    final offset =
        rawOffset is num ? rawOffset.toInt().clamp(-840, 840).toInt() : null;

    return GamificationProfile(
      totalXp: safeInt('total_xp'),
      currentStreak: safeInt('current_streak', max: 10000),
      longestStreak: safeInt('longest_streak', max: 10000),
      lastReviewAtUtc: DateTime.tryParse(
        row['last_review_utc']?.toString() ?? '',
      )?.toUtc(),
      lastLocalDay: _safeDay(row['last_local_day']),
      lastTimezoneOffsetMinutes: offset,
      lastMonotonicElapsedMilliseconds:
          _safeNullableNonNegativeInt(row['last_monotonic_elapsed_ms']),
      lastBootCount:
          _safeNullableNonNegativeInt(row['last_boot_count']),
      clockAnomalyDetected: row['clock_anomaly_detected'] == 1,
      streakFreezeAvailable: row['streak_freeze_available'] != 0,
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

  static Future<List<UnlockedMilestone>> _readUnlocked(
    DatabaseExecutor db,
  ) async {
    final rows = await db.query(
      'gamification_badges',
      orderBy: 'unlocked_at_utc ASC, badge_id ASC',
      limit: 200,
    );
    final result = <UnlockedMilestone>[];
    for (final row in rows) {
      final id = row['badge_id']?.toString().trim() ?? '';
      final at =
          DateTime.tryParse(row['unlocked_at_utc']?.toString() ?? '')?.toUtc();
      if (id.isEmpty || id.length > 120 || at == null) continue;
      result.add(UnlockedMilestone(badgeId: id, unlockedAtUtc: at));
    }
    return List<UnlockedMilestone>.unmodifiable(result);
  }

  static String _dayKey(DateTime utc, int offsetMinutes) {
    final local = utc.toUtc().add(Duration(minutes: offsetMinutes));
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String? _safeDay(Object? raw) {
    final value = raw?.toString().trim() ?? '';
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return null;
    return DateTime.tryParse('${value}T00:00:00Z') == null ? null : value;
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _database.close();
  }
}
