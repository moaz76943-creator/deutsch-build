import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/pooled_database_manager.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('J008 handle failed opening, cancellation, leaked leases', () async {
    final manager = PooledDatabaseManager(
      maxConnections: 2,
      openConnection: (code) async {
        if (code == 'deu-bad') throw Exception('Bad pack');
        return await databaseFactory.openDatabase(inMemoryDatabasePath, options: OpenDatabaseOptions(readOnly: true));
      },
    );

    // Test failed opening
    await expectLater(() => manager.withDatabase('deu-bad', (db) async {}), throwsException);
    expect(manager.activeCount, 0);

    // Test cancellation (timeout)
    final f = manager.withDatabase('deu-101', (db) async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }).timeout(const Duration(milliseconds: 10), onTimeout: () => throw TimeoutException(''));

    await expectLater(() => f, throwsA(isA<TimeoutException>()));
    // wait a bit for the lease to supposedly return - but wait, timeout doesn't cancel the future inside `withDatabase`, it just cancels the outer future!
    await Future<void>.delayed(const Duration(milliseconds: 150));

    expect(manager.activeCount, 1);

    // Leases should be clean
    // The manager shouldn't have leaked a lease
    final f2 = manager.withDatabase('deu-102', (db) async {});
    final f3 = manager.withDatabase('deu-103', (db) async {});

    await Future.wait([f2, f3]);
    expect(manager.activeCount, 2);
  });
}
