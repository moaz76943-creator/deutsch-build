import argparse
import sqlite3
import json
import os
import sys
from pathlib import Path

# To allow running as a script directly
sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent))

from tools.morphology.analyzer import MorphologyAnalyzer, get_profile

def main():
    parser = argparse.ArgumentParser(description="Generate indexed morphology output.")
    parser.add_argument("--words", nargs="+", help="List of surface forms to analyze")
    parser.add_argument("--words-file", type=str, help="JSON file containing a list of surface forms")
    parser.add_argument("--lang", required=True, help="Language code (e.g. de, tr, fi)")
    parser.add_argument("--dbs", nargs="+", required=True, help="Paths to input SQLite databases")
    parser.add_argument("--output", required=True, help="Path to output SQLite database")

    args = parser.parse_args()

    words = []
    if args.words:
        words.extend(args.words)
    if args.words_file:
        with open(args.words_file, 'r', encoding='utf-8') as f:
            words.extend(json.load(f))

    if not words:
        print("No words provided.", file=sys.stderr)
        sys.exit(1)

    profile = get_profile(args.lang)
    analyzer = MorphologyAnalyzer(args.dbs, profile)

    if os.path.exists(args.output):
        os.remove(args.output)

    conn = sqlite3.connect(args.output)

    schema_path = Path(__file__).parent / "reverse_lemmatization_schema.sql"
    with open(schema_path, 'r', encoding='utf-8') as f:
        conn.executescript(f.read())

    cur = conn.cursor()

    for word in words:
        results = analyzer.analyze(word)
        for r in results:
            try:
                cur.execute("""
                    INSERT INTO inflections_lookup
                    (inflected_form, language_code, lemma, pos, lexicon_id, source_kind)
                    VALUES (?, ?, ?, ?, ?, 'lexicon')
                """, (r.surface, args.lang, r.lemma, r.part_of_speech, r.lexical_id))
            except sqlite3.IntegrityError:
                pass

    conn.commit()
    conn.close()
    analyzer.close()

if __name__ == "__main__":
    main()
