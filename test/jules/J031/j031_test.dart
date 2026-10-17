import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:deutsch_bilarabi/services/database_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await DatabaseService.instance.close();
    final dbPath = await databaseFactory.getDatabasesPath();
    final contentDbPath = p.join(dbPath, 'polyglot_content_v2.db');
    final progressDbPath = p.join(dbPath, 'user_progress_v2.db');

    // ignore: avoid_catching_errors
    try {
      if (await File(contentDbPath).exists()) {
        await File(contentDbPath).delete();
      }
    } catch (_) {}

    // ignore: avoid_catching_errors
    try {
      if (await File(progressDbPath).exists()) {
        await File(progressDbPath).delete();
      }
    } catch (_) {}
  });

  tearDown(() async {
    await DatabaseService.instance.close();
  });

  test('contentDb enforces read-only access to immutable language packs', () async {
    final db = await DatabaseService.instance.contentDb;
    expect(
      () async => await db.insert('language_profiles', {
        'language_code': 'fr',
        'name_native': 'Français',
        'name_ar': 'الفرنسية',
        'direction': 'ltr',
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

    await DatabaseService.instance.updateSrsProgressAtomic(
      lexemeId: 'lex1',
      status: 'reviewing',
    );

    final realResults2 = await db.query('srs_progress', where: 'lexeme_id = ?', whereArgs: ['lex1']);
    expect(realResults2.first['repetition_count'], 2);
    expect(realResults2.first['status'], 'reviewing');
  });

  test('updateSrsProgressAtomic handles simultaneous requests correctly', () async {
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

  test('Simultaneous initialization requests return same instance', () async {
    final futures = [
      DatabaseService.instance.progressDb,
      DatabaseService.instance.progressDb,
    ];
    final dbs = await Future.wait(futures);
    expect(identical(dbs[0], dbs[1]), isTrue);

    final contentFutures = [
      DatabaseService.instance.contentDb,
      DatabaseService.instance.contentDb,
    ];
    final contentDbs = await Future.wait(contentFutures);
    expect(identical(contentDbs[0], contentDbs[1]), isTrue);
  });

  test('Transaction rollback (inserting invalid data throws and rolls back)', () async {
    final service = DatabaseService.instance;
    final progressDb = await service.progressDb;
    var countResult = await progressDb.rawQuery('SELECT COUNT(*) FROM srs_progress;');
    expect(countResult.first.values.first, 0);

    try {
      await progressDb.transaction((txn) async {
        await txn.rawInsert('''
          INSERT INTO srs_progress (lexeme_id, target_language_code, repetition_count, status)
          VALUES (?, ?, ?, ?)
        ''', ['lex.test.1', 'de', 0, 'learning']);
        await txn.rawInsert('INSERT INTO non_existent_table (id) VALUES (1)');
      });
      fail('Transaction should have thrown');
    } catch (e) {
      expect(e, isA<DatabaseException>());
    }

    countResult = await progressDb.rawQuery('SELECT COUNT(*) FROM srs_progress;');
    expect(countResult.first.values.first, 0);
  });
}
