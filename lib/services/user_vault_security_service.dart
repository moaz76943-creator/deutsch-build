import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

/// No key bytes ever cross the Flutter platform channel.
/// Unsupported/non-hardware-backed keystores fail closed.
abstract class VaultCipher {
  Future<Uint8List> encrypt(String recordId, Uint8List plaintext);
  Future<Uint8List> decrypt(String recordId, Uint8List ciphertext);
}

class AndroidKeystoreVaultCipher implements VaultCipher {
  const AndroidKeystoreVaultCipher();
  static const MethodChannel _channel =
      MethodChannel('com.deutschbilarabi.app/user_vault_security');
  @override
  Future<Uint8List> encrypt(String recordId, Uint8List plaintext) async {
    final data = await _channel.invokeMethod<Uint8List>(
      'encrypt', <String,Object>{'recordId':recordId,'bytes':plaintext});
    if(data==null) throw StateError('Hardware vault unavailable');
    return data;
  }
  @override
  Future<Uint8List> decrypt(String recordId, Uint8List ciphertext) async {
    final data = await _channel.invokeMethod<Uint8List>(
      'decrypt', <String,Object>{'recordId':recordId,'bytes':ciphertext});
    if(data==null) throw StateError('Vault decryption failed');
    return data;
  }
}

/// Result of a verified, lossless opt-in legacy database migration.
class LegacyProgressMigrationResult {
  const LegacyProgressMigrationResult({
    required this.migrated,
    required this.tableRowCounts,
  });
  final bool migrated;
  final Map<String, int> tableRowCounts;
}

/// Opt-in encrypted record vault. This does not silently rewrite legacy
/// user_progress_v2.db, which needs a separate, lossless migration.
class UserVaultSecurityService {
  UserVaultSecurityService({
    VaultCipher? cipher,
    Future<Database> Function()? openVaultDatabase,
    Future<String> Function()? legacyDatabasePath,
  }) : _cipher=cipher ?? const AndroidKeystoreVaultCipher(),
       _openDatabase=openVaultDatabase ?? _openDefault,
       _legacyDatabasePath=legacyDatabasePath ?? _defaultLegacyPath;
  static const maximumRecordBytes=4*1024*1024;
  final VaultCipher _cipher;
  final Future<Database> Function() _openDatabase;
  final Future<String> Function() _legacyDatabasePath;
  Future<Database>? _cached;
  Future<LegacyProgressMigrationResult>? _migration;

  static Future<String> _defaultLegacyPath() async =>
      path.join(await getDatabasesPath(), 'user_progress_v2.db');

  static Future<Database> _openDefault() async {
    final root=await getDatabasesPath();
    return openDatabase(path.join(root,'user_vault_v1.db'),version:1,
      onCreate:(db,_) async {
        await db.execute('CREATE TABLE vault_entries ('
          'record_hash TEXT PRIMARY KEY, ciphertext BLOB NOT NULL)');
      });
  }

  Future<Database> get _db=>_cached ??= _openDatabase();

  static void _validateId(String id) {
    if(!RegExp(r'^[a-zA-Z0-9_.:/-]{1,128}$').hasMatch(id)) {
      throw ArgumentError.value(id,'recordId','Invalid vault record ID');
    }
  }

  static String _index(String id)=>sha256.convert(utf8.encode(id)).toString();

  Future<void> putRecord(String id,Uint8List plaintext) async {
    _validateId(id);
    if(plaintext.length>maximumRecordBytes) {
      throw ArgumentError.value(plaintext.length,'plaintext','Record too large');
    }
    // Encryption completes before any SQLite write.
    final ciphertext=await _cipher.encrypt(id,plaintext);
    if(ciphertext.length < 29 || ciphertext[0]!=1) {
      throw StateError('Invalid encrypted vault envelope');
    }
    final database=await _db;
    await database.insert('vault_entries',<String,Object>{
      'record_hash':_index(id),'ciphertext':ciphertext,
    },conflictAlgorithm:ConflictAlgorithm.replace);
  }

  Future<Uint8List?> readRecord(String id) async {
    _validateId(id);
    final database=await _db;
    final rows=await database.query('vault_entries',
      columns:<String>['ciphertext'],
      where:'record_hash = ?',whereArgs:<Object>[_index(id)],limit:1);
    if(rows.isEmpty)return null;
    final encrypted=rows.single['ciphertext'];
    if(encrypted is! Uint8List || encrypted.length<29 || encrypted[0]!=1) {
      throw StateError('Vault record is corrupt');
    }
    return _cipher.decrypt(id,encrypted);
  }

  Future<void> deleteRecord(String id) async {
    _validateId(id);
    await (await _db).delete('vault_entries',
      where:'record_hash = ?',whereArgs:<Object>[_index(id)]);
  }

  /// Transfers every user-owned SQLite table (including SRS, history and
  /// bookmarks) into an encrypted, recoverable snapshot. This is explicitly
  /// invoked AFTER progress consumers have switched to the vault; invoking it
  /// does not transparently replace the legacy relational progress API.
  ///
  /// The source remains untouched on any encryption, write, or verification
  /// failure. One destination transaction holds the complete snapshot.
  Future<LegacyProgressMigrationResult> migrateLegacyProgressDatabase() =>
      _migration ??= _migrateLegacyProgressDatabase().whenComplete(() {
        _migration = null;
      });

  static const int _migrationPageSize = 64;
  static const int _maximumLegacyRows = 250000;
  static const String _manifestId = 'legacy/v1/manifest';

  static String _rowId(int table, int index) =>
      'legacy/v1/t${table.toRadixString(36)}/r${index.toRadixString(36)}';

  static Object? _encodeSqliteValue(Object? value) {
    if (value == null || value is String || value is num) return value;
    if (value is List<int>) {
      return <String, String>{'sqlite_blob_b64': base64Encode(value)};
    }
    throw StateError('Unsupported SQLite value type during vault migration');
  }

  Future<void> _writeEncrypted(
    DatabaseExecutor destination,
    String id,
    Uint8List plaintext,
  ) async {
    _validateId(id);
    if (plaintext.length > maximumRecordBytes) {
      throw StateError('Legacy record exceeds vault limit');
    }
    final cipher = await _cipher.encrypt(id, plaintext);
    if (cipher.length < 29 || cipher[0] != 1) {
      throw StateError('Hardware vault returned an invalid envelope');
    }
    await destination.insert('vault_entries', <String, Object>{
      'record_hash': _index(id),
      'ciphertext': cipher,
    }, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<LegacyProgressMigrationResult> _migrateLegacyProgressDatabase() async {
    final oldFile = File(await _legacyDatabasePath());
    if (!await oldFile.exists()) {
      return const LegacyProgressMigrationResult(
        migrated: false, tableRowCounts: <String, int>{},
      );
    }
    final backup = File('${oldFile.path}.migrated');
    if (await backup.exists()) {
      throw StateError('Previous migrated backup must not be overwritten');
    }

    final destination = await _db;
    if ((await destination.query('vault_entries', columns: ['record_hash'],
      where: 'record_hash = ?', whereArgs: [_index(_manifestId)],
      limit: 1)).isNotEmpty) {
      throw StateError('A previous legacy vault snapshot already exists');
    }

    // Opening a non-existent path here would create a database; existence was
    // checked first. singleInstance:false avoids reusing a cached connection.
    final source = await openDatabase(oldFile.path, singleInstance: false);
    final counts = <String, int>{};
    try {
      await destination.transaction((vaultTxn) async {
        await source.transaction((legacyTxn) async {
          final objects = await legacyTxn.rawQuery(
            "SELECT type, name, tbl_name, sql FROM sqlite_master "
            "WHERE name NOT LIKE 'sqlite_%' AND sql IS NOT NULL "
            "ORDER BY type, name",
          );
          final definitions = objects.where((entry) => entry['type'] == 'table')
              .toList()
            ..sort((left, right) =>
                (left['name'] as String).compareTo(right['name'] as String));
          final tables = <Map<String, Object?>>[];
          var totalRows = 0;
          for (var t = 0; t < definitions.length; t++) {
            final definition = definitions[t];
            final name = definition['name'] as String;
            final quoted = '"${name.replaceAll('"', '""')}"';
            final count = Sqflite.firstIntValue(
              await legacyTxn.rawQuery('SELECT COUNT(*) FROM $quoted'),
            ) ?? 0;
            totalRows += count;
            if (totalRows > _maximumLegacyRows) {
              throw StateError('Legacy database exceeds safe migration limit');
            }
            counts[name] = count;
            final rowDigests = StringBuffer();
            for (var offset = 0; offset < count; offset += _migrationPageSize) {
              final block = await legacyTxn.query(name,
                  limit: _migrationPageSize, offset: offset);
              final expected = count - offset < _migrationPageSize
                  ? count - offset : _migrationPageSize;
              if (block.length != expected) {
                throw StateError('Legacy snapshot changed during migration');
              }
              for (var r = 0; r < block.length; r++) {
                final row = <String, Object?>{
                  for (final entry in block[r].entries)
                    entry.key: _encodeSqliteValue(entry.value),
                };
                final bytes = Uint8List.fromList(utf8.encode(jsonEncode(row)));
                rowDigests.write(sha256.convert(bytes).toString());
                await _writeEncrypted(vaultTxn, _rowId(t, offset + r), bytes);
              }
            }
            tables.add(<String, Object?>{
              'name': name,
              'sql': definition['sql'],
              'count': count,
              'digest': sha256.convert(utf8.encode(rowDigests.toString())).toString(),
            });
          }

          final manifest = <String, Object?>{
            'format': 'legacy-sqlite-snapshot-v1',
            'tables': tables,
            // Preserve index/trigger/view DDL as well as user table rows.
            'schema_objects': objects,
            'total_rows': totalRows,
          };
          await _writeEncrypted(vaultTxn, _manifestId,
              Uint8List.fromList(utf8.encode(jsonEncode(manifest))));
        });
      });

      // Verify every saved ciphertext through the real decrypt boundary,
      // including a per-table digest and precise row count, before renaming.
      final manifestBytes = await readRecord(_manifestId);
      if (manifestBytes == null) throw StateError('Vault manifest missing');
      final manifest = jsonDecode(utf8.decode(manifestBytes));
      if (manifest is! Map || manifest['format'] != 'legacy-sqlite-snapshot-v1') {
        throw StateError('Vault manifest is malformed');
      }
      final tables = manifest['tables'];
      if (tables is! List || tables.length != counts.length) {
        throw StateError('Vault table count mismatch');
      }
      var verifiedRows = 0;
      for (var t = 0; t < tables.length; t++) {
        final table = Map<String, dynamic>.from(tables[t] as Map);
        final name = table['name'];
        final count = table['count'];
        if (name is! String || count is! int || counts[name] != count) {
          throw StateError('Vault table row count mismatch');
        }
        final digests = StringBuffer();
        for (var index = 0; index < count; index++) {
          final record = await readRecord(_rowId(t, index));
          if (record == null) throw StateError('Missing encrypted legacy row');
          digests.write(sha256.convert(record).toString());
          verifiedRows++;
        }
        final digest = sha256.convert(utf8.encode(digests.toString())).toString();
        if (digest != table['digest']) {
          throw StateError('Encrypted legacy data integrity mismatch');
        }
      }
      if (manifest['total_rows'] != verifiedRows) {
        throw StateError('Vault total record count mismatch');
      }

      // Flush any journaled transactions before moving just the SQLite file.
      // Fail closed if another connection prevents a full checkpoint.
      final checkpoint = await source.rawQuery('PRAGMA wal_checkpoint(TRUNCATE)');
      if (checkpoint.isNotEmpty &&
          (checkpoint.first['busy'] as num?) != null &&
          (checkpoint.first['busy'] as num) != 0) {
        throw StateError('Legacy SQLite database is busy');
      }
    } finally {
      if (source.isOpen) await source.close();
    }

    // A nonempty WAL might still hold committed records from another writer.
    final wal = File('${oldFile.path}-wal');
    if (await wal.exists() && await wal.length() > 0) {
      throw StateError('Legacy WAL is not empty; migration not finalized');
    }
    if (await backup.exists() || !await oldFile.exists()) {
      throw StateError('Legacy DB changed before atomic rename');
    }
    await oldFile.rename(backup.path);
    return LegacyProgressMigrationResult(
      migrated: true, tableRowCounts: Map<String, int>.unmodifiable(counts),
    );
  }

}
