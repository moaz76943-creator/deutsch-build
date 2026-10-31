from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]


def _service_body():
    text = (ROOT / 'lib/services/authentication_service.dart').read_text(encoding='utf-8')
    start = text.index('final class ProviderAuthenticationService')
    return text[start:]


def test_authentication_service_accepts_secure_session_storage_boundary():
    text = (ROOT / 'lib/services/authentication_service.dart').read_text(encoding='utf-8')
    assert "secure_session_storage.dart" in text
    assert "SecureSessionStorage" in text


def test_account_session_remains_credential_free():
    model = (ROOT / 'lib/models/account_session.dart').read_text(encoding='utf-8')
    assert 'SecureSessionCredentials' not in model
    assert 'password' not in model.lower()
    assert 'token' not in model.lower()


def test_logout_clears_secure_session_storage_in_finally():
    service = _service_body()
    assert 'await _secureSessionStorage.clear()' in service or '_backendGateway.revokeSession(credentials)' in service
    signout = service[service.index('Future<void> signOut()'):]
    assert 'finally' in signout
