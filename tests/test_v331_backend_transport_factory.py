from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_factory_exists_and_exposes_runtime_config_entrypoint():
    source = (ROOT / "lib/services/backend_transport_factory.dart").read_text()
    assert "class BackendTransportFactory" in source
    assert "fromRuntimeConfig" in source
    assert "BackendRuntimeConfig" in source
    assert "BackendTransport" in source


def test_factory_selects_http_transport_only_for_explicit_configuration():
    source = (ROOT / "lib/services/backend_transport_factory.dart").read_text()
    assert "config.isConfigured" in source
    assert "HttpBackendTransport(config.baseUri!)" in source
    assert "UnavailableBackendTransport()" in source


def test_offline_production_root_does_not_compose_backend_transport():
    source = (ROOT / "lib/main.dart").read_text()
    assert "BackendTransportFactory" not in source
    assert "HttpBackendTransport" not in source
    assert "BackendRuntimeConfig.fromEnvironment()" not in source


def test_factory_does_not_contain_network_url_literals_or_secrets():
    source = (ROOT / "lib/services/backend_transport_factory.dart").read_text()
    assert "https://" not in source
    assert "client_secret" not in source
    assert "api_key" not in source.lower()
    assert "password" not in source.lower()
