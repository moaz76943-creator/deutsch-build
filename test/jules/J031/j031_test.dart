import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/database_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDown(() async {
    final service = DatabaseService.instance;
    await service.close();

    final dbPath = await getDatabasesPath();
    final contentPath = join(dbPath, 'polyglot_content_v2.db');
    final progressPath = join(dbPath, 'user_progress_v2.db');

    if (await databaseFactory.databaseExists(contentPath)) {
      await databaseFactory.deleteDatabase(contentPath);
    }
    if (await databaseFactory.databaseExists(progressPath)) {
      await databaseFactory.deleteDatabase(progressPath);
    }
  });

  test('Content DB should be Read-Only and Progress DB should use WAL', () async {
    final service = DatabaseService.instance;
    final progressDb = await service.progressDb;
    final contentDb = await service.contentDb;

    // Check progressDb WAL mode
    final modeResult = await progressDb.rawQuery('PRAGMA journal_mode;');
    expect(modeResult.first.values.first.toString().toLowerCase(), 'wal', reason: 'progress DB must use WAL mode');

    // Check contentDb is read-only
    try {
      await contentDb.execute('CREATE TABLE dummy (id INTEGER)');
      fail('Should throw DatabaseException because content DB must be read-only');
    } catch (e) {
      expect(e, isA<DatabaseException>());
      expect(e.toString().toLowerCase().contains('readonly'), isTrue);
    }
  });

  test('Simultaneous initialization requests return same instance', () async {
    final service = DatabaseService.instance;

    // Request db twice concurrently
    final futures = [
      service.progressDb,
      service.progressDb,
    ];

    final dbs = await Future.wait(futures);
    expect(identical(dbs[0], dbs[1]), isTrue);

    final contentFutures = [
      service.contentDb,
      service.contentDb,
    ];

    final contentDbs = await Future.wait(contentFutures);
    expect(identical(contentDbs[0], contentDbs[1]), isTrue);
  });

  test('Transaction rollback (inserting invalid data throws and rolls back)', () async {
    final service = DatabaseService.instance;
    final progressDb = await service.progressDb;

    // We expect a DatabaseException when inserting without required fields (if schema enforces it)
    // Or we can simulate a crash in transaction

    // Initially empty
    var countResult = await progressDb.rawQuery('SELECT COUNT(*) FROM srs_progress;');
    expect(countResult.first.values.first, 0);

    try {
      await progressDb.transaction((txn) async {
        await txn.rawInsert('''
          INSERT INTO srs_progress (lexeme_id, target_language_code, repetition_count, status)
          VALUES (?, ?, ?, ?)
        ''', ['lex.test.1', 'de', 0, 'learning']);

        // This should fail due to syntax or constraint (e.g. unknown table or null constraint)
        await txn.rawInsert('INSERT INTO non_existent_table (id) VALUES (1)');
      });
      fail('Transaction should have thrown');
    } catch (e) {
      expect(e, isA<DatabaseException>());
    }

    // Since transaction rolled back, the first insert should not be there
    countResult = await progressDb.rawQuery('SELECT COUNT(*) FROM srs_progress;');
    expect(countResult.first.values.first, 0);
  });

  test('updateSrsProgressAtomic works correctly', () async {
    final service = DatabaseService.instance;
    await service.updateSrsProgressAtomic(lexemeId: 'lex.test.2', status: 'learning');

    final progressDb = await service.progressDb;
    var result = await progressDb.rawQuery('SELECT * FROM srs_progress WHERE lexeme_id = ?', ['lex.test.2']);
    expect(result.length, 1);
    expect(result.first['repetition_count'], 1);
    expect(result.first['status'], 'learning');

    // Update again
    await service.updateSrsProgressAtomic(lexemeId: 'lex.test.2', status: 'reviewing');
    result = await progressDb.rawQuery('SELECT * FROM srs_progress WHERE lexeme_id = ?', ['lex.test.2']);
    expect(result.length, 1);
    expect(result.first['repetition_count'], 2);
    expect(result.first['status'], 'reviewing');
  });
}
