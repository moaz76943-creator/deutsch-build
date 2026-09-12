from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
AUTH = ROOT / 'lib/services/authentication_backend_gateway.dart'
CONTRACT = ROOT / 'lib/services/authentication_contract.dart'
SERVICE = ROOT / 'lib/services/authentication_service.dart'


def test_backend_authentication_gateway_declares_all_transport_lifecycle_methods():
    text = CONTRACT.read_text(encoding='utf-8')
    interface = text[text.index('abstract interface class BackendAuthenticationGateway'):]
    for method in ('renewSession', 'revokeSession'):
        assert method in interface


def test_sign_out_storage_read_is_inside_cleanup_protected_path():
    text = SERVICE.read_text(encoding='utf-8')
    start = text.index('Future<void> signOut() async {')
    end = text.index('\n  Future<AccountSession> _authenticate', start)
    method = text[start:end]
    assert 'try {' in method
    assert method.index('try {') < method.index('_secureSessionStorage.read()')
    assert 'finally {' in method
    assert '_backendGateway.revokeSession(credentials)' in method


def test_current_session_clears_local_credential_when_backend_rejects_it():
    text = AUTH.read_text(encoding='utf-8')
    start = text.index('Future<AccountSession> getCurrentSession() async {')
    end = text.index('\n  @override\n  Future<void> signOut()', start)
    method = text[start:end]
    assert 'if (!session.isAuthenticated || session.identity == null)' in method
    assert 'await _secureSessionStorage.clear();' in method or 'await _clearCredential(operationGeneration);' in method
