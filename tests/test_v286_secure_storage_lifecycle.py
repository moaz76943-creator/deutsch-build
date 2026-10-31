from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]

def test_authentication_handles_storage_failures_closed():
    text = (ROOT / 'lib/services/authentication_service.dart').read_text(encoding='utf-8')
    assert 'SecureSessionStorageFailure' in text
    assert 'AuthenticationFailureCode.invalidSession' in text
    assert 'on SecureSessionStorageFailure catch' in text

def test_clear_remains_finally_protected():
    text = (ROOT / 'lib/services/authentication_service.dart').read_text(encoding='utf-8')
    assert 'finally {' in text
    assert '_backendGateway.revokeSession(credentials)' in text
