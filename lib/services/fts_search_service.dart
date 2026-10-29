import 'package:deutsch_bilarabi/services/database_service.dart';

class FtsSearchService {
  final DatabaseService _dbService;

  FtsSearchService({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  Future<List<Map<String, dynamic>>> search(String query, String langCode, {int limit = 20, int offset = 0}) async {
    final db = await _dbService.contentDb;

    // Fallback if query is empty
    if (query.trim().isEmpty) {
      return await db.rawQuery('''
        SELECT l.*, e.sentence, e.translation_ar
        FROM lexemes l
        LEFT JOIN examples e ON e.concept_id = l.concept_id AND e.language_code = l.language_code
        WHERE l.language_code = ?
        LIMIT ? OFFSET ?
      ''', [langCode, limit, offset]);
    }

    // Check if FTS table exists
    final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='lexemes_fts';");
    final hasFts = tables.isNotEmpty;

    if (hasFts) {
      // Safe query string preparation for FTS MATCH
      // Remove characters that can break MATCH syntax. Only allow word characters, space,
      // Arabic, Hebrew, and Latin Extended characters.
      final safeQuery = query.replaceAll(RegExp(r'[^\w\s\u0600-\u06FF\u0590-\u05FF\u00C0-\u017F]'), '').trim();

      if (safeQuery.isEmpty) {
        return [];
      }

      // Prefix search format: term1* term2*
      final matchQuery = safeQuery.split(RegExp(r'\s+')).map((e) => '"$e"*').join(' ');

      return await db.rawQuery('''
        SELECT l.*, e.sentence, e.translation_ar
        FROM lexemes_fts fts
        JOIN lexemes l ON l.lexeme_id = fts.lexeme_id
        LEFT JOIN examples e ON e.concept_id = l.concept_id AND e.language_code = l.language_code
        WHERE fts.lexemes_fts MATCH ? AND l.language_code = ?
        ORDER BY bm25(lexemes_fts)
        LIMIT ? OFFSET ?
      ''', [matchQuery, langCode, limit, offset]);
    } else {
      // Fallback to LIKE if FTS is missing
      return await db.rawQuery('''
        SELECT l.*, e.sentence, e.translation_ar
        FROM lexemes l
        LEFT JOIN examples e ON e.concept_id = l.concept_id AND e.language_code = l.language_code
        WHERE l.language_code = ? AND (l.lemma LIKE ? OR l.display_text LIKE ? OR e.translation_ar LIKE ?)
        LIMIT ? OFFSET ?
      ''', [langCode, '%$query%', '%$query%', '%$query%', limit, offset]);
    }
  }
}
