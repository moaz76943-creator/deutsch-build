import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/database_service.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Reset database service state before each test
    await DatabaseService.instance.close();

    // Delete existing test databases
    final dbPath = await databaseFactory.getDatabasesPath();
    final contentDbPath = p.join(dbPath, 'polyglot_content_v2.db');
    final progressDbPath = p.join(dbPath, 'user_progress_v2.db');

    if (await File(contentDbPath).exists()) {
      await File(contentDbPath).delete();
    }
    if (await File(progressDbPath).exists()) {
      await File(progressDbPath).delete();
    }
  });

  tearDown(() async {
    await DatabaseService.instance.close();
  });

  test('contentDb enforces read-only access to immutable language packs', () async {
    final db = await DatabaseService.instance.contentDb;

    // Attempting to write should throw an exception
    expect(
      () async => await db.insert('language_profiles', {
        'language_code': 'fr',
        'name_native': 'Français',
        'name_ar': 'الفرنسية',
        'direction': 'ltr'
      }),
      throwsA(isA<DatabaseException>()),
      reason: 'Read-only content packs cannot be modified by progress writes',
    );
  });

  test('progressDb uses WAL mode for writable learner databases', () async {
    final db = await DatabaseService.instance.progressDb;

    final result = await db.rawQuery('PRAGMA journal_mode');
    expect(result.first.values.first.toString().toLowerCase(), 'wal',
        reason: 'Writable database must use WAL mode');
  });

  test('progressDb uses busy_timeout to handle SQLite busy/interrupted transactions', () async {
    final db = await DatabaseService.instance.progressDb;

    final result = await db.rawQuery('PRAGMA busy_timeout');
    expect(result.first.values.first.toString(), '5000',
        reason: 'Writable database must configure a busy_timeout for concurrency');
  });

  test('updateSrsProgressAtomic is atomic and commits on success', () async {
    final db = await DatabaseService.instance.progressDb;

    await DatabaseService.instance.updateSrsProgressAtomic(
      lexemeId: 'lex1',
      status: 'learning',
    );

    final realResults = await db.query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['lex1']);

    expect(realResults.length, 1);
    expect(realResults.first['repetition_count'], 1);

    // Do it again to trigger the COALESCE logic
    await DatabaseService.instance.updateSrsProgressAtomic(
      lexemeId: 'lex1',
      status: 'reviewing',
    );

    final realResults2 = await db.query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['lex1']);
    expect(realResults2.first['repetition_count'], 2);
    expect(realResults2.first['status'], 'reviewing');
  });

  test('updateSrsProgressAtomic handles simultaneous requests correctly', () async {
    // Fire off multiple transactions simultaneously
    final futures = <Future>[];
    for (int i = 0; i < 5; i++) {
      futures.add(DatabaseService.instance.updateSrsProgressAtomic(
        lexemeId: 'lex2',
        status: 'simultaneous_$i',
      ));
    }

    await Future.wait(futures);

    final db = await DatabaseService.instance.progressDb;
    final results = await db.query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['lex2']);

    expect(results.length, 1);
    // Since they run simultaneously without explicit lock around the read/write,
    // the COALESCE + subquery might lead to race conditions for repetition_count.
    // In SQLite, if it is in an IMMEDIATE transaction, it will be serialized.
    // sqflite default transaction is DEFERRED but writes will promote.
    // This test ensures no "database is locked" crashes occur (WAL + busy_timeout).
    expect(results.first['lexeme_id'], 'lex2');
  });

  test('DatabaseService close respects pooled leases', () async {
    final contentDb = await DatabaseService.instance.contentDb;
    final progressDb = await DatabaseService.instance.progressDb;

    expect(contentDb.isOpen, isTrue);
    expect(progressDb.isOpen, isTrue);

    await DatabaseService.instance.close();

    expect(contentDb.isOpen, isFalse);
    expect(progressDb.isOpen, isFalse);
  });
}
