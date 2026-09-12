from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SERVICE = ROOT / "lib/services/authentication_service.dart"
GATEWAY = ROOT / "lib/services/authentication_backend_gateway.dart"


def test_service_canonical_session_rejects_empty_or_whitespace_identity():
    text = SERVICE.read_text(encoding="utf-8")
    start = text.index("  static AccountSession _canonicalSession")
    end = text.index("\n  static SocialAuthenticationProvider", start)
    block = text[start:end]
    assert "result.identity!.userId.trim().isEmpty" in block
    assert "AccountSession.unauthenticated" in block


def test_gateway_rejects_authenticated_response_with_invalid_identity():
    text = GATEWAY.read_text(encoding="utf-8")
    start = text.index("  static AccountSession _sessionFromResponse")
    end = text.index("\n  static AuthenticationFailure _mapFailure", start)
    block = text[start:end]
    assert "session.identity == null" in block
    assert "session.identity!.userId.trim().isEmpty" in block
    assert "AuthenticationFailureCode.invalidSession" in block
