import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import '../../../lib/services/pooled_database_manager.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('stress test 100 language identities', () async {
    final opened = <String>[];
    final manager = PooledDatabaseManager(
      maxConnections: 5,
      openConnection: (code) async {
        openCalls++;
        final db = await databaseFactory.openDatabase(
          inMemoryDatabasePath,
          options: OpenDatabaseOptions(singleInstance: false),
        );
        return db;
      },
    );

    final futures = <Future>[];
    for (int i = 0; i < 100; i++) {
      final code = 'en-${i.toString().padLeft(3, '0')}';
      futures.add(manager.withDatabase(code, (db) async {
        await Future.delayed(Duration(milliseconds: 10));
        return db.isOpen;
      }));
    }

    await Future.wait(futures);
    expect(manager.activeCount, lessThanOrEqualTo(5));
  });
}
