import sqlite3
import unicodedata
from typing import List, Dict, Any, Optional
from dataclasses import dataclass

@dataclass
class AnalysisResult:
    surface: str
    lemma: str
    lexical_id: str
    part_of_speech: str
    tags: List[str]

class LanguageProfile:
    def analyze(self, word: str, analyzer: 'MorphologyAnalyzer') -> List[AnalysisResult]:
        raise NotImplementedError()

class TurkishProfile(LanguageProfile):
    def __init__(self):
        self.suffixes = [
            ("ler", ["PL"]), ("lar", ["PL"]),
            ("de", ["LOC"]), ("da", ["LOC"]), ("te", ["LOC"]), ("ta", ["LOC"]),
            ("im", ["POSS1S"]), ("ım", ["POSS1S"]), ("um", ["POSS1S"]), ("üm", ["POSS1S"]), ("m", ["POSS1S"]),
            ("miz", ["POSS1P"]), ("mız", ["POSS1P"]), ("muz", ["POSS1P"]), ("müz", ["POSS1P"]),
            ("imiz", ["POSS1P"]), ("ımız", ["POSS1P"]), ("umuz", ["POSS1P"]), ("ümüz", ["POSS1P"]),
        ]

    def analyze(self, word: str, analyzer: 'MorphologyAnalyzer') -> List[AnalysisResult]:
        results = []
        state = {"nodes_visited": 0}
        def decompose(current_word: str, current_tags: List[str], depth: int):
            state["nodes_visited"] += 1
            if state["nodes_visited"] > 100:
                return
            if len(results) >= analyzer.max_results:
                return
            if depth > analyzer.max_recursion_depth:
                return

            for nom in analyzer.lookup_nominal_lemma(current_word):
                results.append(AnalysisResult(word, nom['lemma'], nom['id'], nom['part_of_speech'], list(reversed(current_tags))))

            for suffix, tags in self.suffixes:
                if current_word.endswith(suffix):
                    stem = current_word[:-len(suffix)]
                    if len(stem) > 0 and self._check_vowel_harmony(stem, suffix):
                        decompose(stem, current_tags + tags, depth + 1)

        decompose(word, [], 0)
        return results

    def _check_vowel_harmony(self, stem: str, suffix: str) -> bool:
        stem = unicodedata.normalize('NFC', stem)
        suffix = unicodedata.normalize('NFC', suffix)
        back_vowels = set("aıouAIOU")
        front_vowels = set("eiöüEİÖÜ")
        stem_vowels = [c for c in stem if c in back_vowels or c in front_vowels]
        suffix_vowels = [c for c in suffix if c in back_vowels or c in front_vowels]
        if not stem_vowels or not suffix_vowels:
            return True
        last_stem_vowel = stem_vowels[-1]
        first_suffix_vowel = suffix_vowels[0]
        if last_stem_vowel in back_vowels and first_suffix_vowel in front_vowels:
            return False
        if last_stem_vowel in front_vowels and first_suffix_vowel in back_vowels:
            return False
        return True

class FinnishProfile(LanguageProfile):
    def __init__(self):
        self.suffixes = [
            ("ssa", ["INE"]), ("ssä", ["INE"]),
            ("sta", ["ELA"]), ("stä", ["ELA"]),
            ("ni", ["POSS1S"]),
            ("i", ["PL"]),
        ]

    def analyze(self, word: str, analyzer: 'MorphologyAnalyzer') -> List[AnalysisResult]:
        results = []
        state = {"nodes_visited": 0}
        def decompose(current_word: str, current_tags: List[str], depth: int):
            state["nodes_visited"] += 1
            if state["nodes_visited"] > 100:
                return
            if len(results) >= analyzer.max_results:
                return
            if depth > analyzer.max_recursion_depth:
                return

            for nom in analyzer.lookup_nominal_lemma(current_word):
                results.append(AnalysisResult(word, nom['lemma'], nom['id'], nom['part_of_speech'], list(reversed(current_tags))))

            for suffix, tags in self.suffixes:
                if current_word.endswith(suffix):
                    stem = current_word[:-len(suffix)]
                    if len(stem) > 0 and self._check_vowel_harmony(stem, suffix):
                        decompose(stem, current_tags + tags, depth + 1)

        decompose(word, [], 0)
        return results

    def _check_vowel_harmony(self, stem: str, suffix: str) -> bool:
        stem = unicodedata.normalize('NFC', stem)
        suffix = unicodedata.normalize('NFC', suffix)
        back_vowels = set("aouAOU")
        front_vowels = set("äöyÄÖY")
        stem_vowels = [c for c in stem if c in back_vowels or c in front_vowels]
        suffix_vowels = [c for c in suffix if c in back_vowels or c in front_vowels]
        if not stem_vowels or not suffix_vowels:
            return True
        has_back = any(v in back_vowels for v in stem_vowels)
        has_front = any(v in front_vowels for v in stem_vowels)
        suffix_has_back = any(v in back_vowels for v in suffix_vowels)
        suffix_has_front = any(v in front_vowels for v in suffix_vowels)

        if has_back and suffix_has_front:
            return False
        if has_front and not has_back and suffix_has_back:
            return False
        return True

class GermanProfile(LanguageProfile):
    def analyze(self, word: str, analyzer: 'MorphologyAnalyzer') -> List[AnalysisResult]:
        results = []

        for vf in analyzer.lookup_verb_form(word):
            results.append(AnalysisResult(word, vf['infinitive'], vf['verb_id'], 'verb', [vf['tense'], vf['person']]))
        for nf in analyzer.lookup_nominal_form(word):
            results.append(AnalysisResult(word, nf['lemma'], nf['id'], nf['part_of_speech'], [nf['grammatical_case'], nf['number'], nf['definiteness']]))

        return results

class MorphologyAnalyzer:
    def __init__(self, db_paths: List[str], profile: LanguageProfile):
        self.dbs = [sqlite3.connect(p) for p in db_paths]
        for db in self.dbs:
            db.row_factory = sqlite3.Row
        self.profile = profile
        self.max_recursion_depth = 4
        self.max_results = 50

    def close(self):
        for db in self.dbs:
            db.close()

    def _query_all(self, query: str, params: tuple) -> List[Dict[str, Any]]:
        results = []
        for db in self.dbs:
            try:
                cur = db.execute(query, params)
                for row in cur.fetchall():
                    results.append(dict(row))
            except sqlite3.OperationalError:
                pass
        return results

    def lookup_verb_lemma(self, lemma: str) -> List[Dict[str, Any]]:
        return self._query_all("SELECT verb_id, infinitive FROM verbs WHERE infinitive = ?", (lemma,))

    def lookup_nominal_lemma(self, lemma: str) -> List[Dict[str, Any]]:
        return self._query_all("SELECT id, lemma, part_of_speech, gender, number FROM nominals WHERE lemma = ?", (lemma,))

    def lookup_verb_form(self, form: str) -> List[Dict[str, Any]]:
        return self._query_all("""
            SELECT v.verb_id, v.infinitive, c.tense, c.person
            FROM verb_conjugations c
            JOIN verbs v ON c.verb_id = v.verb_id
            WHERE c.conjugated_form = ?
        """, (form,))

    def lookup_nominal_form(self, form: str) -> List[Dict[str, Any]]:
        return self._query_all("""
            SELECT n.id, n.lemma, n.part_of_speech, c.grammatical_case, c.number, c.definiteness
            FROM nominal_declensions c
            JOIN nominals n ON c.nominal_id = n.id
            WHERE c.inflected_form = ?
        """, (form,))

    def analyze(self, word: str) -> List[AnalysisResult]:
        results = self.profile.analyze(word, self)

        seen = set()
        unique = []
        for r in results:
            if len(unique) >= self.max_results:
                break
            key = (r.lemma, r.lexical_id, r.part_of_speech, tuple(r.tags))
            if key not in seen:
                seen.add(key)
                unique.append(r)
        return unique

def get_profile(lang: str) -> LanguageProfile:
    if lang == "de":
        return GermanProfile()
    elif lang == "tr":
        return TurkishProfile()
    elif lang == "fi":
        return FinnishProfile()
    else:
        raise ValueError(f"Unsupported language profile: {lang}")
