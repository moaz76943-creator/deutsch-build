import 'package:deutsch_bilarabi/services/pooled_database_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('J008 Stress-test 100 language identities', () async {
    int maxConnectionsConfigured = 5;
    final manager = PooledDatabaseManager(
      openConnection: (String code) async {
        final file = File('stress_test_$code.db');
        return await databaseFactory.openDatabase(file.path);
      },
      maxConnections: maxConnectionsConfigured,
    );

    // Test with 100 identities
    List<String> identities = [];
    for (int i = 0; i < 100; i++) {
      identities.add('de-${i.toString().padLeft(3, '0')}');
    }

    final futures = <Future<void>>[];
    for (int i = 0; i < 200; i++) {
      final id = identities[i % 100];
      futures.add(manager.withDatabase(id, (db) async {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        expect(db.isOpen, true);
        // Simulate reading
        await db.execute('CREATE TABLE IF NOT EXISTS test (id INTEGER)');
      }));
    }

    await Future.wait(futures);
    expect(manager.activeCount, lessThanOrEqualTo(maxConnectionsConfigured));

    await manager.closeAll();

    // cleanup
    for(final id in identities) {
      if(File('stress_test_$id.db').existsSync()) {
        File('stress_test_$id.db').deleteSync();
      }
    }
  });
}
