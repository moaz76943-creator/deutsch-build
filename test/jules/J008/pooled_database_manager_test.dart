import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/pooled_database_manager.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('PooledDatabaseManager', () {
    test('Can open and close database', () async {
      final manager = PooledDatabaseManager(
        maxConnections: 2,
        openConnection: (lang) async => await databaseFactory.openDatabase(inMemoryDatabasePath, options: OpenDatabaseOptions(singleInstance: false)),
      );
      final db = await manager.open('en');
      expect(db.isOpen, isTrue);
      expect(manager.activeCount, 1);
      await manager.close('en');
      expect(manager.activeCount, 0);
    });

    test('LRU eviction respects maxConnections', () async {
      final manager = PooledDatabaseManager(
        maxConnections: 2,
        openConnection: (lang) async => await databaseFactory.openDatabase(inMemoryDatabasePath, options: OpenDatabaseOptions(singleInstance: false)),
      );
      await manager.open('en');
      await manager.open('fr');
      expect(manager.activeCount, 2);
      await manager.open('es'); // Should evict 'en'
      expect(manager.activeCount, 2);
      expect(manager.leastToMostRecentlyUsed.contains('en'), isFalse);
    });

    test('Cannot evict pinned handle during withDatabase', () async {
      final manager = PooledDatabaseManager(
        maxConnections: 1,
        openConnection: (lang) async => await databaseFactory.openDatabase(inMemoryDatabasePath, options: OpenDatabaseOptions(singleInstance: false)),
      );
      await manager.withDatabase('en', (db) async {
        expect(() => manager.open('fr'), throwsA(isA<StateError>()));
      });
      expect(manager.activeCount, 1); // 'en' still open
    });

    test('Failed opening does not leak connection', () async {
      final manager = PooledDatabaseManager(
        maxConnections: 2,
        openConnection: (lang) async {
          if (lang == 'fa') throw Exception('Failed to open');
          return await databaseFactory.openDatabase(inMemoryDatabasePath, options: OpenDatabaseOptions(singleInstance: false));
        }
      );
      await expectLater(() => manager.open('fa'), throwsException);
      expect(manager.activeCount, 0);
    });

    test('Stress-test 100 concurrent identities', () async {
      final manager = PooledDatabaseManager(
        maxConnections: 4,
        openConnection: (lang) async {
          return await databaseFactory.openDatabase(inMemoryDatabasePath, options: OpenDatabaseOptions(singleInstance: false));
        }
      );
      final futures = <Future<void>>[];
      for (int i = 0; i < 100; i++) {
        final langId = 'la-${i.toString().padLeft(3, '0')}';
        futures.add(manager.withDatabase(langId, (db) async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          expect(db.isOpen, isTrue);
        }));
      }
      await Future.wait(futures);
      expect(manager.activeCount, lessThanOrEqualTo(4));
    });
  });
}
