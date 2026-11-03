import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/srs_scheduler_service.dart';

void main() {
  late Database db;
  late SrsSchedulerService scheduler;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await databaseFactory.openDatabase(inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute('''
          CREATE TABLE IF NOT EXISTS srs_progress (
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
          },
        ));
    scheduler = SrsSchedulerService();
  });

  tearDown(() async {
    await db.close();
  });

  test(
      'Real SQLite review fixtures schedule correct due dates in epoch seconds',
      () async {
    final now = DateTime.utc(2023, 1, 1);
    final schedule = await scheduler.gradeAndPersist(
      progressDb: db,
      lexemeId: 'lex1',
      languageCode: 'de',
      grade: 3, // good
      reviewedAt: now,
    );

    expect(schedule, isNotNull);

    final nextReviewDate = DateTime.fromMillisecondsSinceEpoch(
        schedule.nextReviewEpoch * 1000,
        isUtc: true);
    expect(nextReviewDate.year, 2023);
    expect(nextReviewDate.month, 1);
    expect(nextReviewDate.day, 2);
    expect(nextReviewDate.isUtc, true);

    final result = await db
        .query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['lex1']);
    expect(result.length, 1);
    expect(result.first['interval_days'], 1);
    expect(result.first['repetition_count'], 1);
    final expectedNextDueAt = schedule.nextReviewEpoch;
    expect(result.first['next_due_at'], expectedNextDueAt);
  });

  test('distinct reviews within five minutes are both persisted', () async {
    final now = DateTime.utc(2023, 1, 1);

    await scheduler.gradeAndPersist(
      progressDb: db,
      lexemeId: 'lex1',
      languageCode: 'de',
      grade: 3, // good
      reviewedAt: now,
    );

    await scheduler.gradeAndPersist(
      progressDb: db,
      lexemeId: 'lex1',
      languageCode: 'de',
      grade: 4, // easy
      reviewedAt: now.add(const Duration(seconds: 10)),
    );

    final result = await db
        .query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['lex1']);
    expect(result.length, 1);
    expect(result.first['repetition_count'], 2);
    expect(await db.query('srs_review_events'), hasLength(2));
  });

  test('Overdue cards process correctly', () async {
    final now = DateTime.utc(2023, 1, 1);

    await scheduler.gradeAndPersist(
      progressDb: db,
      lexemeId: 'lex1',
      languageCode: 'de',
      grade: 3, // good
      reviewedAt: now,
    );

    final overdueDate = now.add(const Duration(days: 10));
    final schedule2 = await scheduler.gradeAndPersist(
      progressDb: db,
      lexemeId: 'lex1',
      languageCode: 'de',
      grade: 3, // good
      reviewedAt: overdueDate,
    );

    expect(schedule2, isNotNull);

    final result = await db
        .query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['lex1']);
    expect(result.first['repetition_count'], 2);
  });

  test('Reverse pairs are isolated using target_language_code and lexeme_id',
      () async {
    final now = DateTime.utc(2023, 1, 1);

    await scheduler.gradeAndPersist(
      progressDb: db,
      lexemeId: 'lex1_ar_de',
      languageCode: 'de',
      grade: 3, // good
      reviewedAt: now,
    );

    await scheduler.gradeAndPersist(
      progressDb: db,
      lexemeId: 'lex1_de_ar',
      languageCode: 'ar',
      grade: 4, // easy
      reviewedAt: now,
    );

    final resultDe = await db.query('srs_progress',
        where: 'lexeme_id = ?', whereArgs: ['lex1_ar_de']);
    expect(resultDe.first['target_language_code'], 'de');
    expect(resultDe.first['repetition_count'], 1);

    final resultAr = await db.query('srs_progress',
        where: 'lexeme_id = ?', whereArgs: ['lex1_de_ar']);
    expect(resultAr.first['target_language_code'], 'ar');
    expect(resultAr.first['repetition_count'], 1);
  });

  test('Clock changes backwards handled gracefully (negative diff)', () async {
    final now = DateTime.utc(2023, 1, 1);

    await scheduler.gradeAndPersist(
      progressDb: db,
      lexemeId: 'lex1',
      languageCode: 'de',
      grade: 3, // good
      reviewedAt: now,
    );

    await scheduler.gradeAndPersist(
      progressDb: db,
      lexemeId: 'lex1',
      languageCode: 'de',
      grade: 4, // easy
      reviewedAt:
          now.subtract(const Duration(seconds: 100)), // Time jumped backwards
    );

    final result = await db
        .query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['lex1']);
    expect(result.length, 1);
    expect(result.first['repetition_count'],
        2); // Processed because it's not swallowed as debounce
  });

  test('same-second reviews without event IDs remain distinct', () async {
    final now = DateTime.utc(2023, 1, 1);
    for (final grade in [3, 4]) {
      await scheduler.gradeAndPersist(
        progressDb: db,
        lexemeId: 'lex1',
        languageCode: 'de',
        grade: grade,
        reviewedAt: now,
      );
    }
    expect((await db.query('srs_progress')).single['repetition_count'], 2);
    final events = await db.query('srs_review_events');
    expect(events, hasLength(2));
    expect(
        events.map((event) => event['review_event_id']).toSet(), hasLength(2));
  });

  test('concurrent exact event retries advance progress only once', () async {
    final schedules = await Future.wait(List.generate(12, (_) {
      return scheduler.gradeAndPersist(
        progressDb: db,
        lexemeId: 'lex1',
        languageCode: 'de',
        grade: 3,
        reviewedAt: DateTime.utc(2023, 1, 1),
        reviewEventId: 'event-1',
      );
    }));
    expect(
        schedules.every((schedule) => schedule.repetitionCount == 1), isTrue);
    expect((await db.query('srs_progress')).single['repetition_count'], 1);
    expect(await db.query('srs_review_events'), hasLength(1));
  });

  for (final collision in [
    (lexeme: 'lex2', language: 'de', grade: 3),
    (lexeme: 'lex1', language: 'ar', grade: 3),
    (lexeme: 'lex1', language: 'de', grade: 4),
  ]) {
    test('event ID rejects conflicting payload $collision without writes',
        () async {
      // Seed the second scope too: silently returning that row is data loss.
      for (final scope in [
        (lexeme: 'lex1', language: 'de'),
        (lexeme: collision.lexeme, language: collision.language),
      ]) {
        await scheduler.gradeAndPersist(
          progressDb: db,
          lexemeId: scope.lexeme,
          languageCode: scope.language,
          grade: 3,
          reviewedAt: DateTime.utc(2023, 1, 1),
        );
      }
      await scheduler.gradeAndPersist(
        progressDb: db,
        lexemeId: 'lex1',
        languageCode: 'de',
        grade: 3,
        reviewEventId: 'event-1',
        reviewedAt: DateTime.utc(2023, 1, 2),
      );
      final progress = await db.query('srs_progress');
      final events = await db.query('srs_review_events');
      await expectLater(
          scheduler.gradeAndPersist(
            progressDb: db,
            lexemeId: collision.lexeme,
            languageCode: collision.language,
            grade: collision.grade,
            reviewEventId: 'event-1',
            reviewedAt: DateTime.utc(2023, 1, 2),
          ),
          throwsStateError);
      expect(await db.query('srs_progress'), progress);
      expect(await db.query('srs_review_events'), events);
    });
  }

  test('event insert failure rolls back the scheduler progress update',
      () async {
    await scheduler.gradeAndPersist(
      progressDb: db,
      lexemeId: 'lex1',
      languageCode: 'de',
      grade: 3,
      reviewEventId: 'event-1',
      reviewedAt: DateTime.utc(2023, 1, 1),
    );
    final progress = await db.query('srs_progress');
    final events = await db.query('srs_review_events');
    await db.execute("""
      CREATE TRIGGER reject_review BEFORE INSERT ON srs_review_events
      BEGIN SELECT RAISE(ABORT, 'simulated disk failure'); END
    """);
    await expectLater(
        scheduler.gradeAndPersist(
          progressDb: db,
          lexemeId: 'lex1',
          languageCode: 'de',
          grade: 4,
          reviewEventId: 'event-2',
          reviewedAt: DateTime.utc(2023, 1, 2),
        ),
        throwsA(isA<DatabaseException>()));
    expect(await db.query('srs_progress'), progress);
    expect(await db.query('srs_review_events'), events);
  });
}
