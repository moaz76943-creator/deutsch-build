from pathlib import Path

ROOT = Path(__file__).parents[1]
SEARCH = ROOT / 'lib/services/search_index.dart'


def test_fuzzy_search_uses_candidate_index_not_full_corpus_scan():
    text = SEARCH.read_text()
    assert '_fuzzyCandidates' in text
    assert 'for (final entry in _fuzzyCandidates' in text
    assert 'for (final entry in _entries)' not in text[text.index('// Fuzzy fallback'):]


def test_search_index_has_trigram_index_for_fuzzy_candidates():
    text = SEARCH.read_text()
    assert '_trigramIndex' in text
    assert '_buildTrigrams' in text
    assert 'trigramsFor' in text


def test_fuzzy_candidate_path_keeps_empty_query_and_limit_guards():
    text = SEARCH.read_text()
    assert 'if (q.isEmpty)' in text
    assert 'limit.clamp(1, 200)' in text
    assert '_fuzzyLimit(q)' in text


def test_trigram_index_covers_all_fuzzy_search_terms_not_only_german():
    text = SEARCH.read_text()
    assert 'for (final term in entry.searchTerms)' in text
