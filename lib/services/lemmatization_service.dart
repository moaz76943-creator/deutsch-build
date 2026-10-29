import 'package:deutsch_bilarabi/services/database_service.dart';

class LemmaMatch {
  final String lemma;
  final String languageCode;
  final String? senseId;
  final String? partOfSpeech;
  final String? packIdentity;

  LemmaMatch({
    required this.lemma,
    required this.languageCode,
    this.senseId,
    this.partOfSpeech,
    this.packIdentity,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LemmaMatch &&
          runtimeType == other.runtimeType &&
          lemma == other.lemma &&
          languageCode == other.languageCode &&
          senseId == other.senseId &&
          partOfSpeech == other.partOfSpeech &&
          packIdentity == other.packIdentity;

  @override
  int get hashCode =>
      lemma.hashCode ^ languageCode.hashCode ^ senseId.hashCode ^ partOfSpeech.hashCode ^ packIdentity.hashCode;

  @override
  String toString() {
    return 'LemmaMatch{lemma: $lemma, languageCode: $languageCode, senseId: $senseId, partOfSpeech: $partOfSpeech, packIdentity: $packIdentity}';
  }
}

class LemmatizationService {
  final DatabaseService _dbService;
  int _queryCounter = 0;

  LemmatizationService({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  Future<List<LemmaMatch>> resolveLemmas({
      required String form,
      required String languageCode,
      required String packIdentity
    }) async {
    final currentQueryId = ++_queryCounter;

    final db = await _dbService.contentDb;
    final List<LemmaMatch> results = [];

    // Check if morphology forms table exists
    final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='morphology_forms';");

    // If a new query has started, abort processing this stale query
    if (_queryCounter != currentQueryId) return results;

    if (tables.isNotEmpty) {
      // Assuming actual morphology_forms has part_of_speech and sense_id
      final hasExtraColumns = await db.rawQuery("PRAGMA table_info(morphology_forms);");
      final bool hasSenseId = hasExtraColumns.any((col) => col['name'] == 'sense_id');
      final bool hasPoS = hasExtraColumns.any((col) => col['name'] == 'part_of_speech');

      String selectClause = "lemma, lang as language_code";
      if (hasSenseId) selectClause += ", sense_id";
      if (hasPoS) selectClause += ", part_of_speech";

      final morphologyResults = await db.rawQuery('''
        SELECT $selectClause FROM morphology_forms
        WHERE form = ? AND lang = ? LIMIT 20
      ''', [form, languageCode]);

      if (_queryCounter != currentQueryId) return [];

      for (final r in morphologyResults) {
        final match = LemmaMatch(
          lemma: r['lemma'] as String,
          languageCode: r['language_code'] as String,
          senseId: hasSenseId ? r['sense_id'] as String? : null,
          partOfSpeech: hasPoS ? r['part_of_speech'] as String? : null,
          packIdentity: packIdentity,
        );
        if (!results.contains(match)) {
            results.add(match);
        }
      }
    }

    if (_queryCounter != currentQueryId) return [];

    // If we already found it in morphology_forms, we can return it.
    // To match actual test fixtures and objective cleanly without doubling results
    // Let's only search lexemes directly if results is still empty or we want to augment

    // As a fallback or combined search, check the lexemes table directly.
    final hasLexemesTable = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='lexemes';");

    if (hasLexemesTable.isNotEmpty) {
        // We know lexemes table schema from earlier checks
        final hasExtraColumns = await db.rawQuery("PRAGMA table_info(lexemes);");
        final bool hasSenseId = hasExtraColumns.any((col) => col['name'] == 'sense_id');
        final bool hasPoS = hasExtraColumns.any((col) => col['name'] == 'part_of_speech');

        String selectClause = "lemma, language_code";
        if (hasSenseId) selectClause += ", sense_id";
        if (hasPoS) selectClause += ", part_of_speech";

        final lexemeResults = await db.rawQuery('''
          SELECT $selectClause FROM lexemes
          WHERE language_code = ? AND (lemma = ? OR display_text = ? OR plural = ?)
          LIMIT 20
        ''', [languageCode, form, form, form]);

        if (_queryCounter != currentQueryId) return [];

        for (final r in lexemeResults) {
            final match = LemmaMatch(
                lemma: r['lemma'] as String,
                languageCode: r['language_code'] as String,
                senseId: hasSenseId ? r['sense_id'] as String? : null,
                partOfSpeech: hasPoS ? r['part_of_speech'] as String? : null,
                packIdentity: packIdentity,
            );
            if (!results.contains(match)) {
                results.add(match);
            }
        }
    }

    return results;
  }
}
