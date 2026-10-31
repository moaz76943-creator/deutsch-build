from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = (ROOT / 'lib/services/repository.dart').read_text()


def test_repository_has_single_cached_state_and_explicit_invalidation_contract():
    assert 'LearnerState? _cachedState;' in SRC
    assert 'LearnerState load() {' in SRC
    assert 'if (cached != null) return cached;' in SRC
    assert '_cachedState = null;' in SRC


def test_successful_persist_refreshes_cache_but_failed_write_does_not_claim_new_state():
    save_body = SRC[SRC.index('Future<void> _saveNow'):SRC.index('Future<void> record(')]
    assert '_cachedState = persisted;' in save_body
    assert 'await persistence.save(persisted);' in save_body
    assert save_body.index('await persistence.save(persisted);') < save_body.index('_cachedState = persisted;')


def test_clear_local_data_invalidates_cached_state_only_after_successful_remove():
    start = SRC.index('Future<bool> clearLocalData()')
    body = SRC[start:SRC.index('Future<void> recordAssessment', start)]
    assert 'await persistence.clearLocalData()' in body
    assert '_cachedState = null;' in body
    assert body.index('await persistence.clearLocalData()') < body.index('_cachedState = null;')
