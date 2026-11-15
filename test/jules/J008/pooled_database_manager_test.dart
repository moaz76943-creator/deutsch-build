import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/pooled_database_manager.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('PooledDatabaseManager Tests', () {
    test('Evicts least recently used connections', () async {
      final manager = PooledDatabaseManager(
        maxConnections: 2,
        openConnection: (code) async {
          return await databaseFactory.openDatabase(inMemoryDatabasePath);
        }
      );

      await manager.open('deu-101');
      await manager.open('deu-102');

      expect(manager.activeCount, 2);
      expect(manager.leastToMostRecentlyUsed, ['deu-101', 'deu-102']);

      await manager.open('deu-103'); // Should evict deu-101

      expect(manager.activeCount, 2);
      expect(manager.leastToMostRecentlyUsed, ['deu-102', 'deu-103']);

      // Now re-open deu-102, which should move it to most recently used
      await manager.open('deu-102');
      expect(manager.leastToMostRecentlyUsed, ['deu-103', 'deu-102']);
    });

    test('Stress test: 100 language identities', () async {
      final openedDbs = <String>[];
      final manager = PooledDatabaseManager(
        maxConnections: 4,
        openConnection: (code) async {
          openedDbs.add(code);
          return await databaseFactory.openDatabase(inMemoryDatabasePath);
        },
      );

      final futures = <Future>[];
      for (int i = 0; i < 100; i++) {
        final code = 'deu-1${i.toString().padLeft(2, '0')}';
        futures.add(manager.withDatabase(code, (db) async {
          await Future<void>.delayed(const Duration(milliseconds: 2));
        }));
      }

      await Future.wait(futures);
      expect(manager.activeCount, lessThanOrEqualTo(4));
    });

    test('Prevent simultaneous duplicate connections to one shard', () async {
      int openCalls = 0;
      final manager = PooledDatabaseManager(
        maxConnections: 4,
        openConnection: (code) async {
          openCalls++;
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return await databaseFactory.openDatabase(inMemoryDatabasePath);
        },
      );

      // Open same code concurrently
      final f1 = manager.withDatabase('deu-101', (db) async {});
      final f2 = manager.withDatabase('deu-101', (db) async {});

      await Future.wait([f1, f2]);

      expect(openCalls, 1, reason: 'Should only open the database once');
    });

    test('Failure in open does not leak connection', () async {
      int openCalls = 0;
      final manager = PooledDatabaseManager(
        maxConnections: 4,
        openConnection: (code) async {
          openCalls++;
          if (code == 'deu-err') {
            throw Exception('Failed to open');
          }
          return await databaseFactory.openDatabase(inMemoryDatabasePath);
        },
      );

      await expectLater(
        manager.withDatabase('deu-err', (db) async {}),
        throwsException,
      );

      expect(manager.activeCount, 0);

      // Try again
      await expectLater(
        manager.withDatabase('deu-err', (db) async {}),
        throwsException,
      );

      expect(openCalls, 2); // Should attempt to open again
      expect(manager.activeCount, 0);
    });

  });
}
