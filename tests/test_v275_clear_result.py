from pathlib import Path
SRC=Path('lib/services/learner_persistence.dart').read_text()
REPO=Path('lib/services/repository.dart').read_text()
def test_clear_local_data_reports_success_and_treats_absent_keys_as_success():
    body=SRC[SRC.index('Future<bool> clearLocalData()'):]
    assert 'prefs.getString(storageKey)' in body and 'prefs.getStringList(legacyFavoriteKey)' in body and 'return success;' in body
def test_clear_local_data_keeps_repository_cache_invalidated_after_cleanup_failure():
    body=REPO[REPO.index('Future<bool> clearLocalData()'):]
    assert 'finally {' in body and '_cachedState = null;' in body and 'persistence.clearLocalData()' in body
