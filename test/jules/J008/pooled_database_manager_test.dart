import 'package:deutsch_bilarabi/services/pooled_database_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('J008 Bounded SQLite Connection Pool & Safe LRU', () async {
    final manager = PooledDatabaseManager(
      openConnection: (String code) async {
        // Use a unique file for each db to test physical close
        final file = File('test_$code.db');
        return await databaseFactory.openDatabase(file.path);
      },
      maxConnections: 2,
    );

    // Initial state
    expect(manager.activeCount, 0);

    // Open first connection
    final db1 = await manager.open('de-de');
    expect(manager.activeCount, 1);
    expect(manager.leastToMostRecentlyUsed, ['de-de']);

    // Open second connection
    final db2 = await manager.open('en-us');
    expect(manager.activeCount, 2);
    expect(manager.leastToMostRecentlyUsed, ['de-de', 'en-us']);

    // Open third connection, should evict the first
    final db3 = await manager.open('fr-fr');
    expect(manager.activeCount, 2);
    expect(manager.leastToMostRecentlyUsed, ['en-us', 'fr-fr']);
    expect(db1.isOpen, false);
    expect(db2.isOpen, true);
    expect(db3.isOpen, true);

    // Leased connections are not evicted
    final futures = <Future<void>>[];
    futures.add(manager.withDatabase('es-es', (db) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(db.isOpen, true);
    }));
    futures.add(manager.withDatabase('it-it', (db) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(db.isOpen, true);
    }));

    await Future.wait(futures);
    expect(manager.activeCount, 2);

    // Try to open a connection while all are leased should wait.
    final f = manager.withDatabase('pt-br', (db) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(db.isOpen, true);
    });

    final f2 = manager.withDatabase('nl-nl', (db) async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(db.isOpen, true);
    });

    expect(() => manager.open('ja-jp'), throwsStateError);

    await Future.wait([f, f2]);

    await manager.closeAll();

    // cleanup
    final files = ['de-de', 'en-us', 'fr-fr', 'es-es', 'it-it', 'pt-br', 'nl-nl', 'ja-jp'];
    for(final f in files) {
      if(File('test_$f.db').existsSync()) {
        File('test_$f.db').deleteSync();
      }
    }
  });

  test('J008 Verify read-only packs remain read-only', () async {
    final file = File('test_readonly.db');
    if (file.existsSync()) file.deleteSync();

    // Create and close to have a db file
    final initDb = await databaseFactory.openDatabase(file.path);
    await initDb.execute('CREATE TABLE IF NOT EXISTS test (id INTEGER)');
    await initDb.close();

    final manager = PooledDatabaseManager(
      openConnection: (String code) async {
        return await databaseFactory.openDatabase(file.path, options: OpenDatabaseOptions(readOnly: true));
      },
      maxConnections: 2,
    );

    final db = await manager.open('ro-db');
    expect(db.isOpen, true);

    // Try to write to it, should fail
    await expectLater(
      () => db.execute('INSERT INTO test (id) VALUES (1)'),
      throwsA(isA<DatabaseException>())
    );

    await manager.closeAll();
    if (file.existsSync()) file.deleteSync();
  });
}
