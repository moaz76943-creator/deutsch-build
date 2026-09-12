from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]

def read(rel): return (ROOT / rel).read_text(encoding='utf-8')

def test_search_indexes_are_lazy_individual_stages():
    src = read('lib/services/search_index.dart')
    assert 'late final Map<String, List<T>> _sourceExact =' in src
    assert 'late final Map<String, List<T>> _translationExact =' in src
    assert 'late final Map<String, List<T>> _tokenIndex =' in src
    assert 'late final Map<String, List<_Entry<T>>> _trigramIndex =' in src
    assert 'late final Map<String, List<_Entry<T>>> _trigramIndex =' in src
    assert '_buildTrigrams(_items.map(_Entry<T>.new).toList(growable: false))' in src

def test_exact_search_can_return_without_token_and_fuzzy_index_builds():
    src = read('lib/services/search_index.dart')
    assert 'if (exactResults.length >= cap) return exactResults.take(cap).toList(growable: false);' in src
    assert 'if (scored.length < cap) {' in src

def test_trigram_index_is_not_built_for_exact_or_token_hits_when_full():
    src = read('lib/services/search_index.dart')
    assert 'if (scored.length >= cap) {' in src
    assert 'return result.take(cap).toList(growable: false);' in src
