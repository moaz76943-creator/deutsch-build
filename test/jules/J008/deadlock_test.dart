import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/pooled_database_manager.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('J008 waiter deadlock on failed open', () async {
    int openCalls = 0;
    final manager = PooledDatabaseManager(
      maxConnections: 1, // Only 1 connection allowed!
      openConnection: (code) async {
        openCalls++;
        if (code == 'deu-bad') throw Exception('Bad pack');
        return await databaseFactory.openDatabase(inMemoryDatabasePath, options: OpenDatabaseOptions(readOnly: true));
      },
    );

    // 1. Lease the only connection
    final lease1 = Completer<void>();
    final f1 = manager.withDatabase('deu-101', (db) async {
      await lease1.future;
    });

    // 2. Wait a bit for f1 to acquire the lease
    await Future<void>.delayed(const Duration(milliseconds: 10));

    // 3. Request a bad connection, which will queue a waiter
    final f2 = manager.withDatabase('deu-bad', (db) async {});

    // 4. Request a good connection, which will queue another waiter
    final f3 = manager.withDatabase('deu-102', (db) async {});

    await Future<void>.delayed(const Duration(milliseconds: 10));

    // 5. Release the first connection
    lease1.complete();

    // 6. f2 should fail
    await expectLater(f2, throwsException);

    // 7. But wait, f3 should succeed because f2 failed, so f2 should wake up the next waiter!
    // But currently it doesn't! So f3 will deadlock!

    // Add a timeout to f3 so we can detect the deadlock
    await expectLater(f3.timeout(const Duration(milliseconds: 50)), completes);
  });
}
