import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

import 'database_service.dart';
import 'lemmatization_service.dart';
import '../utils/fuzzy_search_engine.dart';

// Neither the SQLite connection nor plugin services cross isolate boundaries.
// Only at most 50 materialized SQL rows and primitive payloads are transferred.
List<Map<String, dynamic>> _decodeFtsRows(Map<String, Object?> request) {
  final code = request['languageCode'] as String;
  final rows = request['rows'] as List;
  return rows
      .map((item) => FtsSearchService._unpack(
            Map<String, Object?>.from(item as Map),
            code,
          ))
      .toList(growable: false);
}

List<String> _suggestOffThread(Map<String, Object?> request) {
  return FuzzySearchEngine.didYouMean(
    request['query'] as String,
    List<String>.from(request['candidates'] as List),
  );
}

/// Structured search metadata while retaining the legacy List-returning API.
class SearchFeedback<T> {
  const SearchFeedback({
    required this.results,
    this.resolvedLemma,
    this.suggestions = const <String>[],
  });
  final List<T> results;
  final String? resolvedLemma;
  final List<String> suggestions;
}

/// Read-only, per-language lookup against build-time FTS5 trigram indexes.
///
/// The pack builder preserves lexicon.rowid in lexicon_fts.rowid. No runtime
/// migration, index creation, or duplication into an in-memory trie occurs.
/// The existing DatabaseService opens content packs read-only.
///
/// Search of 1-2 Unicode scalars, or devices without FTS5, uses a NOCASE
/// B-tree prefix query first, then a legacy substring scan if more results
/// are needed. The latter cannot promise index-only performance.
class FtsSearchService {
  final DatabaseService _databaseService;

  FtsSearchService({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance;

  /// Compatible with the existing dictionary result shape.
  /// Each installed language pack has its own lexicon_fts and lexicon tables.
  Future<List<Map<String, dynamic>>> searchDictionary(
    String query,
    String languageCode, {
    int limit = 50,
  }) async {
    return _databaseService.withContentDb(
      languageCode,
      (database) => searchDatabase(
        database,
        query,
        languageCode: languageCode,
        limit: limit,
      ),
    );
  }

  /// Active dictionary pipeline: attested lemma first, then normal search,
  /// then at most three offline typo suggestions if there were no hits.
  Future<SearchFeedback<Map<String, dynamic>>> searchDictionaryWithFeedback(
    String query,
    String languageCode, {
    int limit = 50,
  }) async {
    return _databaseService.withContentDb(
      languageCode,
      (database) => searchDatabaseWithFeedback(
        database,
        query,
        languageCode: languageCode,
        limit: limit,
      ),
    );
  }

  Future<SearchFeedback<Map<String, dynamic>>> searchDatabaseWithFeedback(
    Database database,
    String query, {
    required String languageCode,
    int limit = 50,
  }) async {
    if (limit < 1 || limit > 50) {
      throw RangeError.range(limit, 1, 50, 'limit');
    }
    final term = query.trim();
    if (term.isNotEmpty) {
      final lemma = await LemmatizationService(
        openContentDb: (_) async => database,
      ).resolve(term, languageCode: languageCode);
      if (lemma != null &&
          lemma.trim().isNotEmpty &&
          lemma.trim().toLowerCase() != term.toLowerCase()) {
        final canonical = lemma.trim();
        final found = await searchDatabase(
          database,
          canonical,
          languageCode: languageCode,
          limit: limit,
        );
        if (found.isNotEmpty) {
          return SearchFeedback(
            results: found,
            resolvedLemma: canonical,
          );
        }
      }
    }

    final results = await searchDatabase(
      database,
      term,
      languageCode: languageCode,
      limit: limit,
    );
    if (results.isNotEmpty ||
        term.isEmpty ||
        term.runes.length > FuzzySearchEngine.maxQueryRunes) {
      return SearchFeedback(results: results);
    }
    final code = _normalizeLanguageCode(languageCode);
    final scoped = await _lexiconHasLanguageCode(database);
    final firstGlyph = String.fromCharCodes(<int>[term.runes.first]);
    final candidates = await database.rawQuery(
      'SELECT surface FROM lexicon WHERE '
      "${scoped ? 'language_code = ? AND ' : ''}"
      r"surface LIKE ? ESCAPE '\' "
      'ORDER BY surface COLLATE NOCASE LIMIT ?',
      <Object?>[
        if (scoped) code,
        '${_escapeLike(firstGlyph)}%',
        FuzzySearchEngine.maxCandidateChecks.clamp(1, 50),
      ],
    );
    return SearchFeedback(
      results: results,
      suggestions: await compute(_suggestOffThread, <String, Object?>{
        'query': term,
        'candidates': candidates
            .map((row) => row['surface']?.toString() ?? '')
            .toList(growable: false),
      }),
    );
  }

  /// Database-injected entry point for pack-level tests and isolated workers.
  Future<List<Map<String, dynamic>>> searchDatabase(
    Database database,
    String query, {
    required String languageCode,
    int limit = 50,
  }) async {
    if (limit < 1 || limit > 50) {
      throw RangeError.range(limit, 1, 50, 'limit');
    }

    final code = _normalizeLanguageCode(languageCode);
    final scoped = await _lexiconHasLanguageCode(database);
    final term = query.trim();
    List<Map<String, Object?>> rows;
    if (term.isEmpty) {
      rows = await database.rawQuery('''
        SELECT rowid AS search_rowid, id, surface, part_of_speech, fields_json
               ${scoped ? ', language_code' : ''}
        FROM lexicon
        WHERE ${scoped ? 'language_code = ?' : '1 = 1'}
        ORDER BY rowid
        LIMIT ?
      ''', <Object?>[if (scoped) code, limit]);
    } else if (term.runes.length >= 3) {
      try {
        final phrase = '"${term.replaceAll('"', '""')}"';
        rows = await database.rawQuery('''
          SELECT l.rowid AS search_rowid, l.id, l.surface,
                 l.part_of_speech, l.fields_json
                 ${scoped ? ', l.language_code' : ''}
          FROM lexicon_fts
          JOIN lexicon AS l ON l.rowid = lexicon_fts.rowid
          WHERE lexicon_fts MATCH ?
            AND ${scoped ? 'l.language_code = ?' : '1 = 1'}
          ORDER BY CASE
            WHEN l.surface = ? COLLATE NOCASE THEN 0
            WHEN l.surface LIKE ? ESCAPE '\\' THEN 1
            ELSE 2
          END, bm25(lexicon_fts), length(l.surface), l.rowid
          LIMIT ?
        ''', <Object?>[
          phrase,
          if (scoped) code,
          term,
          '${_escapeLike(term)}%',
          limit,
        ]);
        if (rows.isEmpty) {
          rows = await _fallback(database, term, limit, code, scoped);
        }
      } on DatabaseException catch (_) {
        // Invalid MATCH syntax, unsupported trigram tokenizer or oversized
        // expression: parameterized LIKE stays available on vendor SQLite.
        rows = await _fallback(database, term, limit, code, scoped);
      }
    } else {
      rows = await _fallback(database, term, limit, code, scoped);
    }
    return compute(_decodeFtsRows, <String, Object?>{
      'languageCode': code,
      'rows': rows
          .map((row) => Map<String, Object?>.from(row))
          .toList(growable: false),
    });
  }

  static String _escapeLike(String text) => text
      .replaceAll('\\', '\\\\')
      .replaceAll('%', '\\%')
      .replaceAll('_', '\\_');

  /// Same acceptance rule as DatabaseService: trim, lower-case, '_' to '-',
  /// and collapse a German region tag to `de`. Anything else that is not a
  /// language tag is rejected before it can reach SQL.
  static String _normalizeLanguageCode(String? value) {
    final normalized =
        (value ?? 'de').trim().toLowerCase().replaceAll('_', '-');
    if (!RegExp(r'^[a-z]{2,3}(?:-[a-z0-9]{2,8})*$').hasMatch(normalized)) {
      throw ArgumentError.value(value, 'languageCode', 'Invalid language code');
    }
    return normalized.split('-').first == 'de' ? 'de' : normalized;
  }

  static Future<bool> _lexiconHasLanguageCode(Database database) async {
    final info = await database.rawQuery('PRAGMA table_info(lexicon)');
    return info.any((row) => row['name']?.toString() == 'language_code');
  }

  static Future<List<Map<String, Object?>>> _fallback(
    Database database,
    String term,
    int limit,
    String languageCode,
    bool scoped,
  ) async {
    final literal = _escapeLike(term);
    final languageSql = scoped ? 'language_code = ? AND ' : '';
    final languageColumn = scoped ? ', language_code' : '';
    final languageArg = scoped ? <Object?>[languageCode] : <Object?>[];
    // This query can use idx_lexicon_surface_nocase, if shipped by the builder.
    final prefixRows = await database.rawQuery('''
      SELECT rowid AS search_rowid, id, surface, part_of_speech, fields_json
             $languageColumn
      FROM lexicon
      WHERE $languageSql surface LIKE ? ESCAPE '\\'
      ORDER BY length(surface), rowid
      LIMIT ?
    ''', <Object?>[...languageArg, '$literal%', limit]);
    if (prefixRows.length >= limit) return prefixRows;

    // Preserve substring/JSON lookup on older Android SQLite engines; this
    // final legacy scan may be slower for very short or unindexed searches.
    final remaining = limit - prefixRows.length;
    final alreadyFound = prefixRows
        .map((row) => row['search_rowid'])
        .whereType<int>()
        .toList(growable: false);
    final exclusions = alreadyFound.isEmpty
        ? ''
        : 'AND rowid NOT IN (${List.filled(alreadyFound.length, '?').join(',')})';
    final substringRows = await database.rawQuery('''
      SELECT rowid AS search_rowid, id, surface, part_of_speech, fields_json
             $languageColumn
      FROM lexicon
      WHERE $languageSql (surface LIKE ? ESCAPE '\\' OR fields_json LIKE ? ESCAPE '\\')
      $exclusions
      ORDER BY length(surface), rowid
      LIMIT ?
    ''', <Object?>[
      ...languageArg,
      '%$literal%',
      '%$literal%',
      ...alreadyFound,
      remaining,
    ]);
    return <Map<String, Object?>>[...prefixRows, ...substringRows];
  }

  static Map<String, dynamic> _unpack(
    Map<String, Object?> row,
    String languageCode,
  ) {
    Map<String, dynamic> fields = <String, dynamic>{};
    final raw = row['fields_json'];
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          fields = <String, dynamic>{
            for (final entry in decoded.entries)
              if (entry.key is String) entry.key as String: entry.value,
          };
        }
      } catch (_) {
        // Malformed optional fields must not hide an otherwise valid lexicon row.
      }
    }
    final id = row['id']?.toString() ?? '';
    final surface = row['surface']?.toString() ?? '';
    final translation = DatabaseService.resolveLexiconTranslation(fields);
    final storedLanguage = row['language_code']?.toString();
    return <String, dynamic>{
      'id': id,
      'lexeme_id': id,
      'concept_id': id,
      'language_code':
          (storedLanguage == null || storedLanguage.isEmpty)
              ? languageCode
              : storedLanguage,
      'surface': surface,
      'display_text': surface,
      'part_of_speech': row['part_of_speech'],
      'lemma': fields['lemma']?.toString() ?? surface,
      'article': fields['article'],
      'plural': fields['plural'],
      'translation_ar': translation?.text,
      'translation_language_code': translation?.languageCode,
      'sentence': fields['sentence'] ?? fields['example'],
      'fields_json': raw,
      'fields': fields,
    };
  }
}
