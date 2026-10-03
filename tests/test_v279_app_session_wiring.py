from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
MAIN = ROOT / "lib/main.dart"
APP = ROOT / "lib/ui_v35/app.dart"


def test_main_constructs_auth_controller_without_learner_coupling():
    text = MAIN.read_text(encoding="utf-8")
    assert "AuthSessionController" in text
    assert "ProviderAuthenticationService" in text
    assert "LearnerRepository" in text
    assert "auth.initialize()" in text


def test_app_receives_session_controller_as_separate_dependency():
    text = APP.read_text(encoding="utf-8")
    assert "final AuthSessionController auth;" in text
    assert "required this.auth" in text
    assert re.search(
        r'HomeV35\(\s*repo:\s*widget\.repo\s*,\s*auth:\s*widget\.auth\s*,',
        text,
        re.DOTALL,
    )


def test_session_wiring_does_not_store_credentials_in_app_layer():
    text = MAIN.read_text(encoding="utf-8") + APP.read_text(encoding="utf-8")
    for forbidden in ("SharedPreferences", "password", "refreshToken", "accessToken"):
        assert forbidden not in text
