from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_offline_production_root_has_no_backend_runtime_configuration():
    source = (ROOT / "lib/main.dart").read_text()
    assert "BackendRuntimeConfig.fromEnvironment()" not in source
    assert "BackendTransportFactory" not in source
    assert "HttpBackendTransport" not in source


def test_backend_factory_preserves_fail_closed_unavailable_default():
    factory = (ROOT / "lib/services/backend_transport_factory.dart").read_text()
    assert "UnavailableBackendTransport()" in factory
    assert "config.isConfigured" in factory


def test_production_root_contains_no_backend_url_or_auth_environment_key():
    source = (ROOT / "lib/main.dart").read_text()
    assert "DEUTSCH_AUTH_BASE_URL" not in source
    assert "http://" not in source
    assert "https://" not in source
