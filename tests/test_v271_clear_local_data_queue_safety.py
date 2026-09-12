from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = (ROOT / 'lib/services/repository.dart').read_text(encoding='utf-8')


def test_clear_local_data_is_queued_and_invalidates_cache_after_cleanup_attempt():
    start = REPO.index('  Future<bool> clearLocalData()')
    end = REPO.index('\n  Future<void> recordAssessment', start)
    body = REPO[start:end]

    assert '=> _enqueue<bool>(() async {' in body
    assert 'await persistence.clearLocalData()' in body
    assert 'await persistence.clearLocalData()' in body
    assert 'finally {' in body
    assert '_cachedState = null;' in body
    assert 'if (primaryRemoved) _cachedState = null;' not in body
