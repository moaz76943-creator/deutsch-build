import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';

/// Offline SQLite delta applier. The owner MUST close/evict every connection
/// to the target before calling this method. Do not patch the golden German DB.
/// A local staged copy, SQL transaction, digest and same-volume atomic rename
/// keep the installed database unchanged until all checks have succeeded.
class DeltaPatchService {
  DeltaPatchService({DatabaseFactory? factory})
      : _factory = factory ?? databaseFactory;

  final DatabaseFactory _factory;
  static final RegExp _name = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');
  static final RegExp _hashFormat = RegExp(r'^[a-fA-F0-9]{64}$');
  static final RegExp _dml = RegExp(
      r'^(?:INSERT\s+INTO|UPDATE\s+|DELETE\s+FROM)\b',
      caseSensitive: false);

  Future<String> applyJsonPatch({
    required File databaseFile,
    required String jsonPatch,
  }) async {
    final value = jsonDecode(jsonPatch);
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON delta object');
    }
    return applyPatch(databaseFile: databaseFile, patch: value);
  }

  /// Required fields: fromVersion, toVersion, expectedSha256 and operations.
  /// Optional baseSha256. Versions are SQLite PRAGMA user_version integers.
  /// Operations are typed insert/update/delete with bound values and where
  /// maps, or {op: sql, sql: <single INSERT/UPDATE/DELETE>, args: [...]}.
  Future<String> applyPatch({
    required File databaseFile,
    required Map<String, dynamic> patch,
  }) async {
    final from = patch['fromVersion'];
    final to = patch['toVersion'];
    final expected = patch['expectedSha256'];
    final baseExpected = patch['baseSha256'];
    final operations = patch['operations'];
    if (from is! int ||
        from < 0 ||
        to is! int ||
        to <= from ||
        expected is! String ||
        !_hashFormat.hasMatch(expected) ||
        (baseExpected != null &&
            (baseExpected is! String || !_hashFormat.hasMatch(baseExpected))) ||
        operations is! List ||
        operations.isEmpty ||
        operations.length > 5000) {
      throw const FormatException(
          'Invalid patch versions, digest or operations');
    }
    if (!await databaseFile.exists()) {
      throw StateError('SQLite file is not installed');
    }
    for (final suffix in ['-wal', '-shm', '-journal']) {
      if (await File(databaseFile.path + suffix).exists()) {
        throw StateError('Close and checkpoint SQLite before patching');
      }
    }

    final before = await _sha(databaseFile);
    if (baseExpected != null) {
      if (baseExpected is! String || !_same(before, baseExpected)) {
        throw StateError('Base SHA-256 mismatch');
      }
    }
    final staged = File('${databaseFile.path}.delta-staging');
    if (await staged.exists()) {
      throw StateError('Unrecovered or concurrent delta staging file');
    }
    await databaseFile.copy(staged.path);
    Database? db;
    try {
      if (!_same(await _sha(staged), before)) {
        throw StateError('SQLite changed during snapshot');
      }
      db = await _factory.openDatabase(staged.path,
          options: OpenDatabaseOptions(singleInstance: false));
      await db.rawQuery('PRAGMA journal_mode=DELETE');
      if (await _version(db) != from) {
        throw StateError('Patch base version mismatch');
      }
      await db.transaction((txn) async {
        for (final raw in operations) {
          if (raw is! Map) {
            throw const FormatException('Malformed delta operation');
          }
          await _execute(txn, Map<String, dynamic>.from(raw));
        }
        await txn.execute('PRAGMA user_version = $to');
      });
      if (await _version(db) != to) {
        throw StateError('Target SQLite version mismatch');
      }
      final check = await db.rawQuery('PRAGMA integrity_check');
      if (check.length != 1 || check.first.values.first != 'ok') {
        throw StateError('SQLite integrity check failed');
      }
      // integrity_check does not report orphaned foreign keys. Reject a
      // candidate with broken references before replacing last-known-good,
      // even when SQLite foreign_keys enforcement was disabled by the opener.
      final foreignKeyViolations =
          await db.rawQuery('PRAGMA foreign_key_check');
      if (foreignKeyViolations.isNotEmpty) {
        throw StateError('SQLite foreign key check failed');
      }
      await db.close();
      db = null;
      final digest = await _sha(staged);
      if (!_same(digest, expected)) {
        throw StateError('Post-patch SHA-256 mismatch');
      }
      if (!_same(await _sha(databaseFile), before)) {
        throw StateError('SQLite changed concurrently during patch');
      }
      // On Android's POSIX filesystem, rename over target is atomic.
      await staged.rename(databaseFile.path);
      return digest;
    } finally {
      if (db != null && db.isOpen) await db.close();
      if (await staged.exists()) await staged.delete();
    }
  }

  static Future<int> _version(DatabaseExecutor db) async {
    final rows = await db.rawQuery('PRAGMA user_version');
    return rows.first['user_version'] as int;
  }

  static Future<void> _execute(Transaction txn, Map<String, dynamic> op) async {
    final kind = op['op'];
    if (kind == 'sql') {
      final sql = op['sql'];
      final arguments = op['args'] ?? <Object?>[];
      if (sql is! String ||
          !_dml.hasMatch(sql.trim()) ||
          sql.contains(';') ||
          sql.contains('--') ||
          sql.contains('/*') ||
          arguments is! List) {
        throw const FormatException('Only one bound DML statement is allowed');
      }
      await txn.execute(sql, arguments.map<Object?>((v) => _bind(v)).toList());
      return;
    }
    final table = _identifier(op['table']);
    if (kind == 'insert') {
      final values = _values(op['values']);
      if (values.isEmpty) throw const FormatException('Empty INSERT');
      await txn.insert(table, values,
          conflictAlgorithm: ConflictAlgorithm.abort);
      return;
    }
    if (kind != 'update' && kind != 'delete') {
      throw const FormatException('Unsupported delta operation');
    }
    final conditions = _values(op['where']);
    if (conditions.isEmpty) {
      throw const FormatException('UPDATE/DELETE requires WHERE');
    }
    final clauses = <String>[];
    final whereArgs = <Object?>[];
    conditions.forEach((key, value) {
      clauses.add(value == null ? '"$key" IS NULL' : '"$key" = ?');
      if (value != null) whereArgs.add(value);
    });
    final where = clauses.join(' AND ');
    if (kind == 'delete') {
      await txn.delete(table, where: where, whereArgs: whereArgs);
    } else {
      final values = _values(op['values']);
      if (values.isEmpty) throw const FormatException('Empty UPDATE');
      await txn.update(table, values, where: where, whereArgs: whereArgs);
    }
  }

  static String _identifier(Object? value) {
    if (value is! String || !_name.hasMatch(value)) {
      throw const FormatException('Unsafe SQLite identifier');
    }
    return value;
  }

  static Map<String, Object?> _values(Object? raw) {
    if (raw is! Map) throw const FormatException('Expected column/value map');
    final result = <String, Object?>{};
    for (final e in raw.entries) {
      result[_identifier(e.key)] = _bind(e.value);
    }
    return result;
  }

  static Object? _bind(Object? value) {
    if (value == null ||
        value is String ||
        value is num ||
        value is List<int>) {
      return value;
    }
    throw const FormatException('Unsupported SQLite argument type');
  }

  static Future<String> _sha(File file) async =>
      (await sha256.bind(file.openRead()).first).toString();

  static bool _same(String left, String right) {
    if (left.length != right.length) return false;
    final lower = right.toLowerCase();
    var difference = 0;
    for (var i = 0; i < left.length; i++) {
      difference |= left.codeUnitAt(i) ^ lower.codeUnitAt(i);
    }
    return difference == 0;
  }
}
