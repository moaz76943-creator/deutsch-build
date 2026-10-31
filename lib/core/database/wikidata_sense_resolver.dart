import 'package:sqflite/sqflite.dart';

/// تمثيل دلالي دقيق لمعنى لكسيمي مربوط بمفهوم ويكي بيانات المفتوح (CC0)
class WikidataSenseRecord {
  final String lexemeId;
  final String languageCode;
  final String lemma;
  final String lexicalCategory;
  final String senseId;
  final String conceptQid;
  final String? glossAr;

  const WikidataSenseRecord({
    required this.lexemeId,
    required this.languageCode,
    required this.lemma,
    required this.lexicalCategory,
    required this.senseId,
    required this.conceptQid,
    this.glossAr,
  });
}

/// محلل المعاني الدلالية واللكسيمات المفتوحة عبر مفاهيم ويكي بيانات (CC0)
///
/// يحل معضلة المشتركات اللفظية (Homonyms) مثل كلمة Schloss الألمانية:
/// - المفهوم Q16560 -> قصر (Palace)
/// - المفهوم Q80113 -> قفل (Lock)
/// من خلال مطابقة concept_qid العابر للغات دون لبس دلالي.
class WikidataSenseResolver {
  static const String tableLexemes = 'wikidata_lexemes';
  static const String tableSenses = 'wikidata_senses';

  /// جداول اللكسيمات والمعاني الدلالية المربوطة بمفاهيم CC0
  static const String createLexemesTableSql = '''
CREATE TABLE IF NOT EXISTS wikidata_lexemes (
    lexeme_id TEXT PRIMARY KEY,
    language_code TEXT NOT NULL,
    lemma TEXT NOT NULL,
    lexical_category TEXT NOT NULL -- 'noun', 'verb', 'adj'
);
''';

  static const String createSensesTableSql = '''
CREATE TABLE IF NOT EXISTS wikidata_senses (
    sense_id TEXT PRIMARY KEY,
    lexeme_id TEXT NOT NULL,
    concept_qid TEXT NOT NULL, -- e.g., 'Q16560' (قصر) مقابل 'Q80113' (قفل)
    gloss_ar TEXT,
    FOREIGN KEY(lexeme_id) REFERENCES wikidata_lexemes(lexeme_id)
);
''';

  static const String createIndexSenseConceptSql = '''
CREATE INDEX IF NOT EXISTS idx_sense_concept ON wikidata_senses(concept_qid);
''';

  static const String createIndexLexemeLemmaSql = '''
CREATE INDEX IF NOT EXISTS idx_lexeme_lemma ON wikidata_lexemes(lemma);
''';

  /// تهيئة الجداول والفهارس في قاعدة البيانات المحلية
  static Future<void> createSchema(Database db) async {
    await db.execute(createLexemesTableSql);
    await db.execute(createSensesTableSql);
    await db.execute(createIndexSenseConceptSql);
    await db.execute(createIndexLexemeLemmaSql);
  }

  /// استرجاع الترجمة الدقيقة الخالية من اللبس لكلمة Schloss حسب المفهوم (Q16560 = قصر)
  static Future<List<String>> resolveExactSenses(
    Database db,
    String lemma,
    String targetLang,
  ) async {
    final rows = await db.rawQuery('''
      SELECT s2.gloss_ar FROM wikidata_lexemes l1
      JOIN wikidata_senses s1 ON l1.lexeme_id = s1.lexeme_id
      JOIN wikidata_senses s2 ON s1.concept_qid = s2.concept_qid
      JOIN wikidata_lexemes l2 ON s2.lexeme_id = l2.lexeme_id
      WHERE l1.lemma = ? AND l2.language_code = ?;
    ''', [lemma, targetLang]);

    return rows
        .map((r) => r['gloss_ar'] as String?)
        .where((g) => g != null && g.isNotEmpty)
        .cast<String>()
        .toList();
  }

  /// استرجاع السجلات الدلالية التفصيلية مع معرف المفهوم (concept_qid)
  static Future<List<Map<String, dynamic>>> resolveSenseDetails(
    Database db,
    String lemma,
    String targetLang,
  ) async {
    return await db.rawQuery('''
      SELECT
        l1.lemma AS source_lemma,
        s1.concept_qid,
        s2.gloss_ar,
        l2.lemma AS target_lemma,
        l2.lexical_category
      FROM wikidata_lexemes l1
      JOIN wikidata_senses s1 ON l1.lexeme_id = s1.lexeme_id
      JOIN wikidata_senses s2 ON s1.concept_qid = s2.concept_qid
      JOIN wikidata_lexemes l2 ON s2.lexeme_id = l2.lexeme_id
      WHERE l1.lemma = ? AND l2.language_code = ?;
    ''', [lemma, targetLang]);
  }
}

/// دالة الواجهة العامة المباشرة المتوافقة تماماً مع توقيع المستخدم
Future<List<String>> resolveExactSenses(
  Database db,
  String lemma,
  String targetLang,
) =>
    WikidataSenseResolver.resolveExactSenses(db, lemma, targetLang);
