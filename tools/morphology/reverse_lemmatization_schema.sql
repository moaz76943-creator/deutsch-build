-- Track 29: offline reverse lemmatization lookup, populated at pack build time.
-- Canonical lemmas are language-specific. Do not guess missing inflections.
CREATE TABLE IF NOT EXISTS inflections_lookup (
  inflected_form TEXT NOT NULL COLLATE NOCASE
    CHECK (length(trim(inflected_form)) > 0),
  language_code TEXT NOT NULL COLLATE NOCASE
    CHECK (length(trim(language_code)) > 0),
  lemma TEXT NOT NULL
    CHECK (length(trim(lemma)) > 0),
  pos TEXT NOT NULL DEFAULT 'unknown'
    CHECK (length(trim(pos)) > 0),
  lexicon_id TEXT,
  source_kind TEXT NOT NULL DEFAULT 'lexicon',
  PRIMARY KEY (inflected_form, language_code, lemma, pos)
) WITHOUT ROWID;

CREATE INDEX IF NOT EXISTS idx_inflection_lang
  ON inflections_lookup (inflected_form, language_code);
