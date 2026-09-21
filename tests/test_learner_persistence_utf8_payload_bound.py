from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PERSISTENCE = ROOT / "lib/services/learner_persistence.dart"


def test_save_enforces_payload_limit_on_utf8_encoded_bytes():
    source = PERSISTENCE.read_text(encoding="utf-8")

    assert "final encodedPayloadBytes = utf8.encode(payload);" in source
    assert "encodedPayloadBytes.length > maxPayloadBytes" in source
    assert "payload.length > maxPayloadBytes" not in source


def test_utf8_payload_bound_preserves_typed_failure_contract():
    source = PERSISTENCE.read_text(encoding="utf-8")

    assert "LearnerPersistenceFailureCode.payloadTooLarge" in source
