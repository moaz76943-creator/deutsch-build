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

/// Decides when an explicit idle maintenance pass may run.
///
/// Production waits for the next frame. Tests inject a scheduler that
/// completes without a frame binding.
abstract class IdleScheduler {
  const IdleScheduler();

  Future<void> waitUntilIdle();
}

/// Post-frame idle signal used by the running app.
class FrameIdleScheduler implements IdleScheduler {
  const FrameIdleScheduler();

  @override
  Future<void> waitUntilIdle() {
    final frame = Completer<void>();
    final binding = WidgetsBinding.instance;
    binding.addPostFrameCallback((_) {
      if (!frame.isCompleted) frame.complete();
    });
    binding.scheduleFrame();
    return frame.future;
  }
}

/// Completes immediately. Widget tests use this so maintenance does not
/// depend on a frame the test binding may never deliver.
class ImmediateIdleScheduler implements IdleScheduler {
  const ImmediateIdleScheduler();

  @override
  Future<void> waitUntilIdle() async {}
}

/// Watches only the writable user-progress SQLite database.
///
/// Read-only content packs MUST NOT be checkpointed or vacuumed. Never delete
/// -wal or -shm sidecars: SQLite owns them and may have active readers.
/// On pause or explicit idle, checkpoint when WAL strictly exceeds 4 MiB.
/// Optional incremental vacuum requires SQLite auto_vacuum=INCREMENTAL.
class SqliteMaintenanceService with WidgetsBindingObserver {
  SqliteMaintenanceService({
    Future<Database> Function()? progressDatabase,
    DateTime Function()? clock,
    IdleScheduler? idleScheduler,
    this.thresholdBytes = 4 * 1024 * 1024,
    this.minimumCheckpointGap = const Duration(minutes: 1),
    this.incrementalVacuumOnIdle = false,
  })  : _progressDatabase =
            progressDatabase ?? (() => DatabaseService.instance.progressDb),
        _clock = clock ?? DateTime.now,
        _idleScheduler = idleScheduler ?? const FrameIdleScheduler() {
    if (thresholdBytes < 1 || minimumCheckpointGap.isNegative) {
      throw ArgumentError('Invalid maintenance threshold or interval');
    }
  }

  final Future<Database> Function() _progressDatabase;
  final DateTime Function() _clock;
  final IdleScheduler _idleScheduler;
  final int thresholdBytes;
  final Duration minimumCheckpointGap;
  final bool incrementalVacuumOnIdle;
  DateTime? _lastCheckpoint;
  Future<SqliteMaintenanceReport>? _running;
  bool _observing = false;
  bool _disposed = false;

  /// Call once during app initialization, then dispose on shutdown.
  void startObserving() {
    if (_disposed) throw StateError('Maintenance service was disposed');
    if (_observing) return;
    WidgetsBinding.instance.addObserver(this);
    _observing = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && !_disposed) {
      // Deliberately do not delay Flutter lifecycle handling.
      unawaited(maintain());
    }
  }

  /// UI or persistent worker may explicitly call this when genuinely idle.
  Future<SqliteMaintenanceReport> onIdle() async {
    await _idleScheduler.waitUntilIdle();
    return maintain(isIdle: true);
  }

  Future<SqliteMaintenanceReport> maintain({bool isIdle = false}) {
    if (_disposed) {
      throw StateError('Maintenance service was disposed');
    }
    final running = _running;
    if (running != null) return running;
    final operation = _maintain(isIdle: isIdle);
    _running = operation;
    return operation.whenComplete(() {
      if (identical(_running, operation)) _running = null;
    });
  }

  Future<SqliteMaintenanceReport> _maintain({required bool isIdle}) async {
    // Never open the progress DB or inspect WAL during the cold-start window.
    await CrashLoopGuard.waitForIntegrityWindow();
    var walBytes = 0;
    var shmBytes = 0;
    try {
      final db = await _progressDatabase();
      if (!db.isOpen) {
        return const SqliteMaintenanceReport(
          walBytes: 0,
          shmBytes: 0,
          checkpointAttempted: false,
          checkpointSucceeded: false,
          vacuumPagesRequested: 0,
        );
      }
      // Both .sqlite-wal and .db-wal paths are derived from the actual DB.
      final path = db.path;
      walBytes = await _fileSize(File('$path-wal'));
      shmBytes = await _fileSize(File('$path-shm'));
      final now = _clock();
      final cooldownActive = _lastCheckpoint != null &&
          now.difference(_lastCheckpoint!) < minimumCheckpointGap;
      if (walBytes <= thresholdBytes || cooldownActive) {
        return SqliteMaintenanceReport(
          walBytes: walBytes,
          shmBytes: shmBytes,
          checkpointAttempted: false,
          checkpointSucceeded: false,
          vacuumPagesRequested: 0,
        );
      }

      // One bounded checkpoint; SQLITE_BUSY is reported, never force-closed.
      final rows = await db.rawQuery('PRAGMA wal_checkpoint(TRUNCATE)');
      final successful = rows.isEmpty ||
          (rows.first['busy'] is num && rows.first['busy'] == 0);
      if (successful) _lastCheckpoint = now;

      var pages = 0;
      if (successful && isIdle && incrementalVacuumOnIdle) {
        final modes = await db.rawQuery('PRAGMA auto_vacuum');
        final mode = modes.isEmpty ? null : modes.first.values.first;
        if (mode == 2) {
          final free = await db.rawQuery('PRAGMA freelist_count');
          final count =
              free.isEmpty ? 0 : (free.first.values.first as num).toInt();
          if (count >= 512) {
            // Incremental vacuum avoids aggressive full-file rewrite.
            pages = count < 128 ? count : 128;
            await db.execute('PRAGMA incremental_vacuum(128)');
          }
        }
      }
      return SqliteMaintenanceReport(
        walBytes: walBytes,
        shmBytes: shmBytes,
        checkpointAttempted: true,
        checkpointSucceeded: successful,
        vacuumPagesRequested: pages,
      );
    } catch (error) {
      return SqliteMaintenanceReport(
        walBytes: walBytes,
        shmBytes: shmBytes,
        checkpointAttempted: false,
        checkpointSucceeded: false,
        vacuumPagesRequested: 0,
        error: error,
      );
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
