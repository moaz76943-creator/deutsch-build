import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../lib/services/pooled_database_manager.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('debug', () async {
    final pool = PooledDatabaseManager(
      openConnection: (String code) async {
        return await databaseFactory.openDatabase('test_$code.db');
      },
      maxConnections: 2,
    );

    final db1 = await pool.open('en');
    print('db1 open: ${db1.isOpen}');

    final db2 = await pool.open('es');
    print('db2 open: ${db2.isOpen}');

    final db3 = await pool.open('fr'); // Should evict 'en'
    print('db3 open: ${db3.isOpen}');
    print('db1 open after fr: ${db1.isOpen}');
    print('pool active count: ${pool.activeCount}');
  });
}
