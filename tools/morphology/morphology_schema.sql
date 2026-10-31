-- Generic verb morphology contract, independent of any specific language.
-- Use one database per language, or namespace all identifiers when mixing languages.
CREATE TABLE IF NOT EXISTS verbs (
    verb_id TEXT PRIMARY KEY,
    infinitive TEXT NOT NULL,
    translation_ar TEXT,
    frequency_rank INTEGER
);

CREATE TABLE IF NOT EXISTS verb_conjugations (
    conjugation_id TEXT PRIMARY KEY,
    verb_id TEXT NOT NULL,
    tense TEXT NOT NULL,
    person TEXT NOT NULL,
    conjugated_form TEXT NOT NULL,
    FOREIGN KEY (verb_id) REFERENCES verbs(verb_id)
);

CREATE INDEX IF NOT EXISTS idx_verb_conjugations_verb_tense
    ON verb_conjugations (verb_id, tense);
