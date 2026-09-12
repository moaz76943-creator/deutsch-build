from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_http_transport_module_exists_with_required_contract_symbols():
    source = (ROOT / "lib/services/backend_http_transport.dart").read_text()
    assert "class HttpBackendTransport" in source
    assert "BackendTransport" in source
    assert "BackendTransportFailure" in source
    assert "32 * 1024" in source
    assert "64 * 1024" in source
    assert "15" in source


def test_backend_api_maps_renew_and_revoke_operations():
    source = (ROOT / "lib/services/backend_authentication_api.dart").read_text()
    assert "BackendAuthenticationOperation.renewSession" in source
    assert "BackendAuthenticationOperation.revokeSession" in source
    assert "BackendTransportRequest.renewSession" in source
    assert "BackendTransportRequest.revokeSession" in source


def test_https_is_required_and_credentials_are_not_logged():
    source = (ROOT / "lib/services/backend_http_transport.dart").read_text()
    assert "scheme != 'https'" in source
    assert "print(" not in source
    assert "debugPrint(" not in source
    assert "credential" in source


def test_response_and_timeout_bounds_are_explicit():
    source = (ROOT / "lib/services/backend_http_transport.dart").read_text()
    assert "MAX_RESPONSE_BYTES" in source
    assert "MAX_REQUEST_BYTES" in source
    assert "timeout" in source


def test_backend_api_has_complete_operation_switch():
    source = (ROOT / "lib/services/backend_authentication_api.dart").read_text()
    expected = [
        "BackendAuthenticationOperation.requestEmailOtp",
        "BackendAuthenticationOperation.verifyEmailOtp",
        "BackendAuthenticationOperation.authenticateProvider",
        "BackendAuthenticationOperation.currentSession",
        "BackendAuthenticationOperation.renewSession",
        "BackendAuthenticationOperation.revokeSession",
        "BackendAuthenticationOperation.signOut",
    ]
    for operation in expected:
        assert operation in source
