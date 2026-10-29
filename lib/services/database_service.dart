import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

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

// Pass only bounded, plain SQLite values to a background isolate; never a
// sqflite Database handle or a StatefulWidget/BuildContext.
List<Map<String, dynamic>> _decodeLexiconRows(Map<String, Object?> request) {
  final languageCode = request['languageCode'] as String;
  final rows = request['rows'] as List;
  return rows
      .map((row) => DatabaseService._unpackLexiconRow(
            Map<String, Object?>.from(row as Map),
            languageCode,
          ))
      .toList(growable: false);
}

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();

  static const String germanGoldenSha256 =
      'cc6f23bad631f6d0f13b5adb4fb840397534db496d5cdc375dce91d00920e2d2';
  static const String _germanAssetPath =
      'assets/content/packs/de/sqlite/de-1.0.0.sqlite';
  static const String _germanDatabaseFileName = 'polyglot_content_v2.db';
  static Database? _progressDb;
  static Future<Database>? _progressDbInitFuture;
  late final UserVaultSecurityService _progressVault =
      UserVaultSecurityService();
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
  ) =>
      _contentPool.withDatabase(_normalizeLanguageCode(languageCode), action);

  // User progress remains physically and logically isolated from content packs.
  Future<Database> get progressDb async {
    if (_progressDb != null) return _progressDb!;
    if (_progressDbInitFuture != null) return await _progressDbInitFuture!;
    _progressDbInitFuture = _initProgressDb('user_progress_v2.db');
    try {
      _progressDb = await _progressDbInitFuture!;
    } finally {
      _progressDbInitFuture = null;
    }
    return _progressDb!;
  }

  Future<Database> _openContentDb(String languageCode) async {
    // The bundled-pack SHA-256 check is also deferred beyond cold boot.
    await CrashLoopGuard.waitForIntegrityWindow();
    if (languageCode != 'de' && CrashLoopGuard.instance.safeModeEnabled) {
      throw StateError('External content packs are disabled in safe mode');
    }
    Database? db;
    try {
      final databasePath = languageCode == 'de'
          ? await _ensureGermanDatabase()
          : await _installedPackPath(languageCode);

      db = await _openContentReadOnly(databasePath);
      if (!await DatabaseIntegrityService.instance
          .checkMountedPack(languageCode, db)) {
        throw StateError('SQLite content pack is quarantined: $languageCode');
      }
      await verifyUniversalSchema(db, languageCode);

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

  Future<Database> _initContentDb(String fileName) async {
    final dbPath = await getDatabasesPath();
    final filePath = path.join(dbPath, fileName);

    return await openDatabase(
      filePath,
      version: 1,
      onOpen: (db) async {
        await db.execute('PRAGMA journal_mode = WAL;');
        await db.execute('PRAGMA synchronous = NORMAL;');
        await db.execute('PRAGMA busy_timeout = 5000;');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS language_profiles (
            language_code TEXT PRIMARY KEY,
            name_native TEXT NOT NULL,
            name_ar TEXT NOT NULL,
            direction TEXT NOT NULL
          );
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS concepts (
            concept_id TEXT PRIMARY KEY,
            category TEXT NOT NULL,
            cefr_level TEXT NOT NULL
          );
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS lexemes (
            lexeme_id TEXT PRIMARY KEY,
            concept_id TEXT NOT NULL,
            language_code TEXT NOT NULL,
            lemma TEXT NOT NULL,
            display_text TEXT NOT NULL,
            article TEXT,
            plural TEXT,
            gender TEXT,
            grammar_json TEXT DEFAULT '{}'
          );
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS examples (
            example_id TEXT PRIMARY KEY,
            concept_id TEXT NOT NULL,
            language_code TEXT NOT NULL,
            sentence TEXT NOT NULL,
            translation_ar TEXT
          );
        ''');

        await _seedInitialData(db);
      },
    );
  }

  // The bundled SQLite library is used only for immutable content packs.
  // Device/system sqflite remains the backend for learner progress.
  static Future<Database> _openContentReadOnly(String databasePath) async {
    try {
      ffi.sqfliteFfiInit();
      return await ffi.databaseFactoryFfi.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(
          readOnly: true,
          singleInstance: false,
        ),
      );
    } on Exception catch (error) {
      debugPrint('Bundled SQLite unavailable; using platform fallback: $error');
      return openDatabase(
        databasePath,
        readOnly: true,
        singleInstance: false,
      );
    }
  }

  Future<void> _seedInitialData(Database db) async {
    final batch = db.batch();
    batch.insert('language_profiles', {
      'language_code': 'de',
      'name_native': 'Deutsch',
      'name_ar': 'الألمانية',
      'direction': 'ltr',
    });
    batch.insert('language_profiles', {
      'language_code': 'ar',
      'name_native': 'العربية',
      'name_ar': 'العربية',
      'direction': 'rtl',
    });
    batch.insert('concepts', {
      'concept_id': 'daily.water',
      'category': 'daily',
      'cefr_level': 'A1',
    });
    batch.insert('concepts', {
      'concept_id': 'daily.book',
      'category': 'daily',
      'cefr_level': 'A1',
    });
    batch.insert('concepts', {
      'concept_id': 'daily.car',
      'category': 'daily',
      'cefr_level': 'A1',
    });
    batch.insert('lexemes', {
      'lexeme_id': 'lex.de.water',
      'concept_id': 'daily.water',
      'language_code': 'de',
      'lemma': 'Wasser',
      'display_text': 'das Wasser',
      'article': 'das',
      'gender': 'n',
    });
    batch.insert('lexemes', {
      'lexeme_id': 'lex.de.book',
      'concept_id': 'daily.book',
      'language_code': 'de',
      'lemma': 'Buch',
      'display_text': 'das Buch',
      'article': 'das',
      'plural': 'Bücher',
      'gender': 'n',
    });
    batch.insert('lexemes', {
      'lexeme_id': 'lex.de.car',
      'concept_id': 'daily.car',
      'language_code': 'de',
      'lemma': 'Auto',
      'display_text': 'das Auto',
      'article': 'das',
      'plural': 'Autos',
      'gender': 'n',
    });
    batch.insert('examples', {
      'example_id': 'ex.de.water',
      'concept_id': 'daily.water',
      'language_code': 'de',
      'sentence': 'Ich trinke Wasser.',
      'translation_ar': 'أشرب الماء.',
    });
    batch.insert('examples', {
      'example_id': 'ex.de.book',
      'concept_id': 'daily.book',
      'language_code': 'de',
      'sentence': 'Ich lese ein Buch.',
      'translation_ar': 'أقرأ كتاباً.',
    });
    batch.insert('examples', {
      'example_id': 'ex.de.car',
      'concept_id': 'daily.car',
      'language_code': 'de',
      'sentence': 'Das Auto ist schnell.',
      'translation_ar': 'السيارة سريعة.',
    });
    await batch.commit(noResult: true);
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

    final ByteData assetData;
    try {
      assetData = await rootBundle.load(_germanAssetPath);
    } on FlutterError {
      // The curated file on disk is de-1.0.0.sqlite.test and is not declared
      // as a production pack. Absence must not be rewritten into that name.
      throw StateError(
        'Bundled German content pack is not present at $_germanAssetPath',
      );
    }
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
    final located =
        await StorageMigrationService().resolvePackPath('$languageCode.sqlite');
    if (located == null) {
      throw StateError('Language pack $languageCode is not installed');
    }
    return located;
  }

  /// Canonical SQLite v2 admission shared by the pack installer and reader.
  /// Reject incompatible schemas before replacing last-known-good content.
  Future<void> verifyUniversalSchema(
    Database db,
    String languageCode,
  ) async {
    final code = _normalizeLanguageCode(languageCode);
    final versionRows = await db.rawQuery('PRAGMA user_version');
    if (versionRows.isEmpty || versionRows.first.values.first != 2) {
      throw StateError('Unsupported SQLite user_version for $code');
    }

    final records = await db.rawQuery('''
      SELECT name, type FROM sqlite_master
      WHERE name IN (
        'metadata', 'schema_migrations', 'concepts', 'lexicon', 'senses',
        'translations', 'examples', 'lexical_relations', 'grammar',
        'lexemes', 'lexicon_fts'
      )
    ''');
    final names = <String, String>{
      for (final row in records) row['name'].toString(): row['type'].toString(),
    };
    const tables = <String>{
      'metadata',
      'schema_migrations',
      'concepts',
      'lexicon',
      'senses',
      'translations',
      'examples',
      'lexical_relations',
      'grammar',
    };
    if (tables.any((name) => names[name] != 'table') ||
        names['lexemes'] != 'view' ||
        names['lexicon_fts'] != 'table') {
      throw StateError('Content database $code has an incompatible v2 schema');
    }

    Future<void> requireColumns(String table, Set<String> required) async {
      final rows = await db.rawQuery('PRAGMA table_info($table)');
      final actual = rows.map((row) => row['name']).whereType<String>().toSet();
      if (!actual.containsAll(required)) {
        throw StateError('Content database $code lacks $table columns');
      }
    }

    await requireColumns('metadata', <String>{'key', 'value'});
    await requireColumns('lexicon', <String>{
      'id',
      'surface',
      'sort_key',
      'language_code',
      'cefr_level',
      'part_of_speech',
      'fields_json',
    });
    await requireColumns('senses', <String>{
      'sense_id',
      'lexeme_id',
      'concept_id',
      'payload_json',
    });
    await requireColumns('examples', <String>{
      'example_id',
      'lexeme_id',
      'language_code',
      'text',
    });

    final metadata = <String, String>{
      for (final row in await db.query('metadata', columns: ['key', 'value']))
        row['key'].toString(): row['value'].toString(),
    };
    if (metadata['mapping_version'] != '2.0.0' ||
        metadata['contract_version'] != '1.0.0' ||
        metadata['language_code'] != code) {
      throw StateError('Content database $code metadata is incompatible');
    }

    final ownedRows = await db.rawQuery(
      'SELECT 1 FROM lexicon WHERE language_code = ? LIMIT 1',
      <Object?>[code],
    );
    if (ownedRows.isEmpty) {
      throw StateError('Content database $code has no matching lexemes');
    }

    // sqlite_master.type is "table" for both ordinary tables and FTS5 virtual
    // tables. A real lexicon index must answer MATCH.
    try {
      await db.rawQuery(
        'SELECT 1 FROM lexicon_fts WHERE lexicon_fts MATCH ? LIMIT 1',
        <Object?>['probe'],
      );
    } on DatabaseException {
      throw StateError('Content database $code lexicon_fts is not FTS5');
    }

    final foreignKeys = await db.rawQuery('PRAGMA foreign_key_check');
    if (foreignKeys.isNotEmpty) {
      throw StateError('Content database $code has dangling foreign keys');
    }
  }

  Future<void> closeContentDb([String? languageCode]) =>
      _contentPool.close(_normalizeLanguageCode(languageCode));

  Future<void> closeAllContentDbs() => _contentPool.closeAll();

  /// Close only idle SQLite content connections under memory pressure.
  /// Retained as a compatibility API; active leases are never interrupted.
  Future<int> trimUnleasedContentConnections() =>
      _contentPool.closeUnleased();

  Future<File> migrateContentPack(
    String filename, {
    required PackStorageLocation destination,
  }) =>
      StorageMigrationService(
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
    String langCode, {
    int limit = 50,
  }) async {
    final code = _normalizeLanguageCode(langCode);
    final term = query.trim();
    final boundedLimit = limit.clamp(1, 50).toInt();
    final rows = await withContentDb<List<Map<String, Object?>>>(
      code,
      (db) async {
        if (term.isEmpty) {
          return db.rawQuery('''
            SELECT id, surface, part_of_speech, fields_json
            FROM lexicon
            WHERE language_code = ?
            ORDER BY sort_key, id LIMIT ?
          ''', <Object?>[code, boundedLimit]);
        }
        return db.rawQuery('''
          SELECT id, surface, part_of_speech, fields_json
          FROM lexicon
          WHERE language_code = ?
            AND (instr(lower(surface), lower(?)) > 0
              OR instr(lower(fields_json), lower(?)) > 0)
          ORDER BY sort_key, id LIMIT ?
        ''', <Object?>[code, term, term, boundedLimit]);
      },
    );
    return compute(_decodeLexiconRows, <String, Object?>{
      'languageCode': code,
      'rows': rows
          .map((row) => Map<String, Object?>.from(row))
          .toList(growable: false),
    });
  }

  /// One language-scoped, bounded daily queue from the active progress ledger.
  /// Immutable content packs and writable user progress stay in separate DBs.
  Future<List<Map<String, dynamic>>> loadDueFlashcards(
    String languageCode, {
    int limit = 20,
  }) async {
    if (limit < 1 || limit > 50) {
      throw RangeError.range(limit, 1, 50, 'limit');
    }
    final code = _normalizeLanguageCode(languageCode);
    final vaultActive = await _progressVault.isOperationalActive;
    final dueIds = <String>[];
    final reviewedIds = <String>{};
    Database? legacyDb;

    if (vaultActive) {
      // The operational encrypted vault is the review authority after cutover.
      // Its read-only snapshot is already bounded by the vault's export limit.
      final snapshot = await _progressVault.exportOperationalSnapshot();
      final dueRows = <Map<String, dynamic>>[];
      final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
      for (final row in snapshot['srs'] ?? <Map<String, dynamic>>[]) {
        if (row['target_language_code']?.toString() != code) continue;
        final id = row['lexeme_id']?.toString() ?? '';
        if (id.isEmpty) continue;
        reviewedIds.add(id);
        final dueAt = row['next_due_at'];
        if (dueAt == null || (dueAt is num && dueAt.toInt() <= now)) {
          dueRows.add(row);
        }
      }
      int dueTime(Map<String, dynamic> row) =>
          (row['next_due_at'] as num?)?.toInt() ?? 0;
      dueRows.sort((a, b) {
        final byTime = dueTime(a).compareTo(dueTime(b));
        return byTime != 0
            ? byTime
            : a['lexeme_id'].toString().compareTo(b['lexeme_id'].toString());
      });
      dueIds.addAll(dueRows.take(limit).map(
            (row) => row['lexeme_id'].toString(),
          ));
    } else {
      legacyDb = await progressDb;
      final dueRows = await legacyDb.rawQuery('''
        SELECT lexeme_id FROM srs_progress
        WHERE target_language_code = ?
          AND (next_due_at IS NULL OR
               next_due_at <= CAST(strftime('%s', 'now') AS INTEGER))
        ORDER BY next_due_at, lexeme_id
        LIMIT ?
      ''', <Object?>[code, limit]);
      dueIds.addAll(dueRows.map((row) => row['lexeme_id'].toString()));
    }

    final cards = <Map<String, dynamic>>[];
    await withContentDb<void>(code, (db) async {
      if (dueIds.isNotEmpty) {
        final placeholders = List<String>.filled(dueIds.length, '?').join(',');
        final rows = await db.rawQuery(
          'SELECT id, surface, part_of_speech, fields_json FROM lexicon WHERE id IN ($placeholders)',
          dueIds,
        );
        final byId = <String, Map<String, Object?>>{
          for (final row in rows) row['id'].toString(): row,
        };
        for (final id in dueIds) {
          final row = byId[id];
          if (row != null) cards.add(_unpackLexiconRow(row, code));
        }
      }

      // Fill remaining slots only with never-reviewed cards. Paging avoids
      // materializing the entire dictionary or an unbounded SQL IN clause.
      const pageSize = 128;
      var offset = 0;
      while (cards.length < limit) {
        final rows = await db.rawQuery('''
          SELECT id, surface, part_of_speech, fields_json
          FROM lexicon ORDER BY rowid LIMIT ? OFFSET ?
        ''', <Object?>[pageSize, offset]);
        if (rows.isEmpty) break;
        offset += rows.length;

        final reviewedOnPage = vaultActive ? reviewedIds : <String>{};
        if (!vaultActive) {
          final ids = rows.map((row) => row['id'].toString()).toList();
          final placeholders = List<String>.filled(ids.length, '?').join(',');
          final tracked = await legacyDb!.rawQuery(
            'SELECT lexeme_id FROM srs_progress WHERE target_language_code = ? AND lexeme_id IN ($placeholders)',
            <Object?>[code, ...ids],
          );
          reviewedOnPage.addAll(
            tracked.map((row) => row['lexeme_id'].toString()),
          );
        }
        for (final row in rows) {
          final id = row['id']?.toString() ?? '';
          if (id.isEmpty || reviewedOnPage.contains(id)) continue;
          cards.add(_unpackLexiconRow(row, code));
          if (cards.length == limit) break;
        }
        if (rows.length < pageSize) break;
      }
    });
    return cards;
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

  static Map<String, dynamic> _unpackLexiconRow(
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
          lexemeId: lexemeId,
          languageCode: languageCode,
          grade: grade,
          reviewedAt: reviewedAt);
    }
    return SrsSchedulerService().gradeAndPersist(
        progressDb: await progressDb,
        lexemeId: lexemeId,
        languageCode: languageCode,
        grade: grade,
        reviewedAt: reviewedAt);
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
    await db.insert(
        'vault_bookmarks',
        {
          'id': bookmarkId,
          'target_language_code': languageCode,
          'payload': jsonEncode(data),
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
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
        whereArgs: [bookmarkId, languageCode],
        limit: 1);
    if (rows.isEmpty) return null;
    return Map<String, dynamic>.from(
        jsonDecode(rows.single['payload'] as String) as Map);
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
    final normalized =
        (value ?? 'de').trim().toLowerCase().replaceAll('_', '-');
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
