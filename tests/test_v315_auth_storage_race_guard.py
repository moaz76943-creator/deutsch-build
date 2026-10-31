from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SERVICE = ROOT / "lib/services/authentication_service.dart"


def test_service_invalidates_stale_storage_mutations():
    text = SERVICE.read_text(encoding="utf-8")
    assert "int _storageOperationGeneration = 0;" in text
    assert "final operationGeneration = ++_storageOperationGeneration;" in text


def test_sign_out_does_not_clear_a_newer_session_credential():
    text = SERVICE.read_text(encoding="utf-8")
    start = text.index("  Future<void> signOut() async {")
    end = text.index("\n  Future<AccountSession> _authenticate", start)
    sign_out = text[start:end]
    assert "final operationGeneration = ++_storageOperationGeneration;" in sign_out
    assert "if (operationGeneration == _storageOperationGeneration)" in sign_out
    assert sign_out.index("++_storageOperationGeneration") < sign_out.index("await _backendGateway.revokeSession(credentials)")


def test_renewal_invalidates_stale_sign_out_storage_cleanup():
    text = SERVICE.read_text(encoding="utf-8")
    start = text.index("  Future<AccountSession> renewSession() async {")
    end = text.index("\n  @override\n  Future<void> signOut()", start)
    renew = text[start:end]
    assert "final operationGeneration = ++_storageOperationGeneration;" in renew
    assert "if (operationGeneration == _storageOperationGeneration)" in renew

GATEWAY = ROOT / "lib/services/authentication_backend_gateway.dart"


def test_backend_gateway_orders_credential_mutations():
    text = GATEWAY.read_text(encoding="utf-8")
    assert "int _credentialOperationGeneration = 0;" in text
    assert "final operationGeneration = ++_credentialOperationGeneration;" in text
    start = text.index("  Future<AccountSession> renewSession(")
    end = text.index("\n  @override\n  Future<void> revokeSession", start)
    renew = text[start:end]
    assert "if (operationGeneration == _credentialOperationGeneration)" in renew
    start = text.index("  Future<void> revokeSession(")
    end = text.index("\n  @override\n  Future<AccountSession> getCurrentSession", start)
    revoke = text[start:end]
    assert "final operationGeneration = ++_credentialOperationGeneration;" in revoke
    assert "if (operationGeneration == _credentialOperationGeneration)" in revoke
