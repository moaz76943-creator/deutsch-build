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

  test('J008 Handle failed opening, cancellation and leaked leases', () async {
    final manager = PooledDatabaseManager(
      openConnection: (String code) async {
        if (code == 'xx-fail') {
          throw Exception('Simulated open failure');
        }
        final file = File('test_fail_$code.db');
        return await databaseFactory.openDatabase(file.path);
      },
      maxConnections: 1,
    );

    // Open one successfully
    await manager.withDatabase('de-de', (db) async {
      expect(db.isOpen, true);
    });

    // Try opening one that fails while having max connections
    // This will evict de-de, and attempt to open fail. It fails.
    // The active connections should be 0.
    await expectLater(() => manager.open('xx-fail'), throwsException);
    expect(manager.activeCount, 0);

    // Try withDatabase when the first slot fails to open,
    // a subsequent wait queue caller should eventually be woken up and able to open their own.
    final futures = <Future<void>>[];

    // Occupy the single slot
    final f1 = manager.withDatabase('en-us', (db) async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });

    futures.add(f1);

    // This will queue up because maxConnections=1 and en-us is leased.
    // When en-us is released, this attempts to open but fails.
    final fFail = manager.withDatabase('xx-fail', (db) async {});

    // This will queue up behind fail. When fail fails, it should wake up this request,
    // which will then successfully open es-es.
    final f3 = manager.withDatabase('es-es', (db) async {
      expect(db.isOpen, true);
    });

    futures.add(f3);

    // Wait for the fail to complete with error
    await expectLater(fFail, throwsException);

    // Wait for the others to succeed
    await Future.wait(futures);

    expect(manager.activeCount, 1);

    await manager.closeAll();

    final files = ['test_fail_de-de.db', 'test_fail_en-us.db', 'test_fail_es-es.db'];
    for(final f in files) {
      if(File(f).existsSync()) {
        File(f).deleteSync();
      }
    }
  });
}
