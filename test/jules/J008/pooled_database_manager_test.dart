import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../lib/services/pooled_database_manager.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('J008 Stress-test 100 language identities', () async {
    final dir = Directory.systemTemp.createTempSync('j008_');
    int activeOpens = 0;
    int maxObservedOpens = 0;

    final manager = PooledDatabaseManager(
      maxConnections: 5,
      openConnection: (code) async {
        final path = p.join(dir.path, '$code.db');
        final db = await databaseFactory.openDatabase(
          path,
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) async {
              await db.execute('CREATE TABLE Test (id INTEGER PRIMARY KEY)');
            },
            readOnly: false, // For onCreate to work
          ),
        );
        activeOpens++;
        if (activeOpens > maxObservedOpens) maxObservedOpens = activeOpens;
        return db;
      },
      beforeClose: (db) async {
        activeOpens--;
      },
    );

    // Simulate 100 concurrent requests across many identities
    final results = await Future.wait(
      List.generate(200, (i) {
        final lang = 'en-US${i % 100}';
        return manager.withDatabase(lang, (db) async {
          await Future.delayed(const Duration(milliseconds: 2));
          return db.isOpen;
        });
      }),
    );

    expect(results.every((r) => r == true), isTrue);
    expect(maxObservedOpens, lessThanOrEqualTo(5));

    // Ensure all remaining can be closed
    await manager.closeAll();
    expect(activeOpens, 0);

    try {
        dir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('J008 Ensure pin cannot be evicted', () async {
    final dir = Directory.systemTemp.createTempSync('j008_pin_');
    final manager = PooledDatabaseManager(
      maxConnections: 2,
      openConnection: (code) async {
        final path = p.join(dir.path, '$code.db');
        return databaseFactory.openDatabase(path, options: OpenDatabaseOptions(version: 1, onCreate: (db, version) async => db.execute('CREATE TABLE T(id)')));
      }
    );

    bool pinOpened = false;
    bool otherCompleted = false;
    final pinTask = manager.withDatabase('en-us1', (db) async {
        pinOpened = true;
        await Future.delayed(const Duration(milliseconds: 100));
        expect(db.isOpen, isTrue); // Should not be evicted while pinned
    });

    while (!pinOpened) { await Future.delayed(const Duration(milliseconds: 1)); }

    // Saturated
    final t2 = manager.withDatabase('en-us2', (db) async {});
    final t3 = manager.withDatabase('en-us3', (db) async {
        otherCompleted = true;
    });

    await Future.wait([pinTask, t2, t3]);
    expect(otherCompleted, isTrue);

    try {
        dir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('J008 Repeated opening failures do not leak', () async {
    int opens = 0;
    final manager = PooledDatabaseManager(
      maxConnections: 2,
      openConnection: (code) async {
        opens++;
        if (opens <= 2) throw Exception('Fail');
        return databaseFactory.openDatabase(inMemoryDatabasePath);
      }
    );

    expect(() => manager.open('en-us1'), throwsException);
    expect(() => manager.open('en-us1'), throwsException);
    final db = await manager.open('en-us1');
    expect(db.isOpen, isTrue);
  });
}
