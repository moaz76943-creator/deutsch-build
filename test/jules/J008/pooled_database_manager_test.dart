import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/pooled_database_manager.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('waiter chain is not broken on open failure', () async {
    bool shouldFail = false;

    final manager = PooledDatabaseManager(
      maxConnections: 1,
      openConnection: (code) async {
        if (shouldFail && code == 'fa-il') {
          throw Exception('Open failed');
        }
        final db = await databaseFactory.openDatabase('test_$code.db');
        return db;
      },
    );

    final completer1 = Completer<void>();
    unawaited(manager.withDatabase('en', (db) async {
      await completer1.future;
    }));

    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(manager.activeCount, 1);

    shouldFail = true;
    final future2 = manager.withDatabase('fa-il', (db) async {});
    final future3 = manager.withDatabase('fr', (db) async {
      return 'success';
    });

    await Future<void>.delayed(const Duration(milliseconds: 50));
    completer1.complete();

    await expectLater(future2, throwsException);

    final result = await future3.timeout(const Duration(milliseconds: 100), onTimeout: () => 'timeout');
    expect(result, 'success');
  });

  test('stress test 100 language identities', () async {
    final manager = PooledDatabaseManager(
      maxConnections: 3,
      openConnection: (code) async {
        return await databaseFactory.openDatabase('test_$code.db');
      },
    );

    final futures = <Future<void>>[];
    for (int i = 0; i < 100; i++) {
      final code = 'la-${i.toString().padLeft(2, '0')}';
      futures.add(manager.withDatabase(code, (db) async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }));
    }

    await Future.wait(futures);
    expect(manager.activeCount, lessThanOrEqualTo(3));
  });

  test('read-only packs remain read-only', () async {
    await databaseFactory.openDatabase('test_readonly_en-us.db').then((db) => db.close());

    final manager = PooledDatabaseManager(
      maxConnections: 2,
      openConnection: (code) async {
        return await databaseFactory.openDatabase(
          'test_readonly_$code.db',
          options: OpenDatabaseOptions(readOnly: true),
        );
      },
    );

    await manager.withDatabase('en-us', (db) async {
      await expectLater(
        () => db.execute('CREATE TABLE Test (id INTEGER PRIMARY KEY)'),
        throwsA(isA<DatabaseException>()),
      );
    });
  });
}
