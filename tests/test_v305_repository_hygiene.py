from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OBSOLETE = [
    'V219_LOCAL_STATE_LOAD_HARDENING.py',
    'V236_CI_CACHE_ISOLATION.py',
    'V237_CONTENT_DATA_ARCHITECTURE.py',
    'V239_CONTENT_ENGINE_ADAPTER.py',
    'V240_JSON_RUNTIME_SOURCE.py',
    'V241_JSON_CONTENT_BUILD_SWITCH.py',
    'V242_SEARCH_INDEX_CONTENT_ENGINE.py',
    'V243_MASTERY_DASHBOARD_CONTENT_ENGINE.py',
    'V245_LEARNING_PAGES_CONTENT_ENGINE.py',
]

def test_obsolete_root_migration_scripts_are_not_runtime_inputs():
    assert all(not (ROOT / name).exists() for name in OBSOLETE)
