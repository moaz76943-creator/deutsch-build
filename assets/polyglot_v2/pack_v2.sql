-- Five content tables per language; never store learner progress here.
-- Enable PRAGMA foreign_keys=ON in every runtime SQLite connection.
PRAGMA foreign_keys=ON;
CREATE TABLE IF NOT EXISTS language_profiles (
  language_code TEXT PRIMARY KEY,
  name_native TEXT NOT NULL,
  name_ar TEXT NOT NULL,
  direction TEXT NOT NULL CHECK(direction IN ('rtl','ltr')),
  is_active INTEGER NOT NULL DEFAULT 1 CHECK(is_active IN (0,1))
);
CREATE TABLE IF NOT EXISTS concepts (
  concept_id TEXT PRIMARY KEY,
  category TEXT NOT NULL,
  cefr_level TEXT NOT NULL CHECK(cefr_level IN ('A1','A2','B1','B2','C1','C2')),
  priority INTEGER NOT NULL DEFAULT 1 CHECK(priority > 0)
);
CREATE TABLE IF NOT EXISTS lexemes (
  lexeme_id TEXT PRIMARY KEY,
  concept_id TEXT NOT NULL REFERENCES concepts(concept_id) ON DELETE CASCADE,
  language_code TEXT NOT NULL REFERENCES language_profiles(language_code),
  sense_id TEXT NOT NULL,
  part_of_speech TEXT NOT NULL,
  lemma TEXT NOT NULL,
  display_text TEXT NOT NULL,
  ipa TEXT,
  gender TEXT,
  article TEXT,
  plural TEXT,
  cefr_level TEXT CHECK(cefr_level IS NULL OR cefr_level IN ('A1','A2','B1','B2','C1','C2')),
  grammar_json TEXT NOT NULL DEFAULT '{}',
  UNIQUE(language_code,concept_id,sense_id,lemma)
);
CREATE INDEX IF NOT EXISTS idx_lexemes_language_lemma ON lexemes(language_code,lemma);
CREATE INDEX IF NOT EXISTS idx_lexemes_concept_language ON lexemes(concept_id,language_code);
CREATE TABLE IF NOT EXISTS example_groups (
  group_id TEXT PRIMARY KEY,
  concept_id TEXT NOT NULL REFERENCES concepts(concept_id) ON DELETE CASCADE,
  context_type TEXT NOT NULL DEFAULT 'daily'
);
CREATE INDEX IF NOT EXISTS idx_example_groups_concept ON example_groups(concept_id);
CREATE TABLE IF NOT EXISTS examples (
  example_id TEXT PRIMARY KEY,
  group_id TEXT NOT NULL REFERENCES example_groups(group_id) ON DELETE CASCADE,
  language_code TEXT NOT NULL REFERENCES language_profiles(language_code),
  sentence TEXT NOT NULL,
  translation_ar TEXT,
  UNIQUE(group_id,language_code)
);
CREATE INDEX IF NOT EXISTS idx_examples_language_group ON examples(language_code,group_id);
PRAGMA user_version=2;
