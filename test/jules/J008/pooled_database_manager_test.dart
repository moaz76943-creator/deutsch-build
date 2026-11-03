import 'dart:async';
import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/services/pooled_database_manager.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    tempDir = Directory.systemTemp.createTempSync('j008_test_');
  });

  tearDownAll(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Future<Database> openDummyDb(String code) async {
    final path = '${tempDir.path}/$code.db';
    // Create an empty database file to simulate read-only pack loading,
    // or just open and return a standard in-memory / temporary DB instance.
    return databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('CREATE TABLE dummy (id INTEGER PRIMARY KEY)');
        },
      ),
    );
  }

  test('LRU eviction maintains active count', () async {
    final manager = PooledDatabaseManager(
      openConnection: openDummyDb,
      maxConnections: 4,
    );

    for (int i = 10; i < 20; i++) {
      final code = 'en-$i';
      await manager.open(code);
      // Wait slightly to ensure asynchronous tasks settle
      await Future<void>.delayed(Duration.zero);
      expect(manager.activeCount, lessThanOrEqualTo(4));
    }

    expect(manager.activeCount, 4);
    await manager.closeAll();
  });

  test('Pinned handle is not evicted', () async {
    final manager = PooledDatabaseManager(
      openConnection: openDummyDb,
      maxConnections: 4,
    );

    final completer = Completer<void>();
    final withDbFuture = manager.withDatabase('en-11', (db) async {
      await completer.future;
      return true;
    });

    // Let en-11 open
    await Future<void>.delayed(const Duration(milliseconds: 50));

    // Open 3 other DBs.
    // Together with en-11, this reaches the maxConnections of 4.
    await manager.open('en-12');
    await manager.open('en-13');
    await manager.open('en-14');

    // The next one tries to evict.
    // However, it will successfully evict en-12, en-13, or en-14 (since they are unleased)
    // before throwing _PoolSaturated. We need to lease them too!

    final c12 = Completer<void>();
    final c13 = Completer<void>();
    final c14 = Completer<void>();

    manager.withDatabase('en-12', (db) async { await c12.future; });
    manager.withDatabase('en-13', (db) async { await c13.future; });
    manager.withDatabase('en-14', (db) async { await c14.future; });

    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(
      () => manager.open('en-15'),
      throwsA(isA<StateError>().having((e) => e.message, 'message',
          'All pooled content databases are in use')),
    );

    c12.complete();
    c13.complete();
    c14.complete();

    expect(manager.activeCount, 4);

    // Release the lease
    completer.complete();
    final result = await withDbFuture;
    expect(result, isTrue);

    await manager.closeAll();
  });

  test('Failed opening does not leak or deadlock', () async {
    int openAttempts = 0;
    final manager = PooledDatabaseManager(
      openConnection: (code) async {
        openAttempts++;
        if (code == 'en-fail') {
          throw Exception('Simulated open failure');
        }
        return openDummyDb(code);
      },
      maxConnections: 1, // Restrict to 1 so the queue gets utilized
    );

    // This one occupies the only slot
    final completer = Completer<void>();
    final task1 = manager.withDatabase('en-ok1', (db) async {
      await completer.future;
    });

    // Let ok-1 begin opening
    await Future<void>.delayed(const Duration(milliseconds: 50));

    // Try opening fail-1; since ok-1 is open, it gets queued as a slotWaiter in withDatabase.
    final task2 = manager.withDatabase('en-fail', (db) async {}).catchError((e) {
      // Ignore
    });

    // Also try opening ok-2, which will also be queued
    final task3 = manager.withDatabase('en-ok2', (db) async {});

    // Allow queues to be set up
    await Future<void>.delayed(const Duration(milliseconds: 50));

    // Complete ok-1 to free up the slot.
    completer.complete();
    await task1;

    // en-fail will attempt to open and throw. The queue should be notified again.
    // So en-ok2 should then successfully proceed and complete.
    await task3;
    expect(openAttempts, 3);

    await manager.closeAll();
  });

  test('Stress-test 100 language identities', () async {
    final manager = PooledDatabaseManager(
      openConnection: openDummyDb,
      maxConnections: 4,
    );

    final identities = List.generate(100, (i) => 'en-${i + 100}');

    // Concurrently request 100 databases.
    // They should wait in line nicely, adhering to maxConnections.
    final futures = identities.map((code) {
      return manager.withDatabase(code, (db) async {
        expect(db.isOpen, isTrue);
        // Ensure max size is never exceeded
        expect(manager.activeCount, lessThanOrEqualTo(4));
        // Add random small delay to make scheduling non-deterministic
        await Future<void>.delayed(Duration(milliseconds: code.hashCode % 5));
      });
    });

    await Future.wait(futures);

    // After all is done, count should be at most 4.
    expect(manager.activeCount, lessThanOrEqualTo(4));

    await manager.closeAll();
  });
}
