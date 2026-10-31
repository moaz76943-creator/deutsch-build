from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GATEWAY = ROOT / "lib/services/authentication_backend_gateway.dart"
SERVICE = ROOT / "lib/services/authentication_service.dart"


def test_gateway_current_session_participates_in_credential_operation_ordering():
    text = GATEWAY.read_text(encoding="utf-8")
    start = text.index("  Future<AccountSession> getCurrentSession() async {")
    end = text.index("\n  @override\n  Future<void> signOut()", start)
    current_session = text[start:end]
    assert "final operationGeneration = ++_credentialOperationGeneration;" in current_session
    assert "if (operationGeneration != _credentialOperationGeneration)" in current_session


def test_gateway_stale_current_session_cannot_clear_newer_credential():
    text = GATEWAY.read_text(encoding="utf-8")
    start = text.index("  Future<AccountSession> getCurrentSession() async {")
    end = text.index("\n  @override\n  Future<void> signOut()", start)
    current_session = text[start:end]
    assert "if (operationGeneration == _credentialOperationGeneration)" in current_session


def test_service_current_session_invalidates_stale_session_mutations():
    text = SERVICE.read_text(encoding="utf-8")
    start = text.index("  Future<AccountSession> get currentSession async {")
    end = text.index("\n  @override\n  Future<void> requestEmailOtp", start)
    current_session = text[start:end]
    assert "final operationGeneration = ++_storageOperationGeneration;" in current_session
    assert "if (operationGeneration != _storageOperationGeneration)" in current_session


def test_gateway_email_otp_does_not_store_a_stale_credential():
    text = GATEWAY.read_text(encoding="utf-8")
    start = text.index("  Future<AccountSession> verifyEmailOtp(")
    end = text.index("\n  @override\n  Future<AccountSession> authenticateProvider", start)
    verify = text[start:end]
    assert "final operationGeneration = ++_credentialOperationGeneration;" in verify
    assert verify.index("final operationGeneration") < verify.index("await _storeCredential")
    assert "if (operationGeneration != _credentialOperationGeneration)" in verify


def test_gateway_social_auth_does_not_store_a_stale_credential():
    text = GATEWAY.read_text(encoding="utf-8")
    start = text.index("  Future<AccountSession> authenticateProvider(")
    end = text.index("\n  @override\n  Future<AccountSession> renewSession", start)
    auth = text[start:end]
    assert "final operationGeneration = ++_credentialOperationGeneration;" in auth
    assert auth.index("final operationGeneration") < auth.index("await _storeCredential")
    assert "if (operationGeneration != _credentialOperationGeneration)" in auth


def test_service_renewal_storage_failure_does_not_clear_newer_session_state():
    text = SERVICE.read_text(encoding="utf-8")
    start = text.index("  Future<AccountSession> renewSession() async {")
    end = text.index("\n  @override\n  Future<void> signOut", start)
    renew = text[start:end]
    storage_failure = renew[renew.index("on SecureSessionStorageFailure"):renew.index("if (credentials == null)")]
    assert "if (operationGeneration == _storageOperationGeneration)" in storage_failure
