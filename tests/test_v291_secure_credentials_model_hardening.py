from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MODEL = ROOT / 'lib/models/secure_session_credentials.dart'


def test_secure_credentials_model_rejects_empty_and_oversized_values():
    text = MODEL.read_text(encoding='utf-8')
    assert 'maxValueBytes' in text
    assert 'value.isEmpty' in text
    assert 'valueBytes.length > maxValueBytes' in text
    assert 'ArgumentError' in text


def test_secure_credentials_model_does_not_expose_semantic_credential_fields():
    text = MODEL.read_text(encoding='utf-8').lower()
    for forbidden in ('password', 'token_type', 'refresh_token', 'expiry', 'provider'):
        assert forbidden not in text
