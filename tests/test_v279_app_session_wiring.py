from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAIN = ROOT / "lib/main.dart"
ACCOUNT = ROOT / "lib/ui_v35/account_auth_page.dart"


def test_offline_production_root_does_not_compose_account_transport():
    text = MAIN.read_text(encoding="utf-8")
    assert "AuthSessionController" not in text
    assert "ProviderAuthenticationService" not in text
    assert "BackendTransportFactory" not in text
    assert "LearnerRepository" in text


def test_account_surface_keeps_auth_as_an_explicit_boundary():
    text = ACCOUNT.read_text(encoding="utf-8")
    assert "final AuthSessionController auth;" in text
    assert "required this.auth" in text
    assert "SharedPreferences" not in text
    assert "package:http/" not in text
    assert "dart:io" not in text


def test_production_root_does_not_store_credentials():
    text = MAIN.read_text(encoding="utf-8")
    for forbidden in ("password", "refreshToken", "accessToken"):
        assert forbidden not in text
