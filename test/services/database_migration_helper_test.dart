import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/database_migration_helper.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('DatabaseMigrationHelper correctly initiates and performs transaction logic', () async {
    final dbPath = inMemoryDatabasePath;
    final db = await DatabaseMigrationHelper.openSafeDatabase(
      path: dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE test_table (
            id TEXT PRIMARY KEY,
            value INTEGER NOT NULL
          )
        ''');
      },
      factory: databaseFactoryFfi,
    );

    await DatabaseMigrationHelper.executeAtomic(db, (txn) async {
      await txn.insert('test_table', {'id': '1', 'value': 100});
    });

    final res = await db.query('test_table');
    expect(res.length, 1);
    expect(res.first['value'], 100);

    await db.close();
  });
}
