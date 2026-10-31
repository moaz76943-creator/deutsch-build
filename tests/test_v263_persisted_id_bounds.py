from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PERSIST = (ROOT / 'lib/services/learner_persistence.dart').read_text(encoding='utf-8')


def test_persistence_reuses_bounded_string_contract_for_all_id_sets():
    assert 'final normalizedLearned = _boundedStringSet(s.learned);' in PERSIST
    assert 'final normalizedReview = _boundedStringSet(s.review);' in PERSIST
    assert 'final normalizedFavorites = _boundedStringSet(s.favoriteVerbs);' in PERSIST


def test_bounded_string_set_rejects_empty_and_oversized_values():
    assert 'static Set<String> _boundedStringSet(Iterable<String> values) =>' in PERSIST
    block = PERSIST[PERSIST.index('static Set<String> _boundedStringSet'):PERSIST.index('static Set<String> _boundedStrings')]
    assert '.where((x) => x.isNotEmpty && x.length <= 160)' in block
    assert '.take(maxCollectionItems)' in block
