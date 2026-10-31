from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = (ROOT / 'lib/services/repository.dart').read_text(encoding='utf-8')
PERSIST = (ROOT / 'lib/services/learner_persistence.dart').read_text(encoding='utf-8') if (ROOT / 'lib/services/learner_persistence.dart').exists() else ''


def test_learner_persistence_owns_json_and_preferences_boundary():
    assert 'class LearnerPersistence' in PERSIST
    assert 'jsonEncode' in PERSIST
    assert 'jsonDecode' in PERSIST
    assert 'prefs.getString' in PERSIST
    assert 'prefs.setString' in PERSIST
    assert 'prefs.remove' in PERSIST


def test_repository_does_not_directly_serialize_or_access_preferences():
    assert 'dart:convert' not in REPO
    assert 'jsonEncode' not in REPO
    assert 'jsonDecode' not in REPO
    assert 'prefs.getString' not in REPO
    assert 'prefs.getStringList' not in REPO
    assert 'prefs.setString' not in REPO
    assert 'prefs.remove' not in REPO
