import 'dart:io';

import 'package:deutsch_bilarabi/services/sqlite_policy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('writable policy applies foreign keys and bounded busy timeout', () async {
    final root = await Directory.systemTemp.createTemp('sqlite_policy_');
    final path = p.join(root.path, 'policy.db');
    final policy = AppSqlitePolicy(factory: databaseFactoryFfi);

    final database = await policy.openWritable(
      path: path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE parent (id INTEGER PRIMARY KEY)',
        );
        await db.execute(
          'CREATE TABLE child ('
          'id INTEGER PRIMARY KEY, '
          'parent_id INTEGER NOT NULL, '
          'FOREIGN KEY(parent_id) REFERENCES parent(id))',
        );
      },
    );

    final foreignKeys = await database.rawQuery('PRAGMA foreign_keys');
    final busyTimeout = await database.rawQuery('PRAGMA busy_timeout');

    expect(foreignKeys.first.values.first, 1);
    expect((busyTimeout.first.values.first as num).toInt(), greaterThanOrEqualTo(5000));
    await expectLater(
      database.insert('child', <String, Object>{'id': 1, 'parent_id': 99}),
      throwsA(isA<DatabaseException>()),
    );

    await database.close();
    await root.delete(recursive: true);
  });

  test('factory-backed path resolution is deterministic and traversal-safe', () async {
    final policy = AppSqlitePolicy(factory: databaseFactoryFfi);

    expect(
      await policy.resolvePath(fileName: 'grammar_hub.db'),
      'grammar_hub.db',
    );
    await expectLater(
      policy.resolvePath(fileName: '../escape.db'),
      throwsA(isA<SqlitePolicyException>()),
    );
  });
}
