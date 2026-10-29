import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

/// One attested reverse-inflection hit, not a guessed morphological rule.
class LemmaMatch {
  const LemmaMatch({
    required this.lemma,
    this.lexiconId,
    this.languageCode,
    this.senseId,
  });

  final String lemma;
  final String? lexiconId;
  final String? languageCode;

  /// Concept id that keeps two lemmas with the same surface form apart.
  final String? senseId;
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
    if (matches.length > 1) return null;
    return matches.single.lemma;
  }

  /// Attested lexeme hits for [form] in one language.
  ///
  /// Matches lemma, display text, or plural stored on the installed pack.
  /// Ambiguous surfaces stay as separate rows, distinguished by [LemmaMatch.senseId].
  Future<List<LemmaMatch>> resolveLemma(String form, String languageCode) async {
    final code = _normalizeLanguage(languageCode);
    final word = form.trim();
    if (word.isEmpty || word.runes.length > maxFormRunes) {
      return const <LemmaMatch>[];
    }

    final db = await _openContentDb(code);
    try {
      final rows = await db.rawQuery(
        'SELECT lexeme_id, lemma, concept_id, language_code '
        'FROM lexemes '
        'WHERE language_code = ? COLLATE NOCASE '
        'AND ('
        'lemma = ? COLLATE NOCASE '
        'OR IFNULL(plural, \'\') = ? COLLATE NOCASE '
        'OR display_text = ? COLLATE NOCASE'
        ') '
        'ORDER BY lemma, lexeme_id '
        'LIMIT ?',
        <Object?>[code, word, word, word, maxMatches],
      );
      return List<LemmaMatch>.unmodifiable(rows.map((row) => LemmaMatch(
            lemma: row['lemma']!.toString(),
            lexiconId: row['lexeme_id']?.toString(),
            languageCode: (row['language_code'] ?? code).toString(),
            senseId: row['concept_id']?.toString(),
          )));
    } on DatabaseException catch (error) {
      if (error.toString().toLowerCase().contains('no such table')) {
        return const <LemmaMatch>[];
      }
      rethrow;
    }
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
    if (matches.length != 1) return originals;
    final tried = <String>{query.trim().toLowerCase()};
    for (final match in matches) {
      final lemma = match.lemma.trim();
      if (lemma.isEmpty || !tried.add(lemma.toLowerCase())) continue;
      final results = await searchDictionary(lemma, code);
      if (results.isNotEmpty) return results;
    }
    return originals;
  }
}
