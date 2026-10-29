import 'dart:async';
import 'dart:io';

import 'package:deutsch_bilarabi/services/sqlite_maintenance_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

class _FakeDatabase extends Fake implements Database {
  _FakeDatabase(this.path);
  @override
  final String path;
  @override
  bool get isOpen => true;
  final sql = <String>[];
  List<Map<String, Object?>> checkpoint = <Map<String, Object?>>[
    <String, Object?>{'busy': 0, 'log': 0, 'checkpointed': 0},
  ];
  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String query, [List<Object?>? arguments],
  ) async {
    sql.add(query);
    if (query.startsWith('PRAGMA wal_checkpoint')) return checkpoint;
    if (query == 'PRAGMA auto_vacuum') {
      return <Map<String, Object?>>[<String, Object?>{'auto_vacuum': 2}];
    }
    if (query == 'PRAGMA freelist_count') {
      return <Map<String, Object?>>[<String, Object?>{'freelist_count': 600}];
    }
    return <Map<String, Object?>>[];
  }
  @override
  Future<void> execute(String query, [List<Object?>? arguments]) async {
    sql.add(query);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late _FakeDatabase database;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('wal-test-');
    database = _FakeDatabase(directory.path + '/progress.sqlite');
  });
  tearDown(() async => directory.delete(recursive: true));

  test('does not checkpoint a missing or 4 MiB WAL', () async {
    final maintenance = SqliteMaintenanceService(
      progressDatabase: () async => database,
    );
    var report = await maintenance.maintain();
    expect(report.walBytes, 0);
    expect(report.checkpointAttempted, false);

    await File(database.path + '-wal')
        .writeAsBytes(List<int>.filled(4 * 1024 * 1024, 0));
    report = await maintenance.maintain();
    expect(report.checkpointAttempted, false);
    expect(database.sql, isEmpty);
  });

  test('checkpoints a WAL above 4 MiB and reports SHM size', () async {
    await File(database.path + '-wal')
        .writeAsBytes(List<int>.filled(4 * 1024 * 1024 + 1, 0));
    await File(database.path + '-shm').writeAsBytes(<int>[1, 2, 3]);
    final maintenance = SqliteMaintenanceService(
      progressDatabase: () async => database,
    );
    final report = await maintenance.maintain();
    expect(report.checkpointAttempted, true);
    expect(report.checkpointSucceeded, true);
    expect(report.shmBytes, 3);
    expect(database.sql.single, 'PRAGMA wal_checkpoint(TRUNCATE)');
  });

  test('honors cooldown and does not vacuum unless idle and opted-in',
      () async {
    await File(database.path + '-wal')
        .writeAsBytes(List<int>.filled(4 * 1024 * 1024 + 1, 0));
    final maintenance = SqliteMaintenanceService(
      progressDatabase: () async => database,
      incrementalVacuumOnIdle: true,
      minimumCheckpointGap: const Duration(minutes: 10),
    );
    final first = await maintenance.maintain();
    expect(first.vacuumPagesRequested, 0);
    final second = await maintenance.onIdle();
    expect(second.checkpointAttempted, false);
    expect(database.sql, <String>['PRAGMA wal_checkpoint(TRUNCATE)']);
  });

  test('incremental vacuum is capped on explicit idle', () async {
    await File(database.path + '-wal')
        .writeAsBytes(List<int>.filled(4 * 1024 * 1024 + 1, 0));
    final maintenance = SqliteMaintenanceService(
      progressDatabase: () async => database,
      incrementalVacuumOnIdle: true,
    );
    final report = await maintenance.onIdle();
    expect(report.vacuumPagesRequested, 128);
    expect(database.sql, contains('PRAGMA incremental_vacuum(128)'));
  });

  test('reports SQLITE_BUSY without deleting the WAL', () async {
    final wal = File(database.path + '-wal');
    await wal.writeAsBytes(List<int>.filled(4 * 1024 * 1024 + 1, 0));
    database.checkpoint = <Map<String, Object?>>[
      <String, Object?>{'busy': 1, 'log': 200, 'checkpointed': 0},
    ];
    final maintenance = SqliteMaintenanceService(
      progressDatabase: () async => database,
    );
    final result = await maintenance.maintain();
    expect(result.checkpointSucceeded, false);
    expect(await wal.exists(), true);
  });

  test('paused lifecycle triggers non-blocking checkpoint and detaches',
      () async {
    await File(database.path + '-wal')
        .writeAsBytes(List<int>.filled(4 * 1024 * 1024 + 1, 0));
    final maintenance = SqliteMaintenanceService(
      progressDatabase: () async => database,
    );
    maintenance.startObserving();
    maintenance.didChangeAppLifecycleState(AppLifecycleState.paused);
    await maintenance.maintain();
    expect(database.sql, contains('PRAGMA wal_checkpoint(TRUNCATE)'));
    maintenance.dispose();
    expect(() => maintenance.maintain(), throwsStateError);
  });
}
