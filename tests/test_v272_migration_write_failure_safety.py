from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = (ROOT / 'lib/services/learner_persistence.dart').read_text(encoding='utf-8')


def test_save_paths_fail_closed_when_preferences_write_returns_false():
    assert 'if (!await prefs.setString(storageKey, payload))' in REPO


def test_legacy_migration_removes_legacy_only_after_successful_canonical_write():
    block_start = REPO.index('Future<LearnerState> loadAndMigrateFavoriteVerbs')
    block_end = REPO.index('Future<bool> clearLocalData()', block_start)
    block = REPO[block_start:block_end]
    assert 'await save(persisted);' in block
    assert 'await prefs.remove(legacyFavoriteKey);' in block
    assert block.index('await save(persisted);') < block.index('await prefs.remove(legacyFavoriteKey);')
