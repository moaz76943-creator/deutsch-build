import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

/// One attested reverse-inflection hit, not a guessed morphological rule.
class LemmaMatch {
  const LemmaMatch({required this.lemma, required this.languageCode, this.lexiconId});

  final String lemma;
  final String languageCode;
  final String? lexiconId;
}

typedef LemmatizationDictionarySearch = Future<List<Map<String, dynamic>>>
    Function(
  String query,
  String languageCode,
);

/// Read-only reverse lookup against an indexed, installed SQLite content pack.
///
/// The composite index (inflected_form, language_code) supports point lookups
/// without scanning all words. Results depend on pack data, not hardcoded
/// English/German/French exceptions. Runtime below 2 ms must be benchmarked on
/// a warmed database/device and cannot be promised by the SQL interface.
class LemmatizationService {
  LemmatizationService({
    Future<Database> Function(String)? openContentDb,
  }) : _openContentDb = openContentDb ??
            ((code) => DatabaseService.instance.getContentDb(code));

  static const int maxFormRunes = 96;
  static const int maxMatches = 8;
  static const int maxFallbackLemmas = 3;

  final Future<Database> Function(String) _openContentDb;

  static String _normalizeLanguage(String languageCode) {
    final normalized = languageCode.trim().toLowerCase().replaceAll('_', '-');
    if (!RegExp(r'^[a-z]{2,3}(?:-[a-z0-9]{2,8})*$').hasMatch(normalized)) {
      throw ArgumentError.value(
        languageCode,
        'languageCode',
        'Invalid language tag',
      );
    }
    return normalized.split('-').first;
  }

  /// Bounded indexed point lookup. Missing optional tables return no matches,
  /// preserving compatibility with older, read-only content packs.
  Future<List<LemmaMatch>> lookup(
    String inflectedForm, {
    String languageCode = 'de',
    int limit = maxMatches,
  }) async {
    if (limit < 1 || limit > maxMatches) {
      throw RangeError.range(limit, 1, maxMatches, 'limit');
    }
    final code = _normalizeLanguage(languageCode);
    final word = inflectedForm.trim();
    if (word.isEmpty || word.runes.length > maxFormRunes) {
      return const <LemmaMatch>[];
    }

    final db = await _openContentDb(code);
    try {
      final rows = await db.rawQuery(
        'SELECT lemma, lexicon_id FROM inflections_lookup '
        'WHERE inflected_form = ? COLLATE NOCASE '
        'AND language_code = ? COLLATE NOCASE '
        'ORDER BY lemma LIMIT ?',
        <Object?>[word, code, limit],
      );
      return List<LemmaMatch>.unmodifiable(rows.map((row) => LemmaMatch(
            lemma: row['lemma']!.toString(),
            languageCode: code,
            lexiconId: row['lexicon_id']?.toString(),
          )));
    } on DatabaseException catch (error) {
      if (error
          .toString()
          .toLowerCase()
          .contains('no such table: inflections_lookup')) {
        return const <LemmaMatch>[];
      }
      rethrow;
    }
  }

  /// Return a single lemma only when that result is unambiguous.
  /// Choosing the first lexeme by SQL order is not linguistic evidence.
  Future<String?> resolve(
    String inflectedForm, {
    String languageCode = 'de',
  }) async {
    final matches = await lookup(
      inflectedForm,
      languageCode: languageCode,
      limit: 2,
    );
    if (matches.isEmpty) return null;
    // Ambiguous candidates remain distinguishable; we refuse to guess.
    if (matches.length > 1) return null;
    return matches.single.lemma;
  }

  /// Intercept only unsuccessful normal searches, then retry attested lemmas.
  /// No unbounded recursion or whole-lexicon scan is performed by this layer.
  Future<List<Map<String, dynamic>>> searchWithLemmaFallback(
    String query, {
    String languageCode = 'de',
    required LemmatizationDictionarySearch searchDictionary,
  }) async {
    final code = _normalizeLanguage(languageCode);
    final originals = await searchDictionary(query, code);
    if (originals.isNotEmpty) return originals;

    // Detect a fourth competing lemma rather than silently truncating
    // ambiguity to the first three candidates.
    final matches = await lookup(
      query,
      languageCode: code,
      limit: maxFallbackLemmas + 1,
    );
    // Explicitly reject fallback if ambiguous candidates are more than 1
    // to prevent stale queries crossing boundaries and to keep senses strict.
    if (matches.length != 1) return originals;

    final tried = <String>{query.trim().toLowerCase()};
    for (final match in matches) {
      if (match.languageCode != code) continue; // Prevent crossing active pairs
      final lemma = match.lemma.trim();
      if (lemma.isEmpty || !tried.add(lemma.toLowerCase())) continue;
      final results = await searchDictionary(lemma, code);
      if (results.isNotEmpty) return results;
    }
    return originals;
  }
}
