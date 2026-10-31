from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = (ROOT / 'lib/services/repository.dart').read_text(encoding='utf-8')


def test_clear_local_data_invalidates_cache_even_when_primary_key_was_already_absent():
    start = REPO.index('  Future<bool> clearLocalData()')
    end = REPO.index('\n  Future<void> recordAssessment', start)
    body = REPO[start:end]

    assert 'finally {' in body
    assert 'if (primaryRemoved) _cachedState = null;' not in body
    assert '_cachedState = null;' in body
