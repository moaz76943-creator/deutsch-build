import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'database_integrity_service.dart';
import 'diagnostic_ledger_service.dart';
import 'crash_loop_guard.dart';
import 'pooled_database_manager.dart';
import 'storage_migration_service.dart';
import 'srs_scheduler_service.dart';
import 'user_vault_security_service.dart';

/// Language-tagged content, including definition fallbacks which may be English.
class LexiconTranslation {
  const LexiconTranslation(this.text, this.languageCode);

  final String text;
  final String? languageCode;
}

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();

  static const String germanGoldenSha256 =
      '359b7e31e06a9c79218e9c8340343529cb3b68d2d4ddac7822880f1c5bfee366';
  static const String _germanAssetPath =
      'assets/content/packs/de/sqlite/de-1.0.0.sqlite';
  static const String _germanDatabaseFileName = 'polyglot_content_v2.db';
  static Database? _progressDb;
  late final UserVaultSecurityService _progressVault = UserVaultSecurityService();
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
    // The bundled-pack SHA-256 check is also deferred beyond cold boot.
    await CrashLoopGuard.waitForIntegrityWindow();
    if(languageCode!='de' && CrashLoopGuard.instance.safeModeEnabled) {
      throw StateError('External content packs are disabled in safe mode');
    }
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

    // Reject old packs before they can be bound to a read-only consumer.
    final lexiconColumns = await db.rawQuery('PRAGMA table_info(lexicon)');
    final columnNames = lexiconColumns
        .map((column) => column['name'])
        .whereType<String>()
        .toSet();
    if (!columnNames.contains('sort_key')) {
      throw StateError(
        'Content database $languageCode is missing required lexicon.sort_key',
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
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS srs_progress (
            lexeme_id TEXT NOT NULL,
            target_language_code TEXT NOT NULL,
            repetition_count INTEGER NOT NULL DEFAULT 0,
            interval_days INTEGER NOT NULL DEFAULT 1,
            ease_factor REAL NOT NULL DEFAULT 2.5,
            next_due_at INTEGER,
            status TEXT NOT NULL DEFAULT 'learning',
            PRIMARY KEY (lexeme_id, target_language_code)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // sqflite runs the upgrade in a transaction. Preserve the existing
          // scheduling counters/due times while widening the identity key.
          await db.execute('''
            CREATE TABLE srs_progress_migration (
              lexeme_id TEXT NOT NULL,
              target_language_code TEXT NOT NULL,
              repetition_count INTEGER NOT NULL DEFAULT 0,
              interval_days INTEGER NOT NULL DEFAULT 1,
              ease_factor REAL NOT NULL DEFAULT 2.5,
              next_due_at INTEGER,
              status TEXT NOT NULL DEFAULT 'learning',
              PRIMARY KEY (lexeme_id, target_language_code)
            )
          ''');
          await db.execute('''
            INSERT INTO srs_progress_migration (
              lexeme_id, target_language_code, repetition_count,
              interval_days, ease_factor, next_due_at, status
            )
            SELECT lexeme_id, target_language_code, repetition_count,
                   interval_days, ease_factor, next_due_at, status
            FROM srs_progress
          ''');
          await db.execute('DROP TABLE srs_progress');
          await db.execute(
            'ALTER TABLE srs_progress_migration RENAME TO srs_progress',
          );
        }
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

  /// Interpret both legacy flat values and structured v2 translations.
  /// A definition must retain its source language instead of pretending to be Arabic.
  static LexiconTranslation? resolveLexiconTranslation(
    Map<String, dynamic> fields,
  ) {
    String? nonEmptyText(Object? value) {
      if (value is! String || value.trim().isEmpty) return null;
      return value.trim();
    }

    String? languageTag(Object? value) {
      final code = nonEmptyText(value);
      return code?.toLowerCase().replaceAll('_', '-');
    }

    LexiconTranslation? taggedItem(Object? value) {
      if (value is! Map) return null;
      final text = nonEmptyText(value['text']);
      if (text == null) return null;
      return LexiconTranslation(
        text,
        languageTag(value['languageCode'] ?? value['language_code']),
      );
    }

    final directArabic = nonEmptyText(fields['translation_ar']);
    if (directArabic != null) {
      return LexiconTranslation(directArabic, 'ar');
    }

    final direct = nonEmptyText(fields['translation']);
    if (direct != null) {
      return LexiconTranslation(
        direct,
        languageTag(
          fields['translationLanguageCode'] ??
              fields['translation_language_code'],
        ),
      );
    }

    final translations = fields['translations'];
    if (translations is List) {
      LexiconTranslation? firstAvailable;
      for (final item in translations) {
        final candidate = taggedItem(item);
        if (candidate == null) continue;
        if (candidate.languageCode == 'ar') return candidate;
        firstAvailable ??= candidate;
      }
      if (firstAvailable != null) return firstAvailable;
    }

    final definitions = fields['definitions'];
    if (definitions is List) {
      for (final item in definitions) {
        final candidate = taggedItem(item);
        if (candidate != null) return candidate;
      }
    }
    return null;
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
    final translation = resolveLexiconTranslation(fields);
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
      'translation_ar': translation?.text,
      'translation_language_code': translation?.languageCode,
      'sentence': sentence,
      'fields_json': rawFields,
      'fields': fields,
    };
  }

  /// Single write authority for active flashcard reviews. Legacy sessions
  /// continue on user_progress_v2.db until the verified vault cutover.
  Future<SrsReviewSchedule> gradeAndPersistSrs({
    required String lexemeId,
    required String languageCode,
    required int grade,
    DateTime? reviewedAt,
  }) async {
    if (await _progressVault.isOperationalActive) {
      return _progressVault.gradeOperationalSrs(
        lexemeId: lexemeId, languageCode: languageCode,
        grade: grade, reviewedAt: reviewedAt);
    }
    return SrsSchedulerService().gradeAndPersist(
      progressDb: await progressDb, lexemeId: lexemeId,
      languageCode: languageCode, grade: grade, reviewedAt: reviewedAt);
  }

  Future<void> saveBookmark({
    required String bookmarkId,
    required String languageCode,
    required Map<String, dynamic> data,
  }) async {
    if (await _progressVault.isOperationalActive) {
      await _progressVault.putOperationalBookmark(
        bookmarkId: bookmarkId, languageCode: languageCode, data: data);
      return;
    }
    final db = await progressDb;
    await _ensureLegacyBookmarks(db);
    await db.insert('vault_bookmarks', {
      'id': bookmarkId,
      'target_language_code': languageCode,
      'payload': jsonEncode(data),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> readBookmark({
    required String bookmarkId,
    required String languageCode,
  }) async {
    if (await _progressVault.isOperationalActive) {
      return _progressVault.readOperationalBookmark(
        bookmarkId: bookmarkId, languageCode: languageCode);
    }
    final db = await progressDb;
    await _ensureLegacyBookmarks(db);
    final rows = await db.query('vault_bookmarks',
      where: 'id = ? AND target_language_code = ?',
      whereArgs: [bookmarkId, languageCode], limit: 1);
    if (rows.isEmpty) return null;
    return Map<String, dynamic>.from(jsonDecode(rows.single['payload'] as String) as Map);
  }

  Future<void> deleteBookmark({
    required String bookmarkId,
    required String languageCode,
  }) async {
    if (await _progressVault.isOperationalActive) {
      await _progressVault.deleteOperationalBookmark(
        bookmarkId: bookmarkId, languageCode: languageCode);
      return;
    }
    final db = await progressDb;
    await _ensureLegacyBookmarks(db);
    await db.delete('vault_bookmarks',
        where: 'id = ? AND target_language_code = ?',
        whereArgs: [bookmarkId, languageCode]);
  }

  Future<void> _ensureLegacyBookmarks(Database db) => db.execute('''
    CREATE TABLE IF NOT EXISTS vault_bookmarks (
      id TEXT NOT NULL,
      target_language_code TEXT NOT NULL,
      payload TEXT NOT NULL,
      PRIMARY KEY (id, target_language_code)
    )
  ''');

  Future<void> updateSrsProgressAtomic({
    required String lexemeId,
    required String status,
    String languageCode = 'de',
  }) async {
    try {
      final normalizedCode = _normalizeLanguageCode(languageCode);
      if (await _progressVault.isOperationalActive) {
        await _progressVault.incrementOperationalSrs(
          lexemeId: lexemeId, languageCode: normalizedCode, status: status);
        return;
      }
      final db = await progressDb;
      await db.transaction((txn) async {
        await txn.rawInsert('''
          INSERT INTO srs_progress (
            lexeme_id, target_language_code, repetition_count, status
          )
          VALUES (?, ?, 1, ?)
          ON CONFLICT(lexeme_id, target_language_code) DO UPDATE SET
            repetition_count = srs_progress.repetition_count + 1,
            status = excluded.status
        ''', <Object?>[lexemeId, normalizedCode, status]);
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
