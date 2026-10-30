import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../lib/services/pooled_database_manager.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('PooledDatabaseManager J008', () {
    late int openedConnections;
    late int closedConnections;
    late Map<String, Database> mockDatabases;

    setUp(() {
      openedConnections = 0;
      closedConnections = 0;
      mockDatabases = {};
    });

    Future<Database> mockOpener(String code) async {
      openedConnections++;
      final db = await databaseFactory.openDatabase(inMemoryDatabasePath);
      mockDatabases[code] = db;
      return db;
    }

    Future<void> mockCloser(Database db) async {
      closedConnections++;
    }

    test('Stress test 100 language identities with a small active-connection budget (maxConnections = 3) and concurrent query leases', () async {
      final pool = PooledDatabaseManager(
        openConnection: mockOpener,
        beforeClose: mockCloser,
        maxConnections: 3,
      );

      final futures = <Future<void>>[];

      // We will loop 100 times to simulate many different language identities
      for (int i = 0; i < 100; i++) {
        final lang = 'eng-${i.toString().padLeft(2, '0')}';
        futures.add(Future(() async {
          // Add a random slight delay to induce concurrency variations
          await Future.delayed(Duration(milliseconds: (i % 5)));

          await pool.withDatabase(lang, (db) async {
            expect(db.isOpen, isTrue);
            // Simulate work
            await Future.delayed(Duration(milliseconds: 2));
          });
        }));
      }

      await Future.wait(futures);

      expect(pool.activeCount, lessThanOrEqualTo(3));
      await pool.closeAll();
    });

    test('Verify that eviction strictly follows Least-Recently-Used order based on when the handle was last requested or leased', () async {
      final pool = PooledDatabaseManager(
        openConnection: mockOpener,
        maxConnections: 2,
      );

      // Open a and b
      await pool.open('eng-aa');
      await pool.open('eng-bb');
      expect(pool.leastToMostRecentlyUsed, ['eng-aa', 'eng-bb']);

      // Access a, moves to most recently used
      await pool.open('eng-aa');
      expect(pool.leastToMostRecentlyUsed, ['eng-bb', 'eng-aa']);

      // Open c, should evict b (least recently used)
      await pool.open('eng-cc');
      expect(pool.leastToMostRecentlyUsed, ['eng-aa', 'eng-cc']);

      await pool.closeAll();
    });

    test('Ensure handles currently in use (leased) are never evicted', () async {
      final pool = PooledDatabaseManager(
        openConnection: mockOpener,
        maxConnections: 2,
      );

      final completer1 = Completer<void>();
      final completer2 = Completer<void>();

      // Pin 'a'
      final futureA = pool.withDatabase('eng-aa', (db) async {
        await completer1.future;
      });

      // Pin 'b'
      final futureB = pool.withDatabase('eng-bb', (db) async {
        await completer2.future;
      });

      // Give them a moment to open and lease
      await Future.delayed(const Duration(milliseconds: 50));

      expect(pool.activeCount, 2);

      // Try to open 'c'. This should queue since pool is full and everything is leased.
      bool cOpened = false;
      final futureC = pool.open('eng-cc').then((_) {
        cOpened = true;
      });

      await Future.delayed(const Duration(milliseconds: 50));
      expect(cOpened, isFalse); // 'c' should still be waiting
      expect(pool.leastToMostRecentlyUsed.contains('eng-cc'), isFalse); // 'c' is not in pool yet

      // Finish 'a'
      completer1.complete();
      await futureA;

      // Now 'c' should be able to open, evicting 'a'
      await futureC;
      expect(cOpened, isTrue);
      expect(pool.leastToMostRecentlyUsed, ['eng-bb', 'eng-cc']);

      completer2.complete();
      await futureB;

      await pool.closeAll();
    });

    test('Verify that failures during opening properly notify capacity and reject the specific promise', () async {
      var failNext = false;
      final pool = PooledDatabaseManager(
        openConnection: (code) async {
          if (failNext) throw Exception('Simulated failure');
          return mockOpener(code);
        },
        maxConnections: 1,
      );

      // Open 'a', leasing it
      final completerA = Completer<void>();
      final futureA = pool.withDatabase('eng-aa', (db) async {
        await completerA.future;
      });

      await Future.delayed(const Duration(milliseconds: 10));

      // Queue 'b' which will fail
      failNext = true;
      final futureB = pool.open('eng-bb');

      // Queue 'c' which will succeed
      failNext = false;
      final futureC = pool.open('eng-cc');

      // Finish 'a'
      completerA.complete();
      await futureA;

      // 'b' should fail
      try {
        await futureB;
        fail('futureB should have thrown');
      } catch (e) {
        if (e is TestFailure) rethrow; // Ensure fail() throws up
        expect(e, isA<Exception>());
        expect(e.toString(), contains('Simulated failure'));
      }

      // 'c' should still succeed because 'b' failing should notify capacity
      await futureC;
      expect(pool.leastToMostRecentlyUsed, ['eng-cc']);

      await pool.closeAll();
    });
  });
}
