import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'srs_scheduler_service.dart';

/// No key bytes ever cross the Flutter platform channel.
/// Android uses hardware AES when available and a versioned PBKDF2/AES
/// software envelope on devices without secure hardware.
abstract class VaultCipher {
  Future<Uint8List> encrypt(String recordId, Uint8List plaintext);
  Future<Uint8List> decrypt(String recordId, Uint8List ciphertext);
}

class AndroidKeystoreVaultCipher implements VaultCipher {
  const AndroidKeystoreVaultCipher();

  static const MethodChannel _channel =
      MethodChannel('com.deutschbilarabi.app/user_vault_security');

  static Never _keyFailure(PlatformException error, StackTrace trace) {
    // Do not silently regenerate a key: old device-bound ciphertext would be
    // irrecoverable. Existing records remain stored for explicit recovery.
    if (error.code == 'vault_key_unavailable_or_corrupt' ||
        error.code.toLowerCase().contains('keystore')) {
      UserVaultSecurityService.reportKeyFailure();
    }
    Error.throwWithStackTrace(error, trace);
  }

  @override
  Future<Uint8List> encrypt(String recordId, Uint8List plaintext) async {
    if (UserVaultSecurityService._keyUnavailable) {
      throw StateError('Vault key recovery is required before further writes');
    }
    try {
      final data = await _channel.invokeMethod<Uint8List>(
        'encrypt',
        <String, Object>{
          'recordId': recordId,
          'bytes': plaintext,
        },
      );
      if (data == null) throw StateError('Hardware vault unavailable');
      return data;
    } on PlatformException catch (error, trace) {
      _keyFailure(error, trace);
    }
  }

  @override
  Future<Uint8List> decrypt(String recordId, Uint8List ciphertext) async {
    try {
      final data = await _channel.invokeMethod<Uint8List>(
        'decrypt',
        <String, Object>{
          'recordId': recordId,
          'bytes': ciphertext,
        },
      );
      if (data == null) throw StateError('Vault decryption failed');
      UserVaultSecurityService._markKeyRecovered();
      return data;
    } on PlatformException catch (error, trace) {
      _keyFailure(error, trace);
    }
  }
}

class VaultException implements Exception {
  final String message;
  VaultException(this.message);
  @override
  String toString() => '$runtimeType: $message';
}

class KeyUnavailableException extends VaultException {
  KeyUnavailableException(super.message);
}

class CorruptRecordException extends VaultException {
  CorruptRecordException(super.message);
}

class TamperedRecordException extends VaultException {
  TamperedRecordException(super.message);
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
  })  : _cipher = cipher ?? const AndroidKeystoreVaultCipher(),
        _openDatabase = openVaultDatabase ?? _openDefault,
        _legacyDatabasePath = legacyDatabasePath ?? _defaultLegacyPath;
  // UI observes this state and offers retry without deleting ciphertext.
  static final ValueNotifier<String?> recoveryMessage =
      ValueNotifier<String?>(null);

  static bool _keyUnavailable = false;

  static void _markKeyRecovered() {
    _keyUnavailable = false;
    recoveryMessage.value = null;
  }

  static void reportKeyFailure() {
    _keyUnavailable = true;
    recoveryMessage.value =
        'تعذّر الوصول إلى مفتاح التشفير في Android Keystore. '
        'بيانات المراجعة المشفّرة محفوظة ولم تُحذف. '
        'تحقّق من قفل الجهاز ثم أعد المحاولة؛ قد تتطلب استعادة المفتاح '
        'القديم نسخة احتياطية صالحة.';
  }

  static void clearRecoveryMessage() {
    recoveryMessage.value = null;
  }

  static const maximumRecordBytes = 4 * 1024 * 1024;
  final VaultCipher _cipher;
  final Future<Database> Function() _openDatabase;
  final Future<String> Function() _legacyDatabasePath;
  Future<Database>? _cached;
  Future<LegacyProgressMigrationResult>? _migration;

  static Future<String> _defaultLegacyPath() async =>
      path.join(await getDatabasesPath(), 'user_progress_v2.db');

  static Future<Database> _openDefault() async {
    final root = await getDatabasesPath();
    return openDatabase(path.join(root, 'user_vault_v1.db'), version: 1,
        onCreate: (db, _) async {
      await db.execute('CREATE TABLE vault_entries ('
          'record_hash TEXT PRIMARY KEY, ciphertext BLOB NOT NULL)');
    });
  }

  Future<Database> get _db => _cached ??= _openDatabase();

  static void _validateId(String id) {
    if (!RegExp(r'^[a-zA-Z0-9_.:/-]{1,128}$').hasMatch(id)) {
      throw ArgumentError.value(id, 'recordId', 'Invalid vault record ID');
    }
  }

  static String _index(String id) => sha256.convert(utf8.encode(id)).toString();

  Future<void> putRecord(String id, Uint8List plaintext) async {
    _validateId(id);
    if (plaintext.length > maximumRecordBytes) {
      throw ArgumentError.value(
          plaintext.length, 'plaintext', 'Record too large');
    }
    // Encryption completes before any SQLite write.
    final ciphertext = await _cipher.encrypt(id, plaintext);
    if (ciphertext.length < 29 || (ciphertext[0] != 1 && ciphertext[0] != 2)) {
      throw StateError('Invalid encrypted vault envelope');
    }
    final database = await _db;
    await database.insert(
        'vault_entries',
        <String, Object>{
          'record_hash': _index(id),
          'ciphertext': ciphertext,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Uint8List?> readRecord(String id) async {
    _validateId(id);
    final database = await _db;
    final rows = await database.query('vault_entries',
        columns: <String>['ciphertext'],
        where: 'record_hash = ?',
        whereArgs: <Object>[_index(id)],
        limit: 1);
    if (rows.isEmpty) return null;
    final encrypted = rows.single['ciphertext'];
    if (encrypted is! Uint8List ||
        encrypted.length < 29 ||
        (encrypted[0] != 1 && encrypted[0] != 2)) {
      throw StateError('Vault record is corrupt');
    }
    return _cipher.decrypt(id, encrypted);
  }

  Future<void> deleteRecord(String id) async {
    _validateId(id);
    await (await _db).delete('vault_entries',
        where: 'record_hash = ?', whereArgs: <Object>[_index(id)]);
  }

  static const String _operationalReadyId = 'progress/v1/ready';

  // Bounded encrypted catalogs: no plaintext lexeme or bookmark IDs in SQLite.
  static const int _catalogBuckets = 256;

  static String _catalogKey(String kind, String id, String language) {
    final key = _progressKey(kind, id, language);
    return 'progress/v1/catalog/$kind/${_index(key).substring(0, 2)}';
  }

  Future<void> _catalogMutation(
      DatabaseExecutor txn, String kind, String id, String language,
      {required bool add}) async {
    final key = _catalogKey(kind, id, language);
    final raw = await _readEncryptedFrom(txn, key);
    final entries = raw == null
        ? <Map<String, dynamic>>[]
        : (jsonDecode(utf8.decode(raw)) as List)
            .map((entry) => Map<String, dynamic>.from(entry as Map))
            .toList();
    final index = entries.indexWhere(
        (entry) => entry['id'] == id && entry['language_code'] == language);
    if (add && index < 0) {
      entries.add({'id': id, 'language_code': language});
    } else if (!add && index >= 0) {
      entries.removeAt(index);
    } else {
      return;
    }
    entries.sort((a, b) {
      final x = (a['language_code'] as String)
          .compareTo(b['language_code'] as String);
      return x != 0 ? x : (a['id'] as String).compareTo(b['id'] as String);
    });
    if (entries.isEmpty) {
      await txn.delete('vault_entries',
          where: 'record_hash = ?', whereArgs: <Object>[_index(key)]);
    } else {
      await _writeEncrypted(
          txn, key, Uint8List.fromList(utf8.encode(jsonEncode(entries))),
          replace: true);
    }
  }

  /// Consistent live snapshot. Archive IDs supplement catalogs created after
  /// the phase-3 migration, without replacing newer active SRS values.
  Future<Map<String, List<Map<String, dynamic>>>>
      exportOperationalSnapshot() async {
    return (await _db).transaction((txn) async {
      final records = <String, List<Map<String, dynamic>>>{
        'srs': <Map<String, dynamic>>[],
        'bookmarks': <Map<String, dynamic>>[],
      };
      final seen = <String>{};
      Future<void> collect(String kind, String id, String lang,
          {bool catalog = false}) async {
        final key = _progressKey(kind, id, lang);
        if (!seen.add(key)) return;
        if (seen.length > _maximumLegacyRows) {
          throw StateError('Operational progress exceeds export limit');
        }
        final raw = await _readEncryptedFrom(txn, key);
        if (raw == null) {
          if (catalog) {
            throw StateError('Vault catalog references a missing record');
          }
          return; // Deleted record from an old immutable migration snapshot.
        }
        final data = _decodeProgress(raw);
        if (kind == 'srs') {
          if (data['lexeme_id'] != id || data['target_language_code'] != lang) {
            throw StateError('Vault SRS identity mismatch');
          }
          records['srs']!.add(data);
        } else {
          records['bookmarks']!.add({
            'id': id,
            'language_code': lang,
            'data': data,
          });
        }
      }

      for (final kind in <String>['srs', 'bookmark']) {
        for (var bucket = 0; bucket < _catalogBuckets; bucket++) {
          final key =
              'progress/v1/catalog/$kind/${bucket.toRadixString(16).padLeft(2, '0')}';
          final raw = await _readEncryptedFrom(txn, key);
          if (raw == null) continue;
          final entries = jsonDecode(utf8.decode(raw));
          if (entries is! List) throw StateError('Corrupt vault catalog');
          for (final item in entries) {
            final entry = Map<String, dynamic>.from(item as Map);
            final id = entry['id'];
            final lang = entry['language_code'];
            if (id is! String ||
                lang is! String ||
                _catalogKey(kind, id, lang) != key) {
              throw StateError('Vault catalog identity mismatch');
            }
            await collect(kind, id, lang, catalog: true);
          }
        }
      }
      final manifestRaw = await _readEncryptedFrom(txn, _manifestId);
      if (manifestRaw != null) {
        final manifest = _decodeProgress(manifestRaw);
        final tables = manifest['tables'];
        if (tables is! List) throw StateError('Corrupt legacy manifest');
        for (var t = 0; t < tables.length; t++) {
          final table = Map<String, dynamic>.from(tables[t] as Map);
          final name = table['name'];
          if (name != 'srs_progress' &&
              name != 'bookmarks' &&
              name != 'vault_bookmarks') {
            continue;
          }
          final count = table['count'];
          if (count is! int || count < 0 || count > _maximumLegacyRows) {
            throw StateError('Invalid legacy row count');
          }
          for (var n = 0; n < count; n++) {
            final raw = await _readEncryptedFrom(txn, _rowId(t, n));
            if (raw == null) throw StateError('Missing legacy snapshot row');
            final row = _decodeProgress(raw);
            final id = name == 'srs_progress'
                ? row['lexeme_id']
                : (row['id'] ?? row['lexeme_id'] ?? row['word']);
            if (id is String && id.isNotEmpty) {
              await collect(name == 'srs_progress' ? 'srs' : 'bookmark', id,
                  (row['target_language_code'] as String?) ?? 'de');
            }
          }
        }
      }
      for (final rows in records.values) {
        rows.sort((a, b) {
          final langA =
              (a['target_language_code'] ?? a['language_code']).toString();
          final langB =
              (b['target_language_code'] ?? b['language_code']).toString();
          final cmp = langA.compareTo(langB);
          return cmp != 0
              ? cmp
              : (a['lexeme_id'] ?? a['id'])
                  .toString()
                  .compareTo((b['lexeme_id'] ?? b['id']).toString());
        });
      }
      return records;
    });
  }

  /// Transactional restoration: progress, bookmarks and their encrypted
  /// catalogs are updated together. Unmentioned local entries remain intact.
  Future<Map<String, int>> restoreOperationalSnapshot({
    required List<Map<String, Object?>> srs,
    required List<Map<String, dynamic>> bookmarks,
    required bool Function(
            Map<String, Object?> local, Map<String, Object?> incoming)
        incomingWins,
  }) async {
    return (await _db).transaction((txn) async {
      await _ensureFreshReady(txn);
      var inserted = 0, updated = 0, unchanged = 0;
      var bookmarkInserted = 0, bookmarkUpdated = 0;
      for (final incoming in srs) {
        final id = incoming['lexeme_id'] as String;
        final lang = incoming['target_language_code'] as String;
        final key = _progressKey('srs', id, lang);
        final previous = await _readEncryptedFrom(txn, key);
        if (previous != null &&
            !incomingWins(Map<String, Object?>.from(_decodeProgress(previous)),
                incoming)) {
          unchanged++;
          continue;
        }
        await _writeEncrypted(
            txn, key, Uint8List.fromList(utf8.encode(jsonEncode(incoming))),
            replace: true);
        await _catalogMutation(txn, 'srs', id, lang, add: true);
        if (previous == null) {
          inserted++;
        } else {
          updated++;
        }
      }
      for (final item in bookmarks) {
        final id = item['id'] as String;
        final lang = item['language_code'] as String;
        final data = Map<String, dynamic>.from(item['data'] as Map);
        final key = _progressKey('bookmark', id, lang);
        final previous = await _readEncryptedFrom(txn, key);
        if (previous != null &&
            jsonEncode(_decodeProgress(previous)) == jsonEncode(data)) {
          continue;
        }
        await _writeEncrypted(
            txn, key, Uint8List.fromList(utf8.encode(jsonEncode(data))),
            replace: true);
        await _catalogMutation(txn, 'bookmark', id, lang, add: true);
        if (previous == null) {
          bookmarkInserted++;
        } else {
          bookmarkUpdated++;
        }
      }
      return {
        'inserted': inserted,
        'updated': updated,
        'unchanged': unchanged,
        'bookmarksInserted': bookmarkInserted,
        'bookmarksUpdated': bookmarkUpdated,
      };
    });
  }

  // Archive encryption uses the same hardware/software AES vault key.
  // Archives are device-bound (not cross-device password backups).
  Future<Uint8List> sealArchiveChunk(int index, Uint8List data) =>
      _cipher.encrypt('progress-backup/v2/chunk/$index', data);

  Future<Uint8List> unsealArchiveChunk(int index, Uint8List data) =>
      _cipher.decrypt('progress-backup/v2/chunk/$index', data);

  static String _progressKey(String kind, String id, String languageCode) {
    if (id.trim().isEmpty || languageCode.trim().isEmpty) {
      throw ArgumentError('Progress identity cannot be empty');
    }
    final identity = '${languageCode.trim().toLowerCase()}::${id.trim()}';
    return 'progress/v1/$kind/${_index(identity)}';
  }

  static Map<String, dynamic> _decodeProgress(Uint8List? bytes) {
    if (bytes == null) return <String, dynamic>{};
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map) throw StateError('Invalid operational vault record');
    return Map<String, dynamic>.from(decoded);
  }

  /// Never opens/creates the old SQLite file merely to probe it. If a
  /// cutover has not happened, consumers must continue using the legacy DB.
  /// Once a migrated backup exists, its encrypted ready marker is mandatory.
  Future<bool> get isOperationalActive async {
    final markerBytes = await readRecord(_operationalReadyId);
    final marker = _decodeProgress(markerBytes);
    if (marker['format'] == 'operational-progress-v1' &&
        marker['origin'] == 'fresh') {
      // A separate legacy exporter may create an empty progress DB later.
      // It must not demote an already-active vault.
      return true;
    }
    final legacy = File(await _legacyDatabasePath());
    final migratedBackup = await File('${legacy.path}.migrated').exists();
    if (migratedBackup && marker['format'] == 'operational-progress-v1') {
      // A legacy exporter can recreate the old filename after cutover.
      return true;
    }
    if (await legacy.exists()) return false;
    if (migratedBackup) {
      // A previous release stored only an encrypted legacy snapshot.
      await _activateArchivedSnapshot();
      return true;
    }
    // First use: durably record the authority before routing any write.
    await (await _db).transaction(_ensureFreshReady);
    return true;
  }

  Future<void> _ensureFreshReady(DatabaseExecutor txn) async {
    if (await _readEncryptedFrom(txn, _operationalReadyId) != null) return;
    await _writeEncrypted(
        txn,
        _operationalReadyId,
        Uint8List.fromList(utf8.encode(jsonEncode({
          'format': 'operational-progress-v1',
          'origin': 'fresh',
        }))));
  }

  /// Atomic encrypted SRS read/modify/write, keyed by language AND lexeme.
  /// No plaintext SRS fields are written into SQLite.
  Future<SrsReviewSchedule> gradeOperationalSrs({
    required String lexemeId,
    required String languageCode,
    required int grade,
    DateTime? reviewedAt,
  }) async {
    final key = _progressKey('srs', lexemeId, languageCode);
    return (await _db).transaction((txn) async {
      await _ensureFreshReady(txn);
      final prior = _decodeProgress(await _readEncryptedFrom(txn, key));
      final state = prior.isEmpty
          ? const SrsReviewState()
          : SrsReviewState(
              repetitionCount: (prior['repetition_count'] as num).toInt(),
              intervalDays: (prior['interval_days'] as num).toInt(),
              easeFactor: (prior['ease_factor'] as num).toDouble(),
            );
      final timestamp = (reviewedAt ?? DateTime.now()).toUtc();
      final schedule = SrsSchedulerService()
          .calculate(grade: grade, previous: state, reviewedAt: timestamp);
      await _writeEncrypted(
          txn,
          key,
          Uint8List.fromList(utf8.encode(jsonEncode({
            'lexeme_id': lexemeId,
            'target_language_code': languageCode,
            'repetition_count': schedule.repetitionCount,
            'interval_days': schedule.intervalDays,
            'ease_factor': schedule.easeFactor,
            'next_due_at': schedule.nextReviewEpoch,
            'last_reviewed_at': timestamp.millisecondsSinceEpoch ~/ 1000,
            'status': schedule.repetitionCount > 1 ? 'review' : 'learning',
          }))),
          replace: true);
      await _catalogMutation(txn, 'srs', lexemeId, languageCode, add: true);
      return schedule;
    });
  }

  Future<Map<String, dynamic>?> readOperationalSrs({
    required String lexemeId,
    required String languageCode,
  }) async {
    final bytes = await readRecord(_progressKey('srs', lexemeId, languageCode));
    return bytes == null ? null : _decodeProgress(bytes);
  }

  /// Preserves the older increment-only API for its existing consumers.
  Future<void> incrementOperationalSrs({
    required String lexemeId,
    required String languageCode,
    required String status,
  }) async {
    final key = _progressKey('srs', lexemeId, languageCode);
    await (await _db).transaction((txn) async {
      await _ensureFreshReady(txn);
      final prior = _decodeProgress(await _readEncryptedFrom(txn, key));
      prior.addAll({
        'lexeme_id': lexemeId,
        'target_language_code': languageCode,
        'repetition_count':
            ((prior['repetition_count'] as num?) ?? 0).toInt() + 1,
        'interval_days': (prior['interval_days'] as num?)?.toInt() ?? 1,
        'ease_factor': (prior['ease_factor'] as num?)?.toDouble() ?? 2.5,
        'status': status,
      });
      await _writeEncrypted(
          txn, key, Uint8List.fromList(utf8.encode(jsonEncode(prior))),
          replace: true);
      await _catalogMutation(txn, 'srs', lexemeId, languageCode, add: true);
    });
  }

  Future<void> putOperationalBookmark({
    required String bookmarkId,
    required String languageCode,
    required Map<String, dynamic> data,
  }) async {
    final key = _progressKey('bookmark', bookmarkId, languageCode);
    await (await _db).transaction((txn) async {
      await _ensureFreshReady(txn);
      await _writeEncrypted(
          txn, key, Uint8List.fromList(utf8.encode(jsonEncode(data))),
          replace: true);
      await _catalogMutation(txn, 'bookmark', bookmarkId, languageCode,
          add: true);
    });
  }

  Future<Map<String, dynamic>?> readOperationalBookmark({
    required String bookmarkId,
    required String languageCode,
  }) async {
    final bytes =
        await readRecord(_progressKey('bookmark', bookmarkId, languageCode));
    return bytes == null ? null : _decodeProgress(bytes);
  }

  Future<void> deleteOperationalBookmark({
    required String bookmarkId,
    required String languageCode,
  }) async {
    final key = _progressKey('bookmark', bookmarkId, languageCode);
    await (await _db).transaction((txn) async {
      await _ensureFreshReady(txn);
      await txn.delete('vault_entries',
          where: 'record_hash = ?', whereArgs: <Object>[_index(key)]);
    });
  }

  Future<void> _hydrateOperationalRow(DatabaseExecutor destination,
      String table, Map<String, dynamic> row) async {
    if (table == 'srs_progress' && row['lexeme_id'] is String) {
      final id = row['lexeme_id'] as String;
      final lang = (row['target_language_code'] as String?) ?? 'de';
      final normalized = <String, Object?>{
        ...row,
        'target_language_code': lang,
        'repetition_count': row['repetition_count'] ?? 0,
        'interval_days': row['interval_days'] ?? 1,
        'ease_factor': row['ease_factor'] ?? 2.5,
        'status': row['status'] ?? 'learning',
      };
      await _writeEncrypted(destination, _progressKey('srs', id, lang),
          Uint8List.fromList(utf8.encode(jsonEncode(normalized))),
          replace: true);
      await _catalogMutation(destination, 'srs', id, lang, add: true);
    } else if (table == 'bookmarks' || table == 'vault_bookmarks') {
      final id = row['id'] ?? row['lexeme_id'] ?? row['word'];
      if (id is! String || id.isEmpty) return;
      final lang = (row['target_language_code'] as String?) ?? 'de';
      final payload = row['payload'];
      final live = payload is String
          ? _decodeProgress(Uint8List.fromList(utf8.encode(payload)))
          : Map<String, dynamic>.from(row);
      await _writeEncrypted(destination, _progressKey('bookmark', id, lang),
          Uint8List.fromList(utf8.encode(jsonEncode(live))),
          replace: true);
      await _catalogMutation(destination, 'bookmark', id, lang, add: true);
    }
  }

  Future<void> _activateArchivedSnapshot() async {
    await (await _db).transaction((txn) async {
      if (await _readEncryptedFrom(txn, _operationalReadyId) != null) return;
      final manifestBytes = await _readEncryptedFrom(txn, _manifestId);
      if (manifestBytes == null) {
        throw StateError('Archived vault manifest missing');
      }
      final manifest = _decodeProgress(manifestBytes);
      if (manifest['format'] != 'legacy-sqlite-snapshot-v1' ||
          manifest['tables'] is! List) {
        throw StateError('Archived vault manifest is not supported');
      }
      final tables = manifest['tables'] as List;
      final counts = <String, int>{};
      var total = 0;
      for (final item in tables) {
        final record = Map<String, dynamic>.from(item as Map);
        final name = record['name'];
        final count = record['count'];
        if (name is! String || count is! int || count < 0) {
          throw StateError('Archived vault table is malformed');
        }
        total += count;
        if (total > _maximumLegacyRows) {
          throw StateError('Archived vault exceeds safe migration limit');
        }
        counts[name] = count;
      }
      await _verifyLegacySnapshot(txn, counts);
      for (var t = 0; t < tables.length; t++) {
        final table = Map<String, dynamic>.from(tables[t] as Map);
        final name = table['name'] as String;
        if (name != 'srs_progress' &&
            name != 'bookmarks' &&
            name != 'vault_bookmarks') {
          continue;
        }
        for (var index = 0; index < (table['count'] as int); index++) {
          final plain = await _readEncryptedFrom(txn, _rowId(t, index));
          if (plain == null) throw StateError('Archived vault row missing');
          await _hydrateOperationalRow(txn, name, _decodeProgress(plain));
        }
      }
      await _writeEncrypted(
          txn,
          _operationalReadyId,
          Uint8List.fromList(utf8.encode(jsonEncode(
              {'format': 'operational-progress-v1', 'origin': 'migrated'}))));
    });
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
    Uint8List plaintext, {
    bool replace = false,
  }) async {
    _validateId(id);
    if (plaintext.length > maximumRecordBytes) {
      throw StateError('Legacy record exceeds vault limit');
    }
    final cipher = await _cipher.encrypt(id, plaintext);
    if (cipher.length < 29 || (cipher[0] != 1 && cipher[0] != 2)) {
      throw StateError('Vault cipher returned an invalid envelope');
    }
    await destination.insert(
        'vault_entries',
        <String, Object>{
          'record_hash': _index(id),
          'ciphertext': cipher,
        },
        conflictAlgorithm:
            replace ? ConflictAlgorithm.replace : ConflictAlgorithm.abort);
  }

  Future<Uint8List?> _readEncryptedFrom(
      DatabaseExecutor database, String id) async {
    _validateId(id);
    final rows = await database.query('vault_entries',
        columns: <String>['ciphertext'],
        where: 'record_hash = ?',
        whereArgs: <Object>[_index(id)],
        limit: 1);
    if (rows.isEmpty) return null;
    final encrypted = rows.single['ciphertext'];
    if (encrypted is! Uint8List ||
        encrypted.length < 29 ||
        (encrypted[0] != 1 && encrypted[0] != 2)) {
      throw StateError('Vault record is corrupt');
    }
    return _cipher.decrypt(id, encrypted);
  }

  Future<void> _verifyLegacySnapshot(
      DatabaseExecutor destination, Map<String, int> counts) async {
    // Verify every saved ciphertext through the real decrypt boundary,
    // including a per-table digest and precise row count, before renaming.
    final manifestBytes = await _readEncryptedFrom(destination, _manifestId);
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
        final record = await _readEncryptedFrom(destination, _rowId(t, index));
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
  }

  Future<LegacyProgressMigrationResult> _migrateLegacyProgressDatabase() async {
    final oldFile = File(await _legacyDatabasePath());
    if (!await oldFile.exists()) {
      return const LegacyProgressMigrationResult(
        migrated: false,
        tableRowCounts: <String, int>{},
      );
    }
    final backup = File('${oldFile.path}.migrated');
    if (await backup.exists()) {
      throw StateError('Previous migrated backup must not be overwritten');
    }

    final destination = await _db;
    if ((await destination.query('vault_entries',
            columns: ['record_hash'],
            where: 'record_hash = ?',
            whereArgs: [_index(_manifestId)],
            limit: 1))
        .isNotEmpty) {
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
          final definitions = objects
              .where((entry) => entry['type'] == 'table')
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
                ) ??
                0;
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
                  ? count - offset
                  : _migrationPageSize;
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
                // The imported active index and snapshot commit together.
                await _hydrateOperationalRow(vaultTxn, name, row);
              }
            }
            tables.add(<String, Object?>{
              'name': name,
              'sql': definition['sql'],
              'count': count,
              'digest':
                  sha256.convert(utf8.encode(rowDigests.toString())).toString(),
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
          await _writeEncrypted(
              vaultTxn,
              _operationalReadyId,
              Uint8List.fromList(utf8
                  .encode(jsonEncode({'format': 'operational-progress-v1'}))));
        });
        // Do not commit a vault snapshot until every record decrypts and its
        // counts and digests match the original SQLite read transaction.
        await _verifyLegacySnapshot(vaultTxn, counts);
      });

      // Flush any journaled transactions before moving just the SQLite file.
      // Fail closed if another connection prevents a full checkpoint.
      final checkpoint =
          await source.rawQuery('PRAGMA wal_checkpoint(TRUNCATE)');
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
      migrated: true,
      tableRowCounts: Map<String, int>.unmodifiable(counts),
    );
  }
}
