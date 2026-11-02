import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/pooled_database_manager.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('Stress-test 100 language identities', () async {
    final manager = PooledDatabaseManager(
      maxConnections: 3,
      openConnection: (String languageCode) async {
        await Future.delayed(const Duration(milliseconds: 2));
        return await databaseFactory.openDatabase(
          inMemoryDatabasePath,
          options: OpenDatabaseOptions(singleInstance: false),
        );
      },
    );

    final futures = <Future>[];
    int maxActive = 0;

    for (var i = 0; i < 100; i++) {
      futures.add(manager.withDatabase('de-lang$i', (db) async {
        if (manager.activeCount > maxActive) {
          maxActive = manager.activeCount;
        }
        expect(db.isOpen, isTrue);
        await Future.delayed(const Duration(milliseconds: 5));
        expect(db.isOpen, isTrue); // No leased handle closes prematurely
      }));
    }

    await Future.wait(futures);
    expect(maxActive, lessThanOrEqualTo(3));
    expect(manager.activeCount, lessThanOrEqualTo(3));
    await manager.closeAll();
  });

  test('Verify read-only packs remain read-only', () async {
    final manager = PooledDatabaseManager(
      maxConnections: 2,
      openConnection: (String languageCode) async {
        final file = File('test/jules/J008/readonly_$languageCode.db');
        if (file.existsSync()) {
          file.deleteSync();
        } else if (!file.parent.existsSync()) {
          file.parent.createSync(recursive: true);
        }

        final initDb = await databaseFactory.openDatabase(file.path);
        // Only create if not exists
        await initDb.execute('CREATE TABLE IF NOT EXISTS foo (id INTEGER)');
        await initDb.close();

        return await databaseFactory.openDatabase(
          file.path,
          options: OpenDatabaseOptions(readOnly: true),
        );
      },
    );

    await manager.withDatabase('de-read', (db) async {
      expect(db.isOpen, isTrue);
      // Attempting to write should throw
      await expectLater(
        () async => await db.execute('INSERT INTO foo (id) VALUES (1)'),
        throwsA(isA<DatabaseException>()),
      );
    });

    await manager.closeAll();

    final file = File('test/jules/J008/readonly_de-read.db');
    if (file.existsSync()) file.deleteSync();
  });

  test('Repeated opening failures do not leak connections', () async {
    int attempts = 0;
    final manager = PooledDatabaseManager(
      maxConnections: 2,
      openConnection: (String languageCode) async {
        attempts++;
        if (languageCode == 'de-fail') {
          throw Exception('Simulated failure');
        }
        return await databaseFactory.openDatabase(
          inMemoryDatabasePath,
          options: OpenDatabaseOptions(singleInstance: false),
        );
      },
    );

    for (var i = 0; i < 5; i++) {
      await expectLater(
        () => manager.withDatabase('de-fail', (db) async {}),
        throwsException,
      );
    }

    expect(attempts, 5);
    expect(manager.activeCount, 0);

    await manager.withDatabase('de-good', (db) async {
      expect(db.isOpen, isTrue);
    });

    expect(manager.activeCount, 1);
    await manager.closeAll();
  });
}
