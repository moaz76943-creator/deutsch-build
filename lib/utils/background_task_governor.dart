import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui' show RootIsolateToken;

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

/// Bounded, offline-only ingestion and FTS work on a dedicated background
/// isolate. Pass a WRITABLE staging database, never a signed/read-only pack.
/// Sqflite's native platform channel is initialized for the background isolate.
class BackgroundTaskGovernor {
  static const int maxBatchSize = 200;
  static const Duration yieldPause = Duration(milliseconds: 5);

  static Iterable<List<T>> batches<T>(
    Iterable<T> source, {
    int batchSize = maxBatchSize,
  }) sync* {
    if (batchSize < 1 || batchSize > maxBatchSize) {
      throw RangeError.range(batchSize, 1, maxBatchSize, 'batchSize');
    }
    var pending = <T>[];
    for (final value in source) {
      pending.add(value);
      if (pending.length == batchSize) {
        yield pending;
        pending = <T>[];
      }
    }
    if (pending.isNotEmpty) yield pending;
  }

  /// For isolate-sendable CPU-only calculations (no widget/DB handles).
  static Future<T> runCpuBound<T>(T Function() function) =>
      Isolate.run<T>(function);

  /// The caller sends only 200 rows at a time. Each transaction is committed
  /// by the worker isolate before the next batch is sent.
  Future<int> ingestLexicon({
    required String writableDatabasePath,
    required Iterable<Map<String, Object?>> rows,
  }) async {
    final worker = await _SqliteIsolateWorker.start(writableDatabasePath);
    var inserted = 0;
    try {
      for (final chunk in batches(rows)) {
        final reply = await worker.request('insert', chunk);
        inserted += reply['count'] as int;
        await Future<void>.delayed(yieldPause);
      }
      return inserted;
    } finally {
      await worker.close();
    }
  }

  /// Rebuilds FTS5 trigram on the writable staging database only. Keyset
  /// pagination avoids OFFSET's quadratic work on large lexicons.
  Future<int> rebuildFts5Index({
    required String writableDatabasePath,
  }) async {
    final worker = await _SqliteIsolateWorker.start(writableDatabasePath);
    var indexed = 0;
    var lastRowId = 0;
    try {
      await worker.request('resetFts', null);
      while (true) {
        final reply = await worker.request('index', lastRowId);
        final count = reply['count'] as int;
        if (count == 0) break;
        indexed += count;
        lastRowId = reply['lastRowId'] as int;
        await Future<void>.delayed(yieldPause);
      }
      return indexed;
    } finally {
      await worker.close();
    }
  }
}

class _SqliteIsolateWorker {
  _SqliteIsolateWorker(this._isolate, this._port);

  final Isolate _isolate;
  final SendPort _port;
  bool _closed = false;

  static Future<_SqliteIsolateWorker> start(String path) async {
    if (path.trim().isEmpty) {
      throw ArgumentError.value(path, 'path', 'Required writable database path');
    }
    final token = RootIsolateToken.instance;
    if (token == null) {
      throw StateError('SQLite background isolate requires the Flutter root isolate');
    }
    final ready = ReceivePort();
    Isolate? isolate;
    try {
      isolate = await Isolate.spawn(
        _sqliteWorkerEntry,
        <Object>[ready.sendPort, token, path],
        debugName: 'pack-sqlite-governor',
      );
      final result = await ready.first.timeout(const Duration(seconds: 30));
      if (result is! SendPort) {
        throw StateError('Background SQLite worker failed: ' + result.toString());
      }
      return _SqliteIsolateWorker(isolate, result);
    } catch (_) {
      isolate?.kill(priority: Isolate.immediate);
      rethrow;
    } finally {
      ready.close();
    }
  }

  Future<Map<String, Object?>> request(String command, Object? data) async {
    if (_closed) throw StateError('Background worker already closed');
    final replyPort = ReceivePort();
    try {
      _port.send(<Object?>[command, data, replyPort.sendPort]);
      final response = await replyPort.first.timeout(const Duration(seconds: 30));
      if (response is! Map) {
        throw StateError('Invalid background worker response');
      }
      final responseMap = Map<String, Object?>.from(response);
      if (responseMap.containsKey('error')) {
        throw StateError(responseMap['error'].toString());
      }
      return responseMap;
    } finally {
      replyPort.close();
    }
  }

  Future<void> close() async {
    if (_closed) return;
    try {
      await request('close', null);
    } finally {
      _closed = true;
      _isolate.kill(priority: Isolate.immediate);
    }
  }
}

Future<void> _sqliteWorkerEntry(List<Object> args) async {
  final ready = args[0] as SendPort;
  final token = args[1] as RootIsolateToken;
  final path = args[2] as String;
  final requests = ReceivePort();
  late final Database db;
  try {
    BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    db = await openDatabase(path, singleInstance: false);
    ready.send(requests.sendPort);
  } catch (error) {
    ready.send(error.toString());
    requests.close();
    return;
  }

  // Requests are serialized by the caller; one transaction per batch.
  await for (final message in requests) {
    final command = (message as List<Object?>)[0] as String;
    final data = message[1];
    final reply = message[2] as SendPort;
    try {
      if (command == 'close') {
        await db.close();
        reply.send(<String, Object?>{'count': 0});
        requests.close();
        break;
      }
      if (command == 'insert') {
        final rows = (data as List).cast<Map>();
        await db.transaction((txn) async {
          for (final raw in rows) {
            final row = Map<String, Object?>.from(raw);
            final id = row['id'];
            final surface = row['surface'];
            if (id is! String || id.isEmpty ||
                surface is! String || surface.isEmpty) {
              throw FormatException('Lexicon rows require nonempty id and surface');
            }
            await txn.rawInsert(
              'INSERT OR REPLACE INTO lexicon '
              '(id, surface, part_of_speech, fields_json) VALUES (?, ?, ?, ?)',
              <Object?>[id, surface, row['part_of_speech'], row['fields_json'] ?? '{}'],
            );
          }
        });
        reply.send(<String, Object?>{'count': rows.length});
      } else if (command == 'resetFts') {
        await db.execute(
          "CREATE VIRTUAL TABLE IF NOT EXISTS lexicon_fts "
          "USING fts5(surface, translation_ar, tokenize='trigram')",
        );
        await db.delete('lexicon_fts');
        reply.send(<String, Object?>{'count': 0});
      } else if (command == 'index') {
        final lastId = data as int;
        final rows = await db.rawQuery(
          'SELECT rowid, surface, fields_json FROM lexicon '
          'WHERE rowid > ? ORDER BY rowid LIMIT ?',
          <Object>[lastId, BackgroundTaskGovernor.maxBatchSize],
        );
        await db.transaction((txn) async {
          for (final row in rows) {
            String translation = '';
            final fields = row['fields_json'];
            if (fields is String && fields.isNotEmpty) {
              try {
                final parsed = jsonDecode(fields);
                if (parsed is Map) {
                  translation = (parsed['translation_ar'] ?? '').toString();
                }
              } on FormatException {
                // Invalid optional translation JSON is not fatal to indexing.
              }
            }
            await txn.rawInsert(
              'INSERT INTO lexicon_fts(rowid, surface, translation_ar) '
              'VALUES (?, ?, ?)',
              <Object?>[row['rowid'], row['surface'], translation],
            );
          }
        });
        reply.send(<String, Object?>{
          'count': rows.length,
          'lastRowId': rows.isEmpty ? lastId : rows.last['rowid'] as int,
        });
      } else {
        throw UnsupportedError('Unknown background task');
      }
    } catch (error) {
      reply.send(<String, Object?>{'error': error.toString()});
    }
  }
}
