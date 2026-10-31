"""Replay SQL extracted from the Dart source, not a replacement Dart runtime.

The fixture is synthetic. Python proves SQLite predicates only; Flutter tests,
analyzer, isolate behavior and Android remain separate mandatory gates.
"""
import os
from pathlib import Path
import re
import sqlite3
import unittest

ROOT = Path(__file__).resolve().parents[4]
SOURCE = Path(os.environ.get("MSG05_SEARCH_SOURCE", ROOT / "lib/services/fts_search_service.dart"))


def queries():
    source = SOURCE.read_text(encoding="utf-8")
    sql = re.findall(r"rawQuery\('''(.*?)'''", source, re.S)
    if len(sql) != 4:
        raise AssertionError("Expected four multiline production search queries")
    # Dart normal strings turn two backslashes into one SQL ESCAPE character.
    sql = [q.replace("\\\\", "\\").replace("$exclusions", "") for q in sql]
    suggestion = re.search(
        r'rawQuery\(\s*r"(.*?)"\s*\n\s*\'(.*?)\',', source, re.S)
    if suggestion is None:
        raise AssertionError("Suggestion SQL extraction failed")
    return (*sql, suggestion[1] + suggestion[2])


class ProductionSqlIsolation(unittest.TestCase):
    def setUp(self):
        self.db = sqlite3.connect(":memory:")
        self.db.execute("CREATE TABLE lexicon(id TEXT PRIMARY KEY, surface TEXT, "
                        "part_of_speech TEXT, fields_json TEXT, language_code TEXT)")
        self.db.execute("CREATE VIRTUAL TABLE lexicon_fts USING fts5(surface, "
                        "tokenize='unicode61 remove_diacritics 0')")
        # Multilingual packs may contain target-language senses; isolation must
        # come from the query, not an assumption about the opened file.
        self.tokens = {"de": "shared", "ar": "shared", "fr": "shared",
                       "tr": "İzmir", "ja": "日本語検索", "zh": "中文搜索",
                       "de.umlaut": "Äpfel", "de.sharp": "Straße",
                       "ar.diacritic": "مِثَال", "en.wildcard": "100%_literal"}
        for identity, text in self.tokens.items():
            code = identity.split(".")[0]
            self.db.execute("INSERT INTO lexicon VALUES(?,?,?,?,?)",
                            (identity, text, "fixture", "{}", code))
            rowid = self.db.execute("SELECT rowid FROM lexicon WHERE id=?", (identity,)).fetchone()[0]
            self.db.execute("INSERT INTO lexicon_fts(rowid,surface) VALUES(?,?)", (rowid, text))
        self.sql = queries()

    def tearDown(self):
        self.db.close()

    def run_sql(self, index, old_params, language="ar"):
        sql = self.sql[index]
        # Supports baseline reproduction without changing its SQL predicates.
        scoped = "language_code = ?" in sql
        args = (language, *old_params) if scoped else old_params
        return self.db.execute(sql, args).fetchall()

    def test_empty_query_keeps_only_requested_language(self):
        rows = self.run_sql(0, (50,))
        self.assertEqual({row[1] for row in rows}, {"ar", "ar.diacritic"})

    def test_fts_same_spelling_never_relabels_other_language(self):
        rows = self.run_sql(1, ('"shared"', "shared", "shared%", 50))
        self.assertEqual([row[1] for row in rows], ["ar"])

    def test_short_prefix_is_scoped(self):
        self.assertEqual([r[1] for r in self.run_sql(2, ("sh%", 50))], ["ar"])

    def test_substring_fallback_is_scoped(self):
        self.assertEqual([r[1] for r in self.run_sql(3, ("%har%", "%har%", 50))], ["ar"])

    def test_suggestion_candidates_are_scoped(self):
        self.assertEqual(self.run_sql(4, ("s%", 50)), [("shared",)])

    def test_unicode_surfaces_preserved(self):
        for identity in ("tr", "ja", "zh", "de.umlaut", "de.sharp", "ar.diacritic"):
            with self.subTest(identity=identity):
                token = self.tokens[identity]
                rows = self.run_sql(2, (token + "%", 50), identity.split(".")[0])
                self.assertEqual([r[2] for r in rows], [token])

    def test_wildcards_are_literals_when_bound(self):
        self.assertEqual([r[2] for r in self.run_sql(2, (r"100\%\_literal%", 50), "en")],
                         ["100%_literal"])

    def test_injection_text_cannot_change_predicate(self):
        self.assertEqual(self.run_sql(2, ("' OR 1=1 --%", 50)), [])

    def test_unknown_language_is_empty(self):
        self.assertEqual(self.run_sql(0, (50,), "xx"), [])

    def test_result_page_bound(self):
        self.assertEqual(len(self.run_sql(0, (1,), "ar")), 1)

    def test_fts_empty_prefix_has_real_prefix_fallback(self):
        self.assertEqual(self.run_sql(1, ('"Äpf"', "Äpf", "Äpf%", 50), "de"), [])
        self.assertEqual([r[2] for r in self.run_sql(2, ("Äpf%", 50), "de")], ["Äpfel"])


if __name__ == "__main__":
    unittest.main()
