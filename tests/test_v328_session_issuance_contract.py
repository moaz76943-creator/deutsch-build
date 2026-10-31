from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(rel):
    return (ROOT / rel).read_text(encoding="utf-8")


def test_backend_authenticated_session_requires_expiry_contract():
    text = read("lib/models/backend_authentication_contract.dart")
    assert "expiresAt" in text
    assert "BackendAuthenticatedSession" in text
    assert "requiresReauthentication" in text


def test_transport_rejects_authenticated_session_without_expiry():
    text = read("lib/services/backend_http_transport.dart")
    assert "rawExpiresAt" in text
    assert "rawExpiresAt == null" in text
    assert "BackendTransportFailureCode.invalidSession" in text


def test_renewal_contract_requires_replacement_credential():
    text = read("lib/services/authentication_backend_gateway.dart")
    renewal = text.split("Future<AccountSession> renewSession(", 1)[1]
    assert "response.credentials == null" in renewal
    assert "_storeCredential(response.credentials, operationGeneration)" in renewal


def test_renewal_contract_documents_rotation():
    text = read("lib/models/backend_authentication_contract.dart")
    assert "rotation" in text.lower()
    assert "replacement" in text.lower()
