from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTROLLER = ROOT / "lib/services/auth_session_controller.dart"


def test_initialize_clears_stale_failure_after_successful_session_lookup():
    text = CONTROLLER.read_text(encoding="utf-8")
    start = text.index("  Future<void> initialize() async {")
    end = text.index("\n  Future<void> requestEmailOtp", start)
    initialize = text[start:end]
    assert "_lastFailure = null;" in initialize
    assert initialize.index("_setSession(session);") < initialize.index("_lastFailure = null;")
    assert "if (_session.isAuthenticated)" not in initialize
