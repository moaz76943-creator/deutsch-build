from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_read_path_must_not_create_a_new_keystore_key():
    text = (ROOT / 'android/app/src/main/kotlin/com/deutschbilarabi/app/AndroidSecureSessionStorage.kt').read_text()
    decrypt_block = text.split('private fun decrypt(', 1)[1].split('private fun getExistingKey', 1)[0]
    assert 'getExistingKey()' in decrypt_block
    assert 'getOrCreateKey()' not in decrypt_block


def test_decrypt_uses_existing_key_only():
    text = (ROOT / 'android/app/src/main/kotlin/com/deutschbilarabi/app/AndroidSecureSessionStorage.kt').read_text()
    decrypt_block = text.split('private fun decrypt(', 1)[1].split('private fun getOrCreateKey', 1)[0]
    assert 'getExistingKey()' in decrypt_block
    assert 'getOrCreateKey()' not in decrypt_block


def test_existing_key_lookup_returns_null_when_missing():
    text = (ROOT / 'android/app/src/main/kotlin/com/deutschbilarabi/app/AndroidSecureSessionStorage.kt').read_text()
    assert 'private fun getExistingKey(): SecretKey?' in text
    assert 'keyStore.getKey(KEY_ALIAS, null) as? SecretKey' in text
