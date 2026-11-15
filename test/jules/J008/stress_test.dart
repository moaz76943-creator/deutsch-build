import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/pooled_database_manager.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('J008 Stress-test 100 language identities with a small active-connection budget', () async {
      final manager = PooledDatabaseManager(
        maxConnections: 5,
        openConnection: (code) async {
          return await databaseFactory.openDatabase(inMemoryDatabasePath, options: OpenDatabaseOptions(readOnly: true));
        },
      );

      final futures = <Future>[];
      for (int i = 0; i < 100; i++) {
        final code = 'deu-1${i.toString().padLeft(2, '0')}';
        futures.add(manager.withDatabase(code, (db) async {
          await Future<void>.delayed(const Duration(milliseconds: 5));
        }));
      }

      await Future.wait(futures);
      expect(manager.activeCount, lessThanOrEqualTo(5));
  });

  test('Verify read-only packs remain read-only', () async {
      final manager = PooledDatabaseManager(
        maxConnections: 5,
        openConnection: (code) async {
          // Mock creating a db
          final path = await getDatabasesPath() + '/dummy_${DateTime.now().millisecondsSinceEpoch}.db';
          final dbWrite = await databaseFactory.openDatabase(path);
          await dbWrite.execute('CREATE TABLE t (id INTEGER)');
          await dbWrite.close();

          return await databaseFactory.openDatabase(path, options: OpenDatabaseOptions(readOnly: true));
        },
      );

      await manager.withDatabase('deu-101', (db) async {
         expect(() => db.execute('INSERT INTO t (id) VALUES (1)'), throwsException);
      });
  });
}
