import 'dart:io';

import 'package:deutsch_bilarabi/services/srs_scheduler_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(ffi.sqfliteFfiInit);

  Future<void> createSchema(Database db) async {
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
  }

  test('five pilot languages remain isolated in shared SRS storage', () async {
    final db =
        await ffi.databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    await createSchema(db);

    final scheduler = SrsSchedulerService();
    for (final language in const <String>['de', 'ar', 'en', 'es', 'fr']) {
      await scheduler.gradeAndPersist(
        progressDb: db,
        lexemeId: 'lex.shared',
        languageCode: language,
        grade: 3,
        reviewedAt: DateTime.utc(2026, 10, 13),
      );
    }

    final rows = await db.query(
      'srs_progress',
      where: 'lexeme_id = ?',
      whereArgs: <Object>['lex.shared'],
      orderBy: 'target_language_code',
    );
    expect(rows, hasLength(5));
    expect(
      rows.map((row) => row['target_language_code']).toSet(),
      <Object?>{'de', 'ar', 'en', 'es', 'fr'},
    );
  });

  test('persisted progress survives a simulated application restart', () async {
    final directory =
        await Directory.systemTemp.createTemp('ws18_srs_restart_');
    addTearDown(() => directory.delete(recursive: true));
    final path = '${directory.path}${Platform.pathSeparator}progress.sqlite';

    var db = await ffi.databaseFactoryFfi.openDatabase(path);
    await createSchema(db);
    await SrsSchedulerService().gradeAndPersist(
      progressDb: db,
      lexemeId: 'lex.de.1',
      languageCode: 'de',
      grade: 4,
      reviewedAt: DateTime.utc(2026, 10, 13),
    );
    await db.close();

    db = await ffi.databaseFactoryFfi.openDatabase(path);
    addTearDown(db.close);
    final rows = await db.query(
      'srs_progress',
      where: 'lexeme_id = ? AND target_language_code = ?',
      whereArgs: <Object>['lex.de.1', 'de'],
    );

    expect(rows, hasLength(1));
    expect((rows.single['repetition_count'] as num).toInt(), 1);
    expect((rows.single['interval_days'] as num).toInt(), greaterThan(0));
  });
}
