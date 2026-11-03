import 'dart:async';

import 'package:deutsch_bilarabi/services/pooled_database_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  Future<Database> openDummyDb(String code) => databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );

  test('failed opener does not strand the next waiting language', () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    final attempted = <String>[];
    final manager = PooledDatabaseManager(
      maxConnections: 1,
      openConnection: (code) async {
        attempted.add(code);
        if (code == 'en-fail') throw StateError('broken pack');
        return openDummyDb(code);
      },
    );
    final held = manager.withDatabase('de', (db) async {
      entered.complete();
      await release.future;
      expect(db.isOpen, isTrue);
    });
    await entered.future.timeout(const Duration(seconds: 3));
    final failed = expectLater(
      manager.withDatabase('en-fail', (_) async {}),
      throwsA(
          isA<StateError>().having((e) => e.message, 'message', 'broken pack')),
    );
    final next = manager.withDatabase('fr', (db) async {
      expect(db.isOpen, isTrue);
    });
    // A cache hit passes through the same mutex after both waiter registrations.
    await manager.open('de');
    release.complete();
    try {
      await Future.wait([held, failed, next])
          .timeout(const Duration(seconds: 3));
      expect(attempted, ['de', 'en-fail', 'fr']);
      expect(manager.activeCount, 1);
    } finally {
      await manager.closeAll();
    }
  });

  test('waiters for the same language share the newly available handle',
      () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    final shared = Completer<void>();
    final manager = PooledDatabaseManager(
      maxConnections: 1,
      openConnection: openDummyDb,
    );
    final held = manager.withDatabase('de', (_) async {
      entered.complete();
      await release.future;
    });
    await entered.future.timeout(const Duration(seconds: 3));
    Database? firstHandle;
    final first = manager.withDatabase('fr', (db) async {
      firstHandle = db;
      await shared.future;
      expect(db.isOpen, isTrue);
    });
    final second = manager.withDatabase('fr', (db) async {
      expect(db, same(firstHandle));
      expect(manager.activeCount, 1);
      shared.complete();
    });
    await manager.open('de');
    release.complete();
    try {
      await Future.wait([held, first, second])
          .timeout(const Duration(seconds: 3));
    } finally {
      if (!shared.isCompleted) shared.complete();
      await Future.wait([held, first, second]);
      await manager.closeAll();
    }
  });

  test('100 language identities never exceed four live handles', () async {
    final handles = <Database>[];
    final manager = PooledDatabaseManager(
      maxConnections: 4,
      openConnection: (code) async {
        final db = await openDummyDb(code);
        handles.add(db);
        expect(handles.where((handle) => handle.isOpen).length,
            lessThanOrEqualTo(4));
        return db;
      },
    );
    try {
      await Future.wait(List.generate(100, (i) {
        final code = 'en-${i.toString().padLeft(3, '0')}';
        return manager.withDatabase(code, (db) async {
          await Future<void>.delayed(Duration.zero);
          expect(db.isOpen, isTrue);
        });
      })).timeout(const Duration(seconds: 10));
      expect(handles, hasLength(100));
      expect(manager.activeCount, lessThanOrEqualTo(4));
    } finally {
      await manager.closeAll();
    }
    expect(handles.every((handle) => !handle.isOpen), isTrue);
  });
}
