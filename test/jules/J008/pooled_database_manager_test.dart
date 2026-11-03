import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../lib/services/pooled_database_manager.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('J008: Stress-test 100 language identities', () async {
    int openCalls = 0;
    int closeCalls = 0;

    final manager = PooledDatabaseManager(
      maxConnections: 5,
      openConnection: (code) async {
        openCalls++;
        // Use in-memory database
        return await databaseFactory.openDatabase(inMemoryDatabasePath,
            options: OpenDatabaseOptions(singleInstance: false));
      },
      beforeClose: (db) async {
        closeCalls++;
      },
    );

    final futures = <Future<void>>[];
    for (int i = 0; i < 100; i++) {
      futures.add(Future.microtask(() async {
        final code = i < 10 ? 'en-0$i' : 'en-$i';
        await manager.withDatabase(code, (db) async {
          expect(db.isOpen, true);
          await Future.delayed(const Duration(milliseconds: 5));
        });
      }));
    }

    await Future.wait(futures);

    expect(manager.activeCount, lessThanOrEqualTo(5));
    expect(openCalls, 100);
    expect(closeCalls, greaterThanOrEqualTo(95));
  });

  test('J008: Failed opening does not leak', () async {
    int attempts = 0;
    final manager = PooledDatabaseManager(
      maxConnections: 2,
      openConnection: (code) async {
        attempts++;
        if (code == 'en-fail') {
          throw Exception('Open failed');
        }
        return await databaseFactory.openDatabase(inMemoryDatabasePath,
            options: OpenDatabaseOptions(singleInstance: false));
      },
    );

    await manager.withDatabase('en-ok1', (db) async {});
    await manager.withDatabase('en-ok2', (db) async {});

    // Pool is full but idle. 'en-fail' will evict one and then fail.
    await expectLater(manager.withDatabase('en-fail', (db) async {}), throwsException);

    // Pool should now have 1 free slot!
    expect(manager.activeCount, 1);

    // Should be able to open en-ok3 without eviction because slot is free
    await manager.withDatabase('en-ok3', (db) async {});
    expect(manager.activeCount, 2);
  });

  test('J008: Failed opening deadlocks waiters', () async {
    final manager = PooledDatabaseManager(
      maxConnections: 1,
      openConnection: (code) async {
        if (code == 'en-fail') throw Exception('Fail');
        return await databaseFactory.openDatabase(inMemoryDatabasePath,
            options: OpenDatabaseOptions(singleInstance: false));
      }
    );

    // Fill the pool
    await manager.withDatabase('en-ok1', (db) async {});

    // Now pool has 1 idle connection ('en-ok1').
    final completer = Completer<void>();
    final t1 = manager.withDatabase('en-ok1', (db) async {
        await completer.future;
    });

    // t2 will go to _slotWaiters
    final t2 = manager.withDatabase('en-fail', (db) async {});

    // t3 will go to _slotWaiters
    final t3 = manager.withDatabase('en-ok2', (db) async {});

    completer.complete();

    await expectLater(t2, throwsException);

    // t3 should complete
    bool t3Completed = false;
    t3.then((_) => t3Completed = true);

    await Future.delayed(const Duration(milliseconds: 50));

    expect(t3Completed, true, reason: 't3 should have completed, but it deadlocked!');
  });
}
