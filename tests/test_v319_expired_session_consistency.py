from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SERVICE = ROOT / "lib/services/authentication_service.dart"
GATEWAY = ROOT / "lib/services/authentication_backend_gateway.dart"
CONTROLLER = ROOT / "lib/services/auth_session_controller.dart"


def _block(text, start_marker, end_marker):
    start = text.index(start_marker)
    end = text.index(end_marker, start)
    return text[start:end]


def test_service_canonical_session_rejects_expired_authenticated_sessions():
    text = SERVICE.read_text(encoding="utf-8")
    block = _block(
        text,
        "  static AccountSession _canonicalSession",
        "\n  static SocialAuthenticationProvider",
    )
    assert "result.requiresReauthentication" in block
    assert "AccountSession.unauthenticated" in block


def test_gateway_rejects_expired_authenticated_backend_sessions():
    text = GATEWAY.read_text(encoding="utf-8")
    block = _block(
        text,
        "  static AccountSession _sessionFromResponse",
        "\n  static AuthenticationFailure _mapFailure",
    )
    assert "session.requiresReauthentication" in block
    assert "AuthenticationFailureCode.invalidSession" in block


def test_controller_set_session_is_fail_closed_for_expired_sessions():
    text = CONTROLLER.read_text(encoding="utf-8")
    block = _block(text, "  void _setSession(AccountSession session)", "\n  void _setFailure")
    assert "session.requiresReauthentication" in block
    assert "AccountSession.unauthenticated" in block
