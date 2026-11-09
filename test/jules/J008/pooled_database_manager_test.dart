import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../lib/services/pooled_database_manager.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('simple open and close', () async {
    int openCalls = 0;
    final pool = PooledDatabaseManager(
      openConnection: (String code) async {
        openCalls++;
        return await databaseFactory.openDatabase('test_$code.db');
      },
      maxConnections: 2,
    );

    final db1 = await pool.open('en');
    expect(db1.isOpen, isTrue);
    expect(pool.activeCount, 1);

    final db2 = await pool.open('es');
    expect(pool.activeCount, 2);

    final db3 = await pool.open('fr'); // Should evict 'en'
    expect(pool.activeCount, 2);
    expect(db1.isOpen, isFalse);
    expect(db3.isOpen, isTrue);
    expect(openCalls, 3);
  });
}
