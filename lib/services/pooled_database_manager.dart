import 'dart:async';
import 'dart:collection';

import 'package:sqflite/sqflite.dart';

typedef ContentDatabaseOpener = Future<Database> Function(String languageCode);
typedef DatabaseFlushHook = Future<void> Function(Database database);

class _PoolFullException implements Exception {}

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

  // To avoid multiple concurrent attempts to open the same DB.
  final Map<String, Future<Database>> _pendingOpens = {};

  // Waiters for when the pool is full and everything is leased.
  final List<Completer<void>> _waiters = [];

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

  void _notifyWaiters() {
    for (final waiter in _waiters) {
      if (!waiter.isCompleted) {
        waiter.complete();
      }
    }
    _waiters.clear();
  }

  Future<void> _waitForLeaseRelease() async {
    final completer = Completer<void>();
    _waiters.add(completer);
    await completer.future;
  }

  Future<Database> open(String languageCode) async {
    final code = _normalizeCode(languageCode);
    while (true) {
      try {
        return await _locked(() => _openLocked(code));
      } on _PoolFullException {
        await _waitForLeaseRelease();
      }
    }
  }

  Future<Database> _openLocked(String code) async {
    final existing = _connections.remove(code);
    if (existing != null && existing.isOpen) {
      // Move to end (most recently used)
      _connections[code] = existing;
      return existing;
    }

    // Close excess idle connections before opening a new one
    while (_connections.length >= maxConnections) {
      final evict = _connections.keys.firstWhere(
        (key) => (_leases[key] ?? 0) == 0,
        orElse: () => '',
      );
      if (evict.isEmpty) {
        // Pool is full and all are leased. Throw special exception to wait.
        throw _PoolFullException();
      }
      await _closeLockedInner(evict);
    }

    if (_pendingOpens.containsKey(code)) {
      final opened = await _pendingOpens[code]!;
      _connections.remove(code);
      _connections[code] = opened;
      return opened;
    }

    final completer = Completer<Database>();
    _pendingOpens[code] = completer.future;

    Database? opened;
    try {
      opened = await _openConnection(code);
      completer.complete(opened);
    } catch (e, st) {
      _pendingOpens.remove(code);
      completer.completeError(e, st);
      rethrow;
    }

    _pendingOpens.remove(code);

    if (!opened.isOpen) {
      throw StateError('Connection for $code is already closed');
    }
    _connections[code] = opened;
    return opened;
  }

  /// Pins a handle for a bounded operation. Never evicts a leased handle.
  Future<T> withDatabase<T>(
    String languageCode,
    Future<T> Function(Database database) action,
  ) async {
    final code = _normalizeCode(languageCode);
    Database db;
    while (true) {
      try {
        db = await _locked(() async {
          final opened = await _openLocked(code);
          _leases[code] = (_leases[code] ?? 0) + 1;
          return opened;
        });
        break;
      } on _PoolFullException {
        await _waitForLeaseRelease();
      }
    }

    try {
      return await action(db);
    } finally {
      await _locked(() async {
        final count = (_leases[code] ?? 1) - 1;
        if (count <= 0) {
          _leases.remove(code);
          _notifyWaiters(); // A lease was released, pool might have free slots
        } else {
          _leases[code] = count;
        }
      });
    }
  }

  Future<void> close(String languageCode) =>
      _locked(() => _closeLockedInner(_normalizeCode(languageCode)));

  Future<void> _closeLockedInner(String code) async {
    if ((_leases[code] ?? 0) != 0) {
      throw StateError('Cannot close an in-use content database: $code');
    }
    final db = _connections.remove(code);
    if (db == null) return;
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
    _notifyWaiters();
  }

  /// Closes all open connections that are not currently leased by active operations.
  /// Safely avoids throwing if other connections are leased; returns count of closed connections.
  Future<int> closeUnleased() => _locked(() async {
        var closedCount = 0;
        final unleased = _connections.keys
            .where((code) => (_leases[code] ?? 0) == 0)
            .toList(growable: false);
        for (final code in unleased) {
          await _closeLockedInner(code);
          closedCount++;
        }
        return closedCount;
      });

  Future<void> closeAll() => _locked(() async {
        if (_leases.values.any((count) => count > 0)) {
          throw StateError('Cannot close leased content databases');
        }
        for (final code in _connections.keys.toList(growable: false)) {
          await _closeLockedInner(code);
        }
      });
}
