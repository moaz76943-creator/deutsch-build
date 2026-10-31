-- Track 25: per-headword multi-word expressions and separable particles.
-- Apply when building a writable content pack, after lexicon has been created.
-- Existing installed content packs are opened read-only by DatabaseService.
-- Foreign-key enforcement requires PRAGMA foreign_keys = ON on the writing connection.
CREATE TABLE IF NOT EXISTS idioms (
  id TEXT PRIMARY KEY NOT NULL,
  headword_id TEXT NOT NULL REFERENCES lexicon(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  expression TEXT NOT NULL CHECK (length(trim(expression)) > 0),
  translation_ar TEXT NOT NULL CHECK (length(trim(translation_ar)) > 0),
  separable_prefix TEXT CHECK (
    separable_prefix IS NULL OR length(trim(separable_prefix)) > 0
  )
);

CREATE INDEX IF NOT EXISTS idx_idioms_headword_expression
  ON idioms (headword_id, expression);
