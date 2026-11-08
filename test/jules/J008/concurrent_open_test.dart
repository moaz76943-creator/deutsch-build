import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/pooled_database_manager.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('J008 stress test concurrent opens without duplicate connections to same shard', () async {
    int openCalls = 0;
    final manager = PooledDatabaseManager(
      maxConnections: 10,
      openConnection: (code) async {
        openCalls++;
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return await databaseFactory.openDatabase(inMemoryDatabasePath, options: OpenDatabaseOptions(readOnly: true));
      },
    );

    // Call open for the same code many times concurrently
    final futures = <Future>[];
    for (int i = 0; i < 20; i++) {
      futures.add(manager.open('deu-101'));
    }

    await Future.wait(futures);
    expect(openCalls, 1);
  });
}
