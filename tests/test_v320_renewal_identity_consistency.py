from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SERVICE = ROOT / "lib/services/authentication_service.dart"


def _block(text, start_marker, end_marker):
    start = text.index(start_marker)
    end = text.index(end_marker, start)
    return text[start:end]


def test_renewal_rejects_identity_change_from_current_authenticated_session():
    text = SERVICE.read_text(encoding="utf-8")
    renew = _block(
        text,
        "  Future<AccountSession> renewSession() async {",
        "\n  @override\n  Future<void> signOut",
    )
    assert "_session.isAuthenticated" in renew
    assert "_session.identity != null" in renew
    assert "canonical.identity!.userId" in renew
    assert "_session.identity!.userId" in renew
    assert "AuthenticationFailureCode.invalidSession" in renew


def test_identity_change_is_checked_before_replacing_current_session():
    text = SERVICE.read_text(encoding="utf-8")
    renew = _block(
        text,
        "  Future<AccountSession> renewSession() async {",
        "\n  @override\n  Future<void> signOut",
    )
    assert renew.index("_session.identity!.userId") < renew.index("_session = canonical;")
