from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def test_repository_accepts_persistence_dependency():
    src = (ROOT / 'lib/services/repository.dart').read_text()
    assert 'required this.persistence' in src
    assert 'this.persistence' in src
    assert 'LearnerPersistence(prefs, key, legacyFavoriteKey)' not in src


def test_main_composes_repository_persistence_once():
    src = (ROOT / 'lib/main.dart').read_text()
    assert re.search(
        r'final persistence\s*=\s*LearnerPersistence\(\s*prefs\s*,',
        src,
        re.DOTALL,
    )
    assert 'LearnerRepository(prefs, persistence: persistence)' in src


def test_repository_boundary_does_not_construct_persistence():
    src = (ROOT / 'lib/services/repository.dart').read_text()
    assert 'LearnerPersistence(' not in src


def test_persistence_remains_the_only_json_state_boundary():
    repo = (ROOT / 'lib/services/repository.dart').read_text()
    persistence = (ROOT / 'lib/services/learner_persistence.dart').read_text()
    assert 'jsonEncode' not in repo
    assert 'jsonDecode' not in repo
    assert 'jsonEncode' in persistence
    assert 'jsonDecode' in persistence
