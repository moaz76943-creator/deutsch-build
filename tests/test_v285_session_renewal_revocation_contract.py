from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(rel):
    return (ROOT / rel).read_text(encoding="utf-8")


def test_transport_has_renew_and_revoke_operations():
    text = read("lib/models/backend_transport.dart")
    assert "renewSession" in text
    assert "revokeSession" in text


def test_transport_request_has_renew_and_revoke_constructors():
    text = read("lib/models/backend_transport.dart")
    assert "BackendTransportRequest.renewSession" in text
    assert "BackendTransportRequest.revokeSession" in text


def test_api_has_renew_and_revoke_operations():
    text = read("lib/models/backend_authentication_api.dart")
    assert "renewSession" in text
    assert "revokeSession" in text


def test_gateway_exposes_renew_and_revoke():
    text = read("lib/services/authentication_backend_gateway.dart")
    assert "renewSession" in text
    assert "revokeSession" in text


def test_renewal_requires_canonical_session_and_replacement_credential():
    text = read("lib/services/authentication_backend_gateway.dart")
    assert "_sessionFromResponse(response)" in text
    assert "_storeCredential(response.credentials, operationGeneration)" in text


def test_renewal_failure_clears_local_credential():
    text = read("lib/services/authentication_backend_gateway.dart")
    assert "_secureSessionStorage.clear()" in text or "_clearCredential(operationGeneration)" in text
    assert "AuthenticationFailureCode.invalidSession" in text


def test_no_shared_preferences_in_session_lifecycle_boundary():
    for rel in [
        "lib/models/backend_transport.dart",
        "lib/models/backend_authentication_api.dart",
        "lib/services/backend_authentication_api.dart",
        "lib/services/authentication.dart",
    ]:
        assert "shared_preferences" not in read(rel).lower()


def test_unavailable_gateway_has_single_renew_and_revoke_implementation():
    text = read("lib/services/authentication_backend_gateway.dart")
    unavailable = text.split("final class UnavailableBackendAuthenticationGateway", 1)[1].split("abstract interface class AuthenticationService", 1)[0]
    assert unavailable.count("Future<AccountSession> renewSession(") == 1
    assert unavailable.count("Future<void> revokeSession(") == 1


def test_renewal_clears_session_when_storage_has_no_replacement():
    text = read("lib/services/authentication_service.dart")
    renewal = text.split("Future<AccountSession> renewSession() async", 1)[1]
    assert "final replacement = await _secureSessionStorage.read();" in renewal
    assert "_session = const AccountSession.unauthenticated();" in renewal
    assert "AuthenticationFailureCode.invalidSession" in renewal


def test_renewal_rejects_non_authenticated_canonical_session():
    text = read("lib/services/authentication_service.dart")
    renewal = text.split("Future<AccountSession> renewSession() async", 1)[1]
    assert "canonical.isAuthenticated" in renewal
    assert "canonical.identity" in renewal
    assert "_session = const AccountSession.unauthenticated();" in renewal
