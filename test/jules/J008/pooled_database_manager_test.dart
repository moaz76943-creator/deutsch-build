import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/pooled_database_manager.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  // Language code requires 2 or 3 lowercase letters optionally followed by -xxx parts.
  // E.g. 'en', 'en-1', 'en-fail'
  test('Stress test 100 language identities with a small connection pool budget', () async {
    int openCalls = 0;

    // Simulate database opener that creates read-only in-memory db.
    final manager = PooledDatabaseManager(
      maxConnections: 3,
      openConnection: (code) async {
        openCalls++;
        // Use a unique URI for in-memory database per language code
        // We use mode=memory&cache=shared so we can return a valid Database object.
        final db = await databaseFactory.openDatabase(
          inMemoryDatabasePath,
          options: OpenDatabaseOptions(
            readOnly: true,
          ),
        );
        return db;
      },
    );

    // Concurrently try to lease a large number of identities
    final languages = List.generate(100, (i) => 'en-0$i'); // Using valid language code pattern

    // We expect the peak connection count (manager.activeCount) to never exceed 3.
    // We also expect leases to block and resolve successfully.
    int maxObservedConnections = 0;
    final List<Future<void>> futures = [];

    int completedLeases = 0;

    for (final code in languages) {
      futures.add(manager.withDatabase(code, (db) async {
        // Record max observed active count
        if (manager.activeCount > maxObservedConnections) {
          maxObservedConnections = manager.activeCount;
        }

        expect(db.isOpen, isTrue);

        // Hold the lease for a tiny bit to simulate work
        await Future.delayed(const Duration(milliseconds: 2));
        completedLeases++;
      }));
    }

    await Future.wait(futures);

    expect(completedLeases, 100, reason: 'All 100 leases should complete successfully');
    expect(maxObservedConnections, lessThanOrEqualTo(3), reason: 'Should not exceed maxConnections budget');
    expect(manager.activeCount, lessThanOrEqualTo(3), reason: 'Final count should not exceed budget');

    // Cleanup
    await manager.closeUnleased();
    expect(manager.activeCount, 0);
  });

  test('Cannot close leased handle', () async {
    final manager = PooledDatabaseManager(
      maxConnections: 2,
      openConnection: (code) async => await databaseFactory.openDatabase(inMemoryDatabasePath, options: OpenDatabaseOptions(readOnly: true)),
    );

    await manager.withDatabase('en-lease', (db) async {
      bool threw = false;
      try {
        await manager.close('en-lease');
      } catch (e) {
        threw = true;
        expect(e, isStateError);
      }
      expect(threw, isTrue);

      threw = false;
      try {
        await manager.closeAll();
      } catch (e) {
        threw = true;
        expect(e, isStateError);
      }
      expect(threw, isTrue);
    });

    await manager.closeAll();
  });

  test('LRU eviction works correctly', () async {
    final manager = PooledDatabaseManager(
      maxConnections: 3,
      openConnection: (code) async => await databaseFactory.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(readOnly: true),
      ),
    );

    await manager.open('en-11');
    await manager.open('en-22');

    // Use open instead of withDatabase to easily check just the LRU aspect since it doesn't hold leases.
    expect(manager.leastToMostRecentlyUsed, ['en-11', 'en-22']);

    // Opening en-11 should move it to most recently used
    await manager.open('en-11');
    expect(manager.leastToMostRecentlyUsed, ['en-22', 'en-11']);

    // Opening en-33 should not evict yet since maxConnections is 3
    await manager.open('en-33');
    expect(manager.leastToMostRecentlyUsed, ['en-22', 'en-11', 'en-33']);

    // Opening en-44 should evict en-22
    await manager.open('en-44');
    expect(manager.leastToMostRecentlyUsed, ['en-11', 'en-33', 'en-44']);

    await manager.closeAll();
  });

  test('Duplicate simultaneous opens resolve to same handle', () async {
    int openCalls = 0;
    final manager = PooledDatabaseManager(
      maxConnections: 2,
      openConnection: (code) async {
        openCalls++;
        await Future.delayed(const Duration(milliseconds: 10));
        return await databaseFactory.openDatabase(inMemoryDatabasePath, options: OpenDatabaseOptions(readOnly: true));
      },
    );

    final db1Future = manager.open('en-dup');
    final db2Future = manager.open('en-dup');

    final db1 = await db1Future;
    final db2 = await db2Future;

    expect(identical(db1, db2), isTrue);
    expect(openCalls, 1, reason: 'Only one actual database open should occur');

    await manager.closeAll();
  });
}
