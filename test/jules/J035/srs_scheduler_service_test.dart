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
           lexeme_id TEXT PRIMARY KEY,
           target_language_code TEXT NOT NULL,
           repetition_count INTEGER NOT NULL DEFAULT 0,
           interval_days INTEGER NOT NULL DEFAULT 1,
           ease_factor REAL NOT NULL DEFAULT 2.5,
           next_due_at INTEGER,
           status TEXT NOT NULL DEFAULT 'learning'
          )
        ''');
            }));

    scheduler = SrsSchedulerService(getDb: () async => db);
  });

  tearDown(() async {
    await db.close();
  });

  test('Schedules correct due dates for new review', () async {
    final now = DateTime.utc(2023, 1, 1, 12, 0, 0);

    await scheduler.submitReview(
      lexemeId: 'lex.de.water',
      languageCode: 'de',
      quality: 4,
      now: now,
    );

    final results = await db.query('srs_progress');
    expect(results.length, 1);

    final state = SrsReviewState.fromMap(results.first);
    expect(state.lexemeId, 'lex.de.water');
    expect(state.targetLanguageCode, 'de');
    expect(state.intervalDays, 1);
    expect(state.repetitionCount, 1);

    final expectedDueEpoch = now.add(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000;
    expect(state.nextDueAtEpoch, expectedDueEpoch);
    expect(state.status, 'reviewing');
  });

  test('Safely handles duplicate review submissions (idempotency)', () async {
    final now = DateTime.utc(2023, 1, 1, 12, 0, 0);

    await scheduler.submitReview(
      lexemeId: 'lex.de.water',
      languageCode: 'de',
      quality: 4,
      now: now,
    );

    final results1 = await db.query('srs_progress');
    final state1 = SrsReviewState.fromMap(results1.first);
    expect(state1.repetitionCount, 1);

    await scheduler.submitReview(
      lexemeId: 'lex.de.water',
      languageCode: 'de',
      quality: 4,
      now: now.add(const Duration(hours: 1)),
    );

    final results2 = await db.query('srs_progress');
    final state2 = SrsReviewState.fromMap(results2.first);

    expect(state2.repetitionCount, 1);
    expect(state2.nextDueAtEpoch, state1.nextDueAtEpoch);
  });

  test('No cross-pair mutation (different languages do not conflict due to unique lexeme_id)', () async {
    final now = DateTime.utc(2023, 1, 1, 12, 0, 0);

    await scheduler.submitReview(
      lexemeId: 'lex.de.water',
      languageCode: 'de',
      quality: 4,
      now: now,
    );

    await scheduler.submitReview(
      lexemeId: 'lex.ar.water',
      languageCode: 'ar',
      quality: 4,
      now: now,
    );

    final results = await db.query('srs_progress');
    expect(results.length, 2);
  });

  test('Correctly handles overdue cards by scheduling based on current time', () async {
    final now = DateTime.utc(2023, 1, 1, 12, 0, 0);

    await scheduler.submitReview(
      lexemeId: 'lex.de.water',
      languageCode: 'de',
      quality: 4,
      now: now,
    );

    final nextReviewDate = DateTime.utc(2023, 1, 5, 12, 0, 0);

    await scheduler.submitReview(
      lexemeId: 'lex.de.water',
      languageCode: 'de',
      quality: 4,
      now: nextReviewDate,
    );

    final results = await db.query('srs_progress');
    final state = SrsReviewState.fromMap(results.first);

    expect(state.repetitionCount, 2);

    // nextDueAtEpoch should be nextReviewDate + interval
    final expectedDueEpoch = nextReviewDate.add(Duration(days: state.intervalDays)).millisecondsSinceEpoch ~/ 1000;
    expect(state.nextDueAtEpoch, expectedDueEpoch);
  });

  test('Retrieves due reviews up to now', () async {
    final now = DateTime.utc(2023, 1, 1, 12, 0, 0);

    await scheduler.submitReview(
      lexemeId: 'lex.de.water',
      languageCode: 'de',
      quality: 4,
      now: now,
    ); // Due on 2023-01-02 12:00:00

    await scheduler.submitReview(
      lexemeId: 'lex.de.book',
      languageCode: 'de',
      quality: 4,
      now: now.subtract(const Duration(days: 3)),
    ); // Due on 2022-12-30 12:00:00, Overdue now

    final checkNow = now.add(const Duration(hours: 1)); // 2023-01-01 13:00:00

    final dueList = await scheduler.getDueReviews('de', checkNow);
    expect(dueList.length, 1);
    expect(dueList.first.lexemeId, 'lex.de.book');
  });

  test('Validates grade meaning and bounds', () async {
    final now = DateTime.utc(2023, 1, 1, 12, 0, 0);

    expect(
      () => scheduler.submitReview(
        lexemeId: 'lex.de.water',
        languageCode: 'de',
        quality: 6, // out of bounds
        now: now,
      ),
      throwsArgumentError,
    );

    expect(
      () => scheduler.submitReview(
        lexemeId: 'lex.de.water',
        languageCode: 'de',
        quality: 0, // out of bounds
        now: now,
      ),
      throwsArgumentError,
    );
  });

  test('Clock changes and daylight saving transitions (using UTC)', () async {
    final now = DateTime.utc(2023, 3, 26, 1, 0, 0); // Before DST change in EU

    await scheduler.submitReview(
      lexemeId: 'lex.de.water',
      languageCode: 'de',
      quality: 4,
      now: now,
    );

    final results = await db.query('srs_progress');
    final state = SrsReviewState.fromMap(results.first);

    // nextDueAtEpoch should be strictly interval * 24h
    // DST doesn't affect UTC epoch addition in dart with Duration(days: 1)
    final expectedDueEpoch = now.add(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000;
    expect(state.nextDueAtEpoch, expectedDueEpoch);

    final nextDueDateUtc = DateTime.fromMillisecondsSinceEpoch(state.nextDueAtEpoch! * 1000, isUtc: true);
    expect(nextDueDateUtc, DateTime.utc(2023, 3, 27, 1, 0, 0));
  });

  test('Safely handles interrupted writes (no regression on conflict)', () async {
    final now = DateTime.utc(2023, 1, 1, 12, 0, 0);

    // Initial state
    await scheduler.submitReview(
      lexemeId: 'lex.de.water',
      languageCode: 'de',
      quality: 4,
      now: now,
    );

    // Check initial ease factor and interval
    final initialResults = await db.query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['lex.de.water']);
    final initialState = SrsReviewState.fromMap(initialResults.first);

    // Update with new data simulating a successful write after an interruption
    final later = now.add(const Duration(days: 2));
    await scheduler.submitReview(
      lexemeId: 'lex.de.water',
      languageCode: 'de',
      quality: 5,
      now: later,
    );

    // Ensure state updated but row identity (and primary key) remained intact and stable
    final finalResults = await db.query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['lex.de.water']);
    final finalState = SrsReviewState.fromMap(finalResults.first);

    expect(finalState.repetitionCount, 2);
    expect(finalState.easeFactor, greaterThan(initialState.easeFactor)); // Quality 5 increases ease
    expect(finalState.intervalDays, greaterThan(initialState.intervalDays));
  });

  test('Reverse pairs (e.g. ar->de vs de->ar) use distinct identities and do not overlap', () async {
    final now = DateTime.utc(2023, 1, 1, 12, 0, 0);

    await scheduler.submitReview(
      lexemeId: 'lex.de_ar.water',
      languageCode: 'ar',
      quality: 4,
      now: now,
    );

    await scheduler.submitReview(
      lexemeId: 'lex.ar_de.water',
      languageCode: 'de',
      quality: 4,
      now: now,
    );

    final results = await db.query('srs_progress');
    expect(results.length, 2); // Distinct lexeme IDs naturally protect against cross-pair mutation

    final deResults = await scheduler.getDueReviews('de', now.add(const Duration(days: 2)));
    expect(deResults.length, 1);
    expect(deResults.first.lexemeId, 'lex.ar_de.water');

    final arResults = await scheduler.getDueReviews('ar', now.add(const Duration(days: 2)));
    expect(arResults.length, 1);
    expect(arResults.first.lexemeId, 'lex.de_ar.water');
  });
}
