-- Separate user-owned local database. Never cascade-delete when a pack is removed.
-- No foreign key into pack databases: progress survives uninstall/reinstall.
PRAGMA foreign_keys=ON;
CREATE TABLE IF NOT EXISTS srs_progress (
  progress_key TEXT PRIMARY KEY,
  learner_id TEXT NOT NULL DEFAULT 'local',
  lexeme_id TEXT NOT NULL,
  concept_id TEXT NOT NULL,
  source_language_code TEXT NOT NULL,
  target_language_code TEXT NOT NULL,
  skill TEXT NOT NULL,
  facet_key TEXT NOT NULL DEFAULT '',
  repetition_count INTEGER NOT NULL DEFAULT 0 CHECK(repetition_count>=0),
  interval_days INTEGER NOT NULL DEFAULT 1 CHECK(interval_days>=0),
  ease_factor REAL NOT NULL DEFAULT 2.5 CHECK(ease_factor>=1.3),
  last_reviewed_at INTEGER,
  next_due_at INTEGER,
  status TEXT NOT NULL DEFAULT 'learning' CHECK(status IN ('learning','review','mastered'))
);
CREATE INDEX IF NOT EXISTS idx_srs_due ON srs_progress(learner_id,status,next_due_at);
CREATE INDEX IF NOT EXISTS idx_srs_lexeme ON srs_progress(lexeme_id,target_language_code);
PRAGMA user_version=2;
