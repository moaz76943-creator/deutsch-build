from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GATEWAY = ROOT / "lib/services/authentication_backend_gateway.dart"
SERVICE = ROOT / "lib/services/authentication_service.dart"


def _block(text, start_marker, end_marker):
    start = text.index(start_marker)
    end = text.index(end_marker, start)
    return text[start:end]


def test_gateway_serializes_generation_checked_credential_mutations():
    text = GATEWAY.read_text(encoding="utf-8")
    assert "Future<bool> _withCredentialMutationLock(" in text
    assert "Future<void> _storeCredential(" in text
    assert "_withCredentialMutationLock(" in text
    assert "if (operationGeneration != _credentialOperationGeneration) return false;" in text


def test_gateway_renew_invalid_session_clears_only_current_credential_generation():
    text = GATEWAY.read_text(encoding="utf-8")
    renew = _block(
        text,
        "  Future<AccountSession> renewSession(",
        "\n  @override\n  Future<void> revokeSession",
    )
    assert "on AuthenticationFailure catch (error)" in renew
    assert "error.code == AuthenticationFailureCode.invalidSession" in renew
    assert "if (operationGeneration == _credentialOperationGeneration)" in renew


def test_service_is_not_a_second_owner_of_credential_clearing():
    text = SERVICE.read_text(encoding="utf-8")
    renew = _block(
        text,
        "  Future<AccountSession> renewSession() async {",
        "\n  @override\n  Future<void> signOut",
    )
    sign_out = _block(
        text,
        "  Future<void> signOut() async {",
        "\n  Future<AccountSession> _authenticate",
    )
    assert "_secureSessionStorage.clear()" not in renew
    assert "_secureSessionStorage.clear()" not in sign_out


def test_stale_credential_store_cannot_report_authentication_success():
    text = GATEWAY.read_text(encoding="utf-8")
    store = _block(text, "  Future<void> _storeCredential(", "\n  Future<void> _clearCredential")
    assert "final applied = await _withCredentialMutationLock" in store
    assert "if (!applied)" in store
    assert "AuthenticationFailureCode.invalidSession" in store
