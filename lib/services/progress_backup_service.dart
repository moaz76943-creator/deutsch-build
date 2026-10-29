import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

/// Counts from a fully committed, atomic import.
class ProgressBackupRestoreResult {
  final int inserted;
  final int updated;
  final int unchanged;
  final int languageConflicts;

  const ProgressBackupRestoreResult({
    required this.inserted,
    required this.updated,
    required this.unchanged,
    required this.languageConflicts,
  });
}

/// Offline portability for the existing user_progress_v2.db SRS table.
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
  static const int _formatVersion = 1;

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
  final Future<Directory> Function() _backupDirectoryProvider;

  ProgressBackupService({
    Future<Database> Function()? databaseProvider,
    Future<Directory> Function()? backupDirectoryProvider,
  })  : _databaseProvider =
            databaseProvider ?? _openDefaultProgressDatabase,
        _backupDirectoryProvider =
            backupDirectoryProvider ?? getApplicationDocumentsDirectory;

  static Future<Database> _openDefaultProgressDatabase() =>
      DatabaseService.instance.progressDb;

  /// Returns a complete .json.gz file path for the caller's system share UI.
  ///
  /// A consistent SQLite snapshot is read before compression, and the file is
  /// published with a same-directory rename after its bytes are flushed.
  Future<String> exportBackup() async {
    final database = await _databaseProvider();
    final rows = await database.transaction((txn) {
      return txn.query(
        _tableName,
        columns: _columns,
        orderBy: 'lexeme_id ASC',
      );
    });

    final exportedAt = DateTime.now().toUtc();
    // CPU-intensive JSON encoding, hashing and GZIP do not run on the UI isolate.
    final compressed = await Isolate.run(
      () => _encodeBackup(rows, exportedAt),
    );
    if (compressed.length > _maxCompressedBytes) {
      throw const FormatException('Backup exceeds the compressed size limit.');
    }

    final root = await _backupDirectoryProvider();
    final directory = Directory(path.join(root.path, 'progress_backups'));
    await directory.create(recursive: true);

    final name = 'progress_' +
        exportedAt.microsecondsSinceEpoch.toString() +
        '.json.gz';
    final destination = File(path.join(directory.path, name));
    final partial = File(destination.path + '.partial');
    if (await destination.exists() || await partial.exists()) {
      throw const FileSystemException('A backup with this name already exists.');
    }

    try {
      await partial.writeAsBytes(compressed, flush: true);
      await partial.rename(destination.path);
      return destination.path;
    } catch (_) {
      if (await partial.exists()) {
        await partial.delete();
      }
      rethrow;
    }
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
    final compressedLength = await source.length();
    if (compressedLength <= 0 || compressedLength > _maxCompressedBytes) {
      throw const FormatException('Invalid backup file size.');
    }

    final builder = BytesBuilder(copy: false);
    var decodedLength = 0;
    // Stream the decompressor and bound its output to reject GZIP bombs.
    await for (final chunk in gzip.decoder.bind(source.openRead())) {
      decodedLength += chunk.length;
      if (decodedLength > _maxJsonBytes) {
        throw const FormatException('Backup expands beyond the size limit.');
      }
      builder.add(chunk);
    }

    final jsonBytes = builder.takeBytes();
    // Parsing, checksum verification and record validation happen off-UI.
    final imported = await Isolate.run(
      () => _decodeAndValidate(jsonBytes),
    );

    final database = await _databaseProvider();
    return database.transaction((txn) async {
      final localRows = await txn.query(_tableName, columns: _columns);
      final localById = <String, Map<String, Object?>>{};
      for (final row in localRows) {
        localById[row['lexeme_id'] as String] = row;
      }

      var inserted = 0;
      var updated = 0;
      var unchanged = 0;
      var languageConflicts = 0;

      for (final record in imported) {
        final id = record['lexeme_id'] as String;
        final local = localById[id];
        if (local == null) {
          await txn.insert(_tableName, record);
          inserted++;
          continue;
        }

        if (local['target_language_code'] !=
            record['target_language_code']) {
          languageConflicts++;
          continue;
        }

        if (_incomingWins(local, record)) {
          await txn.update(
            _tableName,
            record,
            where: 'lexeme_id = ?',
            whereArgs: <Object>[id],
          );
          updated++;
        } else {
          unchanged++;
        }
      }

      return ProgressBackupRestoreResult(
        inserted: inserted,
        updated: updated,
        unchanged: unchanged,
        languageConflicts: languageConflicts,
      );
    });
  }

  static List<int> _encodeBackup(
    List<Map<String, Object?>> databaseRows,
    DateTime exportedAt,
  ) {
    if (databaseRows.length > _maxRecords) {
      throw const FormatException('Too many progress records to export.');
    }

    final records = _validateRecords(databaseRows);
    final recordsJson = jsonEncode(records);
    final digest = sha256.convert(utf8.encode(recordsJson)).toString();
    final envelope = <String, Object?>{
      'format': _formatName,
      'version': _formatVersion,
      'source_database': _databaseName,
      'table': _tableName,
      'exported_at_utc': exportedAt.toIso8601String(),
      'records_sha256': digest,
      'records': records,
    };

    final bytes = utf8.encode(jsonEncode(envelope));
    if (bytes.length > _maxJsonBytes) {
      throw const FormatException('Backup JSON exceeds the size limit.');
    }
    return gzip.encode(bytes);
  }

  static List<Map<String, Object?>> _decodeAndValidate(
    Uint8List bytes,
  ) {
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic> ||
        decoded['format'] != _formatName ||
        decoded['version'] != _formatVersion ||
        decoded['source_database'] != _databaseName ||
        decoded['table'] != _tableName) {
      throw const FormatException('Unsupported progress backup schema.');
    }

    final timestamp = decoded['exported_at_utc'];
    if (timestamp is! String || DateTime.tryParse(timestamp) == null) {
      throw const FormatException('Invalid backup creation timestamp.');
    }

    final rows = decoded['records'];
    final checksum = decoded['records_sha256'];
    if (rows is! List || checksum is! String || checksum.length != 64) {
      throw const FormatException('Malformed backup records or checksum.');
    }
    if (rows.length > _maxRecords) {
      throw const FormatException('Too many progress records to import.');
    }

    // Verify the exact serialized values before normalizing SQLite types.
    final actualChecksum =
        sha256.convert(utf8.encode(jsonEncode(rows))).toString();
    if (actualChecksum != checksum) {
      throw const FormatException('Backup checksum does not match.');
    }

    return _validateRecords(rows);
  }

  static List<Map<String, Object?>> _validateRecords(Iterable<dynamic> rows) {
    final seen = <String>{};
    final validated = <Map<String, Object?>>[];

    for (final candidate in rows) {
      if (candidate is! Map ||
          candidate.length != _columns.length ||
          !_columns.every(candidate.containsKey)) {
        throw const FormatException('Invalid progress record fields.');
      }

      final lexemeId = candidate['lexeme_id'];
      final languageCode = candidate['target_language_code'];
      final repetitions = candidate['repetition_count'];
      final intervalDays = candidate['interval_days'];
      final easeFactor = candidate['ease_factor'];
      final nextDueAt = candidate['next_due_at'];
      final status = candidate['status'];

      if (lexemeId is! String ||
          lexemeId.isEmpty ||
          lexemeId.length > 512 ||
          !seen.add(lexemeId) ||
          languageCode is! String ||
          languageCode.isEmpty ||
          languageCode.length > 32 ||
          repetitions is! int ||
          repetitions < 0 ||
          intervalDays is! int ||
          intervalDays < 0 ||
          easeFactor is! num ||
          !easeFactor.isFinite ||
          easeFactor < 1.0 ||
          (nextDueAt != null &&
              (nextDueAt is! int || nextDueAt < 0)) ||
          status is! String ||
          status.isEmpty ||
          status.length > 64) {
        throw const FormatException('Invalid or duplicate progress record.');
      }

      validated.add(<String, Object?>{
        'lexeme_id': lexemeId,
        'target_language_code': languageCode,
        'repetition_count': repetitions,
        'interval_days': intervalDays,
        'ease_factor': easeFactor.toDouble(),
        'next_due_at': nextDueAt,
        'status': status,
      });
      if (validated.length > _maxRecords) {
        throw const FormatException('Too many progress records.');
      }
    }
    return validated;
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
