from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def read(rel):
    return (ROOT / rel).read_text(encoding="utf-8")


def test_credential_model_exposes_only_opaque_value():
    text = read("lib/models/secure_session_credentials.dart")
    assert "final class SecureSessionCredentials" in text
    assert "final String value" in text
    assert "tokenType" not in text
    assert "expiresAt" not in text
    assert "refresh" not in text.lower()


def test_backend_api_has_credential_contract():
    text = read("lib/models/backend_authentication_api.dart")
    assert "SecureSessionCredentials" in text
    assert "final SecureSessionCredentials? credentials" in text


def test_authentication_keeps_credentials_out_of_account_session():
    text = read("lib/services/authentication_backend_gateway.dart")
    assert "SecureSessionCredentials" in text
    assert "AccountSession" in text
    assert "credential" in text.lower()
    account = read("lib/models/account_session.dart")
    assert "SecureSessionCredentials" not in account


def test_no_shared_preferences_in_auth_credential_boundary():
    for rel in [
        "lib/models/secure_session_credentials.dart",
        "lib/services/secure_session_storage.dart",
        "lib/models/backend_authentication_api.dart",
        "lib/services/backend_authentication_api.dart",
    ]:
        assert "shared_preferences" not in read(rel).lower()


def test_current_session_request_can_carry_opaque_credential():
    text = read("lib/models/backend_authentication_api.dart")
    marker = r'currentSession\(\{\s*SecureSessionCredentials\? credentials\s*,?\s*\}\)'
    assert re.search(marker, text, re.DOTALL)
    transport = read("lib/models/backend_transport.dart")
    assert re.search(marker, transport, re.DOTALL)


def test_successful_auth_requires_and_stores_credential():
    text = read("lib/services/authentication_backend_gateway.dart")
    assert "await _storeCredential(response.credentials, operationGeneration);" in text
    assert "AuthenticationFailureCode.invalidSession" in text


def test_restoration_reads_storage_and_sends_credential_to_backend():
    text = read("lib/services/authentication_backend_gateway.dart")
    assert "final credential = await _secureSessionStorage.read();" in text
    assert "BackendTransportRequest.currentSession(credentials: credential)" in text


def test_credential_is_stored_only_after_valid_authenticated_session():
    text = read("lib/services/authentication_backend_gateway.dart")
    for marker in (
        "BackendTransportRequest.verifyEmailOtp(",
        "BackendTransportRequest.authenticateProvider(",
    ):
        start = text.index(marker)
        end = text.index("\n  }", start)
        block = text[start:end]
        assert "final session = _sessionFromResponse(response);" in block
        assert block.index("final session = _sessionFromResponse(response);") < block.index(
            "await _storeCredential(response.credentials, operationGeneration);"
        )
