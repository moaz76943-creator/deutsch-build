from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
S=(ROOT/'lib/services/search_index.dart').read_text(encoding='utf-8')

def test_token_fallback_does_not_scan_entire_corpus_into_entry_cache():
    assert 'final pool = candidates.isEmpty ? _items : candidates;' not in S
    assert 'for (final item in candidates)' in S
    assert '_entryCache[item.id] ??= _Entry<T>(item, _textNormalizer)' in S

def test_short_fuzzy_fallback_does_not_materialize_every_entry():
    assert 'return _items.map(_Entry.new).where((entry)' not in S
    assert 'for (final item in _items)' in S
    assert 'if (candidates.length >= _fuzzyCandidateCap(q)) break;' in S

def test_fuzzy_candidate_work_is_bounded_before_distance_calculation():
    assert 'const maxCandidates = 160;' in S
    assert '_fuzzyCandidateCap(q)' in S
    assert 'if (candidates.length >= maxCandidates) break;' in S
