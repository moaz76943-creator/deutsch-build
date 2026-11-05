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
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        singleInstance: false,
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
      ),
    );
    scheduler = SrsSchedulerService();
  });

  tearDown(() async {
    await db.close();
  });

  // 1. Real SQLite review fixtures schedule correct due dates in epoch seconds
  test('Real SQLite review fixtures schedule correct due dates in epoch seconds',
      () async {
    final reviewedAt = DateTime.utc(2023, 1, 1);
    final schedule = await scheduler.gradeAndPersist(
      progressDb: db,
      lexemeId: 'lex1',
      languageCode: 'de',
      grade: 3,
      reviewedAt: reviewedAt,
      reviewEventId: 'evt-1',
    );

    expect(schedule.nextReviewEpoch, isPositive);
    final due = DateTime.fromMillisecondsSinceEpoch(
      schedule.nextReviewEpoch * 1000,
      isUtc: true,
    );
    expect(due.year, 2023);
    expect(due.month, 1);
    expect(due.day, 2);
    expect(due.isUtc, true);

    final result = await db.query(
      'srs_progress',
      where: 'lexeme_id = ?',
      whereArgs: ['lex1'],
    );
    expect(result.length, 1);
    expect(result.first['interval_days'], 1);
    expect(result.first['repetition_count'], 1);
    expect(result.first['next_due_at'], schedule.nextReviewEpoch);
  });

  // 2. Duplicate review submissions are safely handled
  test('Duplicate review event ids do not apply the review twice', () async {
    final reviewedAt = DateTime.utc(2023, 1, 1);

    await scheduler.gradeAndPersist(
      progressDb: db,
      lexemeId: 'lex1',
      languageCode: 'de',
      grade: 3,
      reviewedAt: reviewedAt,
      reviewEventId: 'evt-dup',
    );

    await scheduler.gradeAndPersist(
      progressDb: db,
      lexemeId: 'lex1',
      languageCode: 'de',
      grade: 4,
      reviewedAt: reviewedAt.add(const Duration(seconds: 10)),
      reviewEventId: 'evt-dup',
    );

    final result = await db.query(
      'srs_progress',
      where: 'lexeme_id = ?',
      whereArgs: ['lex1'],
    );
    expect(result.length, 1);
    expect(result.first['repetition_count'], 1);
    expect(result.first['interval_days'], 1);
  });

  // 3. Overdue cards process correctly
  test('Overdue cards process correctly', () async {
    final reviewedAt = DateTime.utc(2023, 1, 1);

    await scheduler.gradeAndPersist(
      progressDb: db,
      lexemeId: 'lex1',
      languageCode: 'de',
      grade: 3,
      reviewedAt: reviewedAt,
      reviewEventId: 'evt-overdue-1',
    );

    final schedule2 = await scheduler.gradeAndPersist(
      progressDb: db,
      lexemeId: 'lex1',
      languageCode: 'de',
      grade: 3,
      reviewedAt: reviewedAt.add(const Duration(days: 10)),
      reviewEventId: 'evt-overdue-2',
    );

    expect(schedule2.repetitionCount, 2);

    final result = await db.query(
      'srs_progress',
      where: 'lexeme_id = ?',
      whereArgs: ['lex1'],
    );
    expect(result.first['repetition_count'], 2);
  });

  // 4. Reverse pairs are isolated
  test('Reverse pairs are isolated using target_language_code and lexeme_id',
      () async {
    final reviewedAt = DateTime.utc(2023, 1, 1);

    await scheduler.gradeAndPersist(
      progressDb: db,
      lexemeId: 'lex1_ar_de',
      languageCode: 'de',
      grade: 3,
      reviewedAt: reviewedAt,
      reviewEventId: 'evt-de',
    );

    await scheduler.gradeAndPersist(
      progressDb: db,
      lexemeId: 'lex1_de_ar',
      languageCode: 'ar',
      grade: 4,
      reviewedAt: reviewedAt,
      reviewEventId: 'evt-ar',
    );

    final resultDe = await db.query(
      'srs_progress',
      where: 'lexeme_id = ?',
      whereArgs: ['lex1_ar_de'],
    );
    expect(resultDe.first['target_language_code'], 'de');
    expect(resultDe.first['repetition_count'], 1);

    final resultAr = await db.query(
      'srs_progress',
      where: 'lexeme_id = ?',
      whereArgs: ['lex1_de_ar'],
    );
    expect(resultAr.first['target_language_code'], 'ar');
    expect(resultAr.first['repetition_count'], 1);
  });

  // 5. Treat wall-clock anomalies as explicit scheduling conditions
  test('Explicit earlier review timestamps are still persisted', () async {
    final reviewedAt = DateTime.utc(2023, 1, 1);

    await scheduler.gradeAndPersist(
      progressDb: db,
      lexemeId: 'lex1',
      languageCode: 'de',
      grade: 3,
      reviewedAt: reviewedAt,
      reviewEventId: 'evt-clock-1',
    );

    await scheduler.gradeAndPersist(
      progressDb: db,
      lexemeId: 'lex1',
      languageCode: 'de',
      grade: 4,
      reviewedAt: reviewedAt.subtract(const Duration(seconds: 100)),
      reviewEventId: 'evt-clock-2',
    );

    final result = await db.query(
      'srs_progress',
      where: 'lexeme_id = ?',
      whereArgs: ['lex1'],
    );
    expect(result.length, 1);
    expect(result.first['repetition_count'], 2);
  });

  // 6. Interrupted writes rollback correctly
  test('Interrupted writes rollback correctly', () async {
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
      // The transaction must roll back.
    }

    final result = await db.query(
      'srs_progress',
      where: 'lexeme_id = ?',
      whereArgs: ['lex1'],
    );
    expect(result.isEmpty, true);
  });
}
