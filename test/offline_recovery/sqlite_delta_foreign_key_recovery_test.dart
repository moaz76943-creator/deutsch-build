import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:deutsch_bilarabi/services/delta_patch_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Cross-component recovery contract: a valid checksum and integrity_check
/// cannot make a candidate with orphaned foreign keys safe to activate.
///
/// This is an independent test-only handoff to existing private PR #139.
/// It intentionally exercises the real DeltaPatchService rather than a fake.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(sqfliteFfiInit);

  late Directory scratch;
  late File installed;

  Future<Database> openFile(File file) =>
      databaseFactoryFfi.openDatabase(
        file.path,
        options: OpenDatabaseOptions(singleInstance: false),
      );

  Future<String> fileHash(File file) async =>
      (await sha256.bind(file.openRead()).first).toString();

  setUp(() async {
    scratch = await Directory.systemTemp.createTemp('offline_delta_recovery_');
    installed = File('${scratch.path}/fr.sqlite');
    final db = await openFile(installed);
    try {
      await db.execute('CREATE TABLE parent (id INTEGER PRIMARY KEY)');
      await db.execute(
        'CREATE TABLE child ('
        'id INTEGER PRIMARY KEY, '
        'parent_id INTEGER NOT NULL REFERENCES parent(id))',
      );
      await db.insert('parent', <String, Object?>{'id': 1});
      await db.insert('child', <String, Object?>{
        'id': 1,
        'parent_id': 1,
      });
      await db.execute('PRAGMA user_version = 1');
    } finally {
      await db.close();
    }
  });

  tearDown(() async {
    if (await scratch.exists()) {
      await scratch.delete(recursive: true);
    }
  });

  test('an orphaned candidate passes integrity_check but fails FK check',
      () async {
    final candidate = File('${scratch.path}/orphaned.sqlite');
    await installed.copy(candidate.path);
    final db = await openFile(candidate);
    try {
      await db.execute('PRAGMA foreign_keys = OFF');
      await db.delete('parent', where: 'id = ?', whereArgs: <Object>[1]);
      expect(
        (await db.rawQuery('PRAGMA integrity_check')).single.values.single,
        'ok',
      );
      expect(await db.rawQuery('PRAGMA foreign_key_check'), isNotEmpty);
    } finally {
      await db.close();
    }
  });

  test('FK-corrupt delta must not replace last-known-good SQLite',
      () async {
    final originalHash = await fileHash(installed);
    final candidate = File('${scratch.path}/expected_broken.sqlite');
    await installed.copy(candidate.path);

    final candidateDb = await openFile(candidate);
    try {
      await candidateDb.execute('PRAGMA journal_mode = DELETE');
      await candidateDb.execute('PRAGMA foreign_keys = OFF');
      await candidateDb.transaction((txn) async {
        await txn.delete('parent', where: 'id = ?', whereArgs: <Object>[1]);
        await txn.execute('PRAGMA user_version = 2');
      });
      expect(
        (await candidateDb.rawQuery('PRAGMA integrity_check'))
            .single.values.single,
        'ok',
      );
      expect(await candidateDb.rawQuery('PRAGMA foreign_key_check'), isNotEmpty);
    } finally {
      await candidateDb.close();
    }

    // On the current staging base this expectation is RED: the implementation
    // runs integrity_check and digest checks but not foreign_key_check.
    // Private Draft PR #139 owns the production fix; do not edit lib/ here.
    await expectLater(
      DeltaPatchService(factory: databaseFactoryFfi).applyPatch(
        databaseFile: installed,
        patch: <String, dynamic>{
          'fromVersion': 1,
          'toVersion': 2,
          'baseSha256': originalHash,
          'expectedSha256': await fileHash(candidate),
          'operations': <Map<String, dynamic>>[
            <String, dynamic>{
              'op': 'delete',
              'table': 'parent',
              'where': <String, Object?>{'id': 1},
            },
          ],
        },
      ),
      throwsA(isA<StateError>().having(
        (error) => error.message.toString(),
        'message',
        contains('foreign key'),
      )),
    );
    expect(await fileHash(installed), originalHash);
    expect(await File('${installed.path}.delta-staging').exists(), isFalse);

    final restored = await openFile(installed);
    try {
      expect(await restored.query('parent'), hasLength(1));
      expect(await restored.query('child'), hasLength(1));
      expect(await restored.rawQuery('PRAGMA foreign_key_check'), isEmpty);
      expect(
        (await restored.rawQuery('PRAGMA user_version'))
            .single['user_version'],
        1,
      );
    } finally {
      await restored.close();
    }
  });
}
