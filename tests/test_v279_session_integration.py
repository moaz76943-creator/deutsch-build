from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTROLLER = ROOT / "lib/services/auth_session_controller.dart"
AUTH = ROOT / "lib/services/authentication_contract.dart"


def test_session_controller_has_no_learner_repository_dependency():
    text = CONTROLLER.read_text(encoding="utf-8")
    assert "LearnerRepository" not in text
    assert "LearnerState" not in text


def test_session_controller_does_not_persist_credentials():
    text = CONTROLLER.read_text(encoding="utf-8")
    for forbidden in (
        "SharedPreferences",
        "password",
        "refreshToken",
        "accessToken",
        "cardNumber",
    ):
        assert forbidden not in text


def test_session_controller_exposes_only_session_state_and_transient_failure():
    text = CONTROLLER.read_text(encoding="utf-8")
    assert "AccountSession get session" in text
    assert "bool get isInitialized" in text
    assert "AuthenticationFailure? get lastFailure" in text
    assert "AccountSession.unauthenticated()" in text


def test_session_controller_fails_closed_on_authentication_errors():
    text = CONTROLLER.read_text(encoding="utf-8")
    assert "AuthenticationFailureCode.unavailable" in text
    assert "_setSession(const AccountSession.unauthenticated())" in text


def test_authentication_boundary_stays_provider_neutral():
    text = AUTH.read_text(encoding="utf-8")
    assert "AuthenticationService" in text
    assert "LearnerRepository" not in text
    assert "LearnerState" not in text
