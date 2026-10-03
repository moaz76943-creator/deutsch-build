from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
PERSIST = (ROOT / 'lib/services/learner_persistence.dart').read_text()


def test_attempts_are_normalized_on_load_and_persistence_to_bound_user_text_and_metadata():
    assert '_normalizeAttempt' in PERSIST
    assert re.search(
        r'final normalized\s*=\s*_normalizeAttempt\(\s*Attempt\.fromJson\(',
        PERSIST,
        re.DOTALL,
    )
    assert re.search(
        r'if\s*\(normalized\.id\.isNotEmpty\s*&&\s*'
        r'normalized\.itemId\.isNotEmpty\)\s*'
        r'attempts\.add\(\s*normalized\s*\)',
        PERSIST,
        re.DOTALL,
    )
    assert '.map(_normalizeAttempt)' in PERSIST
    assert 'answer:' in PERSIST and '1000' in PERSIST
    assert 'itemId: a.itemId.toString().trim().length > 160' in PERSIST
    assert 'skill: a.skill.toString().trim().length > 160' in PERSIST


def test_attempt_normalization_bounds_timing_and_identifier_fields_without_changing_valid_values():
    assert 'id: a.id.toString().trim().length > 160' in PERSIST
    assert 'seconds: a.seconds.clamp(0, 3600)' in PERSIST
    assert 'final safeAt = a.at.isAfter(now.add(const Duration(days: 1))) ? now : a.at;' in PERSIST
