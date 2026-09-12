from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]

def read(rel):
    return (ROOT / rel).read_text(encoding='utf-8')

def test_secure_storage_declares_platform_contract_semantics():
    text = read('lib/services/secure_session_storage.dart')
    assert 'SecureSessionStorageFailure' in text
    assert 'corrupted' in text.lower()
    assert 'platform-secure' in text.lower()
    assert 'replace' in text.lower()

def test_credentials_remain_opaque_and_immutable():
    text = read('lib/models/secure_session_credentials.dart')
    assert 'final String value;' in text
    assert 'toJson' not in text
    assert 'fromJson' not in text
    assert 'Map<String' not in text

def test_platform_contract_forbids_shared_preferences_and_concrete_package():
    text = read('lib/services/secure_session_storage.dart').lower()
    assert 'shared_preferences' not in text
    assert 'flutter_secure_storage' not in text
    assert 'android.keystore' not in text
