import 'package:deutsch_bilarabi/services/srs_scheduler_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(sqfliteFfiInit);

  Future<Database> openProgressDb() async {
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

  Future<void> seed(Database db, String language) => db.insert(
        'srs_progress',
        <String, Object?>{
          'lexeme_id': 'shared-id',
          'target_language_code': language,
          'repetition_count': 2,
          'interval_days': 6,
          'ease_factor': 2.5,
          'next_due_at': 1791676800,
          'status': 'review',
          'user_note': 'retain learner data',
        },
      ).then((_) {});

  for (final column in <String>['repetition_count', 'interval_days']) {
    for (final invalid in <Object>[-0.5, 0.5, 2.5, -1, 'corrupt']) {
      test('rejects $column=$invalid without modifying any saved row', () async {
        final db = await openProgressDb();
        await seed(db, 'de');
        await seed(db, 'tr');
        await db.update(
          'srs_progress', <String, Object?>{column: invalid},
          where: 'target_language_code = ?', whereArgs: <Object>['de'],
        );
        final before = await db.query(
          'srs_progress', orderBy: 'target_language_code',
        );
        // The fixture must actually retain the invalid value despite INTEGER
        // affinity; otherwise this would not exercise the decoding defect.
        expect(before.first[column], invalid);

        await expectLater(
          SrsSchedulerService().gradeAndPersist(
            progressDb: db, lexemeId: 'shared-id', languageCode: 'de',
            grade: 3, reviewedAt: DateTime.utc(2026, 10, 11),
          ),
          throwsArgumentError,
        );
        expect(
          await db.query('srs_progress', orderBy: 'target_language_code'),
          before,
        );
      });
    }
  }

  test('accepts intact counters and preserves notes and other languages',
      () async {
    final db = await openProgressDb();
    await seed(db, 'de');
    await seed(db, 'tr');
    final otherBefore = await db.query(
      'srs_progress',
      where: 'target_language_code = ?', whereArgs: <Object>['tr'],
    );
    final now = DateTime.utc(2026, 10, 11);
    final result = await SrsSchedulerService().gradeAndPersist(
      progressDb: db, lexemeId: 'shared-id', languageCode: 'de',
      grade: 3, reviewedAt: now,
    );
    expect(result.repetitionCount, 3);
    expect(result.intervalDays, 15);
    final saved = (await db.query(
      'srs_progress',
      where: 'target_language_code = ?', whereArgs: <Object>['de'],
    )).single;
    expect(saved['next_due_at'], result.nextReviewEpoch);
    expect(saved['user_note'], 'retain learner data');
    expect(
      await db.query(
        'srs_progress',
        where: 'target_language_code = ?', whereArgs: <Object>['tr'],
      ),
      otherBefore,
    );
  });

  test('creates a first review when no schedule exists', () async {
    final db = await openProgressDb();
    final result = await SrsSchedulerService().gradeAndPersist(
      progressDb: db, lexemeId: 'new-id', languageCode: 'de',
      grade: 3, reviewedAt: DateTime.utc(2026, 10, 11),
    );
    expect(result.repetitionCount, 1);
    expect(result.intervalDays, 1);
    expect(await db.query('srs_progress'), hasLength(1));
  });
}
