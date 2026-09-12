from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]

def test_secure_session_storage_contract_exists():
    p = ROOT / 'lib/services/secure_session_storage.dart'
    assert p.exists()
    text = p.read_text(encoding='utf-8')
    assert 'abstract interface class SecureSessionStorage' in text
    assert 'Future<void> save' in text
    assert 'Future<SecureSessionCredentials?> read' in text
    assert 'Future<void> clear' in text

def test_credential_model_is_opaque_and_minimal():
    p = ROOT / 'lib/models/secure_session_credentials.dart'
    assert p.exists()
    text = p.read_text(encoding='utf-8')
    assert 'final class SecureSessionCredentials' in text
    assert 'String value' in text
    assert 'sharedpreferences' not in text.lower()
    assert 'learner' not in text.lower()
    assert 'premium' not in text.lower()

def test_no_shared_preferences_import_in_secure_storage():
    for rel in ['lib/services/secure_session_storage.dart','lib/models/secure_session_credentials.dart']:
        text = (ROOT / rel).read_text(encoding='utf-8')
        assert 'shared_preferences' not in text.lower()
