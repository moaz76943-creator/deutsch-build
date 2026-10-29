import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final dbPath = await getDatabasesPath();
    final cDbPath = join(dbPath, 'polyglot_content_v2.db');
    final pDbPath = join(dbPath, 'user_progress_v2.db');

    // Make sure service state is clean
    await DatabaseService.instance.close();

    if (await File(cDbPath).exists()) {
      try {
        await File(cDbPath).delete();
      } catch (_) {}
    }
    if (await File(pDbPath).exists()) {
      try {
        await File(pDbPath).delete();
      } catch (_) {}
    }
  });

  tearDown(() async {
    await DatabaseService.instance.close();
  });

  test('Content pack is read-only and rejects inserts', () async {
    final db = await DatabaseService.instance.contentDb;

    expect(
      () async => await db.execute('INSERT INTO concepts (concept_id, category, cefr_level) VALUES ("test", "test", "test")'),
      throwsA(isA<DatabaseException>().having((e) => e.toString().toLowerCase(), 'message', contains('readonly'))),
    );
  });

  test('Progress DB enforces WAL journal mode', () async {
    final db = await DatabaseService.instance.progressDb;
    final results = await db.rawQuery('PRAGMA journal_mode;');
    expect(results.first.values.first.toString().toLowerCase(), 'wal');
  });

  test('updateSrsProgressAtomic executes correctly atomically', () async {
    final service = DatabaseService.instance;
    await service.updateSrsProgressAtomic(lexemeId: 'test_id', status: 'learning', languageCode: 'de');

    final db = await service.progressDb;
    final results = await db.query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['test_id']);
    expect(results.length, 1);
    expect(results.first['status'], 'learning');
    expect(results.first['repetition_count'], 1);

    // Update again
    await service.updateSrsProgressAtomic(lexemeId: 'test_id', status: 'review', languageCode: 'de');
    final results2 = await db.query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['test_id']);
    expect(results2.length, 1);
    expect(results2.first['status'], 'review');
    expect(results2.first['repetition_count'], 2);
  });

  test('close method safely releases resources and subsequent getter reopens DB', () async {
    final service = DatabaseService.instance;
    final contentDb1 = await service.contentDb;
    final progressDb1 = await service.progressDb;
    expect(contentDb1.isOpen, isTrue);
    expect(progressDb1.isOpen, isTrue);

    await service.close();
    expect(contentDb1.isOpen, isFalse);
    expect(progressDb1.isOpen, isFalse);

    // Getters should reopen
    final contentDb2 = await service.contentDb;
    final progressDb2 = await service.progressDb;
    expect(contentDb2.isOpen, isTrue);
    expect(progressDb2.isOpen, isTrue);
    expect(contentDb2, isNot(contentDb1));
    expect(progressDb2, isNot(progressDb1));
  });

  test('updateSrsProgressAtomic retries on closed db exception', () async {
    final service = DatabaseService.instance;
    // ensure opened
    final db = await service.progressDb;

    // forcefully close the DB behind its back
    await db.close();

    // this should trigger a retry internally, reopen the db, and succeed
    await service.updateSrsProgressAtomic(lexemeId: 'retry_test', status: 'learning', languageCode: 'de');

    final reopenedDb = await service.progressDb;
    final results = await reopenedDb.query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['retry_test']);
    expect(results.length, 1);
  });
}
