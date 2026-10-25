import sqlite3
import os
from typing import List, Tuple
from tools.morphology.analyzer import MorphologyAnalyzer, get_profile

def export_to_db(analyzer: MorphologyAnalyzer, words: List[str], language_code: str, output_db_path: str):
    conn = sqlite3.connect(output_db_path)
    conn.execute("""
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
    """)
    conn.execute("""
        CREATE INDEX IF NOT EXISTS idx_inflection_lang
          ON inflections_lookup (inflected_form, language_code);
    """)

    for word in words:
        results = analyzer.analyze(word)
        for res in results:
            try:
                conn.execute(
                    "INSERT INTO inflections_lookup (inflected_form, language_code, lemma, pos, lexicon_id, source_kind) VALUES (?, ?, ?, ?, ?, ?)",
                    (res.surface, language_code, res.lemma, res.part_of_speech, res.lexical_id, 'lexicon')
                )
            except sqlite3.IntegrityError:
                # Ignore duplicates for the same lemma/pos/word combination
                pass

    conn.commit()
    conn.close()

if __name__ == '__main__':
    import argparse
    import json

    parser = argparse.ArgumentParser(description="Generate indexed morphology database")
    parser.add_argument("--input", required=True, help="Input JSON file containing words")
    parser.add_argument("--output", required=True, help="Output SQLite database path")
    parser.add_argument("--lang", required=True, help="Language code")
    parser.add_argument("--dbs", required=True, nargs='+', help="Lexicon DB paths")

    args = parser.parse_args()

    with open(args.input, 'r', encoding='utf-8') as f:
        data = json.load(f)

    profile = get_profile(args.lang)
    analyzer = MorphologyAnalyzer(args.dbs, profile)

    export_to_db(analyzer, data.get("words", []), args.lang, args.output)
    analyzer.close()
