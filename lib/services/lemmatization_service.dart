import 'package:sqflite/sqflite.dart';

import 'database_service.dart';
import 'fts_search_service.dart';

/// Search implementation injected for deterministic offline tests.
typedef DictionarySearch = Future<List<Map<String, dynamic>>> Function(
  String query,
  String languageCode,
  int limit,
);

/// Reads the offline inflection index only after ordinary FTS has no matches.
///
/// No network, runtime schema migration, full-table preloading, or synchronous
/// database calls. The (inflected_form, language_code) composite index is
/// provisioned by tools/morphology/reverse_lemmatization_schema.sql.
///
/// On a warm SQLite handle the indexed lookup targets under 2 ms, but real
/// device latency also depends on storage, cache state, and concurrent load.
/// This class makes no unconditional latency guarantee.
class LemmatizationService {
  LemmatizationService({
    Future<Database> Function(String)? openContentDb,
    DictionarySearch? search,
  })  : _openContentDb = openContentDb ??
            ((code) => DatabaseService.instance.getContentDb(code)),
        _search = search ??
            ((term, language, limit) => FtsSearchService().searchDictionary(
                  term,
                  language,
                  limit: limit,
                ));

  static const int maxTermLength = 64;

  final Future<Database> Function(String) _openContentDb;
  final DictionarySearch _search;

  /// Return a canonical lemma for an indexed inflected form, if available.
  ///
  /// Optional POS disambiguation supports homographs (noun versus verb).
  /// Older v1 packs without inflections_lookup return null, without failure.
  Future<String?> resolveLemma(
    String inflectedForm,
    String languageCode, {
    String? partOfSpeech,
  }) async {
    final code = _normalizeLanguageCode(languageCode);
    if (code == null || !_validTerm(inflectedForm)) return null;
    if (partOfSpeech != null && !_validTerm(partOfSpeech)) return null;
    final word = inflectedForm.trim();
    if (word.isEmpty) return null;

    final pos = partOfSpeech?.trim().toLowerCase();
    final sql = StringBuffer(
      'SELECT lemma FROM inflections_lookup '
      'WHERE inflected_form = ? COLLATE NOCASE '
      'AND language_code = ?',
    );
    final args = <Object?>[word, code];
    if (pos != null && pos.isNotEmpty) {
      sql.write(' AND pos = ? COLLATE NOCASE');
      args.add(pos);
    }
    sql.write(' ORDER BY lemma COLLATE NOCASE LIMIT 1');

    final database = await _openContentDb(code);
    try {
      final rows = await database.rawQuery(sql.toString(), args);
      if (rows.isEmpty) return null;
      final lemma = rows.first['lemma']?.toString().trim();
      if (lemma == null || lemma.isEmpty || !_validTerm(lemma)) {
        return null;
      }
      return lemma;
    } on DatabaseException catch (error) {
      // Legacy packs may not contain the new optional morphology index.
      if (error.toString().toLowerCase().contains(
            'no such table: inflections_lookup',
          )) {
        return null;
      }
      rethrow;
    }
  }

  /// Dictionary query interceptor for screens and search delegates to adopt.
  ///
  /// Exact/FTS results always win. Only an empty ordinary result set triggers
  /// the indexed reverse lookup, followed by one canonical FTS retry.
  Future<List<Map<String, dynamic>>> searchDictionary(
    String query,
    String languageCode, {
    int limit = 20,
  }) async {
    if (limit < 1 || limit > 100) {
      throw RangeError.range(limit, 1, 100, 'limit');
    }
    final code = _normalizeLanguageCode(languageCode);
    if (code == null || !_validTerm(query)) {
      return <Map<String, dynamic>>[];
    }
    final word = query.trim();
    final directResults = await _search(word, code, limit);
    if (directResults.isNotEmpty || word.isEmpty) return directResults;

    final lemma = await resolveLemma(word, code);
    if (lemma == null || lemma.toLowerCase() == word.toLowerCase()) {
      return directResults;
    }
    return _search(lemma, code, limit);
  }

  static String? _normalizeLanguageCode(String value) {
    final normalized = value.trim().toLowerCase().replaceAll('_', '-');
    if (normalized.length > 35 ||
        !RegExp(r'^[a-z]{2,3}(?:-[a-z0-9]{2,8})*$').hasMatch(normalized)) {
      return null;
    }
    return normalized;
  }

  static bool _validTerm(String value) {
    if (value.length > maxTermLength * 2) return false;
    return value.trim().runes.length <= maxTermLength;
  }
}
