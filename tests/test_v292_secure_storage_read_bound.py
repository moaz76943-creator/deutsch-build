from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
KOTLIN = ROOT / 'android/app/src/main/kotlin/com/deutschbilarabi/app/AndroidSecureSessionStorage.kt'


def test_read_checks_file_size_before_loading_bytes():
    text = KOTLIN.read_text(encoding='utf-8')
    assert 'MAX_STORED_PAYLOAD_BYTES' in text
    assert 'file.length() > MAX_STORED_PAYLOAD_BYTES' in text
    assert 'file.readBytes()' in text
    assert text.index('file.length() > MAX_STORED_PAYLOAD_BYTES') < text.index('file.readBytes()')


def test_read_bound_covers_nonce_tag_and_max_credential():
    text = KOTLIN.read_text(encoding='utf-8')
    assert 'MAX_CREDENTIAL_BYTES + NONCE_BYTES + (GCM_TAG_BITS / 8)' in text
