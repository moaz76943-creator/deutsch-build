from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_main_wires_runtime_backend_configuration():
    source = (ROOT / "lib/main.dart").read_text()
    assert "BackendRuntimeConfig.fromEnvironment()" in source
    factory = (ROOT / "lib/services/backend_transport_factory.dart").read_text()
    assert "HttpBackendTransport(config.baseUri!)" in factory


def test_main_preserves_fail_closed_unavailable_default():
    source = (ROOT / "lib/main.dart").read_text()
    factory = (ROOT / "lib/services/backend_transport_factory.dart").read_text()
    assert "UnavailableBackendTransport()" in factory
    assert "config.isConfigured" in factory


def test_backend_runtime_configuration_does_not_enable_backend_without_explicit_url():
    source = (ROOT / "lib/main.dart").read_text()
    assert "String.fromEnvironment('DEUTSCH_AUTH_BASE_URL'" not in source
    assert "https://" not in source
