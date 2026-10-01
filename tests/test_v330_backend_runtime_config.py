from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def test_runtime_config_contract_exists_and_reads_only_dart_defines():
    source = (ROOT / "lib/models/backend_runtime_config.dart").read_text()
    assert "class BackendRuntimeConfig" in source
    assert re.search(
        r'String\.fromEnvironment\(\s*baseUrlDefine\s*,',
        source,
        re.DOTALL,
    ) or "String.fromEnvironment('DEUTSCH_AUTH_BASE_URL'" in source
    assert re.search(
        r'String\.fromEnvironment\(\s*allowedHostsDefine\s*,',
        source,
        re.DOTALL,
    ) or "String.fromEnvironment('DEUTSCH_AUTH_ALLOWED_HOSTS'" in source
    assert "https" in source


def test_runtime_config_rejects_unsafe_uri_components_and_http():
    source = (ROOT / "lib/models/backend_runtime_config.dart").read_text()
    assert "toLowerCase() != 'https'" in source
    assert "userInfo" in source
    assert "query" in source
    assert "fragment" in source


def test_runtime_config_requires_explicit_allowed_host_when_allowlist_is_present():
    source = (ROOT / "lib/models/backend_runtime_config.dart").read_text()
    assert "allowedHosts" in source
    assert "contains" in source
    assert "isConfigured" in source


def test_invalid_allowed_host_configuration_fails_closed_instead_of_becoming_empty_allowlist():
    source = (ROOT / "lib/models/backend_runtime_config.dart").read_text()
    assert "allowedHostsValid" in source
    assert "!allowedHostsValid" in source


def test_runtime_config_contains_no_secret_or_token_material():
    source = (ROOT / "lib/models/backend_runtime_config.dart").read_text().lower()
    assert "password" not in source
    assert "api_key" not in source
    assert "client_secret" not in source
    assert "access_token" not in source
