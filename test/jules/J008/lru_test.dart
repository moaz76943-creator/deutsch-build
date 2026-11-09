import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../lib/services/pooled_database_manager.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('deterministic LRU eviction', () async {
    final pool = PooledDatabaseManager(
      openConnection: (String code) async {
        return await databaseFactory.openDatabase('test_$code.db');
      },
      maxConnections: 3,
    );

    // Open 3 connections
    await pool.open('en-us01');
    await pool.open('en-us02');
    await pool.open('en-us03');

    expect(pool.leastToMostRecentlyUsed, ['en-us01', 'en-us02', 'en-us03']);

    // Access en-us01 again to move it to MRU
    await pool.open('en-us01');

    // Note: the current implementation does NOT move the accessed element to the end of the map.
    // _tryOpenLocked does:
    // final existing = _connections.remove(code);
    // if (existing != null && existing.isOpen) {
    //   _connections[code] = existing;
    //   return existing;
    // }

    expect(pool.leastToMostRecentlyUsed, ['en-us02', 'en-us03', 'en-us01']);

    // Open a 4th, it should evict the LRU which is now en-us02
    await pool.open('en-us04');
    expect(pool.leastToMostRecentlyUsed, ['en-us03', 'en-us01', 'en-us04']);
  });
}
