from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(rel):
    return (ROOT / rel).read_text(encoding="utf-8")


def test_transport_validates_response_by_operation():
    text = read("lib/services/backend_http_transport.dart")
    assert "_validateResponseForOperation" in text
    assert "BackendTransportOperation.verifyEmailOtp" in text
    assert "BackendTransportOperation.authenticateProvider" in text
    assert "BackendTransportOperation.renewSession" in text


def test_authenticated_operations_require_session_and_credential():
    text = read("lib/services/backend_http_transport.dart")
    block = text.split("static void _validateResponseForOperation(", 1)[1]
    assert "response.session == null" in block
    assert "response.credentials == null" in block
    assert "BackendTransportFailureCode.invalidSession" in block


def test_current_session_requires_a_session_but_not_response_credential():
    text = read("lib/services/backend_http_transport.dart")
    block = text.split("static void _validateResponseForOperation(", 1)[1]
    current = block.split("BackendTransportOperation.currentSession", 1)[1]
    assert "response.session == null" in current


def test_request_and_terminal_operations_allow_empty_response():
    text = read("lib/services/backend_http_transport.dart")
    block = text.split("static void _validateResponseForOperation(", 1)[1]
    assert "requestEmailOtp" in block
    assert "revokeSession" in block
    assert "signOut" in block
