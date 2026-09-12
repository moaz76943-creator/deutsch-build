from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
KOTLIN = ROOT / 'android/app/src/main/kotlin/com/deutschbilarabi/app/AndroidSecureSessionStorage.kt'


def test_storage_format_has_explicit_version_header():
    text = KOTLIN.read_text(encoding='utf-8')
    assert 'FORMAT_VERSION' in text
    assert 'VERSION_BYTES' in text
    assert 'val version = payload[0]' in text


def test_read_rejects_unknown_storage_version_before_decryption():
    text = KOTLIN.read_text(encoding='utf-8')
    assert 'if (version != FORMAT_VERSION)' in text
    assert text.index('if (version != FORMAT_VERSION)') < text.index('decrypt(')


def test_write_includes_format_version_before_nonce():
    text = KOTLIN.read_text(encoding='utf-8')
    assert '.put(FORMAT_VERSION)' in text
    assert text.index('.put(FORMAT_VERSION)') < text.index('.put(cipher.iv)')
