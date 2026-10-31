import 'package:deutsch_bilarabi/services/srs_scheduler_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Models failures inside the real sqflite transaction, not a mocked SRS DB.
/// Only disposable in-memory learner fixtures are used.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(sqfliteFfiInit);

  Future<Database> progressDb() async {
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
    return db;
  }

  Future<void> seed(Database db, String languageCode) async {
    await db.insert('srs_progress', <String, Object?>{
      'lexeme_id': 'same-stable-id',
      'target_language_code': languageCode,
      'repetition_count': 2,
      'interval_days': 6,
      'ease_factor': 2.5,
      'next_due_at': 1791676800,
      'status': 'review',
      'user_note': 'persisted learner note',
    });
  }

  test('failed SRS update rolls back and retains both language records',
      () async {
    final db = await progressDb();
    await seed(db, 'de');
    await seed(db, 'tr');
    final before = await db.query(
      'srs_progress',
      orderBy: 'target_language_code',
    );

    // This trigger models a persistence failure at the write boundary;
    // it is not a simulated process crash.
    await db.execute('''
      CREATE TRIGGER fail_german_review
      BEFORE UPDATE ON srs_progress
      WHEN NEW.target_language_code = 'de'
      BEGIN
        SELECT RAISE(ABORT, 'simulated write failure');
      END
    ''');

    await expectLater(
      SrsSchedulerService().gradeAndPersist(
        progressDb: db,
        lexemeId: 'same-stable-id',
        languageCode: 'de',
        grade: 3,
        reviewedAt: DateTime.utc(2026, 10, 11),
      ),
      throwsA(isA<Exception>()),
    );
    expect(
      await db.query('srs_progress', orderBy: 'target_language_code'),
      before,
    );
  });

  test('reviewing one language preserves another and retained notes',
      () async {
    final db = await progressDb();
    await seed(db, 'de');
    await seed(db, 'tr');

    final originalOther = await db.query(
      'srs_progress',
      where: 'target_language_code = ?',
      whereArgs: <Object>['tr'],
    );
    final result = await SrsSchedulerService().gradeAndPersist(
      progressDb: db,
      lexemeId: 'same-stable-id',
      languageCode: 'de',
      grade: 3,
      reviewedAt: DateTime.utc(2026, 10, 11),
    );
    final changed = (await db.query(
      'srs_progress',
      where: 'target_language_code = ?',
      whereArgs: <Object>['de'],
    )).single;

    expect(result.repetitionCount, 3);
    expect(changed['repetition_count'], 3);
    expect(changed['user_note'], 'persisted learner note');
    expect(
      await db.query(
        'srs_progress',
        where: 'target_language_code = ?',
        whereArgs: <Object>['tr'],
      ),
      originalOther,
    );
  });

  test('fractional corrupt counter never overwrites saved SRS data',
      () async {
    final db = await progressDb();
    await seed(db, 'de');
    await seed(db, 'tr');

    await db.update(
      'srs_progress',
      <String, Object?>{'repetition_count': -0.5},
      where: 'target_language_code = ?',
      whereArgs: <Object>['de'],
    );
    final before = await db.query(
      'srs_progress',
      orderBy: 'target_language_code',
    );
    expect(before.first['repetition_count'], -0.5);

    // RED on the current staging base: num.toInt() silently converts -0.5
    // into 0. Private Draft PR #134 owns the corresponding production fix.
    await expectLater(
      SrsSchedulerService().gradeAndPersist(
        progressDb: db,
        lexemeId: 'same-stable-id',
        languageCode: 'de',
        grade: 3,
        reviewedAt: DateTime.utc(2026, 10, 11),
      ),
      throwsArgumentError,
    );
    expect(
      await db.query('srs_progress', orderBy: 'target_language_code'),
      before,
    );
  });
}
