from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTROLLER = ROOT / "lib/services/auth_session_controller.dart"


def test_auth_controller_invalidates_stale_async_operations_before_they_apply():
    text = CONTROLLER.read_text(encoding="utf-8")
    assert "int _operationGeneration = 0;" in text
    assert "final operationGeneration = ++_operationGeneration;" in text
    assert "if (operationGeneration != _operationGeneration)" in text
    assert "if (operationGeneration == _operationGeneration)" in text


def test_sign_out_invalidates_pending_authentication_before_awaiting_backend():
    text = CONTROLLER.read_text(encoding="utf-8")
    start = text.index("  Future<void> signOut() async {")
    end = text.index("\n  Future<void> _runAuthentication", start)
    sign_out = text[start:end]
    assert "final operationGeneration = ++_operationGeneration;" in sign_out
    assert sign_out.index("++_operationGeneration") < sign_out.index("await _authenticationService.signOut()")
