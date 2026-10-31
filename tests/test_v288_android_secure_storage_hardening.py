from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
KOTLIN = ROOT / 'android/app/src/main/kotlin/com/deutschbilarabi/app/AndroidSecureSessionStorage.kt'
DART = ROOT / 'lib/services/android_secure_session_storage.dart'


def test_keystore_key_is_non_exportable_and_randomized_encryption_is_explicit():
    text = KOTLIN.read_text(encoding='utf-8')
    assert 'KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT' in text
    assert '.setRandomizedEncryptionRequired(true)' in text
    assert '.setUserAuthenticationRequired' not in text


def test_credential_payload_never_uses_external_storage_or_logging():
    text = KOTLIN.read_text(encoding='utf-8')
    assert 'context.filesDir' in text
    assert 'Log.' not in text
    assert 'SharedPreferences' not in text
    assert 'getExternalFilesDir' not in text
    assert 'Environment.getExternalStorageDirectory' not in text


def test_platform_channel_exposes_only_expected_storage_operations():
    kotlin = KOTLIN.read_text(encoding='utf-8')
    dart = DART.read_text(encoding='utf-8')
    for method in ('save', 'read', 'clear'):
        assert f'"{method}"' in kotlin
        assert f"_{method}Method" in dart
    assert 'deleteKey' not in kotlin

def test_clear_fails_closed_if_temporary_credential_cannot_be_deleted():
    text = KOTLIN.read_text(encoding='utf-8')
    clear_start = text.index('private fun clear(')
    clear_end = text.index('private fun encrypt(', clear_start)
    clear = text[clear_start:clear_end]

    checked_delete = 'if (temporary.exists() && !temporary.delete())'
    assert checked_delete in clear
    assert 'result.error("unreadable", null, null)' in clear
    assert clear.index(checked_delete) < clear.index('result.success(null)')
