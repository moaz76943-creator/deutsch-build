from pathlib import Path
import re
ROOT = Path(__file__).resolve().parents[1]

def read(rel): return (ROOT / rel).read_text(encoding='utf-8')

def test_search_indexes_are_lazy_individual_stages():
    src = read('lib/services/search_index.dart')
    assert 'late final Map<String, List<T>> _sourceExact =' in src
    assert 'late final Map<String, List<T>> _translationExact =' in src
    assert 'late final Map<String, List<T>> _tokenIndex =' in src
    assert 'late final Map<String, List<_Entry<T>>> _trigramIndex =' in src
    assert 'late final Map<String, List<_Entry<T>>> _trigramIndex =' in src
    assert re.search(
        r'_buildTrigrams\(\s*_items\s*\.map\(\(item\) => _Entry<T>\(item, _textNormalizer\)\)\s*\.toList\(growable: false\),?\s*\)',
        src,
        re.DOTALL,
    )

def test_exact_search_can_return_without_token_and_fuzzy_index_builds():
    src = read('lib/services/search_index.dart')
    assert re.search(
        r'if\s*\(exactResults\.length >= cap\)\s*return exactResults\.take\(cap\)\.toList\(growable: false\);',
        src,
        re.DOTALL,
    )
    assert 'if (scored.length < cap) {' in src

def test_trigram_index_is_not_built_for_exact_or_token_hits_when_full():
    src = read('lib/services/search_index.dart')
    assert 'if (scored.length >= cap) {' in src
    assert 'return result.take(cap).toList(growable: false);' in src
