-- Track 29: build-time, read-only lookup for inflected -> canonical lemmas.
-- Populate this table during offline pack generation, never on the UI thread.
-- Stored inflected_form and language_code should be normalized consistently
-- with the Dart query layer. SQLite NOCASE folds ASCII but not all Unicode.

CREATE TABLE IF NOT EXISTS inflections_lookup (
  inflected_form TEXT NOT NULL COLLATE NOCASE CHECK (length(trim(inflected_form)) > 0),
  lemma TEXT NOT NULL CHECK (length(trim(lemma)) > 0),
  pos TEXT NOT NULL CHECK (length(trim(pos)) > 0),
  language_code TEXT NOT NULL COLLATE NOCASE CHECK (length(trim(language_code)) > 0)
);

CREATE INDEX IF NOT EXISTS idx_inflection_lang
  ON inflections_lookup(inflected_form, language_code);
