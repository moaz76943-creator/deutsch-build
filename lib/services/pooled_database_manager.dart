import 'dart:async';
import 'dart:collection';

import 'package:sqflite/sqflite.dart';

typedef ContentDatabaseOpener = Future<Database> Function(String languageCode);
typedef DatabaseFlushHook = Future<void> Function(Database database);

/// Serialized, bounded LRU cache of open SQLite content databases.
///
/// All opens, closes and evictions share one asynchronous mutex. Eviction
/// closes the old handle BEFORE opening a fifth handle, so even concurrent
/// callers cannot exceed [maxConnections]. Content packs are opened read-only;
/// SQLite's close operation releases their resources and any pending buffers.
/// For writable connections a [beforeClose] hook can checkpoint their WAL.
///
/// Callers must finish using a returned handle before allowing it to be
/// evicted; [withDatabase] is provided for operations that need a pinned lease.
class PooledDatabaseManager {
  PooledDatabaseManager({
    required ContentDatabaseOpener openConnection,
    this.maxConnections = 4,
    DatabaseFlushHook? beforeClose,
  })  : _openConnection = openConnection,
        _beforeClose = beforeClose {
    if (maxConnections < 1) {
      throw RangeError.range(maxConnections, 1, null, 'maxConnections');
    }
  }

  final int maxConnections;
  final ContentDatabaseOpener _openConnection;
  final DatabaseFlushHook? _beforeClose;
  final LinkedHashMap<String, Database> _connections =
      LinkedHashMap<String, Database>();
  final Map<String, int> _leases = <String, int>{};
  final List<Completer<void>> _slotWaiters = <Completer<void>>[];
  Future<void> _mutexTail = Future<void>.value();

  int get activeCount => _connections.values.where((db) => db.isOpen).length;
  List<String> get leastToMostRecentlyUsed =>
      List<String>.unmodifiable(_connections.keys);

  Future<T> _locked<T>(Future<T> Function() operation) {
    final result = Completer<T>();
    _mutexTail = _mutexTail.then((_) async {
      try {
        result.complete(await operation());
      } catch (error, stack) {
        result.completeError(error, stack);
      }
    });
    return result.future;
  }

  static String _normalizeCode(String languageCode) {
    final code = languageCode.trim().toLowerCase().replaceAll('_', '-');
    if (!RegExp(r'^[a-z]{2,3}(?:-[a-z0-9]{2,8})*$').hasMatch(code)) {
      throw ArgumentError.value(languageCode, 'languageCode');
    }
    return code;
  }

  Future<Database> open(String languageCode) => _locked(() async {
        try {
          final opened = await _tryOpenLocked(_normalizeCode(languageCode));
          if (opened == null) throw const _PoolSaturated();
          return opened;
        } on _PoolSaturated {
          throw StateError('All pooled content databases are in use');
        }
      });

  void _wakeUpNextWaiterLocked() {
    if (_slotWaiters.isNotEmpty) {
      final next = _slotWaiters.removeAt(0);
      if (!next.isCompleted) next.complete();
    }
  }

  Future<Database?> _tryOpenLocked(String code) async {
    final existing = _connections.remove(code);
    if (existing != null && existing.isOpen) {
      _connections[code] = existing;
      return existing;
    }

    // Close excess idle connections before opening a new one.
    while (_connections.length >= maxConnections) {
      final evict = _connections.keys.firstWhere(
        (key) => (_leases[key] ?? 0) == 0,
        orElse: () => '',
      );
      if (evict.isEmpty) {
        throw const _PoolSaturated();
      }
      await _closeLocked(evict);
    }

    Database? opened;
    try {
      opened = await _openConnection(code);
    } catch (e) {
      // If opening fails, do not add to connections, let the error propagate
      _wakeUpNextWaiterLocked();
      rethrow;
    }

    if (!opened.isOpen) {
      throw StateError('Connection for $code is already closed');
    }
    _connections[code] = opened;
    return opened;
  }

  /// Pins a handle for a bounded operation. Never evicts a leased handle.
  ///
  /// If every connection is already leased, the caller waits for a release
  /// instead of failing the lesson read.
  Future<T> withDatabase<T>(
    String languageCode,
    Future<T> Function(Database database) action,
  ) async {
    final code = _normalizeCode(languageCode);
    while (true) {
      final waiter = Completer<void>();
      Database? leased;
      var waiting = false;
      await _locked(() async {
        try {
          final opened = await _tryOpenLocked(code);
          if (opened == null) throw const _PoolSaturated();
          _leases[code] = (_leases[code] ?? 0) + 1;
          leased = opened;
        } on _PoolSaturated {
          _slotWaiters.add(waiter);
          waiting = true;
        }
      });
      if (waiting) {
        await waiter.future;
        continue;
      }
      try {
        return await action(leased!);
      } finally {
        await _locked(() async {
          final count = (_leases[code] ?? 1) - 1;
          if (count <= 0) {
            _leases.remove(code);
          } else {
            _leases[code] = count;
          }
          _wakeUpNextWaiterLocked();
        });
      }
    }
  }

  Future<void> close(String languageCode) =>
      _locked(() => _closeLocked(_normalizeCode(languageCode)));

  Future<void> _closeLocked(String code) async {
    if ((_leases[code] ?? 0) != 0) {
      throw StateError('Cannot close an in-use content database: $code');
    }
    final db = _connections.remove(code);
    if (db == null) return;

    final stillReferenced =
        _connections.values.any((other) => identical(other, db));
    if (stillReferenced) return;

    if (db.isOpen) {
      if (_beforeClose != null) {
        try {
          await _beforeClose!(db);
        } catch (_) {
          // Ignore errors in beforeClose during eviction to guarantee close
        }
      }
      await db.close();
    }
    _wakeUpNextWaiterLocked();
  }

  /// Closes all open connections that are not currently leased by active operations.
  /// Safely avoids throwing if other connections are leased; returns count of closed connections.
  Future<int> closeUnleased() => _locked(() async {
        var closedCount = 0;
        final unleased = _connections.keys
            .where((code) => (_leases[code] ?? 0) == 0)
            .toList(growable: false);
        for (final code in unleased) {
          await _closeLocked(code);
          closedCount++;
        }
        return closedCount;
      });

  Future<void> closeAll() => _locked(() async {
        if (_leases.values.any((count) => count > 0)) {
          throw StateError('Cannot close leased content databases');
        }
        for (final code in _connections.keys.toList(growable: false)) {
          await _closeLocked(code);
        }
      });
}

class _PoolSaturated implements Exception {
  const _PoolSaturated();
}
