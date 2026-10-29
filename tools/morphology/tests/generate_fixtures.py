import sqlite3
import os

def generate_fixtures():
    os.makedirs("tools/morphology/tests/fixtures", exist_ok=True)

    verb_db = "tools/morphology/tests/fixtures/verbs.db"
    noun_db = "tools/morphology/tests/fixtures/nouns.db"
    if os.path.exists(verb_db): os.remove(verb_db)
    if os.path.exists(noun_db): os.remove(noun_db)

    vdb = sqlite3.connect(verb_db)
    vdb.executescript("""
        CREATE TABLE verbs (verb_id TEXT PRIMARY KEY, infinitive TEXT NOT NULL, translation_ar TEXT, frequency_rank INTEGER);
        CREATE TABLE verb_conjugations (conjugation_id TEXT PRIMARY KEY, verb_id TEXT NOT NULL, tense TEXT NOT NULL, person TEXT NOT NULL, conjugated_form TEXT NOT NULL, FOREIGN KEY (verb_id) REFERENCES verbs(verb_id));
        CREATE INDEX idx_verb_conjugations_verb_tense ON verb_conjugations (verb_id, tense);
    """)
    vdb.execute("INSERT INTO verbs VALUES ('v1', 'sein', 'be', 1)")
    vdb.execute("INSERT INTO verbs VALUES ('v2', 'arbeiten', 'work', 2)")
    vdb.execute("INSERT INTO verb_conjugations VALUES ('c1', 'v1', 'present', '3s', 'ist')")
    vdb.commit()

    ndb = sqlite3.connect(noun_db)
    ndb.executescript("""
        CREATE TABLE nominals (id TEXT PRIMARY KEY, lemma TEXT NOT NULL, part_of_speech TEXT NOT NULL, gender TEXT NOT NULL, number TEXT NOT NULL);
        CREATE TABLE nominal_declensions (id TEXT PRIMARY KEY, nominal_id TEXT NOT NULL, grammatical_case TEXT NOT NULL, number TEXT NOT NULL, definiteness TEXT NOT NULL, inflected_form TEXT NOT NULL, FOREIGN KEY (nominal_id) REFERENCES nominals(id));
        CREATE INDEX idx_nominal_declensions_nominal_case_number ON nominal_declensions (nominal_id, grammatical_case, number);
    """)

    # Turkish fixture
    ndb.execute("INSERT INTO nominals VALUES ('ev1', 'ev', 'noun', 'none', 'sg')")
    # Finnish fixture
    ndb.execute("INSERT INTO nominals VALUES ('talo1', 'talo', 'noun', 'none', 'sg')")
    # German ambiguous noun fixture
    ndb.execute("INSERT INTO nominals VALUES ('n1', 'Tor', 'noun', 'neu', 'sg')")
    ndb.execute("INSERT INTO nominal_declensions VALUES ('d1', 'n1', 'nom', 'sg', 'def', 'Tor')")
    ndb.execute("INSERT INTO nominal_declensions VALUES ('d2', 'n1', 'nom', 'pl', 'def', 'Tore')")
    ndb.execute("INSERT INTO nominals VALUES ('n2', 'Tor', 'noun', 'masc', 'sg')")
    ndb.execute("INSERT INTO nominal_declensions VALUES ('d3', 'n2', 'nom', 'sg', 'def', 'Tor')")
    ndb.execute("INSERT INTO nominal_declensions VALUES ('d4', 'n2', 'nom', 'pl', 'def', 'Toren')")
    ndb.commit()

    vdb.close()
    ndb.close()

if __name__ == "__main__":
    generate_fixtures()
