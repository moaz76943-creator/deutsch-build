from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = (ROOT / 'lib/services/repository.dart').read_text(encoding='utf-8')


def test_repository_exposes_explicit_reload_boundary_for_external_persistence_changes():
    assert 'LearnerState reload()' in REPO
    assert '_cachedState = null;' in REPO
    assert 'return load();' in REPO


def test_reload_is_the_only_supported_way_to_bypass_a_cached_snapshot():
    load = REPO[REPO.index('  LearnerState load()'):REPO.index('  LearnerState _loadFromPrefs()')]
    assert 'final cached = _cachedState;' in load
    assert 'if (cached != null) return cached;' in load
