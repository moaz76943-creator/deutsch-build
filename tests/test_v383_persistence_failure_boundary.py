from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PERSISTENCE = ROOT / 'lib/services/learner_persistence.dart'


def test_persistence_exposes_typed_failure_contract():
    src = PERSISTENCE.read_text()
    assert 'LearnerPersistenceFailureCode' in src
    assert 'final class LearnerPersistenceFailure implements Exception' in src
    assert 'payloadTooLarge' in src
    assert 'writeFailed' in src


def test_persistence_save_does_not_leak_generic_state_errors():
    src = PERSISTENCE.read_text()
    assert "throw StateError('Learner state exceeds the safe storage limit.')" not in src
    assert "throw StateError('Failed to persist learner state.')" not in src
    assert 'LearnerPersistenceFailure(' in src


def test_failure_contract_has_stable_codes_and_safe_string_representation():
    src = PERSISTENCE.read_text()
    assert 'enum LearnerPersistenceFailureCode {' in src
    assert 'payloadTooLarge,' in src
    assert 'writeFailed,' in src
