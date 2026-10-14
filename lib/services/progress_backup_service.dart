import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'database_service.dart';
import 'user_vault_security_service.dart';

class _DecodedProgressBackup {
  const _DecodedProgressBackup(this.records, this.bookmarks);
  final List<Map<String, Object?>> records;
  final List<Map<String, dynamic>> bookmarks;
}

/// Counts from a fully committed, atomic import.
class ProgressBackupRestoreResult {
  final int bookmarksInserted;
  final int bookmarksUpdated;
  final int inserted;
  final int updated;
  final int unchanged;
  final int languageConflicts;

  const ProgressBackupRestoreResult({
    required this.inserted,
    required this.updated,
    required this.unchanged,
    required this.languageConflicts,
    this.bookmarksInserted = 0,
    this.bookmarksUpdated = 0,
  });
}

/// Offline progress backups from the live vault or the legacy database.
/// Plain .json.gz archives contain decrypted user data. Device-bound
/// .vault.json archives use the vault AES-GCM key (not portable to other devices).
///
/// Backups are GZIP-compressed JSON, NOT encrypted. The SHA-256 digest protects
/// against accidental corruption, not deliberate tampering. Callers must use a
/// trusted destination when sharing a backup containing learning activity.
///
/// The current database schema has no per-review event log or last-reviewed
/// timestamp. Only persisted SRS state (including next_due_at) is exported;
/// the service never fabricates review history.
class ProgressBackupService {
  static const String _databaseName = 'user_progress_v2.db';
  static const String _tableName = 'srs_progress';
  static const String _formatName = 'deutsch-bilarabi-progress';
  static const int _formatVersion = 2;
  static const String _archiveFormat = 'deutsch-vault-archive-v1';
  static const int _archiveChunkBytes = 128 * 1024;
  static const int _maxArchiveBytes = 32 * 1024 * 1024;

  static const int _maxCompressedBytes = 16 * 1024 * 1024;
  static const int _maxJsonBytes = 64 * 1024 * 1024;
  static const int _maxRecords = 250000;

  static const List<String> _columns = <String>[
    'lexeme_id',
    'target_language_code',
    'repetition_count',
    'interval_days',
    'ease_factor',
    'next_due_at',
    'status',
  ];

  final Future<Database> Function() _databaseProvider;
  final UserVaultSecurityService? _vault;
  final Future<Directory> Function() _backupDirectoryProvider;

  ProgressBackupService({
    Future<Database> Function()? databaseProvider,
    Future<Directory> Function()? backupDirectoryProvider,
    UserVaultSecurityService? vaultService,
  })  : _vault = vaultService ??
            (databaseProvider == null ? UserVaultSecurityService() : null),
        _databaseProvider = databaseProvider ?? _openDefaultProgressDatabase,
        _backupDirectoryProvider =
            backupDirectoryProvider ?? getApplicationDocumentsDirectory;

  static Future<Database> _openDefaultProgressDatabase() =>
      DatabaseService.instance.progressDb;

  /// Returns a complete .json.gz file path for the caller's system share UI.
  ///
  /// A consistent SQLite snapshot is read before compression, and the file is
  /// published with a same-directory rename after its bytes are flushed.

  Future<String> exportBackup({bool encryptedArchive = false}) async {
    final vault = _vault;
    final active = vault != null && await vault.isOperationalActive;
    if (encryptedArchive && !active) {
      throw StateError('An active encrypted vault is required for AES archives');
    }
    final List<Map<String, Object?>> rows;
    final List<Map<String, dynamic>> bookmarks;
    if (active) {
      final snapshot = await vault!.exportOperationalSnapshot();
      rows = snapshot['srs']!
          .map((e) => _asBackupSrs(e)).toList(growable: false);
      bookmarks = snapshot['bookmarks']!;
    } else {
      final db = await _databaseProvider();
      final snapshot = await db.transaction((txn) async {
        final srs = await txn.query(_tableName,
            columns: _columns, orderBy: 'target_language_code, lexeme_id');
        final items = await _readLegacyBookmarks(txn);
        return <String, dynamic>{'srs': srs, 'bookmarks': items};
      });
      rows = (snapshot['srs'] as List<Map<String, Object?>>)
          .map(_asBackupSrs).toList(growable: false);
      bookmarks = snapshot['bookmarks'] as List<Map<String, dynamic>>;
    }

    final exportedAt = DateTime.now().toUtc();
    final compressed = await Isolate.run(() =>
        _encodeBackup(rows, bookmarks, exportedAt,
            active ? 'user_vault_v1.db' : _databaseName));
    if (compressed.length > _maxCompressedBytes) {
      throw const FormatException('Backup exceeds compressed size limit');
    }
    final List<int> output;
    final String extension;
    if (encryptedArchive) {
      final sealed = <String>[];
      for (var offset = 0, i = 0; offset < compressed.length;
          offset += _archiveChunkBytes, i++) {
        final end = offset + _archiveChunkBytes < compressed.length
            ? offset + _archiveChunkBytes : compressed.length;
        sealed.add(base64Encode(await vault!.sealArchiveChunk(
            i, Uint8List.fromList(compressed.sublist(offset, end)))));
      }
      output = utf8.encode(jsonEncode({
        'format': _archiveFormat,
        'version': 1,
        'sha256': sha256.convert(compressed).toString(),
        'chunks': sealed,
      }));
      extension = '.vault.json';
      if (output.length > _maxArchiveBytes) {
        throw const FormatException('Encrypted archive is too large');
      }
    } else {
      output = compressed;
      extension = '.json.gz';
    }

    final root = await _backupDirectoryProvider();
    final directory = Directory(path.join(root.path, 'progress_backups'));
    await directory.create(recursive: true);
    final name = 'progress_${exportedAt.microsecondsSinceEpoch}$extension';
    final destination = File(path.join(directory.path, name));
    final partial = File('${destination.path}.partial');
    if (await destination.exists() || await partial.exists()) {
      throw const FileSystemException('A backup with this name already exists');
    }
    try {
      await partial.writeAsBytes(output, flush: true);
      await partial.rename(destination.path);
      return destination.path;
    } catch (_) {
      if (await partial.exists()) await partial.delete();
      rethrow;
    }
  }

  static Map<String, Object?> _asBackupSrs(Map<String, dynamic> data) {
    return <String, Object?>{
      for (final field in _columns) field: data[field],
      'last_reviewed_at': data['last_reviewed_at'],
    };
  }


  static Future<List<Map<String, dynamic>>> _readLegacyBookmarks(
      DatabaseExecutor txn) async {
    final tables = (await txn.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' "
      "AND name IN ('vault_bookmarks','bookmarks')"))
        .map((row) => row['name']).toSet();
    final byIdentity = <String, Map<String, dynamic>>{};
    if (tables.contains('vault_bookmarks')) {
      final rows = await txn.query('vault_bookmarks',
          columns: ['id', 'target_language_code', 'payload'],
          orderBy: 'target_language_code, id');
      for (final row in rows) {
        final decoded = jsonDecode(row['payload'] as String);
        if (decoded is! Map) {
          throw const FormatException('Corrupt legacy bookmark payload');
        }
        final id = row['id'] as String;
        final lang = row['target_language_code'] as String;
        byIdentity['$lang::$id'] = {
          'id': id, 'language_code': lang,
          'data': Map<String, dynamic>.from(decoded),
        };
      }
    }
    if (tables.contains('bookmarks')) {
      final rows = await txn.query('bookmarks');
      for (final row in rows) {
        final id = (row['id'] ?? row['lexeme_id'] ?? row['word'])?.toString();
        if (id == null || id.isEmpty) continue;
        final lang = row['target_language_code']?.toString() ?? 'de';
        byIdentity.putIfAbsent('$lang::$id', () => {
          'id': id, 'language_code': lang,
          'data': <String, Object?>{
            for (final item in row.entries)
              item.key: item.value is List<int>
                  ? {'sqlite_blob_b64': base64Encode(item.value as List<int>)}
                  : item.value,
          },
        });
      }
    }
    final result = byIdentity.values.toList();
    result.sort((a, b) =>
        ('${a['language_code']}::${a['id']}').compareTo(
            '${b['language_code']}::${b['id']}'));
    return result;
  }

  /// Validates an entire backup before writing a single row.
  ///
  /// The winner is the record with the longer retention interval; ties use
  /// repetitions, next-due timestamp, then ease factor. Equal records or
  /// complete ties preserve local data. A language mismatch for the same
  /// lexeme_id is never overwritten because the current primary key is only
  /// lexeme_id, not a composite pair key.

  Future<ProgressBackupRestoreResult> importBackup(String backupPath) async {
    final source = File(backupPath);
    final length = await source.length();
    if (length < 1 || length > _maxArchiveBytes) {
      throw const FormatException('Invalid backup file size');
    }
    final Uint8List jsonBytes;
    if (backupPath.endsWith('.vault.json')) {
      final vault = _vault;
      if (vault == null || !await vault.isOperationalActive) {
        throw StateError('An active vault is required to decrypt an archive');
      }
      final decoded = jsonDecode(await source.readAsString());
      if (decoded is! Map || decoded['format'] != _archiveFormat ||
          decoded['version'] != 1 || decoded['chunks'] is! List) {
        throw const FormatException('Unsupported AES archive envelope');
      }
      final chunks = decoded['chunks'] as List;
      if (chunks.isEmpty || chunks.length > 256 ||
          decoded['sha256'] is! String) {
        throw const FormatException('Malformed AES archive');
      }
      final buffer = BytesBuilder(copy: false);
      for (var i = 0; i < chunks.length; i++) {
        if (chunks[i] is! String) throw const FormatException('Bad archive chunk');
        final encoded = base64Decode(chunks[i] as String);
        final raw = await vault.unsealArchiveChunk(i, Uint8List.fromList(encoded));
        buffer.add(raw);
        if (buffer.length > _maxCompressedBytes) {
          throw const FormatException('AES archive exceeds limit');
        }
      }
      final compressed = buffer.takeBytes();
      if (sha256.convert(compressed).toString() != decoded['sha256']) {
        throw const FormatException('AES archive checksum mismatch');
      }
      jsonBytes = await _inflateBounded(Stream<List<int>>.value(compressed));
    } else {
      if (length > _maxCompressedBytes) {
        throw const FormatException('Backup is too large');
      }
      jsonBytes = await _inflateBounded(source.openRead());
    }

    final imported = await Isolate.run(() => _decodeAndValidate(jsonBytes));
    final vault = _vault;
    if (vault != null && await vault.isOperationalActive) {
      final counts = await vault.restoreOperationalSnapshot(
        srs: imported.records,
        bookmarks: imported.bookmarks,
        incomingWins: _incomingWins,
      );
      return ProgressBackupRestoreResult(
        inserted: counts['inserted']!, updated: counts['updated']!,
        unchanged: counts['unchanged']!, languageConflicts: 0,
        bookmarksInserted: counts['bookmarksInserted']!,
        bookmarksUpdated: counts['bookmarksUpdated']!,
      );
    }
    final db = await _databaseProvider();
    return db.transaction((txn) async {
      final localRows = await txn.query(_tableName, columns: _columns);
      final localById = <String, Map<String, Object?>>{
        for (final row in localRows)
          '${row['target_language_code']}::${row['lexeme_id']}': row
      };
      var inserted = 0, updated = 0, unchanged = 0;
      for (final record in imported.records) {
        final id = record['lexeme_id'] as String;
        final language = record['target_language_code'] as String;
        final key = '$language::$id';
        final local = localById[key];
        final fields = <String, Object?>{
          for (final field in _columns) field: record[field]
        };
        if (local == null) {
          await txn.insert(_tableName, fields);
          inserted++;
        } else if (_incomingWins(local, record)) {
          await txn.update(_tableName, fields,
              where: 'lexeme_id = ? AND target_language_code = ?',
              whereArgs: <Object>[id, language]);
          updated++;
        } else {
          unchanged++;
        }
      }
      var bookmarksInserted = 0, bookmarksUpdated = 0;
      if (imported.bookmarks.isNotEmpty) {
        await txn.execute('''
          CREATE TABLE IF NOT EXISTS vault_bookmarks (
            id TEXT NOT NULL, target_language_code TEXT NOT NULL,
            payload TEXT NOT NULL, PRIMARY KEY(id,target_language_code))
        ''');
        for (final item in imported.bookmarks) {
          final id = item['id'] as String;
          final language = item['language_code'] as String;
          final encoded = jsonEncode(item['data']);
          final existing = await txn.query('vault_bookmarks',
            columns: ['payload'],
            where: 'id = ? AND target_language_code = ?',
            whereArgs: [id, language], limit: 1);
          if (existing.isNotEmpty && existing.single['payload'] == encoded) continue;
          await txn.insert('vault_bookmarks', {
            'id': id, 'target_language_code': language, 'payload': encoded,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
          if (existing.isEmpty) { bookmarksInserted++; } else { bookmarksUpdated++; }
        }
      }
      return ProgressBackupRestoreResult(
        inserted: inserted, updated: updated, unchanged: unchanged,
        languageConflicts: 0,
        bookmarksInserted: bookmarksInserted,
        bookmarksUpdated: bookmarksUpdated,
      );
    });
  }

  static Future<Uint8List> _inflateBounded(Stream<List<int>> compressed) async {
    final builder = BytesBuilder(copy: false);
    var length = 0;
    await for (final chunk in gzip.decoder.bind(compressed)) {
      length += chunk.length;
      if (length > _maxJsonBytes) {
        throw const FormatException('Backup expands beyond size limit');
      }
      builder.add(chunk);
    }
    return builder.takeBytes();
  }


  static List<int> _encodeBackup(
    List<Map<String, Object?>> rows,
    List<Map<String, dynamic>> bookmarks,
    DateTime exportedAt,
    String sourceDatabase,
  ) {
    if (rows.length > _maxRecords || bookmarks.length > _maxRecords) {
      throw const FormatException('Too many records for backup');
    }
    final records = _validateRecords(rows, version: 2);
    final checkedBookmarks = _validateBookmarks(bookmarks);
    final envelope = <String, Object?>{
      'format': _formatName,
      'version': _formatVersion,
      'source_database': sourceDatabase,
      'table': _tableName,
      'exported_at_utc': exportedAt.toIso8601String(),
      'records_sha256': sha256.convert(utf8.encode(jsonEncode(records))).toString(),
      'bookmarks_sha256': sha256.convert(
          utf8.encode(jsonEncode(checkedBookmarks))).toString(),
      'records': records,
      'bookmarks': checkedBookmarks,
    };
    final bytes = utf8.encode(jsonEncode(envelope));
    if (bytes.length > _maxJsonBytes) {
      throw const FormatException('Backup JSON exceeds size limit');
    }
    return gzip.encode(bytes); // stable bytes for the same envelope.
  }

  static _DecodedProgressBackup _decodeAndValidate(Uint8List bytes) {
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic> ||
        decoded['format'] != _formatName ||
        decoded['table'] != _tableName ||
        (decoded['version'] != 1 && decoded['version'] != _formatVersion)) {
      throw const FormatException('Unsupported progress backup schema');
    }
    final version = decoded['version'] as int;
    final source = decoded['source_database'];
    if (source != _databaseName &&
        !(version == 2 && source == 'user_vault_v1.db')) {
      throw const FormatException('Unknown progress backup source');
    }
    final time = decoded['exported_at_utc'];
    if (time is! String || DateTime.tryParse(time) == null) {
      throw const FormatException('Invalid backup creation timestamp');
    }
    final rows = decoded['records'];
    final hash = decoded['records_sha256'];
    if (rows is! List || rows.length > _maxRecords ||
        hash is! String || hash.length != 64 ||
        sha256.convert(utf8.encode(jsonEncode(rows))).toString() != hash) {
      throw const FormatException('Progress backup integrity failure');
    }
    final records = _validateRecords(rows, version: version);
    if (version == 1) return _DecodedProgressBackup(records, []);
    final bookmarks = decoded['bookmarks'];
    final bookmarkHash = decoded['bookmarks_sha256'];
    if (bookmarks is! List || bookmarks.length > _maxRecords ||
        bookmarkHash is! String || bookmarkHash.length != 64 ||
        sha256.convert(utf8.encode(jsonEncode(bookmarks))).toString() != bookmarkHash) {
      throw const FormatException('Bookmarks backup integrity failure');
    }
    return _DecodedProgressBackup(records, _validateBookmarks(bookmarks));
  }

  static List<Map<String, Object?>> _validateRecords(
      Iterable<dynamic> rows, {required int version}) {
    final seen = <String>{};
    final result = <Map<String, Object?>>[];
    for (final value in rows) {
      if (value is! Map ||
          value.length != _columns.length + (version == 2 ? 1 : 0) ||
          !_columns.every(value.containsKey) ||
          (version == 2 && !value.containsKey('last_reviewed_at'))) {
        throw const FormatException('Invalid SRS backup columns');
      }
      final id = value['lexeme_id'];
      final lang = value['target_language_code'];
      final repetitions = value['repetition_count'];
      final interval = value['interval_days'];
      final ease = value['ease_factor'];
      final due = value['next_due_at'];
      final status = value['status'];
      final reviewed = value['last_reviewed_at'];
      if (id is! String || id.isEmpty || id.length > 512 ||
          lang is! String || lang.isEmpty || lang.length > 32 ||
          !seen.add('$lang::$id') ||
          repetitions is! int || repetitions < 0 ||
          interval is! int || interval < 0 ||
          ease is! num || !ease.isFinite || ease < 1.0 ||
          (due != null && (due is! int || due < 0)) ||
          (version == 2 && reviewed != null &&
              (reviewed is! int || reviewed < 0)) ||
          status is! String || status.isEmpty || status.length > 64) {
        throw const FormatException('Invalid or duplicate SRS backup record');
      }
      result.add(<String, Object?>{
        'lexeme_id': id,
        'target_language_code': lang,
        'repetition_count': repetitions,
        'interval_days': interval,
        'ease_factor': ease.toDouble(),
        'next_due_at': due,
        'status': status,
        if (version == 2) 'last_reviewed_at': reviewed,
      });
      if (result.length > _maxRecords) {
        throw const FormatException('Too many SRS backup records');
      }
    }
    return result;
  }

  static List<Map<String, dynamic>> _validateBookmarks(Iterable<dynamic> rows) {
    final seen = <String>{};
    final result = <Map<String, dynamic>>[];
    for (final value in rows) {
      if (value is! Map || value.length != 3 ||
          !value.containsKey('id') || !value.containsKey('language_code') ||
          !value.containsKey('data')) {
        throw const FormatException('Invalid bookmark backup entry');
      }
      final id = value['id'];
      final lang = value['language_code'];
      final data = value['data'];
      if (id is! String || id.isEmpty || id.length > 512 ||
          lang is! String || lang.isEmpty || lang.length > 32 ||
          data is! Map || !seen.add('$lang::$id')) {
        throw const FormatException('Invalid or duplicate bookmark identity');
      }
      final safeData = Map<String, dynamic>.from(data);
      if (utf8.encode(jsonEncode(safeData)).length >
          UserVaultSecurityService.maximumRecordBytes) {
        throw const FormatException('Bookmark record is too large');
      }
      result.add({'id': id, 'language_code': lang, 'data': safeData});
      if (result.length > _maxRecords) {
        throw const FormatException('Too many bookmarks');
      }
    }
    return result;
  }

  static bool _incomingWins(
    Map<String, Object?> local,
    Map<String, Object?> incoming,
  ) {
    final localInterval = local['interval_days'] as int;
    final importedInterval = incoming['interval_days'] as int;
    if (importedInterval != localInterval) {
      return importedInterval > localInterval;
    }

    final localRepetitions = local['repetition_count'] as int;
    final importedRepetitions = incoming['repetition_count'] as int;
    if (importedRepetitions != localRepetitions) {
      return importedRepetitions > localRepetitions;
    }

    // next_due_at is the only persisted SRS timestamp in this schema.
    final localDue = (local['next_due_at'] as int?) ?? -1;
    final importedDue = (incoming['next_due_at'] as int?) ?? -1;
    if (importedDue != localDue) {
      return importedDue > localDue;
    }

    final localEase = (local['ease_factor'] as num).toDouble();
    final importedEase = (incoming['ease_factor'] as num).toDouble();
    return importedEase > localEase;
  }
}
