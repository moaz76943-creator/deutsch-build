import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';

import 'crash_loop_guard.dart';
import 'database_service.dart';

class SqliteMaintenanceReport {
  const SqliteMaintenanceReport({
    required this.walBytes,
    required this.shmBytes,
    required this.checkpointAttempted,
    required this.checkpointSucceeded,
    required this.vacuumPagesRequested,
    this.error,
  });

  final int walBytes;
  final int shmBytes;
  final bool checkpointAttempted;
  final bool checkpointSucceeded;
  final int vacuumPagesRequested;
  final Object? error;
}

class SqliteMaintenanceService with WidgetsBindingObserver {
  SqliteMaintenanceService({
    Future<Database> Function()? progressDatabase,
    DateTime Function()? clock,
    this.thresholdBytes = 4 * 1024 * 1024,
    this.minimumCheckpointGap = const Duration(minutes: 1),
    this.incrementalVacuumOnIdle = false,
  })  : _progressDatabase =
            progressDatabase ?? (() => DatabaseService.instance.progressDb),
        _clock = clock ?? DateTime.now {
    if (thresholdBytes < 1 || minimumCheckpointGap.isNegative) {
      throw ArgumentError('Invalid maintenance threshold or interval');
    }
  }

  final Future<Database> Function() _progressDatabase;
  final DateTime Function() _clock;
  final int thresholdBytes;
  final Duration minimumCheckpointGap;
  final bool incrementalVacuumOnIdle;

  DateTime? _lastCheckpoint;
  Future<SqliteMaintenanceReport>? _running;
  bool _observing = false;
  bool _disposed = false;

  void startObserving() {
    if (_disposed) throw StateError('Maintenance service was disposed');
    if (_observing) return;
    WidgetsBinding.instance.addObserver(this);
    _observing = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && !_disposed) {
      unawaited(maintain());
    }
  }

  Future<SqliteMaintenanceReport> onIdle() async {
    final frame = Completer<void>();
    final binding = WidgetsBinding.instance;
    binding.addPostFrameCallback((_) {
      if (!frame.isCompleted) frame.complete();
    });
    binding.scheduleFrame();
    if (!binding.sendFramesToEngine ||
        binding.runtimeType.toString().contains('AutomatedTest')) {
      scheduleMicrotask(() {
        if (!frame.isCompleted) frame.complete();
      });
    }
    await frame.future;
    return maintain(isIdle: true);
  }

  Future<SqliteMaintenanceReport> maintain({bool isIdle = false}) {
    return _runMaintenance(isIdle: isIdle);
  }

  Future<SqliteMaintenanceReport> performMaintenance(Database db) {
    return _runMaintenance(
      isIdle: true,
      forceCheckpoint: true,
      requestedDatabase: db,
    );
  }

  Future<SqliteMaintenanceReport> _runMaintenance({
    required bool isIdle,
    bool forceCheckpoint = false,
    Database? requestedDatabase,
  }) {
    if (_disposed) {
      throw StateError('Maintenance service was disposed');
    }
    final running = _running;
    if (running != null) {
      if (forceCheckpoint) {
        return running.then((_) => _runMaintenance(
              isIdle: isIdle,
              forceCheckpoint: true,
              requestedDatabase: requestedDatabase,
            ));
      }
      return running;
    }

    final operation = _maintain(
      isIdle: isIdle,
      forceCheckpoint: forceCheckpoint,
      requestedDatabase: requestedDatabase,
    );
    _running = operation;
    return operation.whenComplete(() {
      if (identical(_running, operation)) _running = null;
    });
  }

  Future<SqliteMaintenanceReport> _maintain({
    required bool isIdle,
    required bool forceCheckpoint,
    Database? requestedDatabase,
  }) async {
    var walBytes = 0;
    var shmBytes = 0;
    var checkpointAttempted = false;
    var checkpointSucceeded = false;
    var vacuumPagesRequested = 0;

    SqliteMaintenanceReport report({Object? error}) {
      return SqliteMaintenanceReport(
        walBytes: walBytes,
        shmBytes: shmBytes,
        checkpointAttempted: checkpointAttempted,
        checkpointSucceeded: checkpointSucceeded,
        vacuumPagesRequested: vacuumPagesRequested,
        error: error,
      );
    }

    try {
      await CrashLoopGuard.waitForIntegrityWindow();
      if (_disposed) return report();
      final progressDb = await _progressDatabase();
      if (_disposed) return report();
      final db = requestedDatabase ?? progressDb;

      if (!identical(db, progressDb)) {
        return report(
          error: StateError(
            'Maintenance is restricted to the configured progress database',
          ),
        );
      }
      if (!db.isOpen) return report();

      walBytes = await _fileSize(File('${db.path}-wal'));
      shmBytes = await _fileSize(File('${db.path}-shm'));
      final now = _clock();
      final cooldownActive = _lastCheckpoint != null &&
          now.difference(_lastCheckpoint!) < minimumCheckpointGap;

      if (!forceCheckpoint &&
          (walBytes <= thresholdBytes || cooldownActive)) {
        return report();
      }

      checkpointAttempted = true;
      final rows = await db.rawQuery('PRAGMA wal_checkpoint(TRUNCATE)');
      final busy = rows.isEmpty ? 0 : rows.first['busy'];
      checkpointSucceeded = busy is num && busy == 0;
      if (!checkpointSucceeded) return report();
      _lastCheckpoint = now;

      if (forceCheckpoint) {
        await db.execute('REINDEX');
      }

      if (isIdle && incrementalVacuumOnIdle) {
        final modes = await db.rawQuery('PRAGMA auto_vacuum');
        final mode = modes.isEmpty ? null : modes.first.values.first;
        if (mode == 2) {
          final free = await db.rawQuery('PRAGMA freelist_count');
          final count = free.isEmpty
              ? 0
              : (free.first.values.first as num).toInt();
          if (count >= 512) {
            vacuumPagesRequested = 128;
            await db.execute('PRAGMA incremental_vacuum(128)');
          }
        }
      }
      return report();
    } on DatabaseException catch (error) {
      return report(error: error);
    } catch (error) {
      return report(error: error);
    }
  }

  static Future<int> _fileSize(File file) async {
    try {
      if (!await file.exists()) return 0;
      final stat = await file.stat();
      return stat.type == FileSystemEntityType.file ? stat.size : 0;
    } on FileSystemException {
      return 0;
    }
  }

  void dispose() {
    if (_observing) WidgetsBinding.instance.removeObserver(this);
    _observing = false;
    _disposed = true;
  }
}
