import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' as sqlcipher;

import 'secure_storage_backend.dart';

final class SqlCipherStorageBackend implements SecureStorageBackend {
  SqlCipherStorageBackend._(this._database);

  static const String _table = 'local_secure_records';
  final Database _database;
  bool _disposed = false;

  static Future<SqlCipherStorageBackend> open({
    required String path,
    required String passphrase,
  }) async {
    if (passphrase.trim().length < 32) {
      throw const SecureStorageBackendException(
        'secure_storage_passphrase_too_short',
      );
    }

    Database? database;
    try {
      database = await sqlcipher.openDatabase(
        path,
        password: passphrase,
        version: 1,
        singleInstance: true,
        onCreate: (db, _) async {
          await db.execute(
            'CREATE TABLE $_table ('
            'record_key TEXT PRIMARY KEY NOT NULL, '
            'primary_payload TEXT NOT NULL, '
            'primary_digest TEXT NOT NULL, '
            'backup_payload TEXT, '
            'backup_digest TEXT, '
            'updated_at INTEGER NOT NULL'
            ')',
          );
        },
      );
      await _assertCipher(database);
      await _assertIntegrity(database);
      return SqlCipherStorageBackend._(database);
    } on SecureStorageBackendException {
      if (database != null) await database.close();
      rethrow;
    } on Object {
      if (database != null) await database.close();
      throw const SecureStorageBackendException('secure_storage_open_failed');
    }
  }

  @override
  Future<StorageRecord?> readRecord(String key) async {
    _ensureActive();
    try {
      final rows = await _database.query(
        _table,
        columns: const <String>[
          'primary_payload',
          'primary_digest',
          'backup_payload',
          'backup_digest',
        ],
        where: 'record_key = ?',
        whereArgs: <Object?>[key],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      final row = rows.first;
      return StorageRecord(
        primaryPayload: row['primary_payload'] as String,
        primaryDigest: row['primary_digest'] as String,
        backupPayload: row['backup_payload'] as String?,
        backupDigest: row['backup_digest'] as String?,
      );
    } on SecureStorageBackendException {
      rethrow;
    } on Object {
      throw const SecureStorageBackendException('secure_storage_read_failed');
    }
  }

  @override
  Future<void> writeRecord(String key, StorageRecord record) async {
    _ensureActive();
    try {
      await _database.insert(
        _table,
        <String, Object?>{
          'record_key': key,
          'primary_payload': record.primaryPayload,
          'primary_digest': record.primaryDigest,
          'backup_payload': record.backupPayload,
          'backup_digest': record.backupDigest,
          'updated_at': DateTime.now().toUtc().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } on Object {
      throw const SecureStorageBackendException('secure_storage_write_failed');
    }
  }

  @override
  Future<void> deleteRecord(String key) async {
    _ensureActive();
    try {
      await _database.delete(
        _table,
        where: 'record_key = ?',
        whereArgs: <Object?>[key],
      );
    } on Object {
      throw const SecureStorageBackendException('secure_storage_delete_failed');
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _database.close();
  }

  static Future<void> _assertCipher(Database database) async {
    final rows = await database.rawQuery('PRAGMA cipher_version');
    if (rows.isEmpty ||
        rows.first.values.isEmpty ||
        rows.first.values.first.toString().trim().isEmpty) {
      throw const SecureStorageBackendException(
        'secure_storage_cipher_unavailable',
      );
    }
  }

  static Future<void> _assertIntegrity(Database database) async {
    final cipherErrors = await database.rawQuery(
      'PRAGMA cipher_integrity_check',
    );
    if (cipherErrors.isNotEmpty) {
      throw const SecureStorageBackendException(
        'secure_storage_cipher_integrity_failed',
      );
    }
    final logical = await database.rawQuery('PRAGMA integrity_check');
    if (logical.isEmpty ||
        logical.first.values.isEmpty ||
        logical.first.values.first.toString().trim().toLowerCase() != 'ok') {
      throw const SecureStorageBackendException(
        'secure_storage_sqlite_integrity_failed',
      );
    }
  }

  void _ensureActive() {
    if (_disposed) {
      throw const SecureStorageBackendException('secure_storage_disposed');
    }
  }
}
