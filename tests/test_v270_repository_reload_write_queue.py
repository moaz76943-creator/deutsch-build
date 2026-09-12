from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = (ROOT / 'lib/services/repository.dart').read_text(encoding='utf-8')


def test_persisted_reload_waits_for_pending_writes_before_reading_storage():
    assert 'Future<LearnerState> reloadPersisted()' in REPO
    start = REPO.index('  Future<LearnerState> reloadPersisted()')
    end = REPO.index('\n  LearnerState _loadFromPrefs()', start)
    body = REPO[start:end]
    assert 'await _writeQueue' in body
    assert '_cachedState = null;' in body
    assert 'return load();' in body


def test_sync_reload_remains_available_for_non_queued_external_reads():
    assert 'LearnerState reload()' in REPO
