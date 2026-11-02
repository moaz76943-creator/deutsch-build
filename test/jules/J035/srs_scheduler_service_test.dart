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
      },
    ));
    scheduler = SrsSchedulerService();
  });

  tearDown(() async {
    await db.close();
  });

  test('Real SQLite review fixtures schedule correct due dates in epoch seconds', () async {
    final now = DateTime.utc(2023, 1, 1);
    final schedule = await scheduler.gradeAndPersist(
      progressDb: db,
      lexemeId: 'lex1',
      languageCode: 'de',
      grade: 3, // good
      reviewedAt: now,
    );

    expect(schedule, isNotNull);

    final nextReviewDate = DateTime.fromMillisecondsSinceEpoch(schedule.nextReviewEpoch * 1000, isUtc: true);
    expect(nextReviewDate.year, 2023);
    expect(nextReviewDate.month, 1);
    expect(nextReviewDate.day, 2);
    expect(nextReviewDate.isUtc, true);

    final result = await db.query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['lex1']);
    expect(result.length, 1);
    expect(result.first['interval_days'], 1);
    expect(result.first['repetition_count'], 1);
    final expectedNextDueAt = schedule.nextReviewEpoch;
    expect(result.first['next_due_at'], expectedNextDueAt);
  });

  test('Duplicate review submissions are safely handled via inference', () async {
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

    final result = await db.query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['lex1']);
    expect(result.length, 1);
    expect(result.first['repetition_count'], 1);
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

    final result = await db.query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['lex1']);
    expect(result.first['repetition_count'], 2);
  });

  test('Reverse pairs are isolated using target_language_code and lexeme_id', () async {
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

    final resultDe = await db.query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['lex1_ar_de']);
    expect(resultDe.first['target_language_code'], 'de');
    expect(resultDe.first['repetition_count'], 1);

    final resultAr = await db.query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['lex1_de_ar']);
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
      reviewedAt: now.subtract(const Duration(seconds: 100)), // Time jumped backwards
    );

    final result = await db.query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['lex1']);
    expect(result.length, 1);
    expect(result.first['repetition_count'], 2); // Processed because it's not swallowed as debounce
  });

  test('Interrupted writes rollback correctly', () async {
    // Though sqflite handles transaction rollback natively, we simulate a logic error inside the transaction to ensure it bubbles out and rolls back.
    final nowSeconds = DateTime.utc(2023, 1, 1).millisecondsSinceEpoch ~/ 1000;

    try {
      await db.transaction((txn) async {
        await txn.insert(
          'srs_progress',
          {
            'lexeme_id': 'lex1',
            'target_language_code': 'de',
            'repetition_count': 1,
            'interval_days': 1,
            'ease_factor': 2.5,
            'next_due_at': nowSeconds + 86400,
            'status': 'reviewing',
          },
        );
        throw Exception('Simulated crash');
      });
    } catch (e) {
      // Ignored
    }

    final result = await db.query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['lex1']);
    expect(result.isEmpty, true);
  });
}
