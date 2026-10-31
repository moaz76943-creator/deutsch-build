import 'dart:io';

import 'package:deutsch_bilarabi/services/database_migration_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late String dbPath;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'deutsch_db_migration_',
    );
    dbPath = '${tempDir.path}/test_srs.db';
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'migrates legacy database sequentially without losing existing data',
    () async {
      final legacyDb = await databaseFactoryFfi.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute(
              'CREATE TABLE cards ('
              'id TEXT PRIMARY KEY, '
              'interval INTEGER NOT NULL'
              ')',
            );
            await db.insert(
              'cards',
              <String, Object?>{
                'id': 'card-1',
                'interval': 5,
              },
            );
          },
        ),
      );
      await legacyDb.close();

      final migratedDb = await DatabaseMigrationHelper.open(
        path: dbPath,
        version: 3,
        factory: databaseFactoryFfi,
        onCreate: (db, version) async {
          fail('Existing legacy database must not trigger onCreate');
        },
        migrationScripts: <int, List<String>>{
          2: <String>[
            'ALTER TABLE cards '
                'ADD COLUMN ease_factor REAL NOT NULL DEFAULT 2.5',
          ],
          3: <String>[
            'ALTER TABLE cards ADD COLUMN last_reviewed_at TEXT',
          ],
        },
      );
      addTearDown(migratedDb.close);

      final rows = await migratedDb.query(
        'cards',
        where: 'id = ?',
        whereArgs: <Object?>['card-1'],
      );

      expect(rows, hasLength(1));
      expect(rows.single['interval'], 5);
      expect(rows.single['ease_factor'], 2.5);
      expect(rows.single['last_reviewed_at'], isNull);

      final columns = await migratedDb.rawQuery('PRAGMA table_info(cards)');
      final columnNames = columns
          .map((row) => row['name'])
          .whereType<String>()
          .toSet();
      expect(
        columnNames,
        containsAll(<String>{
          'id',
          'interval',
          'ease_factor',
          'last_reviewed_at',
        }),
      );

      final versionRows = await migratedDb.rawQuery('PRAGMA user_version');
      expect(versionRows.single['user_version'], 3);

      final backupDir = Directory('${tempDir.path}/backups');
      expect(await backupDir.exists(), isTrue);

      final backups = await backupDir
          .list()
          .where(
            (entity) =>
                entity is File &&
                entity.path.contains('test_srs_v1_') &&
                entity.path.endsWith('.db'),
          )
          .toList();
      expect(backups, hasLength(1));
    },
  );
}
