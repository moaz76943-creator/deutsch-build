import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/pooled_database_manager.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('J008 LRU deterministic eviction', () async {
    final manager = PooledDatabaseManager(
      maxConnections: 2,
      openConnection: (code) async {
        return await databaseFactory.openDatabase(inMemoryDatabasePath, options: OpenDatabaseOptions(readOnly: true));
      },
    );

    await manager.open('deu-101');
    await manager.open('deu-102');

    // Now both are open.
    // If we open deu-101 again, it should become most recently used.
    await manager.open('deu-101');

    // Now if we open a new one (deu-103), it should evict deu-102, NOT deu-101!
    await manager.open('deu-103');

    expect(manager.leastToMostRecentlyUsed, ['deu-101', 'deu-103']); // Wait, LinkedHashMap keys should be deu-101, deu-103

    // Check which one was evicted by seeing what is active
    final openCodes = manager.leastToMostRecentlyUsed;
    expect(openCodes.contains('deu-102'), isFalse);
    expect(openCodes.contains('deu-101'), isTrue);
  });
}
