import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import '../../../lib/services/pooled_database_manager.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('Aggressive stress test', () async {
    final manager = PooledDatabaseManager(
      openConnection: (String code) async {
        await Future.delayed(Duration(milliseconds: 2));
        return await databaseFactory.openDatabase('test_$code.db');
      },
      maxConnections: 3,
    );

    final futures = <Future<void>>[];
    int completed = 0;

    for (int i = 0; i < 200; i++) {
      final code = 'en-us0${i % 10}';
      futures.add(manager.withDatabase(code, (db) async {
        expect(db.isOpen, true);
        await Future.delayed(Duration(milliseconds: 5));
        completed++;
      }));
    }

    await Future.wait(futures);
    expect(completed, 200);
    expect(manager.activeCount, lessThanOrEqualTo(3));
  });
}
