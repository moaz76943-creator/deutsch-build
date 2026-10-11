import 'package:deutsch_bilarabi/services/srs_scheduler_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
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
        lexeme_id TEXT PRIMARY KEY,
        target_language_code TEXT NOT NULL,
        repetition_count INTEGER NOT NULL DEFAULT 0,
        interval_days INTEGER NOT NULL DEFAULT 1,
        ease_factor REAL NOT NULL DEFAULT 2.5,
        next_due_at INTEGER,
        status TEXT NOT NULL DEFAULT 'learning'
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
}
