import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/pooled_database_manager.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('J008: Stress test 100 language identities', () async {
    int openCalls = 0;
    final tempDir = Directory.systemTemp.createTempSync();

    final pool = PooledDatabaseManager(
      maxConnections: 4,
      openConnection: (code) async {
        openCalls++;
        // Use a unique database per language code to avoid sharing identical paths
        final db = await databaseFactory.openDatabase('${tempDir.path}/$code.db');
        return db;
      },
    );

    final futures = <Future>[];
    for (int i = 0; i < 100; i++) {
      final code = 'en-${i.toString().padLeft(2, '0')}';
      futures.add(pool.withDatabase(code, (db) async {
        await Future.delayed(const Duration(milliseconds: 10));
        expect(db.isOpen, true);
      }));
    }

    await Future.wait(futures);
    expect(pool.activeCount, lessThanOrEqualTo(4));
    expect(openCalls, 100);

    // Clean up
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });
}
