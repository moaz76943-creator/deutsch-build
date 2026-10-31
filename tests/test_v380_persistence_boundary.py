from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_learner_persistence_review_card_guard_uses_key_not_undefined_id():
    source = (ROOT / 'lib/services/learner_persistence.dart').read_text(encoding='utf-8')
    assert 'if (key.isEmpty || id.length > 160 || entry.value is! Map)' not in source
    assert 'key.length > maxReviewStorageKeyLength' in source


def test_learner_persistence_is_the_only_learner_state_json_boundary():
    repository = (ROOT / 'lib/services/repository.dart').read_text(encoding='utf-8')
    persistence = (ROOT / 'lib/services/learner_persistence.dart').read_text(encoding='utf-8')
    assert 'jsonEncode(' not in repository
    assert 'jsonDecode(' not in repository
    assert 'jsonEncode(' in persistence
    assert 'jsonDecode(' in persistence
