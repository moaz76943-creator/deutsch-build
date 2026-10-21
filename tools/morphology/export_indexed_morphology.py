#!/usr/bin/env python3
import sqlite3
import argparse
from pathlib import Path
from tools.morphology.analyzer import MorphologyAnalyzer, get_profile

def export_indexed_morphology(dbs, lang, out_db, words):
    profile = get_profile(lang)
    analyzer = MorphologyAnalyzer(dbs, profile)

    conn = sqlite3.connect(out_db)
    schema_path = Path(__file__).parent / "reverse_lemmatization_schema.sql"
    with open(schema_path) as f:
        conn.executescript(f.read())

    for word in words:
        results = analyzer.analyze(word)
        for r in results:
            try:
                conn.execute("""
                    INSERT OR IGNORE INTO inflections_lookup
                    (inflected_form, language_code, lemma, pos, lexicon_id, source_kind)
                    VALUES (?, ?, ?, ?, ?, 'lexicon')
                """, (r.surface, lang, r.lemma, r.part_of_speech, r.lexical_id))
            except sqlite3.IntegrityError:
                pass

    conn.commit()
    conn.close()
    analyzer.close()

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--dbs', nargs='+', required=True)
    parser.add_argument('--lang', required=True)
    parser.add_argument('--out', required=True)
    parser.add_argument('--words', nargs='+', required=True)
    args = parser.parse_args()

    export_indexed_morphology(args.dbs, args.lang, args.out, args.words)
