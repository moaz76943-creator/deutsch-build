import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/srs_scheduler_service.dart';
import 'package:deutsch_bilarabi/core/srs/production_srs_engine.dart';

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

  Future<SrsReviewSchedule?> processReviewHelper({
    required String lexemeId,
    required String targetLanguageCode,
    required SrsRating rating,
    required int currentTimeSeconds,
  }) async {
    int grade;
    switch (rating) {
      case SrsRating.hard:
        grade = 1;
        break;
      case SrsRating.good:
        grade = 2;
        break;
      case SrsRating.easy:
        grade = 3;
        break;
    }
    return scheduler.gradeAndPersist(
      progressDb: db,
      lexemeId: lexemeId,
      languageCode: targetLanguageCode,
      grade: grade,
      reviewedAt: DateTime.fromMillisecondsSinceEpoch(currentTimeSeconds * 1000, isUtc: true),
    );
  }

  test('Real SQLite review fixtures schedule correct due dates in epoch seconds', () async {
    final nowSeconds = DateTime.utc(2023, 1, 1).millisecondsSinceEpoch ~/ 1000;
    final schedule = await processReviewHelper(
      lexemeId: 'lex1',
      targetLanguageCode: 'de',
      rating: SrsRating.good,
      currentTimeSeconds: nowSeconds,
    );

    expect(schedule, isNotNull);

    expect(schedule!.nextReviewDate.year, 2023);
    expect(schedule.nextReviewDate.month, 1);
    expect(schedule.nextReviewDate.day, 2);
    expect(schedule.nextReviewDate.isUtc, true);

    final result = await db.query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['lex1']);
    expect(result.length, 1);
    expect(result.first['interval_days'], 1);
    expect(result.first['repetition_count'], 1);
    final expectedNextDueAt = schedule.nextReviewDate.millisecondsSinceEpoch ~/ 1000;
    expect(result.first['next_due_at'], expectedNextDueAt);
  });

  test('Duplicate review submissions are safely handled via inference', () async {
    final nowSeconds = DateTime.utc(2023, 1, 1).millisecondsSinceEpoch ~/ 1000;

    await processReviewHelper(
      lexemeId: 'lex1',
      targetLanguageCode: 'de',
      rating: SrsRating.good,
      currentTimeSeconds: nowSeconds,
    );

    await processReviewHelper(
      lexemeId: 'lex1',
      targetLanguageCode: 'de',
      rating: SrsRating.easy,
      currentTimeSeconds: nowSeconds + 10,
    );

    final result = await db.query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['lex1']);
    expect(result.length, 1);
    expect(result.first['repetition_count'], 1);
  });

  test('Overdue cards process correctly', () async {
    final nowSeconds = DateTime.utc(2023, 1, 1).millisecondsSinceEpoch ~/ 1000;

    await processReviewHelper(
      lexemeId: 'lex1',
      targetLanguageCode: 'de',
      rating: SrsRating.good,
      currentTimeSeconds: nowSeconds,
    );

    final overdueSeconds = nowSeconds + (10 * 86400);
    final schedule2 = await processReviewHelper(
      lexemeId: 'lex1',
      targetLanguageCode: 'de',
      rating: SrsRating.good,
      currentTimeSeconds: overdueSeconds,
    );

    expect(schedule2, isNotNull);

    final result = await db.query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['lex1']);
    expect(result.first['repetition_count'], 2);
  });

  test('Reverse pairs are isolated using target_language_code and lexeme_id', () async {
    final nowSeconds = DateTime.utc(2023, 1, 1).millisecondsSinceEpoch ~/ 1000;

    await processReviewHelper(
      lexemeId: 'lex1_ar_de',
      targetLanguageCode: 'de',
      rating: SrsRating.good,
      currentTimeSeconds: nowSeconds,
    );

    await processReviewHelper(
      lexemeId: 'lex1_de_ar',
      targetLanguageCode: 'ar',
      rating: SrsRating.easy,
      currentTimeSeconds: nowSeconds,
    );

    final resultDe = await db.query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['lex1_ar_de']);
    expect(resultDe.first['target_language_code'], 'de');
    expect(resultDe.first['repetition_count'], 1);

    final resultAr = await db.query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['lex1_de_ar']);
    expect(resultAr.first['target_language_code'], 'ar');
    expect(resultAr.first['repetition_count'], 1);
  });

  test('Clock changes backwards handled gracefully (negative diff)', () async {
    final nowSeconds = DateTime.utc(2023, 1, 1).millisecondsSinceEpoch ~/ 1000;

    await processReviewHelper(
      lexemeId: 'lex1',
      targetLanguageCode: 'de',
      rating: SrsRating.good,
      currentTimeSeconds: nowSeconds,
    );

    await processReviewHelper(
      lexemeId: 'lex1',
      targetLanguageCode: 'de',
      rating: SrsRating.easy,
      currentTimeSeconds: nowSeconds - 1000, // Time jumped backwards more than 5 minutes to avoid idempotency check
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
