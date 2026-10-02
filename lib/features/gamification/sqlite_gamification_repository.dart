import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common/sqlite_api.dart'
    show
        ConflictAlgorithm,
        Database,
        DatabaseExecutor,
        DatabaseFactory,
        OpenDatabaseOptions;

import 'domain/gamification_models.dart';
import 'gamification_engine.dart';
import 'gamification_repository.dart';

final class SqliteGamificationRepository
    implements GamificationRepository {
  SqliteGamificationRepository._(this._database);

  final Database _database;
  bool _closed = false;

  static Future<SqliteGamificationRepository> open(
    String databasePath,
  ) => openWithFactory(
    sqflite.databaseFactory,
    databasePath,
  );

  static Future<SqliteGamificationRepository> openWithFactory(
    DatabaseFactory factory,
    String databasePath,
  ) async {
    final database = await factory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 1,
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
              clock_anomaly_detected INTEGER NOT NULL
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
      ),
    );
    return SqliteGamificationRepository._(database);
  }

  @override
  Future<void> recordReview(GamificationReviewEvent event) async {
    if (_closed) return;
    final id = event.reviewId.trim();
    if (id.isEmpty || id.length > 160) return;

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
          'clock_anomaly': transition.clockAnomaly ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      final profile = transition.profile;
      await txn.update(
        'gamification_profile',
        <String, Object?>{
          'total_xp': profile.totalXp,
          'current_streak': profile.currentStreak,
          'longest_streak': profile.longestStreak,
          'last_review_utc': profile.lastReviewAtUtc?.toIso8601String(),
          'last_local_day': profile.lastLocalDay,
          'last_timezone_offset_minutes':
              profile.lastTimezoneOffsetMinutes,
          'clock_anomaly_detected':
              profile.clockAnomalyDetected ? 1 : 0,
        },
        where: 'id = 1',
      );

      for (final badge in transition.newlyUnlocked) {
        await txn.insert(
          'gamification_badges',
          <String, Object?>{
            'badge_id': badge.id,
            'unlocked_at_utc': event.occurredAtUtc
                .toUtc()
                .toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
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
      return const GamificationSnapshot(
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
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<GamificationProfile> _readProfile(
    DatabaseExecutor db,
  ) async {
    final rows = await db.query(
      'gamification_profile',
      where: 'id = 1',
      limit: 1,
    );
    if (rows.isEmpty) return const GamificationProfile();
    final row = rows.first;

    int safeInt(String key, {int max = 100000000}) {
      final value = row[key];
      final parsed = value is num
          ? value.toInt()
          : int.tryParse(value?.toString() ?? '') ?? 0;
      return parsed.clamp(0, max).toInt();
    }

    final rawOffset = row['last_timezone_offset_minutes'];
    final offset = rawOffset is num
        ? rawOffset.toInt().clamp(-840, 840).toInt()
        : null;

    return GamificationProfile(
      totalXp: safeInt('total_xp'),
      currentStreak: safeInt('current_streak', max: 10000),
      longestStreak: safeInt('longest_streak', max: 10000),
      lastReviewAtUtc: DateTime.tryParse(
        row['last_review_utc']?.toString() ?? '',
      )?.toUtc(),
      lastLocalDay: _safeDay(row['last_local_day']),
      lastTimezoneOffsetMinutes: offset,
      clockAnomalyDetected: row['clock_anomaly_detected'] == 1,
    );
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
      final at = DateTime.tryParse(
        row['unlocked_at_utc']?.toString() ?? '',
      )?.toUtc();
      if (id.isEmpty || id.length > 120 || at == null) continue;
      result.add(UnlockedMilestone(badgeId: id, unlockedAtUtc: at));
    }
    return List<UnlockedMilestone>.unmodifiable(result);
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
