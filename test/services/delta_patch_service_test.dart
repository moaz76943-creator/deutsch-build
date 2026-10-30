import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:deutsch_bilarabi/services/delta_patch_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(sqfliteFfiInit);

  late Directory temp;
  late File installed;
  late DeltaPatchService service;

  Future<String> digest(File f) async =>
      (await sha256.bind(f.openRead()).first).toString();

  Future<Database> openFile(File f) =>
      databaseFactoryFfi.openDatabase(f.path,
          options: OpenDatabaseOptions(singleInstance: false));

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('delta_service_');
    installed = File(temp.path + '/fr.sqlite');
    final db = await openFile(installed);
    await db.execute('CREATE TABLE words (id INTEGER PRIMARY KEY, word TEXT)');
    await db.insert('words', {'id': 1, 'word': 'old'});
    await db.execute('PRAGMA user_version = 1');
    await db.close();
    service = DeltaPatchService(factory: databaseFactoryFfi);
  });

  tearDown(() async => temp.delete(recursive: true));

  test('publishes inserts, updates, deletes and SQL only after digest check',
      () async {
    final expected = File(temp.path + '/expected.sqlite');
    await installed.copy(expected.path);
    final db = await openFile(expected);
    await db.transaction((txn) async {
      await txn.update('words', {'word': 'new'},
          where: 'id = ?', whereArgs: [1]);
      await txn.insert('words', {'id': 2, 'word': 'remove'});
      await txn.delete('words', where: 'id = ?', whereArgs: [2]);
      await txn.execute('INSERT INTO words (id,word) VALUES (?,?)',
          [3, 'bonjour']);
      await txn.execute('PRAGMA user_version = 2');
    });
    await db.close();
    final expectedHash = await digest(expected);
    final result = await service.applyPatch(
      databaseFile: installed,
      patch: {
        'fromVersion': 1, 'toVersion': 2,
        'baseSha256': await digest(installed),
        'expectedSha256': expectedHash,
        'operations': [
          {'op': 'update', 'table': 'words',
            'values': {'word': 'new'}, 'where': {'id': 1}},
          {'op': 'insert', 'table': 'words',
            'values': {'id': 2, 'word': 'remove'}},
          {'op': 'delete', 'table': 'words', 'where': {'id': 2}},
          {'op': 'sql', 'sql': 'INSERT INTO words (id,word) VALUES (?,?)',
            'args': [3, 'bonjour']},
        ],
      },
    );
    expect(result, expectedHash);
    final installedDb = await openFile(installed);
    expect((await installedDb.query('words', orderBy: 'id'))
        .map((row) => row['word']).toList(), ['new', 'bonjour']);
    expect((await installedDb.rawQuery('PRAGMA user_version'))
        .first['user_version'], 2);
    await installedDb.close();
  });

  test('rejects wrong target SHA and preserves original', () async {
    final originalHash = await digest(installed);
    await expectLater(
      service.applyPatch(databaseFile: installed, patch: {
        'fromVersion': 1, 'toVersion': 2,
        'expectedSha256': List.filled(64, '0').join(),
        'operations': [{'op': 'insert', 'table': 'words',
          'values': {'id': 2, 'word': 'test'}}],
      }),
      throwsStateError,
    );
    expect(await digest(installed), originalHash);
    expect(await File(installed.path + '.delta-staging').exists(), false);
  });

  test('refuses wrong version, unsafe destructive DML and SQL batching',
      () async {
    final originalHash = await digest(installed);
    for (final patch in [
      {
        'fromVersion': 3, 'toVersion': 4,
        'expectedSha256': List.filled(64, '0').join(),
        'operations': [{'op': 'delete', 'table': 'words', 'where': {'id': 1}}],
      },
      {
        'fromVersion': 1, 'toVersion': 2,
        'expectedSha256': List.filled(64, '0').join(),
        'operations': [{'op': 'delete', 'table': 'words', 'where': {}}],
      },
      {
        'fromVersion': 1, 'toVersion': 2,
        'expectedSha256': List.filled(64, '0').join(),
        'operations': [{'op': 'sql', 'sql': 'DELETE FROM words; DROP TABLE words'}],
      },
    ]) {
      await expectLater(
        service.applyPatch(databaseFile: installed, patch: patch),
        throwsA(anything),
      );
      expect(await digest(installed), originalHash);
    }
  });

  test('does not copy files with an active WAL sidecar', () async {
    await File(installed.path + '-wal').writeAsString('busy');
    await expectLater(
      service.applyPatch(databaseFile: installed, patch: {
        'fromVersion': 1, 'toVersion': 2,
        'expectedSha256': List.filled(64, '0').join(),
        'operations': [{'op': 'delete', 'table': 'words', 'where': {'id': 1}}],
      }),
      throwsStateError,
    );
  });
}
