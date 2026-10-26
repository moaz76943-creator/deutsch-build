import 'dart:io';

import 'package:deutsch_bilarabi/services/srs_scheduler_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(sqfliteFfiInit);

  test('SM-2 successive Good grades use one, six, then multiplied days', () {
    final scheduler = SrsSchedulerService();
    final now = DateTime.utc(2026, 10, 11, 12);
    final first = scheduler.calculate(grade: 3, reviewedAt: now);
    expect(first.repetitionCount, 1);
    expect(first.intervalDays, 1);
    expect(first.easeFactor, 2.5);
    expect(first.nextReviewEpoch, now.add(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000);

    final second = scheduler.calculate(
      grade: 3, previous: first.asState(), reviewedAt: now,
    );
    expect(second.repetitionCount, 2);
    expect(second.intervalDays, 6);

    final third = scheduler.calculate(
      grade: 3, previous: second.asState(), reviewedAt: now,
    );
    expect(third.repetitionCount, 3);
    expect(third.intervalDays, 15);
  });

  test('failed recall resets streak and ease never drops below 1.3', () {
    final scheduler = SrsSchedulerService();
    final result = scheduler.calculate(
      grade: 0,
      previous: const SrsReviewState(
        repetitionCount: 7, intervalDays: 90, easeFactor: 1.3,
      ),
      reviewedAt: DateTime.utc(2026),
    );
    expect(result.repetitionCount, 0);
    expect(result.intervalDays, 1);
    expect(result.easeFactor, 1.3);
    expect(scheduler.calculate(grade: 1).repetitionCount, 0);
  });

  test('Hard qualifies as low-quality recall and Easy increases ease', () {
    final scheduler = SrsSchedulerService();
    final hard = scheduler.calculate(grade: 2);
    final easy = scheduler.calculate(grade: 4);
    expect(hard.repetitionCount, 1);
    expect(hard.easeFactor, closeTo(2.36, 0.00001));
    expect(easy.repetitionCount, 1);
    expect(easy.easeFactor, closeTo(2.6, 0.00001));
  });

  test('rejects invalid grades and corrupt saved counters', () {
    final scheduler = SrsSchedulerService();
    expect(() => scheduler.calculate(grade: -1), throwsRangeError);
    expect(() => scheduler.calculate(grade: 5), throwsRangeError);
    expect(
      () => scheduler.calculate(
        grade: 3,
        previous: const SrsReviewState(repetitionCount: -1),
      ),
      throwsArgumentError,
    );
  });

  test('persists epoch seconds atomically in the existing SRS ledger', () async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    addTearDown(db.close);
    await db.execute('''
      CREATE TABLE srs_progress (
        lexeme_id TEXT NOT NULL,
        target_language_code TEXT NOT NULL,
        repetition_count INTEGER NOT NULL DEFAULT 0,
        interval_days INTEGER NOT NULL DEFAULT 1,
        ease_factor REAL NOT NULL DEFAULT 2.5,
        next_due_at INTEGER,
        status TEXT NOT NULL DEFAULT 'learning',
        PRIMARY KEY (lexeme_id, target_language_code)
      )
    ''');
    final scheduler = SrsSchedulerService();
    final now = DateTime.utc(2026, 10, 11);
    final first = await scheduler.gradeAndPersist(
      progressDb: db, lexemeId: 'haus', languageCode: 'de',
      grade: 3, reviewedAt: now,
    );
    final second = await scheduler.gradeAndPersist(
      progressDb: db, lexemeId: 'haus', languageCode: 'de',
      grade: 3, reviewedAt: now,
    );
    expect(first.intervalDays, 1);
    expect(second.intervalDays, 6);
    final rows = await db.query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['haus']);
    expect(rows, hasLength(1));
    expect(rows.single['repetition_count'], 2);
    expect(rows.single['next_due_at'], second.nextReviewEpoch);
    expect(rows.single['interval_days'], 6);
    expect(rows.single['status'], 'review');
  });

  test('identical lexeme IDs in separate languages never overwrite progress', () async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    addTearDown(db.close);
    await db.execute('''
      CREATE TABLE srs_progress (
        lexeme_id TEXT NOT NULL,
        target_language_code TEXT NOT NULL,
        repetition_count INTEGER NOT NULL DEFAULT 0,
        interval_days INTEGER NOT NULL DEFAULT 1,
        ease_factor REAL NOT NULL DEFAULT 2.5,
        next_due_at INTEGER,
        status TEXT NOT NULL DEFAULT 'learning',
        user_note TEXT,
        PRIMARY KEY (lexeme_id, target_language_code)
      )
    ''');
    final scheduler = SrsSchedulerService();
    final now = DateTime.utc(2026, 10, 11);
    await scheduler.gradeAndPersist(
      progressDb: db, lexemeId: 'shared-id', languageCode: 'de',
      grade: 3, reviewedAt: now,
    );
    await db.update(
      'srs_progress', <String, Object?>{'user_note': 'retain'},
      where: 'lexeme_id = ? AND target_language_code = ?',
      whereArgs: <Object>['shared-id', 'de'],
    );
    await scheduler.gradeAndPersist(
      progressDb: db, lexemeId: 'shared-id', languageCode: 'tr',
      grade: 4, reviewedAt: now,
    );
    await scheduler.gradeAndPersist(
      progressDb: db, lexemeId: 'shared-id', languageCode: 'de',
      grade: 3, reviewedAt: now,
    );
    final rows = await db.query(
      'srs_progress', where: 'lexeme_id = ?',
      whereArgs: <Object>['shared-id'],
      orderBy: 'target_language_code',
    );
    expect(rows, hasLength(2));
    expect(rows[0]['target_language_code'], 'de');
    expect(rows[0]['repetition_count'], 2);
    expect(rows[0]['interval_days'], 6);
    expect(rows[0]['user_note'], 'retain');
    expect(rows[1]['target_language_code'], 'tr');
    expect(rows[1]['repetition_count'], 1);
  });

  test('legacy review event replays only the same immutable payload after restart',
      () async {
    final directory = await Directory.systemTemp.createTemp('srs-event-replay-');
    final databasePath = '${directory.path}/progress.sqlite';
    var db = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    addTearDown(() async {
      if (db.isOpen) await db.close();
      await directory.delete(recursive: true);
    });
    await db.execute('''
      CREATE TABLE srs_progress (
        lexeme_id TEXT NOT NULL,
        target_language_code TEXT NOT NULL,
        repetition_count INTEGER NOT NULL DEFAULT 0,
        interval_days INTEGER NOT NULL DEFAULT 1,
        ease_factor REAL NOT NULL DEFAULT 2.5,
        next_due_at INTEGER,
        status TEXT NOT NULL DEFAULT 'learning',
        PRIMARY KEY (lexeme_id, target_language_code)
      )
    ''');

    final scheduler = SrsSchedulerService();
    final now = DateTime.utc(2026, 10, 25);
    Future<SrsReviewSchedule> review({
      String lexemeId = 'haus',
      String languageCode = 'de',
      int grade = 3,
    }) =>
        scheduler.gradeAndPersist(
          progressDb: db,
          lexemeId: lexemeId,
          languageCode: languageCode,
          grade: grade,
          reviewedAt: now,
          reviewEventId: 'immutable-event-1',
        );

    final first = await review();
    expect(first.repetitionCount, 1);
    await db.close();
    db = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );

    final replay = await review();
    expect(replay.repetitionCount, 1);
    // A reused event ID cannot claim a different explicit review instant.
    // The timestamp is part of the immutable durable event identity.
    await expectLater(
      scheduler.gradeAndPersist(
        progressDb: db,
        lexemeId: 'haus',
        languageCode: 'de',
        grade: 3,
        reviewedAt: now.add(const Duration(minutes: 1)),
        reviewEventId: 'immutable-event-1',
      ),
      throwsStateError,
    );
    await expectLater(review(lexemeId: 'other-card'), throwsStateError);
    await expectLater(review(languageCode: 'ar'), throwsStateError);
    await expectLater(review(grade: 4), throwsStateError);
    final events = await db.query('srs_review_events');
    expect(events, hasLength(1));
    final rows = await db.query('srs_progress');
    expect(rows, hasLength(1));
    expect(rows.single['repetition_count'], 1);

    // An event without its corresponding progress row is inconsistent.
    // Never silently apply that event again after a damaged partial restore.
    await db.delete('srs_progress',
        where: 'lexeme_id = ? AND target_language_code = ?',
        whereArgs: <Object>['haus', 'de']);
    await expectLater(review(), throwsStateError);
    expect(await db.query('srs_review_events'), hasLength(1));
    expect(await db.query('srs_progress'), isEmpty);
    // New fractional-second rows must compare the full recorded instant,
    // not only their epoch second, after a database reopen.
    final fractional = DateTime.utc(2026, 10, 25, 12, 0, 0, 250, 125);
    Future<SrsReviewSchedule> fractionalReview(DateTime at) =>
        scheduler.gradeAndPersist(
          progressDb: db,
          lexemeId: 'subsecond-card',
          languageCode: 'de',
          grade: 3,
          reviewedAt: at,
          reviewEventId: 'immutable-subsecond-event',
        );
    expect((await fractionalReview(fractional)).repetitionCount, 1);
    expect((await fractionalReview(fractional)).repetitionCount, 1);
    await expectLater(
      fractionalReview(fractional.add(const Duration(microseconds: 1))),
      throwsStateError,
    );
    final subsecondRows = await db.query('srs_progress',
        where: 'lexeme_id = ?', whereArgs: <Object>['subsecond-card']);
    expect(subsecondRows.single['repetition_count'], 1);
  });

  test('fractional saved due date cannot be truncated or overwritten', () async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    addTearDown(db.close);
    await db.execute('''
      CREATE TABLE srs_progress (
        lexeme_id TEXT NOT NULL,
        target_language_code TEXT NOT NULL,
        repetition_count INTEGER NOT NULL DEFAULT 0,
        interval_days INTEGER NOT NULL DEFAULT 1,
        ease_factor REAL NOT NULL DEFAULT 2.5,
        next_due_at INTEGER,
        status TEXT NOT NULL DEFAULT 'learning',
        PRIMARY KEY (lexeme_id, target_language_code)
      )
    ''');
    final scheduler = SrsSchedulerService();
    Future<SrsReviewSchedule> review(String eventId) =>
        scheduler.gradeAndPersist(
          progressDb: db,
          lexemeId: 'haus',
          languageCode: 'de',
          grade: 3,
          reviewedAt: DateTime.utc(2026, 10, 25),
          reviewEventId: eventId,
        );

    await review('durable-1');
    // SQLite INTEGER affinity still accepts a fractional REAL.
    await db.update(
      'srs_progress',
      <String, Object>{'next_due_at': 1760000000.5},
      where: 'lexeme_id = ? AND target_language_code = ?',
      whereArgs: <Object>['haus', 'de'],
    );
    final before = (await db.query('srs_progress')).single;
    expect(before['next_due_at'], 1760000000.5);

    // Neither an exact replay nor a fresh review may acknowledge/overwrite
    // corrupt durable scheduling state.
    await expectLater(review('durable-1'), throwsArgumentError);
    await expectLater(review('durable-2'), throwsArgumentError);
    expect((await db.query('srs_progress')).single, before);
    expect(await db.query('srs_review_events'), hasLength(1));
  });

  test('replayed review rejects corrupt saved ease without changing progress',
      () async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    addTearDown(db.close);
    await db.execute('''
      CREATE TABLE srs_progress (
        lexeme_id TEXT NOT NULL,
        target_language_code TEXT NOT NULL,
        repetition_count INTEGER NOT NULL DEFAULT 0,
        interval_days INTEGER NOT NULL DEFAULT 1,
        ease_factor REAL NOT NULL DEFAULT 2.5,
        next_due_at INTEGER,
        status TEXT NOT NULL DEFAULT 'learning',
        PRIMARY KEY (lexeme_id, target_language_code)
      )
    ''');
    final scheduler = SrsSchedulerService();
    Future<SrsReviewSchedule> review() => scheduler.gradeAndPersist(
          progressDb: db,
          lexemeId: 'haus',
          languageCode: 'de',
          grade: 3,
          reviewedAt: DateTime.utc(2026, 10, 25),
          reviewEventId: 'immutable-ease-1',
        );
    await review();
    await db.update('srs_progress', <String, Object>{'ease_factor': 0.5},
        where: 'lexeme_id = ? AND target_language_code = ?',
        whereArgs: <Object>['haus', 'de']);
    final before = (await db.query('srs_progress')).single;
    await expectLater(review(), throwsArgumentError);
    expect((await db.query('srs_progress')).single, before);
    expect(await db.query('srs_review_events'), hasLength(1));
  });

  test('whitespace event IDs cannot silently bypass idempotency', () async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    addTearDown(db.close);
    await db.execute('''
      CREATE TABLE srs_progress (
        lexeme_id TEXT NOT NULL,
        target_language_code TEXT NOT NULL,
        repetition_count INTEGER NOT NULL DEFAULT 0,
        interval_days INTEGER NOT NULL DEFAULT 1,
        ease_factor REAL NOT NULL DEFAULT 2.5,
        next_due_at INTEGER,
        status TEXT NOT NULL DEFAULT 'learning',
        PRIMARY KEY (lexeme_id, target_language_code)
      )
    ''');
    final scheduler = SrsSchedulerService();
    for (final invalidId in <String>['', '   ', 'event-with-space ']) {
      await expectLater(
        scheduler.gradeAndPersist(
          progressDb: db,
          lexemeId: 'haus',
          languageCode: 'de',
          grade: 3,
          reviewedAt: DateTime.utc(2026, 10, 25),
          reviewEventId: invalidId,
        ),
        throwsArgumentError,
      );
    }
    expect(await db.query('srs_progress'), isEmpty);
    final journal = await db.query(
      'sqlite_master',
      where: 'type = ? AND name = ?',
      whereArgs: <Object>['table', 'srs_review_events'],
    );
    expect(journal, isEmpty,
        reason: 'Invalid event IDs must not mutate the durable ledger');
  });


  test('noncanonical learner keys cannot fork existing durable progress', () async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    addTearDown(db.close);
    await db.execute('''
      CREATE TABLE srs_progress (
        lexeme_id TEXT NOT NULL,
        target_language_code TEXT NOT NULL,
        repetition_count INTEGER NOT NULL DEFAULT 0,
        interval_days INTEGER NOT NULL DEFAULT 1,
        ease_factor REAL NOT NULL DEFAULT 2.5,
        next_due_at INTEGER,
        status TEXT NOT NULL DEFAULT 'learning',
        PRIMARY KEY (lexeme_id, target_language_code)
      )
    ''');
    final scheduler = SrsSchedulerService();
    Future<SrsReviewSchedule> review(
      String lexemeId,
      String languageCode,
      String eventId,
    ) => scheduler.gradeAndPersist(
          progressDb: db,
          lexemeId: lexemeId,
          languageCode: languageCode,
          grade: 3,
          reviewedAt: DateTime.utc(2026, 10, 25),
          reviewEventId: eventId,
        );

    await review('haus', 'de', 'valid-key-review');
    final before = (await db.query('srs_progress')).single;
    for (final bad in <(String, String)>[
      (' haus', 'de'),
      ('haus ', 'de'),
      ('haus', ' de'),
      ('haus', 'de '),
      ('haus\n', 'de'),
    ]) {
      await expectLater(
        review(bad.$1, bad.$2, 'bad-key-${bad.$1}-${bad.$2}'),
        throwsArgumentError,
      );
    }
    expect(await db.query('srs_progress'), <Map<String, Object?>>[before]);
    final events = await db.query('srs_review_events');
    expect(events, hasLength(1));
    expect(events.single['review_event_id'], 'valid-key-review');
  });

  test('stale replay cannot rewind the durable SRS ledger after restart',
      () async {
    final directory = await Directory.systemTemp.createTemp('srs-stale-');
    final databasePath = '${directory.path}/progress.sqlite';
    var db = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    addTearDown(() async {
      if (db.isOpen) await db.close();
      await directory.delete(recursive: true);
    });
    await db.execute('''
      CREATE TABLE srs_progress (
        lexeme_id TEXT NOT NULL,
        target_language_code TEXT NOT NULL,
        repetition_count INTEGER NOT NULL DEFAULT 0,
        interval_days INTEGER NOT NULL DEFAULT 1,
        ease_factor REAL NOT NULL DEFAULT 2.5,
        next_due_at INTEGER,
        status TEXT NOT NULL DEFAULT 'learning',
        PRIMARY KEY (lexeme_id, target_language_code)
      )
    ''');
    final scheduler = SrsSchedulerService();
    Future<SrsReviewSchedule> review(
      String? eventId,
      DateTime when, {
      String language = 'de',
    }) =>
        scheduler.gradeAndPersist(
          progressDb: db,
          lexemeId: 'haus',
          languageCode: language,
          grade: 3,
          reviewedAt: when,
          reviewEventId: eventId,
        );

    final newer = DateTime.utc(2026, 10, 25, 12);
    final older = newer.subtract(const Duration(minutes: 10));
    await review('newer-committed', newer);
    final saved = (await db.query('srs_progress')).single;
    await db.close();
    db = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );

    // An older distinct event must not move the saved schedule backwards.
    await expectLater(review('older-delayed', older), throwsStateError);
    // A legacy caller with no event ID must not bypass the durable stale
    // guard and rewind a newer committed SRS schedule after process restart.
    await expectLater(review(null, older), throwsStateError);
    expect((await db.query('srs_progress')).single, saved);
    expect(await db.query('srs_review_events'), hasLength(1));

    // Exact retries remain idempotent; other language scopes are independent.
    expect((await review('newer-committed', newer)).repetitionCount, 1);
    expect((await review('reverse-independent', older, language: 'ar'))
        .repetitionCount, 1);

    // A partially restored database with a journal but no progress row
    // must not reset an established learner streak on the next event.
    await db.delete('srs_progress',
        where: 'lexeme_id = ? AND target_language_code = ?',
        whereArgs: <Object>['haus', 'de']);
    await expectLater(
      review('fresh-after-lost-row', newer.add(const Duration(minutes: 5))),
      throwsStateError,
    );
    // No-ID callers must also fail closed if a committed review exists but
    // its corresponding learner progress row has disappeared.
    await expectLater(
      review(null, newer.add(const Duration(minutes: 6))),
      throwsStateError,
    );
    expect(await db.query('srs_review_events'), hasLength(2));
    expect(await db.query('srs_progress'), hasLength(1));
  });


  test('anonymous legacy reviews persist durable stale and missing-row guards',
      () async {
    final directory = await Directory.systemTemp.createTemp('srs-anonymous-');
    final databasePath = '${directory.path}/progress.sqlite';
    var db = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    addTearDown(() async {
      if (db.isOpen) await db.close();
      await directory.delete(recursive: true);
    });
    await db.execute('''
      CREATE TABLE srs_progress (
        lexeme_id TEXT NOT NULL,
        target_language_code TEXT NOT NULL,
        repetition_count INTEGER NOT NULL DEFAULT 0,
        interval_days INTEGER NOT NULL DEFAULT 1,
        ease_factor REAL NOT NULL DEFAULT 2.5,
        next_due_at INTEGER,
        status TEXT NOT NULL DEFAULT 'learning',
        PRIMARY KEY (lexeme_id, target_language_code)
      )
    ''');

    final scheduler = SrsSchedulerService();
    final newest = DateTime.utc(2026, 10, 25, 12);
    Future<SrsReviewSchedule> anonymousReview(DateTime at) =>
        scheduler.gradeAndPersist(
          progressDb: db,
          lexemeId: 'haus',
          languageCode: 'de',
          grade: 3,
          reviewedAt: at,
        );

    // Anonymous submissions are distinct learning actions, not duplicates.
    await anonymousReview(newest);
    await anonymousReview(newest);
    final beforeRestart = await db.query('srs_review_events');
    expect(beforeRestart, hasLength(2));
    expect(
      beforeRestart.map((row) => row['review_event_id']).toSet(),
      hasLength(2),
      reason: 'Anonymous reviews need unique durable event identities',
    );
    expect((await db.query('srs_progress')).single['repetition_count'], 2);

    await db.close();
    db = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    final progressBefore = (await db.query('srs_progress')).single;
    await expectLater(
      anonymousReview(newest.subtract(const Duration(minutes: 5))),
      throwsStateError,
    );
    expect((await db.query('srs_progress')).single, progressBefore);
    expect(await db.query('srs_review_events'), hasLength(2));

    // A damaged restore must not silently recreate an established streak.
    await db.delete(
      'srs_progress',
      where: 'lexeme_id = ? AND target_language_code = ?',
      whereArgs: <Object>['haus', 'de'],
    );
    await expectLater(
      anonymousReview(newest.add(const Duration(minutes: 5))),
      throwsStateError,
    );
    expect(await db.query('srs_progress'), isEmpty);
    expect(await db.query('srs_review_events'), hasLength(2));
  });


  test('subsecond stale review cannot rewind persisted SRS after restart',
      () async {
    final directory = await Directory.systemTemp.createTemp('srs-subsecond-');
    final databasePath = '${directory.path}/progress.sqlite';
    var db = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    addTearDown(() async {
      if (db.isOpen) await db.close();
      await directory.delete(recursive: true);
    });
    await db.execute('''
      CREATE TABLE srs_progress (
        lexeme_id TEXT NOT NULL,
        target_language_code TEXT NOT NULL,
        repetition_count INTEGER NOT NULL DEFAULT 0,
        interval_days INTEGER NOT NULL DEFAULT 1,
        ease_factor REAL NOT NULL DEFAULT 2.5,
        next_due_at INTEGER,
        status TEXT NOT NULL DEFAULT 'learning',
        PRIMARY KEY (lexeme_id, target_language_code)
      )
    ''');
    final scheduler = SrsSchedulerService();
    final newer = DateTime.utc(2026, 10, 25, 12, 0, 0, 800);
    final older = DateTime.utc(2026, 10, 25, 12, 0, 0, 200);

    Future<SrsReviewSchedule> review(
      String id,
      DateTime at, {
      String language = 'de',
    }) => scheduler.gradeAndPersist(
          progressDb: db,
          lexemeId: 'haus',
          languageCode: language,
          grade: 3,
          reviewedAt: at,
          reviewEventId: id,
        );

    await review('newer-subsecond', newer);
    final saved = (await db.query('srs_progress')).single;
    await db.close();
    db = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );

    // These timestamps share an epoch second. Truncating the journal
    // watermark to whole seconds incorrectly accepts the older review.
    await expectLater(review('older-subsecond', older), throwsStateError);
    expect((await db.query('srs_progress')).single, saved);
    expect(await db.query('srs_review_events'), hasLength(1));
    expect((await review('newer-subsecond', newer)).repetitionCount, 1);
    expect((await review('independent-ar', older, language: 'ar'))
        .repetitionCount, 1);
  });


  test('implicit review survives clock rollback after database restart',
      () async {
    final directory =
        await Directory.systemTemp.createTemp('srs-clock-rollback-');
    final databasePath = '${directory.path}/progress.sqlite';
    var db = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    addTearDown(() async {
      if (db.isOpen) await db.close();
      await directory.delete(recursive: true);
    });
    await db.execute('''
      CREATE TABLE srs_progress (
        lexeme_id TEXT NOT NULL,
        target_language_code TEXT NOT NULL,
        repetition_count INTEGER NOT NULL DEFAULT 0,
        interval_days INTEGER NOT NULL DEFAULT 1,
        ease_factor REAL NOT NULL DEFAULT 2.5,
        next_due_at INTEGER,
        status TEXT NOT NULL DEFAULT 'learning',
        PRIMARY KEY (lexeme_id, target_language_code)
      )
    ''');

    // Simulate an already committed event newer than the restarted device
    // clock. Its durable schedule and event must not be lost or overwritten.
    final savedFuture = DateTime.now().toUtc().add(
      const Duration(days: 1),
    );
    await SrsSchedulerService().gradeAndPersist(
      progressDb: db,
      lexemeId: 'clock-card',
      languageCode: 'de',
      grade: 3,
      reviewedAt: savedFuture,
      reviewEventId: 'clock-first',
    );
    await db.close();
    db = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );

    // A fresh legitimate submission has no explicit timestamp. Clamp only
    // this case to the durable watermark instead of discarding the review.
    final second = await SrsSchedulerService().gradeAndPersist(
      progressDb: db,
      lexemeId: 'clock-card',
      languageCode: 'de',
      grade: 3,
      reviewEventId: 'clock-second',
    );
    expect(second.repetitionCount, 2);
    final events = await db.query('srs_review_events',
        orderBy: 'created_at ASC');
    expect(events, hasLength(2));
    expect(events.first['review_event_id'], 'clock-first');
    expect(events.last['review_event_id'], 'clock-second');
    expect((events.last['created_at'] as num).toDouble(),
        greaterThan((events.first['created_at'] as num).toDouble()));

    // A delayed command with an explicit older instant is not a new
    // wall-clock submission and must remain blocked after the same restart.
    await expectLater(
      SrsSchedulerService().gradeAndPersist(
        progressDb: db,
        lexemeId: 'clock-card',
        languageCode: 'de',
        grade: 3,
        reviewedAt: DateTime.now().toUtc(),
        reviewEventId: 'clock-delayed',
      ),
      throwsStateError,
    );
    expect(await db.query('srs_review_events'), hasLength(2));
    expect((await db.query('srs_progress')).single['repetition_count'], 2);
  });
}
