-- Standalone, language-neutral nominal morphology database.
-- IDs must be globally unique if several languages share the same database.
-- Case/number/definiteness are normalized textual labels, not a fixed
-- Indo-European-only enumeration: Finnish/Hungarian additional cases remain valid.
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS nominals (
    id TEXT PRIMARY KEY NOT NULL CHECK (length(trim(id)) > 0),
    lemma TEXT NOT NULL CHECK (length(trim(lemma)) > 0),
    part_of_speech TEXT NOT NULL CHECK (part_of_speech IN ('noun', 'adjective', 'pronoun')),
    gender TEXT NOT NULL CHECK (length(trim(gender)) > 0),
    number TEXT NOT NULL CHECK (length(trim(number)) > 0)
);

CREATE TABLE IF NOT EXISTS nominal_declensions (
    id TEXT PRIMARY KEY NOT NULL CHECK (length(trim(id)) > 0),
    nominal_id TEXT NOT NULL CHECK (length(trim(nominal_id)) > 0),
    grammatical_case TEXT NOT NULL CHECK (length(trim(grammatical_case)) > 0),
    number TEXT NOT NULL CHECK (length(trim(number)) > 0),
    definiteness TEXT NOT NULL CHECK (length(trim(definiteness)) > 0),
    inflected_form TEXT NOT NULL CHECK (length(trim(inflected_form)) > 0),
    FOREIGN KEY (nominal_id) REFERENCES nominals(id) ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_nominal_declensions_nominal_case_number
    ON nominal_declensions (nominal_id, grammatical_case, number);
