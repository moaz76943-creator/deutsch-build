from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTROLLER = ROOT / "lib/services/auth_session_controller.dart"
AUTH = ROOT / "lib/services/authentication_service.dart"
MODEL = ROOT / "lib/models/account_session.dart"


def test_initialize_clears_stale_failure_after_valid_session_restoration():
    text = CONTROLLER.read_text(encoding="utf-8")
    initialize = text[text.index("Future<void> initialize()") : text.index("Future<void> signInWithEmailOtp")]
    assert "_lastFailure = null;" in initialize


def test_initialize_is_fail_closed_when_restored_session_is_expired():
    text = AUTH.read_text(encoding="utf-8")
    assert "requiresReauthentication" in text
    assert "_session = const AccountSession.unauthenticated();" in text


def test_logout_always_ends_unauthenticated_even_when_provider_logout_fails():
    text = CONTROLLER.read_text(encoding="utf-8")
    signout = text[text.index("Future<void> signOut()") : text.index("Future<void> _runAuthentication")]
    assert "_setSession(const AccountSession.unauthenticated());" in signout
    assert signout.count("_setSession(const AccountSession.unauthenticated());") >= 2


def test_restart_like_initial_state_has_no_authenticated_session():
    text = CONTROLLER.read_text(encoding="utf-8")
    assert "AccountSession _session = const AccountSession.unauthenticated();" in text
    assert "bool _isInitialized = false;" in text


def test_session_boundary_contains_no_credentials_or_learner_state():
    text = "\n".join(
        path.read_text(encoding="utf-8") for path in (CONTROLLER, AUTH, MODEL)
    )
    for forbidden in (
        "SharedPreferences",
        "password",
        "refreshToken",
        "accessToken",
        "cardNumber",
        "LearnerRepository",
        "LearnerState",
    ):
        assert forbidden not in text
