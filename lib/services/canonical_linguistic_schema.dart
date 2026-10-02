import 'package:sqflite/sqflite.dart';

/// Relational schema for canonical linguistic data.
///
/// SQLite user_version 3 is additive: the legacy lexicon table is deliberately
/// preserved so Phase-1 runtime readers continue working during migration.
abstract final class CanonicalLinguisticSchema {
  static const int sqliteUserVersion = 3;
  static const int canonicalSchemaVersion = 2;

  static const String conceptsTable = 'concepts';
  static const String nounsTable = 'german_nouns';
  static const String verbsTable = 'german_verbs';
  static const String valencyTable = 'verb_valency_frames';
  static const String verbFormsTable = 'german_verb_forms';
  static const String wordFamiliesTable = 'german_word_families';
  static const String wordFamilyMembersTable = 'german_word_family_members';

  static const List<String> createStatements = <String>[
    '''
CREATE TABLE IF NOT EXISTS concepts (
  concept_id TEXT PRIMARY KEY,
  sense_id TEXT NOT NULL,
  lemma TEXT NOT NULL,
  part_of_speech TEXT NOT NULL,
  register TEXT NOT NULL,
  cefr TEXT NOT NULL,
  surface TEXT NOT NULL,
  direction TEXT NOT NULL,
  semantic_tags_json TEXT NOT NULL DEFAULT '[]',
  legacy_fields_json TEXT NOT NULL DEFAULT '{}'
)
''',
    '''
CREATE TABLE IF NOT EXISTS german_nouns (
  concept_id TEXT PRIMARY KEY
    REFERENCES concepts(concept_id) ON DELETE CASCADE,
  gender TEXT NOT NULL,
  plural TEXT,
  declension_class TEXT NOT NULL,
  nominative_singular TEXT NOT NULL,
  accusative_singular TEXT NOT NULL,
  dative_singular TEXT NOT NULL,
  genitive_singular TEXT NOT NULL,
  nominative_plural TEXT,
  accusative_plural TEXT,
  dative_plural TEXT,
  genitive_plural TEXT
)
''',
    '''
CREATE TABLE IF NOT EXISTS german_verbs (
  concept_id TEXT PRIMARY KEY
    REFERENCES concepts(concept_id) ON DELETE CASCADE,
  infinitive TEXT NOT NULL,
  separable_prefix TEXT,
  inseparable_prefix TEXT,
  reflexivity TEXT NOT NULL,
  auxiliary TEXT NOT NULL,
  participle_ii TEXT,
  preterite TEXT,
  imperative TEXT
)
''',
    '''
CREATE TABLE IF NOT EXISTS verb_valency_frames (
  concept_id TEXT NOT NULL
    REFERENCES german_verbs(concept_id) ON DELETE CASCADE,
  frame_id TEXT NOT NULL,
  governed_case TEXT,
  preposition TEXT,
  preposition_case TEXT,
  semantic_role TEXT NOT NULL,
  object_required INTEGER NOT NULL CHECK (object_required IN (0, 1)),
  PRIMARY KEY (concept_id, frame_id)
)
''',
    '''
CREATE TABLE IF NOT EXISTS german_verb_forms (
  concept_id TEXT NOT NULL
    REFERENCES german_verbs(concept_id) ON DELETE CASCADE,
  tense TEXT NOT NULL,
  person_key TEXT NOT NULL,
  form TEXT NOT NULL,
  PRIMARY KEY (concept_id, tense, person_key)
)
''',
    '''
CREATE TABLE IF NOT EXISTS german_word_families (
  family_id TEXT PRIMARY KEY,
  base_concept_id TEXT NOT NULL
    REFERENCES concepts(concept_id) ON DELETE CASCADE
)
''',
    '''
CREATE TABLE IF NOT EXISTS german_word_family_members (
  family_id TEXT NOT NULL
    REFERENCES german_word_families(family_id) ON DELETE CASCADE,
  concept_id TEXT NOT NULL
    REFERENCES concepts(concept_id) ON DELETE CASCADE,
  relation_type TEXT NOT NULL,
  prefix TEXT,
  suffix TEXT,
  semantic_distance TEXT NOT NULL,
  pedagogical_level TEXT NOT NULL,
  interference_risk INTEGER NOT NULL
    CHECK (interference_risk IN (0, 1)),
  PRIMARY KEY (family_id, concept_id)
)
''',
    'CREATE INDEX IF NOT EXISTS idx_concepts_lemma ON concepts(lemma)',
    'CREATE INDEX IF NOT EXISTS idx_concepts_sense ON concepts(sense_id)',
    'CREATE INDEX IF NOT EXISTS idx_valency_prep '
        'ON verb_valency_frames(preposition, preposition_case)',
    'CREATE INDEX IF NOT EXISTS idx_word_family_member_concept '
        'ON german_word_family_members(concept_id)',
    'CREATE INDEX IF NOT EXISTS idx_word_family_distance '
        'ON german_word_family_members(family_id, semantic_distance)',
  ];

  static const String selectConceptById =
      'SELECT * FROM concepts WHERE concept_id = ? LIMIT 1';
  static const String selectLegacyConceptById =
      'SELECT id, surface, part_of_speech, direction, fields_json '
      'FROM lexicon WHERE id = ? LIMIT 1';
  static const String selectNounById =
      'SELECT * FROM german_nouns WHERE concept_id = ? LIMIT 1';
  static const String selectVerbById =
      'SELECT * FROM german_verbs WHERE concept_id = ? LIMIT 1';
  static const String selectValencyByVerb =
      'SELECT * FROM verb_valency_frames WHERE concept_id = ? '
      'ORDER BY frame_id ASC';
  static const String selectFormsByVerb =
      'SELECT * FROM german_verb_forms WHERE concept_id = ? '
      'ORDER BY tense ASC, person_key ASC';
  static const String selectWordFamilyIds =
      'SELECT family_id FROM german_word_families ORDER BY family_id ASC LIMIT ?';
  static const String selectWordFamily =
      'SELECT f.family_id, f.base_concept_id, '
      'm.relation_type, m.prefix, m.suffix, m.semantic_distance, '
      'm.pedagogical_level, m.interference_risk, '
      'c.concept_id, c.sense_id, c.lemma, c.part_of_speech, '
      'c.register, c.cefr, c.surface, c.direction, '
      'c.semantic_tags_json, c.legacy_fields_json '
      'FROM german_word_families f '
      'JOIN german_word_family_members m ON m.family_id = f.family_id '
      'JOIN concepts c ON c.concept_id = m.concept_id '
      'WHERE f.family_id = ? '
      "ORDER BY CASE m.relation_type WHEN 'base' THEN 0 ELSE 1 END, "
      'm.semantic_distance ASC, c.lemma COLLATE NOCASE ASC';

  static Future<void> migrateLegacyFlatSchema(Database database) async {
    await database.execute('PRAGMA foreign_keys = ON');
    await database.transaction((txn) async {
      for (final statement in createStatements) {
        await txn.execute(statement);
      }
      if (await _hasTable(txn, 'lexicon')) {
        // Backfill only language-neutral concept identity. No noun/verb
        // morphology is guessed from flat legacy strings.
        await txn.execute('''
INSERT OR IGNORE INTO concepts(
  concept_id,
  sense_id,
  lemma,
  part_of_speech,
  register,
  cefr,
  surface,
  direction,
  semantic_tags_json,
  legacy_fields_json
)
SELECT
  id,
  id,
  surface,
  LOWER(part_of_speech),
  'neutral',
  'unknown',
  surface,
  direction,
  '[]',
  fields_json
FROM lexicon
''');
      }
      await txn.execute('PRAGMA user_version = $sqliteUserVersion');
    });
  }

  static Future<bool> _hasTable(DatabaseExecutor db, String table) async {
    final rows = await db.rawQuery(
      'SELECT name FROM sqlite_master WHERE type = ? AND name = ?',
      <Object?>['table', table],
    );
    return rows.isNotEmpty;
  }
}
