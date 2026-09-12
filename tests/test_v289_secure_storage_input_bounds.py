from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
KOTLIN = ROOT / 'android/app/src/main/kotlin/com/deutschbilarabi/app/AndroidSecureSessionStorage.kt'


def read():
    return KOTLIN.read_text(encoding='utf-8')


def test_secure_credential_input_has_explicit_size_bound():
    text = read()
    assert 'MAX_CREDENTIAL_BYTES' in text
    assert 'toByteArray(Charsets.UTF_8)' in text
    assert 'valueBytes.size > MAX_CREDENTIAL_BYTES' in text


def test_oversized_credentials_are_rejected_before_encryption():
    text = read()
    assert 'if (valueBytes.size > MAX_CREDENTIAL_BYTES)' in text
    assert 'result.error("unreadable", null, null)' in text
