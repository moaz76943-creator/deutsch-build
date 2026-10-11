import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'database_integrity_service.dart';
import 'diagnostic_ledger_service.dart';
import 'pooled_database_manager.dart';
import 'storage_migration_service.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();

  static const String germanGoldenSha256 =
      '359b7e31e06a9c79218e9c8340343529cb3b68d2d4ddac7822880f1c5bfee366';
  static const String _germanAssetPath =
      'assets/content/packs/de/sqlite/de-1.0.0.sqlite';
  static const String _germanDatabaseFileName = 'polyglot_content_v2.db';
  static Database? _progressDb;
  late final PooledDatabaseManager _contentPool = PooledDatabaseManager(
    openConnection: _openContentDb,
  );

  DatabaseService._init();

  // Backward-compatible default content database getter.
  Future<Database> get contentDb => getContentDb();

  Future<Database> getContentDb([String? languageCode]) =>
      _contentPool.open(_normalizeLanguageCode(languageCode));

  Future<T> withContentDb<T>(
    String languageCode,
    Future<T> Function(Database database) action,
  ) => _contentPool.withDatabase(_normalizeLanguageCode(languageCode), action);

  // User progress remains physically and logically isolated from content packs.
  Future<Database> get progressDb async {
    if (_progressDb != null) return _progressDb!;
    _progressDb = await _initProgressDb('user_progress_v2.db');
    return _progressDb!;
  }

  Future<Database> _openContentDb(String languageCode) async {
    Database? db;
    try {
      final databasePath = languageCode == 'de'
          ? await _ensureGermanDatabase()
          : await _installedPackPath(languageCode);

      db = await openDatabase(
        databasePath,
        readOnly: true,
        singleInstance: false,
      );
      if (!await DatabaseIntegrityService.instance
          .checkMountedPack(languageCode, db)) {
        throw StateError('SQLite content pack is quarantined: $languageCode');
      }
      await _verifyUniversalSchema(db, languageCode);

      return db;
    } catch (error) {
      if (db != null && db.isOpen) {
        try {
          await db.close();
        } catch (_) {}
      }
      await DatabaseIntegrityService.instance.quarantine(languageCode, error);
      rethrow;
    }
  }

  Future<String> _ensureGermanDatabase() async {
    final dbRoot = await getDatabasesPath();
    final target = File(path.join(dbRoot, _germanDatabaseFileName));

    if (await target.exists()) {
      final installedHash = await _sha256File(target);
      if (_constantTimeHexEquals(installedHash, germanGoldenSha256)) {
        return target.path;
      }
    }

    final assetData = await rootBundle.load(_germanAssetPath);
    final assetBytes = assetData.buffer.asUint8List(
      assetData.offsetInBytes,
      assetData.lengthInBytes,
    );
    final assetHash = sha256.convert(assetBytes).toString();
    if (!_constantTimeHexEquals(assetHash, germanGoldenSha256)) {
      throw StateError(
        'Bundled German database does not match the Golden baseline. '
        'Expected $germanGoldenSha256, got $assetHash.',
      );
    }

    await Directory(dbRoot).create(recursive: true);
    final staged = File('${target.path}.installing');
    if (await staged.exists()) {
      await staged.delete();
    }
    await staged.writeAsBytes(assetBytes, flush: true);
    await _verifySqliteHeader(staged);
    await _replaceAtomically(staged, target);
    return target.path;
  }

  Future<String> _installedPackPath(String languageCode) async {
    final located = await StorageMigrationService()
        .resolvePackPath('$languageCode.sqlite');
    if (located == null) {
      throw StateError('Language pack $languageCode is not installed');
    }
    return located;
  }

  Future<void> _verifyUniversalSchema(
    Database db,
    String languageCode,
  ) async {
    final rows = await db.rawQuery('''
      SELECT name, type
      FROM sqlite_master
      WHERE name IN ('metadata', 'lexicon', 'concepts', 'grammar', 'lexemes', 'examples')
    ''');
    final names = rows
        .map((row) => row['name'])
        .whereType<String>()
        .toSet();
    const required = <String>{
      'metadata',
      'lexicon',
      'concepts',
      'grammar',
      'lexemes',
      'examples',
    };
    if (!names.containsAll(required)) {
      throw StateError(
        'Content database $languageCode does not satisfy the universal schema contract',
      );
    }

    final metadataRows = await db.rawQuery(
      "SELECT value FROM metadata WHERE key = 'languageCode' LIMIT 1",
    );
    if (metadataRows.isNotEmpty) {
      final storedCode = metadataRows.first['value']?.toString().toLowerCase();
      if (storedCode != null &&
          _normalizeLanguageCode(storedCode) != languageCode) {
        throw StateError(
          'Content database language mismatch: expected $languageCode, got $storedCode',
        );
      }
    }
  }

  Future<void> closeContentDb([String? languageCode]) =>
      _contentPool.close(_normalizeLanguageCode(languageCode));

  Future<void> closeAllContentDbs() => _contentPool.closeAll();

  Future<File> migrateContentPack(
    String filename, {
    required PackStorageLocation destination,
  }) => StorageMigrationService(
        closeContentDb: (languageCode) => closeContentDb(languageCode),
      ).migratePack(filename, destination: destination);

  Future<Database> _initProgressDb(String fileName) async {
    final dbPath = await getDatabasesPath();
    final databasePath = path.join(dbPath, fileName);

    return await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS srs_progress (
           lexeme_id TEXT PRIMARY KEY,
           target_language_code TEXT NOT NULL,
           repetition_count INTEGER NOT NULL DEFAULT 0,
           interval_days INTEGER NOT NULL DEFAULT 1,
           ease_factor REAL NOT NULL DEFAULT 2.5,
           next_due_at INTEGER,
           status TEXT NOT NULL DEFAULT 'learning'
          )
        ''');
      },
    );
  }

  Future<List<Map<String, dynamic>>> searchDictionary(
    String query,
    String langCode,
  ) async {
    final code = _normalizeLanguageCode(langCode);
    final db = await getContentDb(code);
    final trimmedQuery = query.trim();
    final rows = trimmedQuery.isEmpty
        ? await db.rawQuery('''
            SELECT id, surface, part_of_speech, fields_json
            FROM lexicon
            LIMIT 20
          ''')
        : await db.rawQuery('''
            SELECT id, surface, part_of_speech, fields_json
            FROM lexicon
            WHERE surface LIKE ? OR fields_json LIKE ?
            LIMIT 20
          ''', <Object?>['%$trimmedQuery%', '%$trimmedQuery%']);

    return rows.map((row) => _unpackLexiconRow(row, code)).toList();
  }

  Map<String, dynamic> _unpackLexiconRow(
    Map<String, Object?> row,
    String languageCode,
  ) {
    Map<String, dynamic> fields = <String, dynamic>{};
    final rawFields = row['fields_json'];
    if (rawFields is String && rawFields.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawFields);
        if (decoded is Map) {
          fields = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }

    final id = row['id']?.toString() ?? '';
    final surface = row['surface']?.toString() ?? '';
    final lemma = fields['lemma']?.toString() ?? surface;
    final translation = fields['translation_ar'] ?? fields['translation'];
    final sentence = fields['sentence'] ?? fields['example'];

    return <String, dynamic>{
      'id': id,
      'lexeme_id': id,
      'concept_id': id,
      'language_code': languageCode,
      'surface': surface,
      'display_text': surface,
      'part_of_speech': row['part_of_speech'],
      'lemma': lemma,
      'article': fields['article'],
      'plural': fields['plural'],
      'translation_ar': translation,
      'sentence': sentence,
      'fields_json': rawFields,
      'fields': fields,
    };
  }

  Future<void> updateSrsProgressAtomic({
    required String lexemeId,
    required String status,
    String languageCode = 'de',
  }) async {
    try {
      final db = await progressDb;
      await db.transaction((txn) async {
        await txn.rawInsert('''
          INSERT OR REPLACE INTO srs_progress (lexeme_id, target_language_code, repetition_count, status)
          VALUES (?, ?,
            COALESCE((SELECT repetition_count + 1 FROM srs_progress WHERE lexeme_id = ?), 1),
            ?
          )
        ''', [lexemeId, languageCode, lexemeId, status]);
      });
    } catch (error) {
      await DiagnosticLedgerService.instance.record(
        category: 'sqlite_write',
        languageCode: languageCode,
        error: error,
      );
      rethrow;
    }
  }

  static String _normalizeLanguageCode(String? value) {
    final normalized = (value ?? 'de').trim().toLowerCase().replaceAll('_', '-');
    if (!RegExp(r'^[a-z]{2,3}(?:-[a-z0-9]{2,8})*$').hasMatch(normalized)) {
      throw ArgumentError.value(value, 'languageCode', 'Invalid language code');
    }
    return normalized.split('-').first == 'de' ? 'de' : normalized;
  }

  static Future<void> _verifySqliteHeader(File file) async {
    final raf = await file.open(mode: FileMode.read);
    try {
      final header = await raf.read(16);
      if (header.length < 16 ||
          !String.fromCharCodes(header).startsWith('SQLite format 3')) {
        throw StateError('Bundled German asset is not a valid SQLite database');
      }
    } finally {
      await raf.close();
    }
  }

  static Future<void> _replaceAtomically(File staged, File target) async {
    final backup = File('${target.path}.bak');
    if (await backup.exists()) {
      await backup.delete();
    }

    final hadTarget = await target.exists();
    if (hadTarget) {
      await target.rename(backup.path);
    }
    try {
      await staged.rename(target.path);
      if (await backup.exists()) {
        await backup.delete();
      }
    } catch (_) {
      if (await staged.exists()) {
        await staged.delete();
      }
      if (await backup.exists() && !await target.exists()) {
        await backup.rename(target.path);
      }
      rethrow;
    }
  }

  static Future<String> _sha256File(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  static bool _constantTimeHexEquals(String left, String right) {
    final a = left.toLowerCase();
    final b = right.toLowerCase();
    if (a.length != b.length) {
      return false;
    }
    var difference = 0;
    for (var index = 0; index < a.length; index++) {
      difference |= a.codeUnitAt(index) ^ b.codeUnitAt(index);
    }
    return difference == 0;
  }
}
